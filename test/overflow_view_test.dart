import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overflow_view/overflow_view.dart';

void main() {
  testWidgets(
    'the overflow indicator is not built if there is enough room and max count is not set',
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
      expect(buildCount, 0);
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

  group('maxCount', () {
    testWidgets(
      'the overflow indicator is not built if there is enough room and max count is set to something higher than the child count',
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
                maxCount: 5,
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
                maxCount: 5,
                children: [const SizedBox(width: 100)],
              ),
            ),
          ),
        );
        expect(buildCount, 0);
      },
    );

    testWidgets(
      'the overflow indicator is built if there is not enough room and max count is higher than the number of children that can be fit',
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
                maxCount: 3,
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
                maxCount: 5,
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
      'the overflow indicator is built if max count is reached despite having sufficient room for more children',
      (tester) async {
        int buildCount = 0;
        late int remainingCount;
        await tester.pumpWidget(
          Center(
            child: SizedBox(
              width: 1000,
              child: OverflowView(
                builder: (context, count) {
                  buildCount++;
                  remainingCount = count;
                  return const SizedBox();
                },
                maxCount: 2,
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
        expect(remainingCount, 2);

        buildCount = 0;

        await tester.pumpWidget(
          Center(
            child: SizedBox(
              width: 1000,
              child: OverflowView.flexible(
                builder: (context, count) {
                  buildCount++;
                  remainingCount = count;
                  return const SizedBox(width: 30);
                },
                maxCount: 2,
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
      'the overflow indicator is not built if max count is zero and there are no children',
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
                maxCount: 0,
                children: [],
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
                  return const SizedBox(width: 30);
                },
                maxCount: 0,
                children: [],
              ),
            ),
          ),
        );
        expect(buildCount, 0);
      },
    );

    testWidgets(
      'the overflow indicator is built if max count is zero and there is more than one child',
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
                maxCount: 0,
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
        expect(remainingCount, 4);

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
                maxCount: 0,
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
        expect(remainingCount, 4);
      },
    );

    testWidgets(
      'the layout is updated when maxCount changes',
      (tester) async {
        Widget build(int maxCount) {
          return _boilerplate(
            width: 200,
            height: 100,
            child: OverflowView(
              maxCount: maxCount,
              builder: (context, count) {
                return const _Text('+');
              },
              children: [
                const _Text('A'),
                const _Text('B'),
                const _Text('C'),
              ],
            ),
          );
        }

        await tester.pumpWidget(build(2));
        expect(find.text('C'), findsNothing);

        await tester.pumpWidget(build(3));
        expect(tester.getTopLeft(find.text('C')), const Offset(100, 0));
      },
    );
  });

  group('runs', () {
    testWidgets(
      'children are laid out in several runs when maxRuns is greater than 1',
      (tester) async {
        int buildCount = 0;
        await tester.pumpWidget(
          _boilerplate(
            width: 100,
            height: 200,
            child: Align(
              alignment: Alignment.topLeft,
              child: OverflowView(
                maxRuns: 2,
                builder: (context, count) {
                  buildCount++;
                  return const SizedBox();
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
        );

        expect(buildCount, 0);
        expect(tester.getTopLeft(find.text('A')), const Offset(0, 0));
        expect(tester.getTopLeft(find.text('B')), const Offset(50, 0));
        expect(tester.getTopLeft(find.text('C')), const Offset(0, 50));
        expect(tester.getTopLeft(find.text('D')), const Offset(50, 50));
        expect(tester.getSize(find.byType(OverflowView)), const Size(100, 100));
      },
    );

    testWidgets(
      'the overflow indicator is at the end of the last run',
      (tester) async {
        int buildCount = 0;
        late int remainingCount;
        await tester.pumpWidget(
          _boilerplate(
            width: 100,
            height: 200,
            child: OverflowView(
              maxRuns: 2,
              builder: (context, count) {
                buildCount++;
                remainingCount = count;
                return const _Text('+');
              },
              children: [
                const _Text('A'),
                const _Text('B'),
                const _Text('C'),
                const _Text('D'),
                const _Text('E'),
              ],
            ),
          ),
        );

        expect(buildCount, 1);
        expect(remainingCount, 2);
        expect(find.text('D'), findsNothing);
        expect(find.text('E'), findsNothing);
        expect(tester.getTopLeft(find.text('C')), const Offset(0, 50));
        expect(tester.getTopLeft(find.text('+')), const Offset(50, 50));
      },
    );

    testWidgets(
      'runs are separated by runSpacing and children by spacing',
      (tester) async {
        await tester.pumpWidget(
          _boilerplate(
            width: 100,
            height: 200,
            child: Align(
              alignment: Alignment.topLeft,
              child: OverflowView.flexible(
                maxRuns: 2,
                spacing: 10,
                runSpacing: 5,
                builder: (context, count) {
                  return const SizedBox();
                },
                children: [
                  const _Text('A', width: 40),
                  const _Text('B', width: 40),
                  const _Text('C', width: 40),
                ],
              ),
            ),
          ),
        );

        // 'C' would end at 40 + 10 + 40 + 10 + 40 = 140, so it starts a new
        // run.
        expect(tester.getTopLeft(find.text('A')), const Offset(0, 0));
        expect(tester.getTopLeft(find.text('B')), const Offset(50, 0));
        expect(tester.getTopLeft(find.text('C')), const Offset(0, 55));
        expect(tester.getSize(find.byType(OverflowView)), const Size(90, 105));
      },
    );

    testWidgets(
      'children are centered in the cross axis of their run',
      (tester) async {
        await tester.pumpWidget(
          _boilerplate(
            width: 100,
            height: 200,
            child: OverflowView.flexible(
              maxRuns: 2,
              builder: (context, count) {
                return const SizedBox();
              },
              children: [
                const _Text('A', height: 20),
                const _Text('B', height: 40),
                const _Text('C', height: 10),
                const _Text('D', height: 30),
              ],
            ),
          ),
        );

        expect(tester.getTopLeft(find.text('A')), const Offset(0, 10));
        expect(tester.getTopLeft(find.text('B')), const Offset(50, 0));
        expect(tester.getTopLeft(find.text('C')), const Offset(0, 50));
        expect(tester.getTopLeft(find.text('D')), const Offset(50, 40));
      },
    );

    testWidgets(
      'the overflow indicator uses the free space at the end of the last run',
      (tester) async {
        late int remainingCount;
        await tester.pumpWidget(
          _boilerplate(
            width: 100,
            height: 200,
            child: OverflowView.flexible(
              maxRuns: 2,
              builder: (context, count) {
                remainingCount = count;
                return const _Text('+', width: 10);
              },
              children: [
                for (final String text in ['A', 'B', 'C', 'D', 'E', 'F', 'G'])
                  _Text(text, width: 30),
              ],
            ),
          ),
        );

        expect(remainingCount, 1);
        expect(find.text('F'), findsOneWidget);
        expect(tester.getTopLeft(find.text('+')), const Offset(90, 50));
      },
    );

    testWidgets(
      'only the children of the last run are hidden to make room for the '
      'overflow indicator',
      (tester) async {
        late int remainingCount;
        await tester.pumpWidget(
          _boilerplate(
            width: 100,
            height: 200,
            child: OverflowView.flexible(
              maxRuns: 2,
              builder: (context, count) {
                remainingCount = count;
                return const _Text('+', width: 50);
              },
              children: [
                for (final String text in ['A', 'B', 'C', 'D', 'E', 'F', 'G'])
                  _Text(text, width: 30),
              ],
            ),
          ),
        );

        expect(remainingCount, 3);
        expect(find.text('C'), findsOneWidget);
        expect(find.text('D'), findsOneWidget);
        expect(find.text('E'), findsNothing);
        expect(tester.getTopLeft(find.text('+')), const Offset(30, 50));
      },
    );

    testWidgets(
      'hitting max count ends the layout',
      (tester) async {
        int buildCount = 0;
        await tester.pumpWidget(
          _boilerplate(
            width: 100,
            height: 200,
            child: Align(
              alignment: Alignment.topLeft,
              child: OverflowView(
                maxRuns: 2,
                builder: (context, count) {
                  buildCount++;
                  return const SizedBox();
                },
                maxCount: 3,
                children: [
                  const _Text('A'),
                  const _Text('B'),
                  const _Text('C'),
                  const _Text('D'),
                ],
              ),
            ),
          ),
        );

        expect(buildCount, 1);
        expect(tester.getTopLeft(find.text('A')), const Offset(0, 0));
        expect(tester.getTopLeft(find.text('B')), const Offset(50, 0));
        expect(tester.getTopLeft(find.text('C')), const Offset(0, 50));
        expect(find.text('D'), findsNothing);
        expect(tester.getSize(find.byType(OverflowView)), const Size(100, 100));
      },
    );

    testWidgets(
      'a child which does not fit in an empty run ends the layout',
      (tester) async {
        late int remainingCount;
        await tester.pumpWidget(
          _boilerplate(
            width: 100,
            height: 200,
            child: OverflowView.flexible(
              maxRuns: 3,
              builder: (context, count) {
                remainingCount = count;
                return const _Text('+');
              },
              children: [
                const _Text('A'),
                const _Text('B', width: 200),
                const _Text('C'),
              ],
            ),
          ),
        );

        expect(remainingCount, 2);
        expect(find.text('C'), findsNothing);
        expect(tester.getTopLeft(find.text('+')), const Offset(50, 0));
      },
    );

    testWidgets(
      'children are laid out in columns when the direction is vertical',
      (tester) async {
        await tester.pumpWidget(
          _boilerplate(
            width: 200,
            height: 100,
            child: OverflowView(
              direction: Axis.vertical,
              maxRuns: 2,
              runSpacing: 10,
              builder: (context, count) {
                return const SizedBox();
              },
              children: [
                const _Text('A'),
                const _Text('B'),
                const _Text('C'),
              ],
            ),
          ),
        );

        expect(tester.getTopLeft(find.text('A')), const Offset(0, 0));
        expect(tester.getTopLeft(find.text('B')), const Offset(0, 50));
        expect(tester.getTopLeft(find.text('C')), const Offset(60, 0));
      },
    );

    testWidgets(
      'the layout is updated when maxRuns changes',
      (tester) async {
        Widget build(int maxRuns) {
          return _boilerplate(
            width: 100,
            height: 200,
            child: OverflowView(
              maxRuns: maxRuns,
              builder: (context, count) {
                return const _Text('+');
              },
              children: [
                const _Text('A'),
                const _Text('B'),
                const _Text('C'),
              ],
            ),
          );
        }

        await tester.pumpWidget(build(1));
        expect(find.text('C'), findsNothing);

        await tester.pumpWidget(build(2));
        expect(tester.getTopLeft(find.text('C')), const Offset(0, 50));
      },
    );
  });

  testWidgets(
    'children which exactly fill the available space are all displayed',
    (tester) async {
      // 100 / 6 can't be represented exactly, so the sum of the children
      // widths is slightly greater than 100.
      const double width = 100 / 6;
      for (final bool flexible in [false, true]) {
        int buildCount = 0;
        final List<Widget> children = [
          for (final String text in ['A', 'B', 'C', 'D', 'E', 'F', 'G'])
            _Text(text, width: width),
        ];
        Widget builder(BuildContext context, int count) {
          buildCount++;
          return const SizedBox();
        }

        await tester.pumpWidget(
          _boilerplate(
            width: 100,
            height: 200,
            child: flexible
                ? OverflowView.flexible(
                    maxRuns: 2,
                    builder: builder,
                    children: children,
                  )
                : OverflowView(
                    maxRuns: 2,
                    builder: builder,
                    children: children,
                  ),
          ),
        );

        expect(buildCount, 0, reason: 'flexible: $flexible');
        expect(tester.getTopLeft(find.text('F')).dy, 0);
        expect(tester.getTopLeft(find.text('G')), const Offset(0, 50));
      }
    },
  );

  testWidgets(
    'OverflowView never builds the overflow indicator with no remaining '
    'children, even if it has already been built',
    (tester) async {
      final List<int> counts = <int>[];
      Widget build(int childCount) {
        return Center(
          child: SizedBox(
            width: 100,
            child: OverflowView(
              builder: (context, count) {
                counts.add(count);
                return const SizedBox();
              },
              children: [
                for (int i = 0; i < childCount; i++) const SizedBox(width: 50),
              ],
            ),
          ),
        );
      }

      await tester.pumpWidget(build(3));
      await tester.pumpWidget(build(2));
      await tester.pumpWidget(const SizedBox());

      expect(counts, isNot(contains(0)));
    },
  );

  testWidgets(
    'children are clipped only when they paint outside of the OverflowView',
    (tester) async {
      Future<RenderObject> pump({
        double spacing = 0,
        double runSpacing = 0,
        int maxRuns = 1,
      }) async {
        await tester.pumpWidget(
          _boilerplate(
            width: 200,
            height: 200,
            child: Align(
              alignment: Alignment.topLeft,
              child: OverflowView.flexible(
                spacing: spacing,
                runSpacing: runSpacing,
                maxRuns: maxRuns,
                builder: (context, count) {
                  return const SizedBox();
                },
                children: [
                  const _Text('A', width: 150),
                  const _Text('B', width: 100),
                ],
              ),
            ),
          ),
        );
        return tester.renderObject(find.byType(OverflowView));
      }

      expect(await pump(spacing: 10, maxRuns: 2), isNot(paints..clipRect()));

      // 'B' ends at 150 - 145 + 100 = 105, so the OverflowView is 105 wide,
      // but 'A' is 150 wide.
      expect(await pump(spacing: -145), paints..clipRect());

      // 'B' is in a second run which starts at 50 - 60 = -10.
      expect(
        await pump(runSpacing: -60, maxRuns: 2),
        paints..clipRect(),
      );
    },
  );

  testWidgets(
    'switching between OverflowView.flexible and OverflowView works',
    (tester) async {
      Widget build({required bool flexible, required int childCount}) {
        final List<Widget> children = [
          for (int i = 0; i < childCount; i++) const SizedBox(width: 50),
        ];
        // The indicator is updated when switching, so it needs a new layout.
        Widget builder(BuildContext context, int count) {
          return SizedBox(width: flexible ? 50 : 51);
        }

        return Center(
          child: SizedBox(
            width: 100,
            child: flexible
                ? OverflowView.flexible(builder: builder, children: children)
                : OverflowView(builder: builder, children: children),
          ),
        );
      }

      await tester.pumpWidget(build(flexible: true, childCount: 3));
      await tester.pumpWidget(build(flexible: false, childCount: 2));
      await tester.pumpWidget(build(flexible: false, childCount: 2));
      await tester.pumpWidget(const SizedBox());

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'the overflow indicator counts all the children when the first one does '
    'not fit',
    (tester) async {
      late int remainingCount;
      await tester.pumpWidget(
        _boilerplate(
          width: 100,
          height: 100,
          child: OverflowView(
            builder: (context, count) {
              remainingCount = count;
              return const SizedBox();
            },
            children: [
              const SizedBox(width: 150),
              const SizedBox(width: 150),
            ],
          ),
        ),
      );

      expect(remainingCount, 2);
    },
  );

  testWidgets(
    'the overflow indicator is positioned with its size for the final count',
    (tester) async {
      await tester.pumpWidget(
        _boilerplate(
          width: 100,
          height: 100,
          child: OverflowView.flexible(
            builder: (context, count) {
              return _Text('+', width: count >= 3 ? 70 : 40);
            },
            children: [
              for (final String text in ['A', 'B', 'C', 'D', 'E'])
                _Text(text, width: 30),
            ],
          ),
        ),
      );

      // With 2 hidden children, the 40 wide indicator fits after 'A' and 'B',
      // but then it has to show 3 hidden children and becomes 70 wide.
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsNothing);
      expect(tester.getTopLeft(find.text('+')), const Offset(30, 0));
    },
  );

  group('text direction', () {
    testWidgets(
      'children are laid out from right to left in RTL',
      (tester) async {
        await tester.pumpWidget(
          _boilerplate(
            width: 100,
            height: 100,
            textDirection: TextDirection.rtl,
            child: OverflowView(
              builder: (context, count) {
                return const _Text('+');
              },
              children: [
                const _Text('A'),
                const _Text('B'),
                const _Text('C'),
              ],
            ),
          ),
        );

        expect(tester.getTopLeft(find.text('A')), const Offset(50, 0));
        expect(find.text('B'), findsNothing);
        expect(tester.getTopLeft(find.text('+')), const Offset(0, 0));
      },
    );

    testWidgets(
      'children of OverflowView.flexible are laid out from right to left in '
      'RTL',
      (tester) async {
        await tester.pumpWidget(
          _boilerplate(
            width: 100,
            height: 100,
            textDirection: TextDirection.rtl,
            child: OverflowView.flexible(
              spacing: 10,
              builder: (context, count) {
                return const _Text('+', width: 20);
              },
              children: [
                const _Text('A', width: 30),
                const _Text('B', width: 40),
                const _Text('C', width: 40),
              ],
            ),
          ),
        );

        // There is no room for the indicator after 'B', so 'B' is hidden.
        expect(tester.getTopLeft(find.text('A')), const Offset(70, 0));
        expect(find.text('B'), findsNothing);
        expect(tester.getTopLeft(find.text('+')), const Offset(40, 0));
      },
    );

    testWidgets(
      'runs are laid out from right to left in RTL',
      (tester) async {
        await tester.pumpWidget(
          _boilerplate(
            width: 100,
            height: 200,
            textDirection: TextDirection.rtl,
            child: OverflowView(
              maxRuns: 2,
              builder: (context, count) {
                return const SizedBox();
              },
              children: [
                const _Text('A'),
                const _Text('B'),
                const _Text('C'),
              ],
            ),
          ),
        );

        expect(tester.getTopLeft(find.text('A')), const Offset(50, 0));
        expect(tester.getTopLeft(find.text('B')), const Offset(0, 0));
        expect(tester.getTopLeft(find.text('C')), const Offset(50, 50));
      },
    );

    testWidgets(
      'vertical runs are laid out from right to left in RTL',
      (tester) async {
        await tester.pumpWidget(
          _boilerplate(
            width: 200,
            height: 100,
            textDirection: TextDirection.rtl,
            child: OverflowView(
              direction: Axis.vertical,
              maxRuns: 2,
              runSpacing: 10,
              builder: (context, count) {
                return const SizedBox();
              },
              children: [
                const _Text('A'),
                const _Text('B'),
                const _Text('C'),
              ],
            ),
          ),
        );

        expect(tester.getTopLeft(find.text('A')), const Offset(150, 0));
        expect(tester.getTopLeft(find.text('B')), const Offset(150, 50));
        expect(tester.getTopLeft(find.text('C')), const Offset(90, 0));
      },
    );

    testWidgets(
      'textDirection overrides the ambient Directionality',
      (tester) async {
        await tester.pumpWidget(
          _boilerplate(
            width: 100,
            height: 100,
            textDirection: TextDirection.rtl,
            child: OverflowView(
              textDirection: TextDirection.ltr,
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

        expect(tester.getTopLeft(find.text('A')), const Offset(0, 0));
        expect(tester.getTopLeft(find.text('B')), const Offset(50, 0));
      },
    );

    testWidgets(
      'children are laid out from left to right without Directionality',
      (tester) async {
        await tester.pumpWidget(
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 100,
              child: OverflowView(
                builder: (context, count) {
                  return const SizedBox();
                },
                children: [
                  const SizedBox(key: ValueKey('A'), width: 50, height: 50),
                  const SizedBox(key: ValueKey('B'), width: 50, height: 50),
                ],
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(tester.getTopLeft(find.byKey(const ValueKey('A'))), Offset.zero);
        expect(
          tester.getTopLeft(find.byKey(const ValueKey('B'))),
          const Offset(50, 0),
        );
      },
    );

    testWidgets(
      'the layout is updated when the ambient Directionality changes',
      (tester) async {
        Widget build(TextDirection textDirection) {
          return _boilerplate(
            width: 100,
            height: 100,
            textDirection: textDirection,
            child: OverflowView(
              builder: (context, count) {
                return const SizedBox();
              },
              children: [
                const _Text('A'),
                const _Text('B'),
              ],
            ),
          );
        }

        await tester.pumpWidget(build(TextDirection.ltr));
        expect(tester.getTopLeft(find.text('A')), const Offset(0, 0));

        await tester.pumpWidget(build(TextDirection.rtl));
        expect(tester.getTopLeft(find.text('A')), const Offset(50, 0));
      },
    );

    testWidgets(
      'a tap on a child is dispatched to it in RTL',
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
            width: 100,
            height: 100,
            textDirection: TextDirection.rtl,
            child: OverflowView(
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

        await tester.tapAt(const Offset(75, 25));
        expect(tappedChildren, ['A']);
      },
    );
  });
}

Widget _boilerplate({
  required double width,
  required double height,
  required Widget child,
  VoidCallback? onTap,
  TextDirection textDirection = TextDirection.ltr,
}) {
  return Directionality(
    textDirection: textDirection,
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
    this.width = 50,
    this.height = 50,
  }) : super(key: key);

  final String text;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Text(text),
    );
  }
}
