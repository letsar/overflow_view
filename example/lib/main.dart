import 'package:flutter/material.dart';
import 'package:overflow_view/overflow_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Avatar {
  const Avatar(this.initials, this.color);
  final String initials;
  final Color color;
}

const List<Avatar> avatars = <Avatar>[
  Avatar('AD', Colors.green),
  Avatar('JG', Colors.pink),
  Avatar('DA', Colors.blue),
  Avatar('JA', Colors.black),
  Avatar('CB', Colors.amber),
  Avatar('RR', Colors.deepPurple),
  Avatar('JD', Colors.pink),
  Avatar('MB', Colors.amberAccent),
  Avatar('AA', Colors.blueAccent),
  Avatar('BA', Colors.tealAccent),
  Avatar('CR', Colors.yellow),
  Avatar('LM', Colors.orange),
  Avatar('PT', Colors.indigo),
  Avatar('SG', Colors.cyan),
  Avatar('EV', Colors.brown),
  Avatar('NB', Colors.lime),
];

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 1;
  double ratio = 1;
  int maxRuns = 1;
  double spacing = -40;
  double runSpacing = 4;
  bool rtl = false;

  void _incrementCounter() {
    setState(() {
      _counter = (_counter + 1).clamp(0, avatars.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Text('RTL'),
          Switch(
            value: rtl,
            onChanged: (value) => setState(() {
              rtl = value;
            }),
          ),
        ],
      ),
      body: Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'People',
                  style: TextStyle(fontSize: 20),
                ),
                _SliderRow(
                  label: 'Runs: $maxRuns',
                  value: maxRuns.toDouble(),
                  min: 1,
                  max: 3,
                  onChanged: (value) => setState(() {
                    maxRuns = value.round();
                  }),
                ),
                _SliderRow(
                  label: 'Spacing: ${spacing.round()}',
                  value: spacing,
                  min: -40,
                  max: 20,
                  onChanged: (value) => setState(() {
                    spacing = value;
                  }),
                ),
                _SliderRow(
                  label: 'Run spacing: ${runSpacing.round()}',
                  value: runSpacing,
                  min: -40,
                  max: 20,
                  onChanged: (value) => setState(() {
                    runSpacing = value;
                  }),
                ),
                SizedBox(height: 12),
                OverflowView.flexible(
                  maxRuns: maxRuns,
                  spacing: spacing,
                  runSpacing: runSpacing,
                  children: <Widget>[
                    for (int i = 0; i < _counter; i++)
                      AvatarWidget(
                        text: avatars[i].initials,
                        color: avatars[i].color,
                      )
                  ],
                  builder: (context, remaining) {
                    return AvatarWidget(
                      text: '+$remaining',
                      color: Colors.red,
                    );
                  },
                ),
                SizedBox(height: 20),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: CommandBar(),
                ),
                SizedBox(height: 20),
                Breadcrumb(),
                SizedBox(height: 20),
                Expanded(
                  child: OverflowView(
                    direction: Axis.vertical,
                    spacing: 4,
                    children: <Widget>[
                      for (int i = 0; i < _counter; i++)
                        AvatarWidget(
                          text: avatars[i].initials,
                          color: avatars[i].color,
                        )
                    ],
                    builder: (context, remaining) {
                      return SizedBox(
                        height: 80,
                        width: 80,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (remaining > 0)
                              AvatarOverview(
                                position: 0,
                                remaining: remaining,
                                counter: _counter,
                              ),
                            if (remaining > 1)
                              AvatarOverview(
                                position: 1,
                                remaining: remaining,
                                counter: _counter,
                              ),
                            if (remaining > 2)
                              AvatarOverview(
                                position: 2,
                                remaining: remaining,
                                counter: _counter,
                              ),
                            if (remaining > 3)
                              AvatarOverview(
                                position: 3,
                                remaining: remaining,
                                counter: _counter,
                              ),
                            Positioned.fill(
                              child: Center(
                                child: FractionallySizedBox(
                                  alignment: Alignment.center,
                                  widthFactor: 0.5,
                                  heightFactor: 0.5,
                                  child: FittedBox(
                                    child: AvatarWidget(
                                      text: '+$remaining',
                                      color:
                                          Colors.black.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Slider(
                //   value: ratio,
                //   min: 0,
                //   max: 1,
                //   divisions: 100,
                //   onChanged: (value) {
                //     setState(() {
                //       ratio = value;
                //     });
                //   },
                // ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    Key? key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  }) : super(key: key);

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class AvatarOverview extends StatelessWidget {
  AvatarOverview({
    Key? key,
    required int remaining,
    required int position,
    required int counter,
  })  : index = counter - remaining + position,
        alignment = _getAlignment(position),
        super(key: key);

  final int index;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final Avatar avatar = avatars[index];
    return FractionallySizedBox(
      key: ValueKey(index),
      alignment: alignment,
      widthFactor: 0.5,
      heightFactor: 0.5,
      child: FittedBox(
        child: AvatarWidget(
          text: avatar.initials,
          color: avatar.color,
        ),
      ),
    );
  }

  static Alignment _getAlignment(int position) {
    switch (position) {
      case 0:
        return Alignment.topLeft;
      case 1:
        return Alignment.topRight;
      case 2:
        return Alignment.bottomLeft;
      default:
        return Alignment.bottomRight;
    }
  }
}

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    Key? key,
    required this.text,
    required this.color,
  }) : super(key: key);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 40,
      backgroundColor: color,
      foregroundColor: Colors.white,
      child: Text(
        text,
        style: TextStyle(fontSize: 30),
      ),
    );
  }
}

class CommandBar extends StatelessWidget {
  const CommandBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<MenuItemData> commands = <MenuItemData>[
      MenuItemData(id: 'a', label: 'File'),
      MenuItemData(id: 'b', icon: Icons.save, label: 'Save'),
      MenuItemData(id: 'c', label: 'Edit'),
      MenuItemData(id: 'd', label: 'View'),
      MenuItemData(id: 'e', icon: Icons.exit_to_app),
      MenuItemData(id: 'f', label: 'Long Command'),
      MenuItemData(id: 'f', label: 'Very Long Command'),
      MenuItemData(id: 'f', label: 'Very very Long Command'),
      MenuItemData(id: 'f', label: 'Help'),
    ];

    return OverflowView.flexible(
      spacing: -4,
      children: [...commands.map((e) => _MenuItem(data: e))],
      builder: (context, remaining) {
        return PopupMenuButton<String>(
          icon: Icon(Icons.menu),
          itemBuilder: (context) {
            return commands
                .skip(commands.length - remaining)
                .map((e) => PopupMenuItem<String>(
                      value: e.id,
                      child: _MenuItem(data: e),
                    ))
                .toList();
          },
        );
      },
    );
  }
}

class MenuItemData {
  const MenuItemData({
    required this.id,
    this.label,
    this.icon,
  });

  final String id;
  final String? label;
  final IconData? icon;
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    Key? key,
    required this.data,
  }) : super(key: key);

  final MenuItemData data;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      child: Row(
        children: [
          if (data.icon != null) Icon(data.icon),
          if (data.icon != null && data.label != null) SizedBox(width: 8),
          if (data.label != null) Text(data.label!),
        ],
      ),
    );
  }
}

