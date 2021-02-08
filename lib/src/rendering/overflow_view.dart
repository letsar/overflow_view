import 'package:flutter/rendering.dart';
import 'package:value_layout_builder/value_layout_builder.dart';

import 'dart:math' as math;

/// Parent data for use with [RenderOverflowView].
class OverflowViewParentData extends ContainerBoxParentData<RenderBox> {
  bool? offstage;
}

enum OverflowViewLayoutBehavior {
  fixed,
  flexible,
}

class RenderOverflowView extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, OverflowViewParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, OverflowViewParentData> {
  RenderOverflowView({
    List<RenderBox>? children,
    required Axis direction,
    required double spacing,
    required OverflowViewLayoutBehavior layoutBehavior,
  })  : assert(spacing > double.negativeInfinity &&
            spacing < double.infinity),
        _direction = direction,
        _spacing = spacing,
        _layoutBehavior = layoutBehavior,
        _isHorizontal = direction == Axis.horizontal {
    addAll(children);
  }

  Axis _direction;

  double _spacing;

  OverflowViewLayoutBehavior _layoutBehavior;

  bool _isHorizontal;

  bool _hasOverflow = false;

  Axis get direction => _direction;

  set direction(Axis value) {
    if (_direction != value) {
      _direction = value;
      _isHorizontal = direction == Axis.horizontal;
      markNeedsLayout();
    }
  }

  double get spacing => _spacing;

  set spacing(double value) {
    assert(value > double.negativeInfinity &&
        value < double.infinity);
    if (_spacing != value) {
      _spacing = value;
      markNeedsLayout();
    }
  }

  OverflowViewLayoutBehavior get layoutBehavior => _layoutBehavior;

  set layoutBehavior(OverflowViewLayoutBehavior value) {
    if (_layoutBehavior != value) {
      _layoutBehavior = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is !OverflowViewParentData)
      child.parentData = OverflowViewParentData();
  }

  double _getCrossSize(RenderBox child) {
    switch (_direction) {
      case Axis.horizontal:
        return child.size.height;
      case Axis.vertical:
        return child.size.width;
    }
  }

  double _getMainSize(RenderBox child) {
    switch (_direction) {
      case Axis.horizontal:
        return child.size.width;
      case Axis.vertical:
        return child.size.height;
    }
  }

  @override
  void performLayout() {
    _hasOverflow = false;
    assert(firstChild != null);
    resetOffstage();
    if (layoutBehavior == OverflowViewLayoutBehavior.fixed) {
      performFixedLayout();
    } else {
      performFlexibleLayout();
    }
  }

  void resetOffstage() {
    visitChildren((child) {
      final OverflowViewParentData childParentData =
          child.parentData as OverflowViewParentData;
      childParentData.offstage = null;
    });
  }

  void performFixedLayout() {
    RenderBox child = firstChild!;
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

    int onstageCount = 0;
    final int count = childCount - 1;
    final double requestedExtent =
        childExtent * (childCount - 1) + spacing * (childCount - 2);
    final int renderedChildCount = requestedExtent <= maxExtent
        ? count
        : (maxExtent + spacing) ~/ childStride - 1;
    final int unRenderedChildCount = count - renderedChildCount;
    if (renderedChildCount > 0) {
      childParentData.offstage = false;
      onstageCount++;
    }

    for (int i = 1; i < renderedChildCount; i++) {
      child = childParentData.nextSibling!;
      childParentData = child.parentData as OverflowViewParentData;
      child.layout(otherChildConstraints);
      childParentData.offset = getChildOffset(i);
      childParentData.offstage = false;
      onstageCount++;
    }

    while (child != lastChild) {
      child = childParentData.nextSibling!;
      childParentData = child.parentData as OverflowViewParentData;
      childParentData.offstage = true;
    }

    if (unRenderedChildCount > 0) {
      // We have to layout the overflow indicator.
      final RenderBox? overflowIndicator = lastChild;

      final BoxValueConstraints<int> overflowIndicatorConstraints =
          BoxValueConstraints<int>(
        value: unRenderedChildCount,
        constraints: otherChildConstraints,
      );
      overflowIndicator?.layout(overflowIndicatorConstraints);
      final OverflowViewParentData overflowIndicatorParentData =
          overflowIndicator?.parentData as OverflowViewParentData;
      overflowIndicatorParentData.offset = getChildOffset(renderedChildCount);
      overflowIndicatorParentData.offstage = false;
      onstageCount++;
    }

    final double mainAxisExtent = onstageCount * childStride - spacing;
    final requestedSize = _isHorizontal
        ? Size(mainAxisExtent, crossExtent)
        : Size(crossExtent, mainAxisExtent);

    size = constraints.constrain(requestedSize);
  }

