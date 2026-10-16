// Bell button: Flutter port of KokonutUI's "Bell Button"
// Original by @dorianbaffier, MIT License, https://kokonutui.com
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';

// Angles in degrees, time in seconds.
const double _dt = 1 / 240;
const double _bellStiffness = 380;
const double _bellDamping = 5;
const double _clapperStiffness = 150;
const double _clapperDamping = 4;
const double _lip = 13;
const double _restitution = 0.45;
const double _recoil = 0.18;
const double _strikeSpeed = 260;
const double _ringKick = 600;
const double _nudgeKick = 160;
const double _muteKick = 300;
const double _rest = 0.05;
const double _waveSeconds = 0.42;
const Offset _pivot = Offset(12, 2.5);
const Cubic _easeOut = Cubic(0.23, 1, 0.32, 1);

final Path _bellBody = parseSvgPathData(
    'M3.26 15.33A1 1 0 0 0 4 17h16a1 1 0 0 0 .74-1.67C19.41 13.96 18 12.5 18 8A6 6 0 0 0 6 8c0 4.5-1.41 5.96-2.74 7.33');
final Path _clapperPath = parseSvgPathData('M10.27 21a2 2 0 0 0 3.46 0');
final Path _rightWavePath = parseSvgPathData('M21.5 4.5c1.2 1.6 1.8 3.4 1.8 5.5');
final Path _leftWavePath = parseSvgPathData('M2.5 4.5C1.3 6.1.7 7.9.7 10');

class _BellSim {
  _BellSim(this.onStrike);

  final VoidCallback onStrike;

  double bell = 0, bellSpeed = 0, clapper = 0, clapperSpeed = 0;
  bool muffled = false;

  double _peakL = 0, _peakR = 0;
  double _ageL = _waveSeconds, _ageR = _waveSeconds;

  void flare(int side, double strength) {
    final peak = math.min(1.0, 0.45 + strength * 0.55);
    if (side > 0) {
      _peakR = peak;
      _ageR = 0;
    } else {
      _peakL = peak;
      _ageL = 0;
    }
  }

  void advanceWaves(double dt) {
    _ageL += dt;
    _ageR += dt;
  }

  double waveProgress(int side) {
    final age = side > 0 ? _ageR : _ageL;
    return _easeOut.transform((age / _waveSeconds).clamp(0.0, 1.0).toDouble());
  }

  double waveOpacity(int side) {
    final peak = side > 0 ? _peakR : _peakL;
    return peak * (1 - waveProgress(side));
  }

  bool get _wavesActive => _ageL < _waveSeconds || _ageR < _waveSeconds;

  double get _energy =>
      bell.abs() +
      bellSpeed.abs() * 0.02 +
      clapper.abs() +
      clapperSpeed.abs() * 0.02;

  bool get atRest => _energy < _rest && !_wavesActive;

  void settle() {
    bell = 0;
    bellSpeed = 0;
    clapper = 0;
    clapperSpeed = 0;
  }

  // Advances both pendulums one step and resolves a clapper hit.
  void stepOnce() {
    bellSpeed += (-bell * _bellStiffness - bellSpeed * _bellDamping) * _dt;
    bell += bellSpeed * _dt;
    if (muffled) {
      clapper = bell;
      clapperSpeed = bellSpeed;
      return;
    }
    clapperSpeed +=
        (-clapper * _clapperStiffness - clapperSpeed * _clapperDamping) * _dt;
    clapper += clapperSpeed * _dt;
    final relative = clapper - bell;
    if (relative.abs() <= _lip) return;
    final side = relative > 0 ? 1 : -1;
    final impact = (clapperSpeed - bellSpeed) * side;
    clapper = bell + side * _lip;
    if (impact <= 0) return;
    clapperSpeed -= side * impact * (1 + _restitution);
    bellSpeed += side * impact * _recoil;
    if (impact > _strikeSpeed) {
      flare(side, impact / 1600);
      onStrike();
    }
  }
}

class BellButton extends StatefulWidget {
  const BellButton({
    super.key,
    this.subscribed = true,
    this.onSubscribedChanged,
    this.onTap,
    this.hasUnread = false,
    this.size = 22,
    this.color,
    this.badgeColor = const Color(0xFFD64545),
    this.tooltip = 'Notifications',
  });

  /// true = notifications on (bell filled). false = muted (slash across).
  final bool subscribed;

  /// Called on long-press with the new value. If null, long-press does nothing.
  final ValueChanged<bool>? onSubscribedChanged;

  /// Called on a normal tap (for example, open the Alerts tab).
  final VoidCallback? onTap;

  /// Shows a small unread dot (hidden while muted).
  final bool hasUnread;

  final double size;
  final Color? color;
  final Color badgeColor;
  final String tooltip;

  @override
  State<BellButton> createState() => _BellButtonState();
}

