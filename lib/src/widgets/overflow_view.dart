import 'package:flutter/material.dart';
import 'package:overflow_view/src/rendering/overflow_view.dart';
import 'package:value_layout_builder/value_layout_builder.dart';

/// Signature for a builder that creates an overflow indicator when there is not
/// enough space to display all the children of an [OverflowView].
typedef OverflowIndicatorBuilder = Widget Function(
  BuildContext context,
  int remainingItemCount,
);

/// A widget that displays its children in a one-dimensional array until there
/// is no more room. If all the children don't fit in the available space, it
/// displays an indicator at the end.
///
/// All chidren will have the same size as the first child.
class OverflowView extends MultiChildRenderObjectWidget {
  /// Creates an [OverflowView].
  ///
  /// All children will have the same size has the first child.
  ///
  /// The [spacing] argument must also be positive and finite.
  OverflowView({
    Key? key,
    required OverflowIndicatorBuilder builder,
    Axis direction = Axis.horizontal,
    required List<Widget> children,
    double spacing = 0,
    int? maxCount = null,
  }) : this._all(
          key: key,
          builder: builder,
          direction: direction,
          children: children,
          spacing: spacing,
          layoutBehavior: OverflowViewLayoutBehavior.fixed,
          maxCount: maxCount,
        );

  /// Creates a flexible [OverflowView].
  ///
  /// All children can have their own size.
  ///
  /// The [spacing] argument must also be positive and finite.
  OverflowView.flexible({
    Key? key,
    required OverflowIndicatorBuilder builder,
    Axis direction = Axis.horizontal,
    required List<Widget> children,
    double spacing = 0,
    int? maxCount = null,
  }) : this._all(
          key: key,
          builder: builder,
          direction: direction,
          children: children,
          spacing: spacing,
          layoutBehavior: OverflowViewLayoutBehavior.flexible,
          maxCount: maxCount,
        );

  OverflowView._all({
    Key? key,
    required OverflowIndicatorBuilder builder,
    this.direction = Axis.horizontal,
    required List<Widget> children,
    this.spacing = 0,
    required OverflowViewLayoutBehavior layoutBehavior,
    this.maxCount = null,
  })  : assert(spacing > double.negativeInfinity && spacing < double.infinity),
        assert(maxCount == null || maxCount >= 0),
        _layoutBehavior = layoutBehavior,
        super(
          key: key,
          children: [
            ...children,
            ValueLayoutBuilder<int>(
              builder: (context, constraints) {
                return builder(context, constraints.value);
              },
            ),
          ],
        );

  /// The direction to use as the main axis.
  ///
  /// For example, if [direction] is [Axis.horizontal], the default, the
  /// children are placed adjacent to one another as in a [Row].
  final Axis direction;

  /// The amount of space between successive children.
  final double spacing;

  /// Maximum number of items to display before overflowing, even if space
  /// remains for more. If `null`, only the available space will influence
  /// the maximum number of children to display.
  final int? maxCount;

  final OverflowViewLayoutBehavior _layoutBehavior;

  @override
  _OverflowViewElement createElement() {
    return _OverflowViewElement(this);
  }

  @override
  RenderOverflowView createRenderObject(BuildContext context) {
    return RenderOverflowView(
      direction: direction,
      spacing: spacing,
      layoutBehavior: _layoutBehavior,
      maxCount: maxCount,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderOverflowView renderObject,
  ) {
    renderObject
      ..direction = direction
      ..spacing = spacing
      ..layoutBehavior = _layoutBehavior
      ..maxCount = maxCount;
  }
}

class _OverflowViewElement extends MultiChildRenderObjectElement {
  _OverflowViewElement(OverflowView widget) : super(widget);

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    children.forEach((element) {
      if (element.renderObject?.isOnstage == true) {
        visitor(element);
      }
    });
  }
}
