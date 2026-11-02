# overflow_view
A widget displaying children in a line with an overflow indicator at the end if there is not enough space.

[![Pub](https://img.shields.io/pub/v/overflow_view.svg)][pub]

## Features
* Renders children horizontally or vertically.
* Has an overflow indicator builder so that you can display a widget showing the number of elements not rendered.
* Can either constrain the children to the size of the first child or let them have the size they want.
* Children can overlap each other by setting a negative spacing.
* Children can be displayed in several runs (rows or columns), like in a `Wrap`.
* Supports right-to-left layouts.

![Overview][overview]

## Getting started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  overflow_view:
```

In your library add the following import:

```dart
import 'package:overflow_view/overflow_view.dart';
```

## Usage

```dart
OverflowView(
  // Either layout the children horizontally (the default)
  // or vertically.
  direction: Axis.horizontal,
  // The amount of space between children.
  spacing: 4,
  // The widgets to display until there is not enough space.
  children: <Widget>[
    for (int i = 0; i < _counter; i++)
      AvatarWidget(
        text: avatars[i].initials,
        color: avatars[i].color,
      )
  ],
  // The overview indicator showed if there is not enough space for
  // all chidren.
  builder: (context, remaining) {
    // You can return any widget here.
    // You can either show a +n widget or a more complex widget
    // which can show a thumbnail of not rendered widgets.
    return AvatarWidget(
      text: '+$remaining',
      color: Colors.red,
    );
  },
)
```

### Constructors

There are two constuctors depending on what you want to do.

The `OverflowView` constructor will constrain all children to have the same size as the first one. This can be used for an avatar list for example.

The `OverflowView.flexible` constructor will let all children to determine their own size. This is less performant than the default one, but it's more flexible. This can be used for a menu bar for example.

### Runs

By default, the children are displayed in a single line. Set `maxRuns` to display them in several runs, like in a `Wrap`: when a child doesn't fit at the end of a run, it starts a new one, until there are `maxRuns` runs. The overflow indicator is then displayed at the end of the last run.

```dart
OverflowView(
  // Display the children in two rows at most.
  maxRuns: 2,
  // The amount of space between children in a run.
  spacing: 4,
  // The amount of space between runs.
  runSpacing: 4,
  children: <Widget>[...],
  builder: (context, remaining) => Text('+$remaining'),
)
```

Both constructors support runs.

### Right-to-left

The children are laid out according to the ambient `Directionality`: in a right-to-left context, they go from right to left and the overflow indicator is on the left. You can override it with `textDirection`. Without any `Directionality`, the children go from left to right.

## Sponsoring

I'm working on my packages on my free-time, but I don't have as much time as I would. If this package or any other package I created is helping you, please consider to sponsor me. By doing so, I will prioritize your issues or your pull-requests before the others. 

## Changelog

Please see the [Changelog][changelog] page to know what's recently changed.

## Contributions

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue][issue].  
If you fixed a bug or implemented a feature, please send a [pull request][pr].

<!--Links-->
[pub]: https://pub.dartlang.org/packages/overflow_view
[changelog]: https://github.com/letsar/overflow_view/blob/master/CHANGELOG.md
[issue]: https://github.com/letsar/overflow_view/issues
[pr]: https://github.com/letsar/overflow_view/pulls
[overview]: https://raw.githubusercontent.com/letsar/overflow_view/master/packages/images/overflow_view.gif