  void performFlexibleLayout() {
    RenderBox? child = firstChild;
    List<RenderBox> renderBoxes = <RenderBox>[];
    int unRenderedChildCount = childCount - 1;
    double availableExtent =
        _isHorizontal ? constraints.maxWidth : constraints.maxHeight;
    double offset = 0;
    final double maxCrossExtent =
        _isHorizontal ? constraints.maxHeight : constraints.maxWidth;

    final Constraints childConstraints = _isHorizontal
        ? BoxConstraints.loose(Size(double.infinity, maxCrossExtent))
        : BoxConstraints.loose(Size(maxCrossExtent, double.infinity));

    bool showOverflowIndicator = false;
    while (child != lastChild) {
      final OverflowViewParentData childParentData =
          child?.parentData as OverflowViewParentData;

      child?.layout(childConstraints, parentUsesSize: true);

      final double childMainSize = child != null ? _getMainSize(child) : 0;

      if (childMainSize <= availableExtent && child != null) {
        // We have room to paint this child.
        renderBoxes.add(child);
        childParentData.offstage = false;
        childParentData.offset =
            _isHorizontal ? Offset(offset, 0) : Offset(0, offset);

        final double childStride = spacing + childMainSize;
        offset += childStride;
        availableExtent -= childStride;
        unRenderedChildCount--;
        child = childParentData.nextSibling;
      } else {
        // We have no room to paint any further child.
        showOverflowIndicator = true;
        break;
      }
    }

    if (showOverflowIndicator) {
      // We didn't layout all the children.
      final RenderBox? overflowIndicator = lastChild;
      final BoxValueConstraints<int> overflowIndicatorConstraints =
          BoxValueConstraints<int>(
        value: unRenderedChildCount,
        constraints: childConstraints as BoxConstraints,
      );
      overflowIndicator?.layout(
        overflowIndicatorConstraints,
        parentUsesSize: true,
      );

      final double childMainSize = overflowIndicator != null ? _getMainSize(overflowIndicator) : 0;

      // We need to remove the children that prevent the overflowIndicator
      // to paint.
      while (childMainSize > availableExtent && renderBoxes.isNotEmpty) {
        final RenderBox child = renderBoxes.removeLast();
        final OverflowViewParentData childParentData =
            child.parentData as OverflowViewParentData;
        childParentData.offstage = true;
        final double childStride = _getMainSize(child) + spacing;

        availableExtent += childStride;
        unRenderedChildCount++;
        offset -= childStride;
      }

      if (childMainSize > availableExtent) {
        // We cannot paint any child because there is not enough space.
        _hasOverflow = true;
      }

      if (overflowIndicatorConstraints.value != unRenderedChildCount && overflowIndicator != null) {
        // The number of unrendered child changed, we have to layout the
        // indicator another time.
        overflowIndicator.layout(
          BoxValueConstraints<int>(
            value: unRenderedChildCount,
            constraints: childConstraints,
          ),
          parentUsesSize: true,
        );
      }

      renderBoxes.add(overflowIndicator!);

      final OverflowViewParentData overflowIndicatorParentData =
          overflowIndicator.parentData as OverflowViewParentData;
      overflowIndicatorParentData.offset =
          _isHorizontal ? Offset(offset, 0) : Offset(0, offset);
      overflowIndicatorParentData.offstage = false;
      offset += childMainSize;
    } else {
      // We layout all children. We need to adjust the offset used to compute
      // the final size.
      offset -= spacing;

      // We need to layout the overflowIndicator because we may have already
      // laid it out with parentUsesSize: true before.
      // When unmounting a _LayoutBuilderElement, it calls markNeedsLayout
      // a last time, and can cause error.
      lastChild?.layout(BoxValueConstraints<int>(
        value: unRenderedChildCount,
        constraints: childConstraints as BoxConstraints,
      ));

      // Because the overflow indicator will be paint outside of the screen,
      // we need to say that there is an overflow.
      _hasOverflow = true;
    }

    final double crossSize = renderBoxes.fold(
      0,
      (previousValue, element) => math.max(
        previousValue,
        _getCrossSize(element),
      ),
    );

    // By default we center all children in the cross-axis.
    for (final child in renderBoxes) {
      final double childCrossPosition =
          crossSize / 2.0 - _getCrossSize(child) / 2.0;
      final OverflowViewParentData childParentData =
          child.parentData as OverflowViewParentData;
      childParentData.offset = _isHorizontal
          ? Offset(childParentData.offset.dx, childCrossPosition)
          : Offset(childCrossPosition, childParentData.offset.dy);
    }

    Size idealSize;
    if (_isHorizontal) {
      idealSize = Size(offset, crossSize);
    } else {
      idealSize = Size(crossSize, offset);
    }

    size = constraints.constrain(idealSize);
  }

  void visitOnlyOnStageChildren(RenderObjectVisitor visitor) {
    visitChildren((child) {
      if (child.isOnstage) {
        visitor(child);
      }
    });
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    visitOnlyOnStageChildren(visitor);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    void paintChild(RenderObject child) {
      final OverflowViewParentData childParentData =
          child.parentData as OverflowViewParentData;
      if (childParentData.offstage == false) {
        context.paintChild(child, childParentData.offset + offset);
      } else {
        // We paint it outside the box.
        context.paintChild(child, size.bottomRight(Offset.zero));
      }
    }

    void defaultPaint(PaintingContext context, Offset offset) {
      visitOnlyOnStageChildren(paintChild);
    }

    if (_hasOverflow) {
      context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        defaultPaint,
        clipBehavior: Clip.hardEdge,
      );
    } else {
      defaultPaint(context, offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // The x, y parameters have the top left of the node's box as the origin.
    visitOnlyOnStageChildren((renderObject) {
      final RenderBox child = renderObject as RenderBox;
      final OverflowViewParentData childParentData =
          child.parentData as OverflowViewParentData;
      result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
    });

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

extension RenderObjectExtensions on RenderObject {
  bool get isOnstage =>
      (parentData as OverflowViewParentData).offstage == false;
}
