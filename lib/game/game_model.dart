import 'package:flutter/material.dart';

@immutable
class BoardCell {
  const BoardCell(this.row, this.col);

  final int row;
  final int col;

  BoardCell moved(Direction direction) {
    return BoardCell(row + direction.rowDelta, col + direction.colDelta);
  }

  @override
  bool operator ==(Object other) {
    return other is BoardCell && other.row == row && other.col == col;
  }

  @override
  int get hashCode => Object.hash(row, col);
}

enum Direction {
  up(-1, 0),
  right(0, 1),
  down(1, 0),
  left(0, -1);

  const Direction(this.rowDelta, this.colDelta);

  final int rowDelta;
  final int colDelta;
}

@immutable
class Worm {
  const Worm({
    required this.id,
    required this.cells,
    required this.color,
    required this.darkColor,
    this.isHero = false,
    this.canMove = true,
  });

  final String id;
  final List<BoardCell> cells;
  final Color color;
  final Color darkColor;
  final bool isHero;
  final bool canMove;

  BoardCell get front => cells.first;

  BoardCell get back => cells.last;

  Worm copyWith({List<BoardCell>? cells}) {
    return Worm(
      id: id,
      cells: cells ?? this.cells,
      color: color,
      darkColor: darkColor,
      isHero: isHero,
      canMove: canMove,
    );
  }
}

@immutable
class GameLevel {
  const GameLevel({
    this.number = firstLevel,
    required this.rows,
    required this.cols,
    required this.worms,
    required this.seconds,
  });

  static const int firstLevel = 1;
  static const int lastLevel = 10;

  final int number;
  final int rows;
  final int cols;
  final List<Worm> worms;
  final int seconds;

  static GameLevel byNumber(int number) {
    final clamped = number.clamp(firstLevel, lastLevel).toInt();
    return _LevelFactory(_levelPlans[clamped - 1]).build();
  }

