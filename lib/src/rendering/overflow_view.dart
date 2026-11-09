import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:value_layout_builder/value_layout_builder.dart';

/// Parent data for use with [RenderOverflowView].
class OverflowViewParentData extends ContainerBoxParentData<RenderBox> {
  bool? offstage;
}

enum OverflowViewLayoutBehavior { fixed, flexible }

class RenderOverflowView extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, OverflowViewParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, OverflowViewParentData> {
  RenderOverflowView({
    List<RenderBox>? children,
    required Axis direction,
    required TextDirection textDirection,
    required double spacing,
    required double runSpacing,
    required int maxRuns,
    required OverflowViewLayoutBehavior layoutBehavior,
    required int? maxCount,
  })  : assert(spacing > double.negativeInfinity && spacing < double.infinity),
        assert(
          runSpacing > double.negativeInfinity && runSpacing < double.infinity,
        ),
        assert(maxRuns >= 1),
        assert(maxCount == null || maxCount >= 0),
        _direction = direction,
        _textDirection = textDirection,
        _spacing = spacing,
        _runSpacing = runSpacing,
        _maxRuns = maxRuns,
        _layoutBehavior = layoutBehavior,
        _maxCount = maxCount,
        _isHorizontal = direction == Axis.horizontal {
    addAll(children);
  }

  Axis get direction => _direction;
  Axis _direction;
  set direction(Axis value) {
    if (_direction != value) {
      _direction = value;
      _isHorizontal = direction == Axis.horizontal;
      markNeedsLayout();
    }
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  double get spacing => _spacing;
  double _spacing;
  set spacing(double value) {
    assert(value > double.negativeInfinity && value < double.infinity);
    if (_spacing != value) {
      _spacing = value;
      markNeedsLayout();
    }
  }

  double get runSpacing => _runSpacing;
  double _runSpacing;
  set runSpacing(double value) {
    assert(value > double.negativeInfinity && value < double.infinity);
    if (_runSpacing != value) {
      _runSpacing = value;
      markNeedsLayout();
    }
  }

  int get maxRuns => _maxRuns;
  int _maxRuns;
  set maxRuns(int value) {
    assert(value >= 1);
    if (_maxRuns != value) {
      _maxRuns = value;
      markNeedsLayout();
    }
  }

  OverflowViewLayoutBehavior get layoutBehavior => _layoutBehavior;
  OverflowViewLayoutBehavior _layoutBehavior;
  set layoutBehavior(OverflowViewLayoutBehavior value) {
    if (_layoutBehavior != value) {
      _layoutBehavior = value;
      markNeedsLayout();
    }
  }

  int? get maxCount => _maxCount;
  int? _maxCount;
  set maxCount(int? value) {
    if (_maxCount != value) {
      _maxCount = value;
      markNeedsLayout();
    }
  }

  bool _isHorizontal;
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! OverflowViewParentData)
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

  bool _hasOverflow = false;

