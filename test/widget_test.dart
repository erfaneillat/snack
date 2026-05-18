import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:game/game/game_model.dart';
import 'package:game/game/worm_game.dart';

void main() {
  test('Generated levels 1 through 10 load deterministically', () {
    for (
      var levelNumber = GameLevel.firstLevel;
      levelNumber <= GameLevel.lastLevel;
      levelNumber++
    ) {
      final level = GameLevel.byNumber(levelNumber);

      expect(level.number, levelNumber);
      expect(level.worms.where((worm) => worm.canMove), isNotEmpty);
    }
  });

  testWidgets('Worm puzzle smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WormJamApp());

    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('0/3'), findsOneWidget);
    expect(find.byKey(const ValueKey('game-board')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('pause-button')));
    await tester.pump();

    expect(find.text('Paused'), findsOneWidget);
  });

  testWidgets('Tapping an open snake escapes it', (WidgetTester tester) async {
    await tester.pumpWidget(const WormJamApp());

    final boardFinder = find.byKey(const ValueKey('game-board'));
    final boardTopLeft = tester.getTopLeft(boardFinder);
    final boardSize = tester.getSize(boardFinder);
    final metrics = BoardMetrics.fromSize(size: boardSize, cols: 8, rows: 8);

    await tester.tapAt(boardTopLeft + metrics.centerOf(const BoardCell(1, 5)));
    await tester.pumpAndSettle();

    expect(find.text('1/3'), findsOneWidget);
  });

  testWidgets('Tapping a blocked snake costs one heart', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const WormJamApp());

    final boardFinder = find.byKey(const ValueKey('game-board'));
    final boardTopLeft = tester.getTopLeft(boardFinder);
    final boardSize = tester.getSize(boardFinder);
    final metrics = BoardMetrics.fromSize(size: boardSize, cols: 8, rows: 8);

    await tester.tapAt(boardTopLeft + metrics.centerOf(const BoardCell(1, 2)));
    await tester.pump();

    final emptyHearts = tester
        .widgetList<Icon>(find.byIcon(Icons.favorite_rounded))
        .where((icon) => icon.color == const Color(0xffb8c2d4))
        .length;

    expect(find.text('0/3'), findsOneWidget);
    expect(emptyHearts, 1);
  });

  testWidgets('Worm puzzle fits a narrow phone viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const WormJamApp());
    await tester.pump();

    expect(find.text('Level 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