  static GameLevel levelThree() {
    const orange = Color(0xffffbd3d);
    const orangeDark = Color(0xffdb861d);
    const red = Color(0xffef5130);
    const redDark = Color(0xffb93621);

    return GameLevel(
      rows: 15,
      cols: 12,
      seconds: 122,
      worms: const [
        Worm(
          id: 'top-left',
          color: orange,
          darkColor: orangeDark,
          cells: [
            BoardCell(0, 0),
            BoardCell(0, 1),
            BoardCell(0, 2),
            BoardCell(0, 3),
            BoardCell(1, 3),
            BoardCell(1, 2),
            BoardCell(1, 1),
            BoardCell(1, 0),
            BoardCell(2, 0),
            BoardCell(2, 1),
            BoardCell(2, 2),
            BoardCell(2, 3),
            BoardCell(3, 3),
            BoardCell(4, 3),
            BoardCell(4, 2),
            BoardCell(4, 1),
            BoardCell(4, 0),
          ],
        ),
        Worm(
          id: 'top-middle',
          color: orange,
          darkColor: orangeDark,
          cells: [
            BoardCell(0, 5),
            BoardCell(1, 5),
            BoardCell(2, 5),
            BoardCell(3, 5),
            BoardCell(4, 5),
            BoardCell(4, 6),
            BoardCell(3, 6),
            BoardCell(2, 6),
            BoardCell(1, 6),
            BoardCell(0, 6),
            BoardCell(0, 7),
            BoardCell(0, 8),
            BoardCell(1, 8),
            BoardCell(2, 8),
            BoardCell(2, 7),
            BoardCell(3, 7),
            BoardCell(4, 7),
          ],
        ),
        Worm(
          id: 'top-right',
          color: orange,
          darkColor: orangeDark,
          cells: [
            BoardCell(0, 10),
            BoardCell(0, 9),
            BoardCell(1, 9),
            BoardCell(1, 10),
            BoardCell(1, 11),
            BoardCell(2, 11),
            BoardCell(2, 10),
            BoardCell(2, 9),
            BoardCell(3, 9),
            BoardCell(3, 10),
            BoardCell(3, 11),
            BoardCell(4, 11),
            BoardCell(4, 10),
            BoardCell(4, 9),
            BoardCell(5, 9),
            BoardCell(5, 10),
            BoardCell(5, 11),
          ],
        ),
        Worm(
          id: 'left-middle',
          color: orange,
          darkColor: orangeDark,
          cells: [
            BoardCell(5, 0),
            BoardCell(5, 1),
            BoardCell(5, 2),
            BoardCell(6, 2),
            BoardCell(6, 1),
            BoardCell(6, 0),
            BoardCell(7, 0),
            BoardCell(8, 0),
            BoardCell(8, 1),
            BoardCell(8, 2),
            BoardCell(7, 2),
            BoardCell(7, 3),
            BoardCell(6, 3),
            BoardCell(5, 3),
          ],
        ),
        Worm(
          id: 'right-middle',
          color: orange,
          darkColor: orangeDark,
          cells: [
            BoardCell(6, 9),
            BoardCell(6, 10),
            BoardCell(6, 11),
            BoardCell(7, 11),
            BoardCell(7, 10),
            BoardCell(7, 9),
            BoardCell(8, 9),
            BoardCell(8, 10),
            BoardCell(8, 11),
            BoardCell(9, 11),
            BoardCell(10, 11),
            BoardCell(10, 10),
            BoardCell(10, 9),
            BoardCell(9, 9),
            BoardCell(9, 8),
            BoardCell(8, 8),
            BoardCell(7, 8),
            BoardCell(6, 8),
            BoardCell(5, 8),
          ],
        ),
        Worm(
          id: 'left-bottom',
          color: orange,
          darkColor: orangeDark,
          cells: [
            BoardCell(9, 0),
            BoardCell(9, 1),
            BoardCell(9, 2),
            BoardCell(9, 3),
            BoardCell(10, 3),
            BoardCell(10, 2),
            BoardCell(10, 1),
            BoardCell(10, 0),
            BoardCell(11, 0),
            BoardCell(12, 0),
            BoardCell(13, 0),
            BoardCell(14, 0),
            BoardCell(14, 1),
            BoardCell(13, 1),
            BoardCell(12, 1),
            BoardCell(12, 2),
            BoardCell(11, 2),
            BoardCell(11, 3),
            BoardCell(12, 3),
            BoardCell(13, 3),
            BoardCell(13, 2),
            BoardCell(14, 2),
          ],
        ),
        Worm(
          id: 'bottom-middle',
          color: orange,
          darkColor: orangeDark,
          cells: [
            BoardCell(10, 4),
            BoardCell(10, 5),
            BoardCell(10, 6),
            BoardCell(10, 7),
            BoardCell(11, 7),
            BoardCell(11, 6),
            BoardCell(11, 5),
            BoardCell(11, 4),
            BoardCell(12, 4),
            BoardCell(13, 4),
            BoardCell(14, 4),
            BoardCell(14, 5),
            BoardCell(13, 5),
            BoardCell(12, 5),
            BoardCell(12, 6),
            BoardCell(13, 6),
            BoardCell(14, 6),
            BoardCell(14, 7),
            BoardCell(13, 7),
            BoardCell(12, 7),
          ],
        ),
        Worm(
          id: 'bottom-right',
          color: orange,
          darkColor: orangeDark,
          cells: [
            BoardCell(11, 9),
            BoardCell(11, 10),
            BoardCell(11, 11),
            BoardCell(12, 11),
            BoardCell(13, 11),
            BoardCell(14, 11),
            BoardCell(14, 10),
            BoardCell(14, 9),
            BoardCell(13, 9),
            BoardCell(12, 9),
            BoardCell(12, 8),
            BoardCell(13, 8),
            BoardCell(14, 8),
          ],
        ),
        Worm(
          id: 'hero',
          color: red,
          darkColor: redDark,
          isHero: true,
          canMove: false,
          cells: [
            BoardCell(5, 4),
            BoardCell(5, 5),
            BoardCell(5, 6),
            BoardCell(6, 6),
            BoardCell(7, 6),
            BoardCell(8, 6),
            BoardCell(8, 5),
            BoardCell(8, 4),
            BoardCell(7, 4),
            BoardCell(6, 4),
            BoardCell(6, 5),
            BoardCell(7, 5),
          ],
        ),
      ],
    );
  }
}

