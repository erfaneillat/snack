import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'game_model.dart';

class WormJamApp extends StatelessWidget {
  const WormJamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Worm Maze',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff4f8df7),
          brightness: Brightness.light,
        ),
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: const WormGameScreen(),
    );
  }
}

class WormGameScreen extends StatefulWidget {
  const WormGameScreen({super.key});

  @override
  State<WormGameScreen> createState() => _WormGameScreenState();
}

class _WormGameScreenState extends State<WormGameScreen>
    with SingleTickerProviderStateMixin {
  late final GameLevel _level;
  late final WormGameController _controller;
  late final AnimationController _escapeController;
  Timer? _timer;
  Timer? _feedbackTimer;
  TapResult? _flashResult;
  TapResult? _escapeResult;
  bool _paused = false;
  late int _remainingSeconds;

  bool get _timeExpired => _remainingSeconds <= 0;

  @override
  void initState() {
    super.initState();
    _level = GameLevel.levelThree();
    _controller = WormGameController(_level)..addListener(_refresh);
    _escapeController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 980),
          )
          ..addListener(_refresh)
          ..addStatusListener(_finishEscape);
    _remainingSeconds = _level.seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted ||
          _paused ||
          _controller.isComplete ||
          _controller.isGameOver ||
          _timeExpired) {
        return;
      }
      setState(() {
        _remainingSeconds--;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _feedbackTimer?.cancel();
    _escapeController
      ..removeListener(_refresh)
      ..removeStatusListener(_finishEscape)
      ..dispose();
    _controller
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void _reset() {
    _flashResult = null;
    _escapeResult = null;
    _escapeController.stop();
    _escapeController.value = 0;
    _paused = false;
    _remainingSeconds = _level.seconds;
    _controller.reset();
  }

  void _togglePause() {
    setState(() {
      _paused = !_paused;
      _flashResult = null;
    });
  }

  void _finishEscape(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }

    final wormId = _escapeResult?.wormId;
    if (wormId == null) {
      return;
    }

    _controller.completeEscape(wormId);
    if (mounted) {
      setState(() {
        _escapeResult = null;
        _flashResult = null;
        _escapeController.value = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final escaping = _escapeResult != null;
    final showOverlay =
        _paused ||
        _controller.isComplete ||
        _controller.isGameOver ||
        _timeExpired;

    return Scaffold(
      backgroundColor: const Color(0xffecf3ff),
      body: SafeArea(
        child: Column(
          children: [
            _HudBar(
              escaped: _controller.escaped,
              total: _controller.totalEscapable,
              lives: _controller.lives,
              remainingSeconds: _remainingSeconds,
              paused: _paused,
              onPause: _togglePause,
              onReset: _reset,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 12),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _level.cols / _level.rows,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size = Size(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        );

                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            GestureDetector(
                              key: const ValueKey('game-board'),
                              behavior: HitTestBehavior.opaque,
                              onTapUp: showOverlay || escaping
                                  ? null
                                  : (details) => _tapBoard(details, size),
                              child: CustomPaint(
                                key: const ValueKey('worm-board-painter'),
                                painter: BoardPainter(
                                  rows: _level.rows,
                                  cols: _level.cols,
                                  worms: _controller.worms,
                                  feedback: _flashResult,
                                  escapeResult: _escapeResult,
                                  escapeProgress: _escapeController.value,
                                ),
                              ),
                            ),
                            if (showOverlay)
                              _StatusOverlay(
                                complete: _controller.isComplete,
                                expired: _timeExpired,
                                paused: _paused,
                                gameOver: _controller.isGameOver,
                                moves: _controller.moves,
                                onResume: _togglePause,
                                onReset: _reset,
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _tapBoard(TapUpDetails details, Size size) {
    final metrics = BoardMetrics.fromSize(
      size: size,
      cols: _level.cols,
      rows: _level.rows,
    );
    final cell = metrics.cellAt(details.localPosition);
    if (cell == null) {
      return;
    }

    final result = _controller.tap(cell);
    if (result.outcome == TapOutcome.ignored) {
      return;
    }

    _feedbackTimer?.cancel();
    if (result.outcome == TapOutcome.escaped) {
      _escapeController.duration = Duration(
        milliseconds: (result.escapeCells * 90).round().clamp(900, 2400),
      );
      setState(() {
        _flashResult = null;
        _escapeResult = result;
      });
      _escapeController.forward(from: 0);
      return;
    }

    setState(() {
      _flashResult = result;
    });
    _feedbackTimer = Timer(const Duration(milliseconds: 420), () {
      if (!mounted || _flashResult != result) {
        return;
      }
      setState(() {
        _flashResult = null;
      });
    });
  }
}

class _HudBar extends StatelessWidget {
  const _HudBar({
    required this.escaped,
    required this.total,
    required this.lives,
    required this.remainingSeconds,
    required this.paused,
    required this.onPause,
    required this.onReset,
  });

  final int escaped;
  final int total;
  final int lives;
  final int remainingSeconds;
  final bool paused;
  final VoidCallback onPause;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final time =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _RoundIconButton(
                key: const ValueKey('pause-button'),
                icon: paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                onPressed: onPause,
                tooltip: paused ? 'Resume' : 'Pause',
              ),
              const SizedBox(width: 8),
              _RoundIconButton(
                key: const ValueKey('reset-button'),
                icon: Icons.restart_alt_rounded,
                onPressed: onReset,
                tooltip: 'Restart',
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 188),
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 9),
                  decoration: BoxDecoration(
                    color: const Color(0xff72a6ff),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x260d4ca3),
                        offset: Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Level 3',
                        key: ValueKey('level-label'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var index = 0; index < 3; index++) ...[
                            _HeartIcon(active: index < lives),
                            if (index != 2) const SizedBox(width: 4),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1f3b4c6c),
                        offset: Offset(0, 2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_rounded,
                        color: Color(0xffffbf28),
                        size: 21,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        key: const ValueKey('timer-label'),
                        style: const TextStyle(
                          color: Color(0xff6b778d),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Row(
            children: [
              Text(
                '$escaped/$total',
                key: const ValueKey('score-label'),
                style: const TextStyle(
                  color: Color(0xffd39b18),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  height: 2.2,
                ),
              ),
              const SizedBox(width: 7),
              const _AvatarBadge(),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x22344766),
            offset: Offset(0, 3),
            blurRadius: 8,
          ),
        ],
        border: Border.all(color: const Color(0xffcbd8f3), width: 1.5),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: const Color(0xff5b73c9),
        iconSize: 28,
        tooltip: tooltip,
        constraints: const BoxConstraints.tightFor(width: 49, height: 49),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _HeartIcon extends StatelessWidget {
  const _HeartIcon({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.favorite_rounded,
      color: active ? const Color(0xffff3030) : const Color(0xffb8c2d4),
      size: 23,
      shadows: const [
        Shadow(color: Color(0x45000000), offset: Offset(0, 1), blurRadius: 2),
      ],
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 49,
      child: CustomPaint(painter: _AvatarPainter()),
    );
  }
}

class _StatusOverlay extends StatelessWidget {
  const _StatusOverlay({
    required this.complete,
    required this.expired,
    required this.paused,
    required this.gameOver,
    required this.moves,
    required this.onResume,
    required this.onReset,
  });

  final bool complete;
  final bool expired;
  final bool paused;
  final bool gameOver;
  final int moves;
  final VoidCallback onResume;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final title = complete
        ? 'Complete'
        : (gameOver ? 'Out of Hearts' : (expired ? 'Time' : 'Paused'));

    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0x5c26344d)),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 220),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xff243252),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (complete) ...[
                const SizedBox(height: 6),
                Text(
                  '$moves moves',
                  style: const TextStyle(
                    color: Color(0xff71809a),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (paused)
                    _RoundIconButton(
                      icon: Icons.play_arrow_rounded,
                      onPressed: onResume,
                      tooltip: 'Resume',
                    ),
                  if (paused) const SizedBox(width: 12),
                  _RoundIconButton(
                    icon: Icons.restart_alt_rounded,
                    onPressed: onReset,
                    tooltip: 'Restart',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BoardMetrics {
  const BoardMetrics({
    required this.cellSize,
    required this.origin,
    required this.boardSize,
    required this.cols,
    required this.rows,
  });

  final double cellSize;
  final Offset origin;
  final Size boardSize;
  final int cols;
  final int rows;

  static BoardMetrics fromSize({
    required Size size,
    required int cols,
    required int rows,
  }) {
    final inset = math.min(10.0, math.min(size.width, size.height) * 0.025);
    final cellSize = math.min(
      (size.width - inset * 2) / cols,
      (size.height - inset * 2) / rows,
    );
    final boardSize = Size(cols * cellSize, rows * cellSize);
    final origin = Offset(
      (size.width - boardSize.width) / 2,
      (size.height - boardSize.height) / 2,
    );

    return BoardMetrics(
      cellSize: cellSize,
      origin: origin,
      boardSize: boardSize,
      cols: cols,
      rows: rows,
    );
  }

  Rect get rect => origin & boardSize;

  Offset centerOf(BoardCell cell) {
    return origin +
        Offset((cell.col + 0.5) * cellSize, (cell.row + 0.5) * cellSize);
  }

  Offset centerAt({required double row, required double col}) {
    return origin + Offset((col + 0.5) * cellSize, (row + 0.5) * cellSize);
  }

  BoardCell? cellAt(Offset point) {
    if (!rect.contains(point)) {
      return null;
    }
    final col = ((point.dx - origin.dx) / cellSize).floor();
    final row = ((point.dy - origin.dy) / cellSize).floor();
    if (row < 0 || row >= rows || col < 0 || col >= cols) {
      return null;
    }
    return BoardCell(row, col);
  }
}

class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.rows,
    required this.cols,
    required this.worms,
    this.feedback,
    this.escapeResult,
    this.escapeProgress = 0,
  });

  final int rows;
  final int cols;
  final List<Worm> worms;
  final TapResult? feedback;
  final TapResult? escapeResult;
  final double escapeProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = BoardMetrics.fromSize(size: size, cols: cols, rows: rows);
    final boardRect = metrics.rect;

    final backgroundPaint = Paint()..color = Colors.white;
    final borderPaint = Paint()
      ..color = const Color(0xffdbe5f8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final boardRadius = Radius.circular(metrics.cellSize * 0.26);
    final boardRRect = RRect.fromRectAndRadius(boardRect, boardRadius);

    canvas.drawShadow(
      Path()..addRRect(boardRRect),
      const Color(0xff6b7895),
      5,
      true,
    );
    canvas.drawRRect(boardRRect, backgroundPaint);
    canvas.drawRRect(boardRRect, borderPaint);

    for (final worm in worms.where((worm) => !worm.isHero)) {
      _drawWorm(canvas, metrics, worm);
    }
    for (final worm in worms.where((worm) => worm.isHero)) {
      _drawWorm(canvas, metrics, worm);
    }

    final result = feedback;
    if (result?.impactCell != null) {
      switch (result!.outcome) {
        case TapOutcome.crashed:
          _drawCrash(canvas, metrics, result.impactCell!);
        case TapOutcome.escaped:
          _drawEscapePulse(canvas, metrics, result.impactCell!);
        case TapOutcome.ignored:
          break;
      }
    }
  }

  void _drawWorm(Canvas canvas, BoardMetrics metrics, Worm worm) {
    if (worm.cells.isEmpty) {
      return;
    }

    final centers = _segmentCenters(metrics, worm);
    if (centers.isEmpty) {
      return;
    }

    final path = _smoothWormPath(centers, metrics.cellSize * 0.42);

    final selected =
        feedback?.wormId == worm.id && feedback?.outcome == TapOutcome.crashed;
    if (selected) {
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xff8ab2ff).withValues(alpha: 0.34)
          ..strokeWidth = metrics.cellSize * 0.88
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke,
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = worm.darkColor
        ..strokeWidth = metrics.cellSize * 0.69
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = worm.color
        ..strokeWidth = metrics.cellSize * 0.58
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    _drawBodyBeads(canvas, metrics, path, worm);

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: worm.isHero ? 0.22 : 0.3)
        ..strokeWidth = metrics.cellSize * 0.1
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    _drawFace(canvas, metrics, worm, centers.first);
  }

  void _drawBodyBeads(
    Canvas canvas,
    BoardMetrics metrics,
    Path path,
    Worm worm,
  ) {
    final metric = _firstMetric(path);
    if (metric == null) {
      return;
    }

    final spacing = metrics.cellSize;
    final count = math.max(1, (metric.length / spacing).round());
    final beadPaint = Paint()..color = worm.color;
    final shadowPaint = Paint()..color = worm.darkColor.withValues(alpha: 0.34);
    final shinePaint = Paint()..color = Colors.white.withValues(alpha: 0.24);

    for (var index = 0; index <= count; index++) {
      final distance = (index * metric.length / count).clamp(
        0.0,
        metric.length,
      );
      final center = metric.getTangentForOffset(distance)?.position;
      if (center == null) {
        continue;
      }

      canvas.drawCircle(
        center + Offset(0, metrics.cellSize * 0.022),
        metrics.cellSize * 0.275,
        shadowPaint,
      );
      canvas.drawCircle(center, metrics.cellSize * 0.255, beadPaint);
      canvas.drawCircle(
        center + Offset(-metrics.cellSize * 0.075, -metrics.cellSize * 0.095),
        metrics.cellSize * 0.055,
        shinePaint,
      );
    }
  }

  Path _smoothWormPath(List<Offset> centers, double maxRadius) {
    final path = Path()..moveTo(centers.first.dx, centers.first.dy);
    if (centers.length == 1) {
      return path;
    }

    for (var index = 1; index < centers.length - 1; index++) {
      final previous = centers[index - 1];
      final current = centers[index];
      final next = centers[index + 1];
      final incoming = previous - current;
      final outgoing = next - current;
      final incomingDistance = incoming.distance;
      final outgoingDistance = outgoing.distance;

      if (incomingDistance < 0.01 || outgoingDistance < 0.01) {
        path.lineTo(current.dx, current.dy);
        continue;
      }

      final incomingUnit = incoming / incomingDistance;
      final outgoingUnit = outgoing / outgoingDistance;
      final isStraight =
          (incomingUnit.dx + outgoingUnit.dx).abs() < 0.01 &&
          (incomingUnit.dy + outgoingUnit.dy).abs() < 0.01;

      if (isStraight) {
        path.lineTo(current.dx, current.dy);
        continue;
      }

      final radius = math.min(
        maxRadius,
        math.min(incomingDistance, outgoingDistance) * 0.48,
      );
      final beforeCorner = current + incomingUnit * radius;
      final afterCorner = current + outgoingUnit * radius;

      path.lineTo(beforeCorner.dx, beforeCorner.dy);
      path.quadraticBezierTo(
        current.dx,
        current.dy,
        afterCorner.dx,
        afterCorner.dy,
      );
    }

    final last = centers.last;
    path.lineTo(last.dx, last.dy);
    return path;
  }

  List<Offset> _segmentCenters(BoardMetrics metrics, Worm worm) {
    final result = escapeResult;
    final direction = result?.direction;
    if (result?.wormId != worm.id || direction == null) {
      return [for (final cell in worm.cells) metrics.centerOf(cell)];
    }

    final radius = metrics.cellSize * 0.42;
    final baseCenters = [
      for (final cell in worm.cells.reversed) metrics.centerOf(cell),
    ];
    final forwardCenters = [
      for (var step = 1; step <= result!.escapeCells.ceil() + 2; step++)
        metrics.centerAt(
          row: worm.front.row + direction.rowDelta * step.toDouble(),
          col: worm.front.col + direction.colDelta * step.toDouble(),
        ),
    ];
    final basePath = _smoothWormPath(baseCenters, radius);
    final trackPath = _smoothWormPath([
      ...baseCenters,
      ...forwardCenters,
    ], radius);
    final crawlDistance =
        result.escapeCells * metrics.cellSize * escapeProgress;

    return [
      for (var index = 0; index < worm.cells.length; index++)
        _pointOnPath(
              trackPath,
              _nearestDistanceOnPath(
                    basePath,
                    metrics.centerOf(worm.cells[index]),
                    metrics.cellSize * 0.08,
                  ) +
                  crawlDistance,
            ) ??
            metrics.centerOf(worm.cells[index]),
    ];
  }

  void _drawFace(
    Canvas canvas,
    BoardMetrics metrics,
    Worm worm,
    Offset headCenter,
  ) {
    if (worm.cells.length < 2) {
      return;
    }
    final main = _faceDirection(worm);
    final normal = Offset(-main.dy, main.dx);
    final eyeCenter = headCenter + main * (metrics.cellSize * 0.11);
    final eyeOffset = normal * (metrics.cellSize * 0.095);
    final eyeRadius = metrics.cellSize * 0.088;
    final pupilRadius = metrics.cellSize * 0.043;
    final pupilShift = main * (metrics.cellSize * 0.02);
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = const Color(0xff1f2e41);
    final shadowPaint = Paint()..color = const Color(0x2d000000);

    for (final offset in [eyeOffset, -eyeOffset]) {
      final eye = eyeCenter + offset;
      canvas.drawCircle(eye + const Offset(0, 0.8), eyeRadius, shadowPaint);
      canvas.drawCircle(eye, eyeRadius, eyePaint);
      canvas.drawCircle(eye + pupilShift, pupilRadius, pupilPaint);
      canvas.drawCircle(
        eye + pupilShift + Offset(-pupilRadius * 0.32, -pupilRadius * 0.32),
        pupilRadius * 0.28,
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
    }
  }

  Offset _faceDirection(Worm worm) {
    final direction = escapeResult?.wormId == worm.id
        ? escapeResult?.direction
        : null;
    if (direction != null) {
      return Offset(
        direction.colDelta.toDouble(),
        direction.rowDelta.toDouble(),
      );
    }

    final cell = worm.front;
    final neighbor = worm.cells[1];
    return Offset(
      (cell.col - neighbor.col).toDouble(),
      (cell.row - neighbor.row).toDouble(),
    );
  }

  Offset? _pointOnPath(Path path, double distance) {
    final metric = _firstMetric(path);
    if (metric == null) {
      return null;
    }

    final clampedDistance = distance.clamp(0.0, metric.length).toDouble();
    return metric.getTangentForOffset(clampedDistance)?.position;
  }

  double _nearestDistanceOnPath(Path path, Offset target, double sampleEvery) {
    final metric = _firstMetric(path);
    if (metric == null) {
      return 0;
    }

    var bestDistance = 0.0;
    var bestDistanceSquared = double.infinity;
    final step = math.max(1.5, sampleEvery);

    for (var distance = 0.0; distance <= metric.length; distance += step) {
      final position = metric.getTangentForOffset(distance)?.position;
      if (position == null) {
        continue;
      }

      final distanceSquared = (position - target).distanceSquared;
      if (distanceSquared < bestDistanceSquared) {
        bestDistanceSquared = distanceSquared;
        bestDistance = distance;
      }
    }

    final endPosition = metric.getTangentForOffset(metric.length)?.position;
    if (endPosition != null) {
      final distanceSquared = (endPosition - target).distanceSquared;
      if (distanceSquared < bestDistanceSquared) {
        bestDistance = metric.length;
      }
    }

    return bestDistance;
  }

  ui.PathMetric? _firstMetric(Path path) {
    for (final metric in path.computeMetrics()) {
      return metric;
    }
    return null;
  }

  void _drawCrash(Canvas canvas, BoardMetrics metrics, BoardCell cell) {
    final center = metrics.centerOf(cell);
    final radius = metrics.cellSize * 0.4;
    final paint = Paint()
      ..color = const Color(0xffff334f)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = metrics.cellSize * 0.07;

    canvas.drawCircle(center, radius, paint);
    for (final angle in [0.0, math.pi / 2, math.pi, math.pi * 1.5]) {
      final start = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      final end =
          center + Offset(math.cos(angle), math.sin(angle)) * radius * 1.38;
      canvas.drawLine(start, end, paint);
    }
  }

  void _drawEscapePulse(Canvas canvas, BoardMetrics metrics, BoardCell cell) {
    final center = metrics.centerOf(cell);
    canvas.drawCircle(
      center,
      metrics.cellSize * 0.44,
      Paint()
        ..color = const Color(0xff30c979)
        ..style = PaintingStyle.stroke
        ..strokeWidth = metrics.cellSize * 0.07,
    );
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) {
    return oldDelegate.worms != worms ||
        oldDelegate.feedback != feedback ||
        oldDelegate.escapeResult != escapeResult ||
        oldDelegate.escapeProgress != escapeProgress;
  }
}

class _AvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.44;
    canvas.drawCircle(
      center + const Offset(0, 2),
      radius,
      Paint()..color = const Color(0x26324666),
    );
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xffffbf38));
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xffeb8a20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.08,
    );

    final leftEye = center + Offset(-size.width * 0.12, -size.height * 0.08);
    final rightEye = center + Offset(size.width * 0.12, -size.height * 0.02);
    for (final eye in [leftEye, rightEye]) {
      canvas.drawCircle(
        eye,
        size.shortestSide * 0.13,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        eye + Offset(size.width * 0.03, size.height * 0.02),
        size.shortestSide * 0.065,
        Paint()..color = const Color(0xff21334e),
      );
    }
  }

  @override
  bool shouldRepaint(_AvatarPainter oldDelegate) => false;
}
