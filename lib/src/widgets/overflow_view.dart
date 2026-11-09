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
/// is no more room, or until a maximum number of children is reached. If all
/// the children don't fit in the available space, or if the maximum number of
/// children to display is reached, it displays an indicator at the end.
///
/// `maxCount` controls the maximum number of children that will be displayed
/// before an indicator is displayed, even if there is sufficient room to
/// display more children.
///
/// The children can also be displayed in several runs, like in a [Wrap], by
/// setting `maxRuns`. In that case, the indicator is at the end of the last
/// run.
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
    TextDirection? textDirection,
    required List<Widget> children,
    double spacing = 0,
    double runSpacing = 0,
    int maxRuns = 1,
    int? maxCount = null,
  }) : this._all(
          key: key,
          builder: builder,
          direction: direction,
          textDirection: textDirection,
          children: children,
          spacing: spacing,
          runSpacing: runSpacing,
          maxRuns: maxRuns,
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
    TextDirection? textDirection,
    required List<Widget> children,
    double spacing = 0,
    double runSpacing = 0,
    int maxRuns = 1,
    int? maxCount = null,
  }) : this._all(
          key: key,
          builder: builder,
          direction: direction,
          textDirection: textDirection,
          children: children,
          spacing: spacing,
          runSpacing: runSpacing,
          maxRuns: maxRuns,
          layoutBehavior: OverflowViewLayoutBehavior.flexible,
          maxCount: maxCount,
        );

  OverflowView._all({
    Key? key,
    required OverflowIndicatorBuilder builder,
    this.direction = Axis.horizontal,
    this.textDirection,
    required List<Widget> children,
    this.spacing = 0,
    this.runSpacing = 0,
    this.maxRuns = 1,
    this.maxCount = null,
    required OverflowViewLayoutBehavior layoutBehavior,
  })  : assert(spacing > double.negativeInfinity && spacing < double.infinity),
        assert(
          runSpacing > double.negativeInfinity && runSpacing < double.infinity,
        ),
        assert(maxRuns >= 1),
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

  /// Determines in which direction the children are placed when [direction]
  /// is [Axis.horizontal], and in which direction the runs are placed when
  /// [direction] is [Axis.vertical].
  ///
  /// Defaults to the ambient [Directionality], or to [TextDirection.ltr] if
  /// there is none.
  final TextDirection? textDirection;

  /// The amount of space between successive children in a run.
  final double spacing;

  /// The amount of space between successive runs.
  final double runSpacing;

  /// The maximum number of runs.
  ///
  /// When a child doesn't fit at the end of a run, it starts a new run, until
  /// there are [maxRuns] runs. For example, if [direction] is
  /// [Axis.horizontal], a run is a row.
  ///
  /// Defaults to 1, which displays the children in a single line.
  final int maxRuns;

  /// Maximum number of items to display before overflowing, even if space
  /// remains for more. If `null`, only the available space will influence
  /// the maximum number of children to display.
  final int? maxCount;

  final OverflowViewLayoutBehavior _layoutBehavior;

  TextDirection _getTextDirection(BuildContext context) {
    return textDirection ??
        Directionality.maybeOf(context) ??
        TextDirection.ltr;
  }

  @override
  _OverflowViewElement createElement() {
    return _OverflowViewElement(this);
  }

  @override
  RenderOverflowView createRenderObject(BuildContext context) {
    return RenderOverflowView(
      direction: direction,
      textDirection: _getTextDirection(context),
      spacing: spacing,
      runSpacing: runSpacing,
      maxRuns: maxRuns,
      maxCount: maxCount,
      layoutBehavior: _layoutBehavior,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderOverflowView renderObject,
  ) {
    renderObject
      ..direction = direction
      ..textDirection = _getTextDirection(context)
      ..spacing = spacing
      ..runSpacing = runSpacing
      ..maxRuns = maxRuns
      ..maxCount = maxCount
      ..layoutBehavior = _layoutBehavior;
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