class _LevelPlan {
  const _LevelPlan({
    required this.number,
    required this.rows,
    required this.cols,
    required this.seconds,
    required this.lanes,
    required this.heroCells,
  });

  final int number;
  final int rows;
  final int cols;
  final int seconds;
  final List<_LaneSpec> lanes;
  final List<BoardCell> heroCells;
}

class _LaneSpec {
  const _LaneSpec({
    required this.direction,
    required this.fixedIndex,
    required this.heads,
    required this.lengths,
  });

  final Direction direction;
  final int fixedIndex;
  final List<int> heads;
  final List<int> lengths;
}

class _WormColors {
  const _WormColors(this.color, this.darkColor);

  final Color color;
  final Color darkColor;
}

class _LevelFactory {
  const _LevelFactory(this.plan);

  final _LevelPlan plan;

  GameLevel build() {
    final worms = <Worm>[];
    var colorIndex = 0;

    for (var laneIndex = 0; laneIndex < plan.lanes.length; laneIndex++) {
      final lane = plan.lanes[laneIndex];
      if (lane.heads.length != lane.lengths.length) {
        throw StateError('Level ${plan.number} has an invalid lane spec.');
      }

      for (var wormIndex = 0; wormIndex < lane.heads.length; wormIndex++) {
        final colors = _wormPalette[colorIndex % _wormPalette.length];
        worms.add(
          Worm(
            id: 'level-${plan.number}-lane-$laneIndex-worm-$wormIndex',
            color: colors.color,
            darkColor: colors.darkColor,
            cells: _cellsFor(lane, wormIndex),
          ),
        );
        colorIndex++;
      }
    }

    if (plan.heroCells.isNotEmpty) {
      worms.add(
        const Worm(
          id: 'hero',
          color: _heroColor,
          darkColor: _heroDarkColor,
          isHero: true,
          canMove: false,
          cells: [],
        ).copyWith(cells: plan.heroCells),
      );
    }

    _validateLevel(plan, worms);

    return GameLevel(
      number: plan.number,
      rows: plan.rows,
      cols: plan.cols,
      seconds: plan.seconds,
      worms: worms,
    );
  }

  List<BoardCell> _cellsFor(_LaneSpec lane, int wormIndex) {
    final head = lane.heads[wormIndex];
    final length = lane.lengths[wormIndex];
    return [
      for (var step = 0; step < length; step++)
        switch (lane.direction) {
          Direction.right => BoardCell(lane.fixedIndex, head - step),
          Direction.left => BoardCell(lane.fixedIndex, head + step),
          Direction.down => BoardCell(head - step, lane.fixedIndex),
          Direction.up => BoardCell(head + step, lane.fixedIndex),
        },
    ];
  }
}

const _heroColor = Color(0xffef5130);
const _heroDarkColor = Color(0xffb93621);

const _wormPalette = [
  _WormColors(Color(0xffffbd3d), Color(0xffdb861d)),
  _WormColors(Color(0xff58c46d), Color(0xff2f9348)),
  _WormColors(Color(0xff4f8df7), Color(0xff2c62bb)),
  _WormColors(Color(0xffb86cff), Color(0xff8341ca)),
  _WormColors(Color(0xffff7c70), Color(0xffc94b42)),
  _WormColors(Color(0xff36c8c4), Color(0xff23918f)),
];

