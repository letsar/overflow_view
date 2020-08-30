# overflow_view
A widget displaying children in a line with an overflow indicator at the end if there is not enough space.

[![Pub](https://img.shields.io/pub/v/overflow_view.svg)][pub]

## Features
* Renders children horizontally or vertically.
* Has an overflow indicator builder so that you can display a widget showing the number of elements not rendered.

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