import 'package:flutter/foundation.dart';
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
  /// The [spacing] argument must also be finite.
  OverflowView({
    Key? key,
    required OverflowIndicatorBuilder builder,
    Axis direction = Axis.horizontal,
    required List<Widget> children,
    double spacing = 0,
  }) : this._all(
          key: key,
          builder: builder,
          direction: direction,
          children: children,
          alignment: WrapAlignment.start,
          spacing: spacing,
          runAlignment: WrapAlignment.start,
          runSpacing: 0,
          crossAxisAlignment: WrapCrossAlignment.start,
          maxRun: 1,
          verticalDirection: VerticalDirection.down,
          layoutBehavior: OverflowViewLayoutBehavior.fixed,
        );

  /// Creates a flexible [OverflowView].
  ///
  /// All children can have their own size.
  ///
  /// The [spacing] argument must also be finite.
  OverflowView.flexible({
    Key? key,
    required OverflowIndicatorBuilder builder,
    Axis direction = Axis.horizontal,
    required List<Widget> children,
    double spacing = 0,
  }) : this._all(
          key: key,
          builder: builder,
          direction: direction,
          children: children,
          alignment: WrapAlignment.start,
          spacing: spacing,
          runAlignment: WrapAlignment.start,
          runSpacing: 0,
          crossAxisAlignment: WrapCrossAlignment.start,
          maxRun: 1,
          verticalDirection: VerticalDirection.down,
          layoutBehavior: OverflowViewLayoutBehavior.flexible,
        );

  /// Creates a flexible [OverflowView].
  ///
  /// All children can have their own size.
  ///
  /// The [spacing] argument must also be finite.
  OverflowView.wrap({
    Key? key,
    required OverflowIndicatorBuilder builder,
    Axis direction = Axis.horizontal,
    required List<Widget> children,
    WrapAlignment alignment = WrapAlignment.start,
    double spacing = 0,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    int? maxRun,
    int? maxItemPerRun,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
  }) : this._all(
          key: key,
          builder: builder,
          direction: direction,
          children: children,
          alignment: alignment,
          spacing: spacing,
          runAlignment: runAlignment,
          runSpacing: runSpacing,
          crossAxisAlignment: crossAxisAlignment,
          maxRun: maxRun,
          maxItemPerRun: maxItemPerRun,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          layoutBehavior: OverflowViewLayoutBehavior.wrap,
        );

  OverflowView._all({
    Key? key,
    required OverflowIndicatorBuilder builder,
    this.direction = Axis.horizontal,
    required List<Widget> children,
    this.alignment = WrapAlignment.start,
    this.spacing = 0,
    this.runAlignment = WrapAlignment.start,
    this.runSpacing = 0.0,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.maxRun,
    this.maxItemPerRun,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    required OverflowViewLayoutBehavior layoutBehavior,
  })  : assert(spacing > double.negativeInfinity && spacing < double.infinity),
        assert(maxItemPerRun == null || maxItemPerRun > 0),
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

  /// How the children within a run should be placed in the main axis.
  ///
  /// For example, if [alignment] is [WrapAlignment.center], the children in
  /// each run are grouped together in the center of their run in the main axis.
  ///
  /// Defaults to [WrapAlignment.start].
  ///
  /// See also:
  ///
  ///  * [runAlignment], which controls how the runs are placed relative to each
  ///    other in the cross axis.
  ///  * [crossAxisAlignment], which controls how the children within each run
  ///    are placed relative to each other in the cross axis.
  final WrapAlignment alignment;

  /// * If [_layoutBehavior] is [OverflowViewLayoutBehavior.fixed],
  /// [OverflowViewLayoutBehavior.flexible]:
  ///
  /// It's the amount of space between successive children.
  ///
  /// * If [_layoutBehavior] is [OverflowViewLayoutBehavior.wrap]:
  ///
  /// How much space to place between children in a run in the main axis.
  ///
  /// For example, if [spacing] is 10.0, the children will be spaced at least
  /// 10.0 logical pixels apart in the main axis.
  ///
  /// If there is additional free space in a run (e.g., because the wrap has a
  /// minimum size that is not filled or because some runs are longer than
  /// others), the additional free space will be allocated according to the
  /// [alignment].
  ///
  /// Defaults to 0.0.
  final double spacing;

  /// How the runs themselves should be placed in the cross axis.
  ///
  /// For example, if [runAlignment] is [WrapAlignment.center], the runs are
  /// grouped together in the center of the overall [OverflowView] in the cross axis.
  ///
  /// Defaults to [WrapAlignment.start].
  ///
  /// See also:
  ///
  ///  * [alignment], which controls how the children within each run are placed
  ///    relative to each other in the main axis.
  ///  * [crossAxisAlignment], which controls how the children within each run
  ///    are placed relative to each other in the cross axis.
  final WrapAlignment runAlignment;

  /// How much space to place between the runs themselves in the cross axis.
  ///
  /// For example, if [runSpacing] is 10.0, the runs will be spaced at least
  /// 10.0 logical pixels apart in the cross axis.
  ///
  /// If there is additional free space in the overall [OverflowView] (e.g., because
  /// the wrap has a minimum size that is not filled), the additional free space
  /// will be allocated according to the [runAlignment].
  ///
  /// Defaults to 0.0.
  final double runSpacing;

  /// How the children within a run should be aligned relative to each other in
  /// the cross axis.
  ///
  /// For example, if this is set to [WrapCrossAlignment.end], and the
  /// [direction] is [Axis.horizontal], then the children within each
  /// run will have their bottom edges aligned to the bottom edge of the run.
  ///
  /// Defaults to [WrapCrossAlignment.start].
  ///
  /// See also:
  ///
  ///  * [alignment], which controls how the children within each run are placed
  ///    relative to each other in the main axis.
  ///  * [runAlignment], which controls how the runs are placed relative to each
  ///    other in the cross axis.
  final WrapCrossAlignment crossAxisAlignment;

  /// A maximum number of rows (the runs).
  final int? maxRun;

  /// A maximum number of columns (the item in each run).
  final int? maxItemPerRun;

  /// Determines the order to lay children out horizontally and how to interpret
  /// `start` and `end` in the horizontal direction.
  ///
  /// Defaults to the ambient [Directionality].
  ///
  /// If the [direction] is [Axis.horizontal], this controls order in which the
  /// children are positioned (left-to-right or right-to-left), and the meaning
  /// of the [alignment] property's [WrapAlignment.start] and
  /// [WrapAlignment.end] values.
  ///
  /// If the [direction] is [Axis.horizontal], and either the
  /// [alignment] is either [WrapAlignment.start] or [WrapAlignment.end], or
  /// there's more than one child, then the [textDirection] (or the ambient
  /// [Directionality]) must not be null.
  ///
  /// If the [direction] is [Axis.vertical], this controls the order in which
  /// runs are positioned, the meaning of the [runAlignment] property's
  /// [WrapAlignment.start] and [WrapAlignment.end] values, as well as the
  /// [crossAxisAlignment] property's [WrapCrossAlignment.start] and
  /// [WrapCrossAlignment.end] values.
  ///
  /// If the [direction] is [Axis.vertical], and either the
  /// [runAlignment] is either [WrapAlignment.start] or [WrapAlignment.end], the
  /// [crossAxisAlignment] is either [WrapCrossAlignment.start] or
  /// [WrapCrossAlignment.end], or there's more than one child, then the
  /// [textDirection] (or the ambient [Directionality]) must not be null.
  final TextDirection? textDirection;

  /// Determines the order to lay children out vertically and how to interpret
  /// `start` and `end` in the vertical direction.
  ///
  /// If the [direction] is [Axis.vertical], this controls which order children
  /// are painted in (down or up), the meaning of the [alignment] property's
  /// [WrapAlignment.start] and [WrapAlignment.end] values.
  ///
  /// If the [direction] is [Axis.vertical], and either the [alignment]
  /// is either [WrapAlignment.start] or [WrapAlignment.end], or there's
  /// more than one child, then the [verticalDirection] must not be null.
  ///
  /// If the [direction] is [Axis.horizontal], this controls the order in which
  /// runs are positioned, the meaning of the [runAlignment] property's
  /// [WrapAlignment.start] and [WrapAlignment.end] values, as well as the
  /// [crossAxisAlignment] property's [WrapCrossAlignment.start] and
  /// [WrapCrossAlignment.end] values.
  ///
  /// If the [direction] is [Axis.horizontal], and either the
  /// [runAlignment] is either [WrapAlignment.start] or [WrapAlignment.end], the
  /// [crossAxisAlignment] is either [WrapCrossAlignment.start] or
  /// [WrapCrossAlignment.end], or there's more than one child, then the
  /// [verticalDirection] must not be null.
  final VerticalDirection verticalDirection;

  /// Defines whether a [OverflowView] should constrain all children and
  /// displays them.
  final OverflowViewLayoutBehavior _layoutBehavior;

  @override
  _OverflowViewElement createElement() {
    return _OverflowViewElement(this);
  }

  @override
  RenderOverflowView createRenderObject(BuildContext context) {
    return RenderOverflowView(
      direction: direction,
      alignment: alignment,
      spacing: spacing,
      runAlignment: runAlignment,
      runSpacing: runSpacing,
      crossAxisAlignment: crossAxisAlignment,
      maxRun: maxRun,
      maxItemPerRun: maxItemPerRun,
      textDirection: textDirection ?? Directionality.maybeOf(context),
      verticalDirection: verticalDirection,
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
      ..alignment = alignment
      ..spacing = spacing
      ..runAlignment = runAlignment
      ..runSpacing = runSpacing
      ..crossAxisAlignment = crossAxisAlignment
      ..maxRun = maxRun
      ..maxItemPerRun = maxItemPerRun
      ..textDirection = textDirection ?? Directionality.maybeOf(context)
      ..verticalDirection = verticalDirection
      ..layoutBehavior = _layoutBehavior;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<Axis>('direction', direction));
    properties.add(EnumProperty<WrapAlignment>('alignment', alignment));
    properties.add(DoubleProperty('spacing', spacing));
    properties.add(EnumProperty<WrapAlignment>('runAlignment', runAlignment));
    properties.add(DoubleProperty('runSpacing', runSpacing));
    properties.add(EnumProperty<WrapCrossAlignment>(
      'crossAxisAlignment',
      crossAxisAlignment,
    ));
    properties.add(IntProperty('maxRun', maxRun));
    properties.add(IntProperty(
      'maxItemPerRun',
      maxItemPerRun,
      defaultValue: null,
    ));
    properties.add(EnumProperty<TextDirection>(
      'textDirection',
      textDirection,
      defaultValue: null,
    ));
    properties.add(EnumProperty<VerticalDirection>(
      'verticalDirection',
      verticalDirection,
      defaultValue: VerticalDirection.down,
    ));
    properties.add(EnumProperty<OverflowViewLayoutBehavior>(
      'layoutBehavior',
      _layoutBehavior,
    ));
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