const _levelPlans = [
  _LevelPlan(
    number: 1,
    rows: 8,
    cols: 8,
    seconds: 70,
    lanes: [
      _LaneSpec(
        direction: Direction.right,
        fixedIndex: 1,
        heads: [2, 5],
        lengths: [2, 2],
      ),
      _LaneSpec(
        direction: Direction.left,
        fixedIndex: 4,
        heads: [5],
        lengths: [2],
      ),
    ],
    heroCells: [
      BoardCell(6, 2),
      BoardCell(6, 3),
      BoardCell(7, 3),
      BoardCell(7, 2),
    ],
  ),
  _LevelPlan(
    number: 2,
    rows: 8,
    cols: 8,
    seconds: 75,
    lanes: [
      _LaneSpec(
        direction: Direction.right,
        fixedIndex: 1,
        heads: [2, 5],
        lengths: [2, 2],
      ),
      _LaneSpec(
        direction: Direction.left,
        fixedIndex: 3,
        heads: [5, 2],
        lengths: [2, 2],
      ),
      _LaneSpec(
        direction: Direction.down,
        fixedIndex: 0,
        heads: [2, 5],
        lengths: [2, 2],
      ),
    ],
    heroCells: [
      BoardCell(6, 3),
      BoardCell(6, 4),
      BoardCell(7, 4),
      BoardCell(7, 3),
    ],
  ),
  _LevelPlan(
    number: 3,
    rows: 9,
    cols: 9,
    seconds: 85,
    lanes: [
      _LaneSpec(
        direction: Direction.right,
        fixedIndex: 1,
        heads: [2, 5, 7],
        lengths: [2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.left,
        fixedIndex: 3,
        heads: [6, 3],
        lengths: [2, 2],
      ),
      _LaneSpec(
        direction: Direction.down,
        fixedIndex: 0,
        heads: [2, 5, 7],
        lengths: [2, 2, 2],
      ),
    ],
    heroCells: [
      BoardCell(5, 4),
      BoardCell(5, 5),
      BoardCell(6, 5),
      BoardCell(6, 4),
    ],
  ),
  _LevelPlan(
    number: 4,
    rows: 10,
    cols: 9,
    seconds: 90,
    lanes: [
      _LaneSpec(
        direction: Direction.right,
        fixedIndex: 1,
        heads: [2, 5, 7],
        lengths: [2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.left,
        fixedIndex: 4,
        heads: [6, 3, 1],
        lengths: [2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.down,
        fixedIndex: 7,
        heads: [3, 6, 8],
        lengths: [2, 2, 2],
      ),
    ],
    heroCells: [
      BoardCell(8, 2),
      BoardCell(8, 3),
      BoardCell(9, 3),
      BoardCell(9, 2),
    ],
  ),
  _LevelPlan(
    number: 5,
    rows: 10,
    cols: 10,
    seconds: 95,
    lanes: [
      _LaneSpec(
        direction: Direction.right,
        fixedIndex: 1,
        heads: [2, 5, 8],
        lengths: [2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.left,
        fixedIndex: 3,
        heads: [7, 4, 1],
        lengths: [2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.down,
        fixedIndex: 0,
        heads: [2, 5, 8],
        lengths: [2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.up,
        fixedIndex: 9,
        heads: [7],
        lengths: [2],
      ),
    ],
    heroCells: [
      BoardCell(6, 4),
      BoardCell(6, 5),
      BoardCell(7, 5),
      BoardCell(7, 4),
    ],
  ),
  _LevelPlan(
    number: 6,
    rows: 11,
    cols: 10,
    seconds: 100,
    lanes: [
      _LaneSpec(
        direction: Direction.right,
        fixedIndex: 1,
        heads: [2, 5, 8],
        lengths: [2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.left,
        fixedIndex: 3,
        heads: [7, 4, 1],
        lengths: [2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.down,
        fixedIndex: 0,
        heads: [2, 5, 8],
        lengths: [2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.up,
        fixedIndex: 8,
        heads: [8, 5],
        lengths: [2, 2],
      ),
    ],
    heroCells: [
      BoardCell(9, 3),
      BoardCell(9, 4),
      BoardCell(10, 4),
      BoardCell(10, 3),
    ],
  ),
  _LevelPlan(
    number: 7,
    rows: 11,
    cols: 11,
    seconds: 105,
    lanes: [
      _LaneSpec(
        direction: Direction.right,
        fixedIndex: 1,
        heads: [2, 5, 8],
        lengths: [2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.left,
        fixedIndex: 3,
        heads: [8, 5, 2],
        lengths: [2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.right,
        fixedIndex: 5,
        heads: [2, 5, 8],
        lengths: [2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.down,
        fixedIndex: 0,
        heads: [2, 5, 8],
        lengths: [2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.up,
        fixedIndex: 10,
        heads: [8, 5],
        lengths: [2, 2],
      ),
    ],
    heroCells: [
      BoardCell(8, 4),
      BoardCell(8, 5),
      BoardCell(9, 5),
      BoardCell(9, 4),
    ],
  ),
  _LevelPlan(
    number: 8,
    rows: 12,
    cols: 11,
    seconds: 110,
    lanes: [
      _LaneSpec(
        direction: Direction.right,
        fixedIndex: 1,
        heads: [2, 5, 8],
        lengths: [2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.left,
        fixedIndex: 3,
        heads: [8, 5, 2],
        lengths: [2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.right,
        fixedIndex: 5,
        heads: [2, 5, 8],
        lengths: [2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.left,
        fixedIndex: 7,
        heads: [8, 5, 2],
        lengths: [2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.down,
        fixedIndex: 0,
        heads: [2, 5, 8, 10],
        lengths: [2, 2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.up,
        fixedIndex: 10,
        heads: [9, 6, 3],
        lengths: [2, 2, 2],
      ),
    ],
    heroCells: [
      BoardCell(10, 4),
      BoardCell(10, 5),
      BoardCell(11, 5),
      BoardCell(11, 4),
    ],
  ),
  _LevelPlan(
    number: 9,
    rows: 12,
    cols: 12,
    seconds: 115,
    lanes: [
      _LaneSpec(
        direction: Direction.right,
        fixedIndex: 1,
        heads: [2, 5, 8, 10],
        lengths: [2, 2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.left,
        fixedIndex: 3,
        heads: [9, 6, 3, 1],
        lengths: [2, 2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.right,
        fixedIndex: 5,
        heads: [2, 5, 8, 10],
        lengths: [2, 2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.left,
        fixedIndex: 7,
        heads: [9, 6, 3, 1],
        lengths: [2, 2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.down,
        fixedIndex: 0,
        heads: [2, 5, 8, 10],
        lengths: [2, 2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.up,
        fixedIndex: 11,
        heads: [9, 6, 3],
        lengths: [2, 2, 2],
      ),
    ],
    heroCells: [
      BoardCell(10, 5),
      BoardCell(10, 6),
      BoardCell(11, 6),
      BoardCell(11, 5),
    ],
  ),
  _LevelPlan(
    number: 10,
    rows: 13,
    cols: 12,
    seconds: 120,
    lanes: [
      _LaneSpec(
        direction: Direction.right,
        fixedIndex: 1,
        heads: [2, 5, 8, 10],
        lengths: [2, 2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.left,
        fixedIndex: 3,
        heads: [9, 6, 3, 1],
        lengths: [2, 2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.right,
        fixedIndex: 5,
        heads: [2, 5, 8, 10],
        lengths: [2, 2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.left,
        fixedIndex: 7,
        heads: [9, 6, 3, 1],
        lengths: [2, 2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.right,
        fixedIndex: 9,
        heads: [2, 5, 8, 10],
        lengths: [2, 2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.down,
        fixedIndex: 0,
        heads: [2, 5, 8, 11],
        lengths: [2, 2, 2, 2],
      ),
      _LaneSpec(
        direction: Direction.up,
        fixedIndex: 11,
        heads: [10, 7, 4],
        lengths: [2, 2, 2],
      ),
    ],
    heroCells: [
      BoardCell(11, 5),
      BoardCell(11, 6),
      BoardCell(12, 6),
      BoardCell(12, 5),
    ],
  ),
];

void _validateLevel(_LevelPlan plan, List<Worm> worms) {
  final occupied = <BoardCell, String>{};
  for (final worm in worms) {
    for (final cell in worm.cells) {
      if (cell.row < 0 ||
          cell.row >= plan.rows ||
          cell.col < 0 ||
          cell.col >= plan.cols) {
        throw StateError('Level ${plan.number} has an out-of-bounds worm.');
      }

      final existing = occupied[cell];
      if (existing != null) {
        throw StateError(
          'Level ${plan.number} overlaps ${worm.id} with $existing.',
        );
      }
      occupied[cell] = worm.id;
    }
  }

  final solution = _solveLevel(plan, worms);
  if (solution.length != worms.where((worm) => worm.canMove).length) {
    throw StateError('Level ${plan.number} is not solvable.');
  }
}

List<String> _solveLevel(_LevelPlan plan, List<Worm> worms) {
  final staticWorms = [
    for (final worm in worms)
      if (!worm.canMove || worm.isHero) worm,
  ];
  final remaining = [
    for (final worm in worms)
      if (worm.canMove && !worm.isHero) worm,
  ];
  final solution = <String>[];

  while (remaining.isNotEmpty) {
    final clearIndex = remaining.indexWhere(
      (worm) => !_hasBlocker(plan, worm, [...staticWorms, ...remaining]),
    );
    if (clearIndex == -1) {
      return solution;
    }
    solution.add(remaining[clearIndex].id);
    remaining.removeAt(clearIndex);
  }

  return solution;
}

bool _hasBlocker(_LevelPlan plan, Worm worm, List<Worm> blockers) {
  final direction = _generatedHeadDirection(worm);
  var cursor = worm.front.moved(direction);
  while (_insidePlan(plan, cursor)) {
    for (final blocker in blockers) {
      if (blocker.id != worm.id && blocker.cells.contains(cursor)) {
        return true;
      }
    }
    cursor = cursor.moved(direction);
  }
  return false;
}

bool _insidePlan(_LevelPlan plan, BoardCell cell) {
  return cell.row >= 0 &&
      cell.row < plan.rows &&
      cell.col >= 0 &&
      cell.col < plan.cols;
}

Direction _generatedHeadDirection(Worm worm) {
  if (worm.cells.length < 2) {
    return Direction.up;
  }

  final rowDelta = worm.front.row - worm.cells[1].row;
  final colDelta = worm.front.col - worm.cells[1].col;

  return Direction.values.firstWhere(
    (direction) =>
        direction.rowDelta == rowDelta && direction.colDelta == colDelta,
    orElse: () => Direction.up,
  );
}

enum TapOutcome { ignored, escaped, crashed }

@immutable
class TapResult {
  const TapResult({
    required this.outcome,
    this.wormId,
    this.impactCell,
    this.direction,
    this.escapeCells = 0,
  });

  final TapOutcome outcome;
  final String? wormId;
  final BoardCell? impactCell;
  final Direction? direction;
  final double escapeCells;
}

class WormGameController extends ChangeNotifier {
  WormGameController(this.level) {
    reset();
  }

  final GameLevel level;

  late List<Worm> _worms;
  int _escaped = 0;
  int _lives = 3;
  int _moves = 0;
  TapResult _lastResult = const TapResult(outcome: TapOutcome.ignored);

  List<Worm> get worms => List.unmodifiable(_worms);

  int get moves => _moves;

  int get lives => _lives;

  int get escaped => _escaped;

  int get totalEscapable =>
      level.worms.where((worm) => worm.canMove && !worm.isHero).length;

  bool get isComplete => _escaped >= totalEscapable;

  bool get isGameOver => _lives <= 0;

  TapResult get lastResult => _lastResult;

  void reset() {
    _worms = [
      for (final worm in level.worms) worm.copyWith(cells: List.of(worm.cells)),
    ];
    _escaped = 0;
    _lives = 3;
    _moves = 0;
    _lastResult = const TapResult(outcome: TapOutcome.ignored);
    notifyListeners();
  }

  TapResult tap(BoardCell cell) {
    final wormIndex = _worms.lastIndexWhere(
      (worm) => worm.canMove && !worm.isHero && worm.cells.contains(cell),
    );
    if (wormIndex == -1 || isComplete || isGameOver) {
      _lastResult = const TapResult(outcome: TapOutcome.ignored);
      notifyListeners();
      return _lastResult;
    }

    final worm = _worms[wormIndex];
    final direction = _headDirection(worm);
    final block = _firstBlockingCell(
      worm: worm,
      start: worm.front,
      direction: direction,
    );

    if (block == null) {
      _moves++;
      _lastResult = TapResult(
        outcome: TapOutcome.escaped,
        wormId: worm.id,
        impactCell: worm.front,
        direction: direction,
        escapeCells: _escapeDistanceCells(worm, direction),
      );
      notifyListeners();
      return _lastResult;
    }

    _lives = (_lives - 1).clamp(0, 3);
    _moves++;
    _lastResult = TapResult(
      outcome: TapOutcome.crashed,
      wormId: worm.id,
      impactCell: block,
      direction: direction,
    );
    notifyListeners();
    return _lastResult;
  }

  void completeEscape(String wormId) {
    final wormIndex = _worms.indexWhere((worm) => worm.id == wormId);
    if (wormIndex == -1) {
      return;
    }

    _worms.removeAt(wormIndex);
    _escaped++;
    _lastResult = const TapResult(outcome: TapOutcome.ignored);
    notifyListeners();
  }

  BoardCell? _firstBlockingCell({
    required Worm worm,
    required BoardCell start,
    required Direction direction,
  }) {
    var cursor = start.moved(direction);
    while (_isInside(cursor)) {
      if (_isOccupiedByAnotherWorm(cursor, worm.id)) {
        return cursor;
      }
      cursor = cursor.moved(direction);
    }
    return null;
  }

  bool _isInside(BoardCell cell) {
    return cell.row >= 0 &&
        cell.row < level.rows &&
        cell.col >= 0 &&
        cell.col < level.cols;
  }

  bool _isOccupiedByAnotherWorm(BoardCell cell, String wormId) {
    for (final worm in _worms) {
      if (worm.id != wormId && worm.cells.contains(cell)) {
        return true;
      }
    }
    return false;
  }

  Direction _headDirection(Worm worm) {
    if (worm.cells.length < 2) {
      return Direction.up;
    }

    final rowDelta = worm.front.row - worm.cells[1].row;
    final colDelta = worm.front.col - worm.cells[1].col;

    return Direction.values.firstWhere(
      (direction) =>
          direction.rowDelta == rowDelta && direction.colDelta == colDelta,
      orElse: () => Direction.up,
    );
  }

  double _escapeDistanceCells(Worm worm, Direction direction) {
    final head = worm.front;
    final length = worm.cells.length;

    return switch (direction) {
      Direction.up => head.row + length + 0.7,
      Direction.down => level.rows - head.row + length - 0.3,
      Direction.left => head.col + length + 0.7,
      Direction.right => level.cols - head.col + length - 0.3,
    };
  }
}