  @override
  void performLayout() {
    resetOffstage();

    final bool isFixed = layoutBehavior == OverflowViewLayoutBehavior.fixed;
    final double maxCrossExtent =
        _isHorizontal ? constraints.maxHeight : constraints.maxWidth;
    final _Runs runs = _Runs(
      maxExtent: _isHorizontal ? constraints.maxWidth : constraints.maxHeight,
      spacing: spacing,
      maxRuns: maxRuns,
    );
    // The onstage children, in order, followed by the overflow indicator if
    // it's displayed.
    final List<RenderBox> onstageChildren = <RenderBox>[];
    final RenderBox overflowIndicator = lastChild!;

    // In fixed mode, the first child is laid out with loose constraints, and
    // then all the other children, including the overflow indicator, get the
    // same size.
    BoxConstraints childConstraints = isFixed
        ? constraints.loosen()
        : _isHorizontal
            ? BoxConstraints(maxHeight: maxCrossExtent)
            : BoxConstraints(maxWidth: maxCrossExtent);
    double? fixedExtent;

    RenderBox child = firstChild!;
    final int? maxCount = _maxCount;
    while (child != overflowIndicator) {
      if (maxCount != null && onstageChildren.length >= maxCount) {
        // Hit max count, so we cannot render any further child.
        break;
      }

      final double? mainOffset;
      if (fixedExtent == null) {
        child.layout(childConstraints, parentUsesSize: true);
        mainOffset = runs.add(_getMainSize(child));
        if (isFixed) {
          childConstraints = BoxConstraints.tight(child.size);
          fixedExtent = _getMainSize(child);
        }
      } else {
        // We already know the size of the child, so we only lay it out if it
        // is displayed.
        mainOffset = runs.add(fixedExtent);
        if (mainOffset != null) {
          child.layout(childConstraints, parentUsesSize: true);
        }
      }

      if (mainOffset == null) {
        // There is no room for this child.
        break;
      }

      _setOnstage(child, mainOffset);
      onstageChildren.add(child);
      child = childAfter(child)!;
    }

    int unRenderedChildCount = childCount - 1 - onstageChildren.length;
    if (unRenderedChildCount > 0) {
      while (true) {
        final int indicatorCount = unRenderedChildCount;
        final double indicatorExtent = fixedExtent ??
            _layoutOverflowIndicator(indicatorCount, childConstraints);

        // We hide the last children until there is room for the indicator.
        double? mainOffset = runs.add(indicatorExtent);
        while (mainOffset == null && !runs.isLastRunEmpty) {
          final RenderBox hiddenChild = onstageChildren.removeLast();
          (hiddenChild.parentData as OverflowViewParentData).offstage = true;
          runs.removeLast(_getMainOffset(hiddenChild));
          unRenderedChildCount++;
          mainOffset = runs.add(indicatorExtent);
        }
        // If the indicator doesn't fit even alone in a run, it overflows.
        mainOffset ??= runs.forceAdd(indicatorExtent);

        if (fixedExtent != null || indicatorCount == unRenderedChildCount) {
          if (fixedExtent != null) {
            _layoutOverflowIndicator(unRenderedChildCount, childConstraints);
          }
          _setOnstage(overflowIndicator, mainOffset);
          onstageChildren.add(overflowIndicator);
          break;
        }

        // The indicator has to display another count, so its size can be
        // different.
        runs.removeLast(mainOffset);
      }
    } else if (overflowIndicator.hasSize &&
        !overflowIndicator.constraints.isTight) {
      // We need to layout the overflowIndicator because we may have already
      // laid it out with parentUsesSize: true before.
      // When unmounting a _LayoutBuilderElement, it calls markNeedsLayout
      // a last time, and can cause error.
      // When its last constraints were tight (fixed mode), the
      // overflowIndicator is a relayout boundary, so markNeedsLayout doesn't
      // reach us and we don't need to build it with no remaining children.
      overflowIndicator.layout(
        BoxValueConstraints<int>(value: 0, constraints: childConstraints),
      );
    }

    // By default we center all children in the cross-axis of their run.
    // We also compute the bounds of the children, because with negative
    // spacings, they can paint outside of the runs.
    Rect contentBounds = Rect.zero;
    double crossOffset = 0;
    int runStart = 0;
    for (final int runChildCount in runs.childCounts) {
      final int runEnd = runStart + runChildCount;
      double runCrossExtent = 0;
      for (int i = runStart; i < runEnd; i++) {
        runCrossExtent = math.max(
          runCrossExtent,
          _getCrossSize(onstageChildren[i]),
        );
      }
      for (int i = runStart; i < runEnd; i++) {
        final RenderBox child = onstageChildren[i];
        final OverflowViewParentData childParentData =
            child.parentData as OverflowViewParentData;
        childParentData.offset = _getOffset(
          _getMainOffset(child),
          crossOffset + (runCrossExtent - _getCrossSize(child)) / 2.0,
        );
        contentBounds = contentBounds.expandToInclude(
          childParentData.offset & child.size,
        );
      }
      crossOffset += runCrossExtent + runSpacing;
      runStart = runEnd;
    }
    assert(runStart == onstageChildren.length);

    size = constraints.constrain(
      _getSize(runs.extent, crossOffset - runSpacing),
    );
    const double tolerance = precisionErrorTolerance;
    _hasOverflow = contentBounds.left < -tolerance ||
        contentBounds.top < -tolerance ||
        contentBounds.right > size.width + tolerance ||
        contentBounds.bottom > size.height + tolerance;

    // In RTL, the layout is the mirror image of the LTR one: horizontally,
    // children go from right to left, and vertically, runs go from right to
    // left.
    if (textDirection == TextDirection.rtl) {
      for (final RenderBox child in onstageChildren) {
        final OverflowViewParentData childParentData =
            child.parentData as OverflowViewParentData;
        final Offset offset = childParentData.offset;
        childParentData.offset = Offset(
          size.width - offset.dx - child.size.width,
          offset.dy,
        );
      }
    }
  }

  void resetOffstage() {
    visitChildren((child) {
      final OverflowViewParentData childParentData =
          child.parentData as OverflowViewParentData;
      childParentData.offstage = null;
    });
  }