class _BellButtonState extends State<BellButton> with TickerProviderStateMixin {
  late final _BellSim _sim;
  late final Ticker _ticker;
  late final AnimationController _stateCtrl;
  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);

  Duration _last = Duration.zero;
  bool _hasLast = false;
  double _carry = 0;
  DateTime _lastNudge = DateTime.fromMillisecondsSinceEpoch(0);

  bool get _reduceMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  @override
  void initState() {
    super.initState();
    _sim = _BellSim(() => HapticFeedback.selectionClick())
      ..muffled = !widget.subscribed;
    _ticker = createTicker(_onTick);
    _stateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.subscribed ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(BellButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subscribed != widget.subscribed) {
      _sim.muffled = !widget.subscribed;
      if (widget.subscribed) {
        _stateCtrl.forward();
      } else {
        _stateCtrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _stateCtrl.dispose();
    _repaint.dispose();
    super.dispose();
  }

  void _onTick(Duration now) {
    final elapsed =
        _hasLast ? math.min((now - _last).inMicroseconds / 1e6, 0.05) : _dt;
    _last = now;
    _hasLast = true;
    _carry += elapsed;
    while (_carry >= _dt) {
      _sim.stepOnce();
      _carry -= _dt;
    }
    _sim.advanceWaves(elapsed);
    if (_sim.atRest) {
      _sim.settle();
      _ticker.stop();
      _hasLast = false;
    }
    _repaint.value++;
  }

  void _ensureRunning() {
    if (!_ticker.isActive) {
      _hasLast = false;
      _carry = 0;
      _ticker.start();
    }
  }

  void _kick(double speed) {
    if (_reduceMotion) return;
    _sim.bellSpeed += speed;
    _ensureRunning();
  }

  void _handleTap() {
    widget.onTap?.call();
    if (widget.subscribed) {
      _sim.muffled = false;
      // Swing the bell away from the clapper so the first hit rings.
      _kick(_sim.bellSpeed >= 0 ? _ringKick : -_ringKick);
      HapticFeedback.lightImpact();
    } else {
      _kick(-_muteKick);
    }
  }

  void _handleLongPress() {
    final next = !widget.subscribed;
    widget.onSubscribedChanged?.call(next);
    if (next) {
      _sim.muffled = false;
      _kick(_sim.bellSpeed >= 0 ? _ringKick : -_ringKick);
      if (_reduceMotion) {
        _sim.flare(1, 0.6);
        _sim.flare(-1, 0.6);
        _ensureRunning();
      }
    } else {
      _sim.muffled = true;
      _kick(-_muteKick);
    }
    HapticFeedback.mediumImpact();
  }

  void _nudge() {
    if (_sim.muffled) return;
    final now = DateTime.now();
    if (now.difference(_lastNudge).inMilliseconds < 700) return;
    _lastNudge = now;
    _kick(_sim.bellSpeed >= 0 ? _nudgeKick : -_nudgeKick);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ??
        IconTheme.of(context).color ??
        Theme.of(context).colorScheme.onSurface;

    return Semantics(
      button: true,
      toggled: widget.subscribed,
      label: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _nudge(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          onLongPress:
              widget.onSubscribedChanged == null ? null : _handleLongPress,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    size: Size.square(widget.size),
                    painter: _BellPainter(
                      sim: _sim,
                      state: _stateCtrl,
                      color: color,
                      repaint: Listenable.merge([_repaint, _stateCtrl]),
                    ),
                  ),
                ),
                if (widget.hasUnread && widget.subscribed)
                  Positioned(
                    top: 8,
                    right: 9,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.badgeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BellPainter extends CustomPainter {
  _BellPainter({
    required this.sim,
    required this.state,
    required this.color,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final _BellSim sim;
  final Animation<double> state;
  final Color color;

  Paint _stroke(Color c) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void _rotated(Canvas canvas, double degrees, VoidCallback draw) {
    canvas.save();
    canvas.translate(_pivot.dx, _pivot.dy);
    canvas.rotate(degrees * math.pi / 180);
    canvas.translate(-_pivot.dx, -_pivot.dy);
    draw();
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24);
    final stroke = _stroke(color);

    // Sound arcs flare out on the side that was struck.
    for (final side in const [1, -1]) {
      final opacity = sim.waveOpacity(side);
      if (opacity <= 0.001) continue;
      canvas.save();
      canvas.translate(side * 3 * sim.waveProgress(side), 0);
      canvas.drawPath(
        side > 0 ? _rightWavePath : _leftWavePath,
        _stroke(color.withValues(alpha: opacity)),
      );
      canvas.restore();
    }

    // The clapper swings on its own angle.
    _rotated(canvas, sim.clapper, () => canvas.drawPath(_clapperPath, stroke));

    // The bell, with fill (on) and the mute slash (off).
    _rotated(canvas, sim.bell, () {
      final fill = state.value;
      if (fill > 0.001) {
        canvas.drawPath(
          _bellBody,
          Paint()
            ..color = color.withValues(alpha: fill)
            ..style = PaintingStyle.fill,
        );
      }
      canvas.drawPath(_bellBody, stroke);
      final slash = 1 - state.value;
      if (slash > 0.001) {
        canvas.drawLine(
          const Offset(3, 3),
          Offset(3 + 18 * slash, 3 + 18 * slash),
          stroke,
        );
      }
    });

    canvas.restore();
  }

  @override
  bool shouldRepaint(_BellPainter old) => old.color != color;
}