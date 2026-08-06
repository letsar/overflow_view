import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:overflow_view/overflow_view.dart';

void main() {

  testWidgets(
    'the overflow indicator is not built if there is enough room (except for flexible)',
    (tester) async {
      int buildCount = 0;
      await tester.pumpWidget(
        Center(
          child: SizedBox(
            width: 100,
            child: OverflowView(
              builder: (context, count) {
                buildCount++;
                return const SizedBox();
              },
              children: [const SizedBox(width: 100)],
            ),
          ),
        ),
      );
      expect(buildCount, 0);

      await tester.pumpWidget(
        Center(
          child: SizedBox(
            width: 100,
            child: OverflowView.flexible(
              builder: (context, count) {
                buildCount++;
                return const SizedBox();
              },
              children: [const SizedBox(width: 100)],
            ),
          ),
        ),
      );
      expect(buildCount, 1);
    },
  );

  testWidgets(
    'the overflow indicator is built if there is not enough room',
    (tester) async {
      int buildCount = 0;
      late int remainingCount;
      await tester.pumpWidget(
        Center(
          child: SizedBox(
            width: 100,
            child: OverflowView(
              builder: (context, count) {
                buildCount++;
                remainingCount = count;
                return const SizedBox();
              },
              children: [
                const SizedBox(width: 50),
                const SizedBox(width: 50),
                const SizedBox(width: 50),
                const SizedBox(width: 50),
              ],
            ),
          ),
        ),
      );
      expect(buildCount, 1);
      expect(remainingCount, 3);

      buildCount = 0;

      await tester.pumpWidget(
        Center(
          child: SizedBox(
            width: 100,
            child: OverflowView.flexible(
              builder: (context, count) {
                buildCount++;
                remainingCount = count;
                return const SizedBox(width: 30);
              },
              children: [
                const SizedBox(width: 50),
                const SizedBox(width: 20),
                const SizedBox(width: 50),
                const SizedBox(width: 50),
              ],
            ),
          ),
        ),
      );
      expect(buildCount, 1);
      expect(remainingCount, 2);
    },
  );

  testWidgets(
    'children are layed out according to direction',
    (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 100,
              width: 100,
              child: OverflowView(
                builder: (context, count) {
                  return const SizedBox();
                },
                children: [
                  const _Text('A'),
                  const _Text('B'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.getTopLeft(find.text('A')), const Offset(0, 0));
      expect(tester.getTopLeft(find.text('B')), const Offset(50, 0));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 100,
              width: 100,
              child: OverflowView(
                direction: Axis.vertical,
                builder: (context, count) {
                  return const SizedBox();
                },
                children: [
                  const _Text('A'),
                  const _Text('B'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.getTopLeft(find.text('A')), const Offset(0, 0));
      expect(tester.getTopLeft(find.text('B')), const Offset(0, 50));
    },
  );

  testWidgets(
    'children are layed out according to direction and spacing',
    (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 110,
              width: 110,
              child: OverflowView(
                spacing: 10,
                builder: (context, count) {
                  return const SizedBox();
                },
                children: [
                  const _Text('A'),
                  const _Text('B'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.getTopLeft(find.text('A')), const Offset(0, 0));
      expect(tester.getTopLeft(find.text('B')), const Offset(60, 0));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 110,
              width: 110,
              child: OverflowView(
                spacing: 10,
                direction: Axis.vertical,
                builder: (context, count) {
                  return const SizedBox();
                },
                children: [
                  const _Text('A'),
                  const _Text('B'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.getTopLeft(find.text('A')), const Offset(0, 0));
      expect(tester.getTopLeft(find.text('B')), const Offset(0, 60));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 110,
              width: 110,
              child: OverflowView.flexible(
                spacing: 10,
                builder: (context, count) {
                  return const SizedBox();
                },
                children: [
                  const _Text('A'),
                  const _Text('B'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.getTopLeft(find.text('A')), const Offset(0, 0));
      expect(tester.getTopLeft(find.text('B')), const Offset(60, 0));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 110,
              width: 110,
              child: OverflowView.flexible(
                spacing: 10,
                direction: Axis.vertical,
                builder: (context, count) {
                  return const SizedBox();
                },
                children: [
                  const _Text('A'),
                  const _Text('B'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.getTopLeft(find.text('A')), const Offset(0, 0));
      expect(tester.getTopLeft(find.text('B')), const Offset(0, 60));
    },
  );

  testWidgets(
    'spacing can be negative for overlapping effect',
    (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 110,
              width: 110,
              child: OverflowView(
                spacing: -10,
                builder: (context, count) {
                  return const SizedBox();
                },
                children: [
                  const _Text('A'),
                  const _Text('B'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.getTopLeft(find.text('A')), const Offset(0, 0));
      expect(tester.getTopLeft(find.text('B')), const Offset(40, 0));
    },
  );

  testWidgets(
    'OverflowView.flexible should build builder twice if there is not enough room for it the first time',
    (tester) async {
      int buildCount = 0;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 150,
              width: 150,
              child: OverflowView.flexible(
                builder: (context, count) {
                  buildCount++;
                  return const SizedBox(
                    width: 100,
                  );
                },
                children: [
                  const _Text('A'),
                  const _Text('B'),
                  const _Text('C'),
                  const _Text('D'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(buildCount, 2);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsNothing);
      expect(find.text('C'), findsNothing);
      expect(find.text('E'), findsNothing);
    },
  );

  testWidgets(
    'unmount successfully the overflow indicator once it has already been laid '
    'out with .flexible()',
    (tester) async {
      await tester.pumpWidget(
        Center(
          child: SizedBox(
            width: 100,
            child: OverflowView.flexible(
              builder: (context, count) {
                return const SizedBox(width: 30);
              },
              children: [
                const SizedBox(width: 50),
                const SizedBox(width: 20),
                const SizedBox(width: 50),
                const SizedBox(width: 50),
              ],
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        Center(
          child: SizedBox(
            width: 100,
            child: OverflowView.flexible(
              builder: (context, count) {
                return const SizedBox(width: 30);
              },
              children: [
                const SizedBox(width: 50),
              ],
            ),
          ),
        ),
      );
    },
  );

  group('hit test', () {
    testWidgets(
      'a tap on a child is dispatched to an enclosing GestureDetector',
      (tester) async {
        int tapCount = 0;
        await tester.pumpWidget(
          _boilerplate(
            width: 100,
            height: 100,
            onTap: () => tapCount++,
            child: OverflowView(
              builder: (context, count) {
                return const SizedBox();
              },
              children: [
                const _Text('A'),
                const _Text('B'),
              ],
            ),
          ),
        );

        await tester.tap(find.text('A'));
        expect(tapCount, 1);

        await tester.tap(find.text('B'));
        expect(tapCount, 2);
      },
    );

    testWidgets(
      'a tap on a child of OverflowView.flexible is dispatched to an enclosing '
      'GestureDetector',
      (tester) async {
        int tapCount = 0;
        await tester.pumpWidget(
          _boilerplate(
            width: 100,
            height: 100,
            onTap: () => tapCount++,
            child: OverflowView.flexible(
              builder: (context, count) {
                return const SizedBox();
              },
              children: [
                const _Text('A'),
                const _Text('B'),
              ],
            ),
          ),
        );

        await tester.tap(find.text('A'));
        expect(tapCount, 1);
      },
    );

    testWidgets(
      'a tap on the overflow indicator is dispatched to it',
      (tester) async {
        int tapCount = 0;
        await tester.pumpWidget(
          _boilerplate(
            width: 100,
            height: 100,
            child: OverflowView(
              builder: (context, count) {
                return GestureDetector(
                  onTap: () => tapCount++,
                  child: const _Text('+'),
                );
              },
              children: [
                const _Text('A'),
                const _Text('B'),
                const _Text('C'),
              ],
            ),
          ),
        );

        await tester.tap(find.text('+'));
        expect(tapCount, 1);
      },
    );

    testWidgets(
      'a tap on an area without any onstage child is not dispatched to an '
      'enclosing GestureDetector',
      (tester) async {
        int tapCount = 0;
        await tester.pumpWidget(
          _boilerplate(
            width: 110,
            height: 110,
            onTap: () => tapCount++,
            child: OverflowView(
              spacing: 10,
              builder: (context, count) {
                return const SizedBox();
              },
              children: [
                const _Text('A'),
                const _Text('B'),
              ],
            ),
          ),
        );

        // The children are 50x50. 'A' is at (0, 0) and 'B' is at (60, 0). The
        // OverflowView itself is 110x110, so these two points are inside it,
        // but outside of any child.
        await tester.tapAt(const Offset(55, 25));
        expect(tapCount, 0);

        await tester.tapAt(const Offset(25, 80));
        expect(tapCount, 0);
      },
    );

    testWidgets(
      'a tap on overlapping children is dispatched to the topmost one',
      (tester) async {
        final List<String> tappedChildren = <String>[];
        Widget buildChild(String text) {
          return GestureDetector(
            onTap: () => tappedChildren.add(text),
            child: _Text(text),
          );
        }

        await tester.pumpWidget(
          _boilerplate(
            width: 110,
            height: 110,
            child: OverflowView(
              spacing: -10,
              builder: (context, count) {
                return const SizedBox();
              },
              children: [
                buildChild('A'),
                buildChild('B'),
              ],
            ),
          ),
        );

        // The children are 50x50. 'A' is at (0, 0) and 'B' is at (40, 0), so
        // they overlap between x = 40 and x = 50. 'B' is painted after 'A', so
        // it is on top.
        await tester.tapAt(const Offset(45, 25));
        expect(tappedChildren, ['B']);
      },
    );

    testWidgets(
      'a tap on an offstage child is not dispatched to it',
      (tester) async {
        int tapCount = 0;
        await tester.pumpWidget(
          _boilerplate(
            width: 100,
            height: 100,
            child: OverflowView(
              builder: (context, count) {
                return const _Text('+');
              },
              children: [
                const _Text('A'),
                GestureDetector(
                  onTap: () => tapCount++,
                  child: const _Text('B'),
                ),
                const _Text('C'),
              ],
            ),
          ),
        );

        // 'B' is offstage, so it is painted at the bottom right corner of the
        // OverflowView. A tap there must not reach it.
        await tester.tapAt(const Offset(99, 99));
        expect(tapCount, 0);
      },
    );
  });
}

Widget _boilerplate({
  required double width,
  required double height,
  required Widget child,
  VoidCallback? onTap,
}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Align(
      alignment: Alignment.topLeft,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: height,
          child: child,
        ),
      ),
    ),
  );
}

class _Text extends StatelessWidget {
  const _Text(
    this.text, {
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 50,
      child: Text(text),
    );
  }
}
