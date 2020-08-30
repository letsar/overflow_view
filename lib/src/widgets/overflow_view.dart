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
  /// The [builder], [spacing] and [children] arguments must not be null.
  /// The [spacing] argument must also be positive and finite.
  OverflowView({
    Key key,
    @required OverflowIndicatorBuilder builder,
    this.direction = Axis.horizontal,
    @required List<Widget> children,
    this.spacing = 0,
  })  : assert(builder != null),
        assert(direction != null),
        assert(children != null),
        assert(spacing != null && spacing >= 0 && spacing < double.infinity),
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

  @override
  RenderOverflowView createRenderObject(BuildContext context) {
    return RenderOverflowView(
      direction: direction,
      spacing: spacing,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderOverflowView renderObject,
  ) {
    renderObject
      ..direction = direction
      ..spacing = spacing;
  }
}