  /// Lays out the overflow indicator and returns its main axis size.
  double _layoutOverflowIndicator(
    int unRenderedChildCount,
    BoxConstraints constraints,
  ) {
    final RenderBox overflowIndicator = lastChild!;
    overflowIndicator.layout(
      BoxValueConstraints<int>(
        value: unRenderedChildCount,
        constraints: constraints,
      ),
      parentUsesSize: true,
    );
    return _getMainSize(overflowIndicator);
  }

  /// Marks [child] as onstage, at [mainOffset] in its run. Its cross axis
  /// offset is set once all the runs are known.
  void _setOnstage(RenderBox child, double mainOffset) {
    final OverflowViewParentData childParentData =
        child.parentData as OverflowViewParentData;
    childParentData.offstage = false;
    childParentData.offset = _getOffset(mainOffset, 0);
  }

  double _getMainOffset(RenderBox child) {
    final Offset offset = (child.parentData as OverflowViewParentData).offset;
    return _isHorizontal ? offset.dx : offset.dy;
  }

  Offset _getOffset(double mainOffset, double crossOffset) {
    return _isHorizontal
        ? Offset(mainOffset, crossOffset)
        : Offset(crossOffset, mainOffset);
  }

  Size _getSize(double mainExtent, double crossExtent) {
    return _isHorizontal
        ? Size(mainExtent, crossExtent)
        : Size(crossExtent, mainExtent);
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
    // The position parameter has the top left of the node's box as the origin.
    // We visit the onstage children in reverse paint order, so that the topmost
    // one wins, and we stop at the first child which is hit.
    RenderBox? child = lastChild;
    while (child != null) {
      final RenderBox currentChild = child;
      final OverflowViewParentData childParentData =
          currentChild.parentData as OverflowViewParentData;
      if (childParentData.offstage == false) {
        final bool isHit = result.addWithPaintOffset(
          offset: childParentData.offset,
          position: position,
          hitTest: (BoxHitTestResult result, Offset transformed) {
            assert(transformed == position - childParentData.offset);
            return currentChild.hitTest(result, position: transformed);
          },
        );
        if (isHit) {
          return true;
        }
      }
      child = childParentData.previousSibling;
    }

    return false;
  }
}

/// Places items one after the other along the main axis, and starts a new run
/// when an item doesn't fit in the current one, up to [maxRuns] runs.
class _Runs {
  _Runs({
    required this.maxExtent,
    required this.spacing,
    required this.maxRuns,
  });

  final double maxExtent;
  final double spacing;
  final int maxRuns;

  /// The number of items in each run.
  final List<int> childCounts = <int>[0];

  /// The main axis extent of the last run.
  double _lastRunExtent = 0;

  /// The largest main axis extent of the runs before the last one.
  double _previousRunsExtent = 0;

  /// The main axis extent of the largest run.
  double get extent => math.max(_previousRunsExtent, _lastRunExtent);

  bool get isLastRunEmpty => childCounts.last == 0;

  /// Adds an item with the given main axis [extent], and returns its offset in
  /// its run, or null if there is no room for it.
  double? add(double extent) {
    if (isLastRunEmpty) {
      return _fits(extent) ? _append(0, extent) : null;
    }

    final double offset = _lastRunExtent + spacing;
    if (_fits(offset + extent)) {
      return _append(offset, extent);
    }

    if (childCounts.length < maxRuns && _fits(extent)) {
      _previousRunsExtent = math.max(_previousRunsExtent, _lastRunExtent);
      childCounts.add(0);
      return _append(0, extent);
    }

    return null;
  }

  /// Whether an item ending at [end] fits in a run.
  ///
  /// We tolerate rounding errors, otherwise children which exactly fill a run
  /// could be hidden.
  bool _fits(double end) => end <= maxExtent + precisionErrorTolerance;

  /// Adds an item to the last run, which must be empty, even if there is no
  /// room for it.
  double forceAdd(double extent) {
    assert(isLastRunEmpty);
    return _append(0, extent);
  }

  /// Removes the last item, which was added at [offset] in the last run.
  void removeLast(double offset) {
    assert(!isLastRunEmpty);
    childCounts.last--;
    _lastRunExtent = isLastRunEmpty ? 0 : offset - spacing;
  }

  double _append(double offset, double extent) {
    childCounts.last++;
    _lastRunExtent = offset + extent;
    return offset;
  }
}

extension RenderObjectExtensions on RenderObject {
  bool get isOnstage =>
      (parentData as OverflowViewParentData).offstage == false;
}