class Breadcrumb extends StatefulWidget {
  const Breadcrumb({Key? key}) : super(key: key);

  @override
  State<Breadcrumb> createState() => _BreadcrumbState();
}

class _BreadcrumbState extends State<Breadcrumb> {
  static const List<String> path = <String>[
    'Home',
    'Documents',
    'Projects',
    'Flutter',
    'overflow_view',
    'lib',
    'src',
  ];

  bool hideFirst = true;
  double widthPercent = 70;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Breadcrumb', style: TextStyle(fontSize: 20)),
            Spacer(),
            Text('Hide first items'),
            Switch(
              value: hideFirst,
              onChanged: (value) => setState(() {
                hideFirst = value;
              }),
            ),
          ],
        ),
        _SliderRow(
          label: 'Width: ${widthPercent.round()}%',
          value: widthPercent,
          min: 20,
          max: 100,
          onChanged: (value) => setState(() {
            widthPercent = value;
          }),
        ),
        FractionallySizedBox(
          widthFactor: widthPercent / 100,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
            ),
            // Lets the OverflowView be as wide as its children.
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: hideFirst ? _buildHidingFirst() : _buildHidingLast(),
            ),
          ),
        ),
      ],
    );
  }

  /// The default behavior: the last items are hidden.
  Widget _buildHidingLast() {
    return OverflowView.flexible(
      spacing: 4,
      children: <Widget>[
        for (final String item in path) Chip(label: Text(item)),
      ],
      builder: (context, remaining) {
        return _Indicator(hiddenItems: path.skip(path.length - remaining));
      },
    );
  }

  /// The first items are hidden by reversing both the children and the text
  /// direction.
  Widget _buildHidingFirst() {
    final TextDirection textDirection = Directionality.of(context);
    return OverflowView.flexible(
      textDirection: textDirection == TextDirection.ltr
          ? TextDirection.rtl
          : TextDirection.ltr,
      spacing: 4,
      children: <Widget>[
        for (final String item in path.reversed) Chip(label: Text(item)),
      ],
      builder: (context, remaining) {
        return _Indicator(hiddenItems: path.take(remaining));
      },
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({Key? key, required this.hiddenItems}) : super(key: key);

  final Iterable<String> hiddenItems;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Hidden items',
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        for (final String item in hiddenItems)
          PopupMenuItem<String>(value: item, child: Text(item)),
      ],
      child: Chip(
        backgroundColor: Colors.red.shade100,
        label: Text('+${hiddenItems.length}'),
      ),
    );
  }
}
