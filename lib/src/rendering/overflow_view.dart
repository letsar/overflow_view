import 'package:flutter/rendering.dart';
import 'package:value_layout_builder/value_layout_builder.dart';

/// Parent data for use with [RenderOverflowView].
class OverflowViewParentData extends ContainerBoxParentData<RenderBox> {}

class RenderOverflowView extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, OverflowViewParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, OverflowViewParentData> {
  RenderOverflowView({
    List<RenderBox> children,
    Axis direction,
    double spacing,
  })  : assert(direction != null),
        assert(spacing != null && spacing >= 0 && spacing < double.infinity),
        _direction = direction,
        _spacing = spacing,
        _isHorizontal = direction == Axis.horizontal {
    addAll(children);
  }

  Axis get direction => _direction;
  Axis _direction;
  set direction(Axis value) {
    assert(value != null);
    if (_direction != value) {
      _direction = value;
      _isHorizontal = direction == Axis.horizontal;
      markNeedsLayout();
    }
  }

  double get spacing => _spacing;
  double _spacing;
  set spacing(double value) {
    assert(value != null && value >= 0 && value < double.infinity);
    if (_spacing != value) {
      _spacing = value;
      markNeedsLayout();
    }
  }

  bool _isHorizontal;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! OverflowViewParentData)
      child.parentData = OverflowViewParentData();
  }

  List<RenderBox> _renderedBoxes = <RenderBox>[];

  @override
  void performLayout() {
    _renderedBoxes.clear();

    RenderBox child = firstChild;
    assert(child != null);
    final BoxConstraints childConstraints = constraints.loosen();
    final double maxExtent =
        _isHorizontal ? constraints.maxWidth : constraints.maxHeight;

    OverflowViewParentData childParentData =
        child.parentData as OverflowViewParentData;
    child.layout(childConstraints, parentUsesSize: true);
    final double childExtent = child.size.getMainExtent(direction);
    final double crossExtent = child.size.getCrossExtent(direction);
    final BoxConstraints otherChildConstraints = _isHorizontal
        ? childConstraints.tighten(width: childExtent, height: crossExtent)
        : childConstraints.tighten(height: childExtent, width: crossExtent);

    final double childStride = childExtent + spacing;
    Offset getChildOffset(int index) {
      final double mainAxisOffset = index * childStride;
      final double crossAxisOffset = 0;
      if (_isHorizontal) {
        return Offset(mainAxisOffset, crossAxisOffset);
      } else {
        return Offset(crossAxisOffset, mainAxisOffset);
      }
    }

    final int count = childCount - 1;
    final double requestedExtent =
        childExtent * (childCount - 1) + spacing * (childCount - 2);
    final int renderedChildCount = requestedExtent <= maxExtent
        ? count
        : (maxExtent + spacing) ~/ childStride - 1;
    final int unrenderedChildCount = count - renderedChildCount;
    if (renderedChildCount > 0) {
      _renderedBoxes.add(child);
    }
    int i;
    for (i = 1; i < renderedChildCount; i++) {
      child = childParentData.nextSibling;
      childParentData = child.parentData as OverflowViewParentData;
      child.layout(otherChildConstraints);
      childParentData.offset = getChildOffset(i);
      _renderedBoxes.add(child);
    }

    if (unrenderedChildCount > 0) {
      // We have to layout the overflow indicator.
      final RenderBox overflowIndicator = lastChild;

      final BoxValueConstraints<int> overflowIndicatorConstraints =
          BoxValueConstraints<int>(
        value: unrenderedChildCount,
        constraints: otherChildConstraints,
      );
      overflowIndicator.layout(overflowIndicatorConstraints);
      final OverflowViewParentData overflowIndicatorParentData =
          overflowIndicator.parentData as OverflowViewParentData;
      overflowIndicatorParentData.offset = getChildOffset(renderedChildCount);
      _renderedBoxes.add(overflowIndicator);
    }

    final double mainAxisExtent = _renderedBoxes.length * childStride - spacing;
    final requestedSize = _isHorizontal
        ? Size(mainAxisExtent, crossExtent)
        : Size(crossExtent, mainAxisExtent);

    size = constraints.constrain(requestedSize);
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    _renderedBoxes.forEach(visitor);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    void paintChild(RenderObject child) {
      final OverflowViewParentData childParentData =
          child.parentData as OverflowViewParentData;
      context.paintChild(child, childParentData.offset + offset);
    }

    _renderedBoxes.forEach(paintChild);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    // The x, y parameters have the top left of the node's box as the origin.
    for (int i = _renderedBoxes.length - 1; i >= 0; i--) {
      final RenderBox child = _renderedBoxes[i];
      final OverflowViewParentData childParentData =
          child.parentData as OverflowViewParentData;
      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
    }

    return false;
  }
}

extension on Size {
  double getMainExtent(Axis axis) {
    return axis == Axis.horizontal ? width : height;
  }

  double getCrossExtent(Axis axis) {
    return axis == Axis.horizontal ? height : width;
  }
}
