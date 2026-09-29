import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:fumble/utils/colors.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';

enum FlumbleAuraPhase { idle, sharing, expired }

/// Soft galaxy Aura — orbital glow + sparse star points around a center mark.
class FlumbleAura extends StatefulWidget {
  const FlumbleAura({
    super.key,
    required this.size,
    this.phase = FlumbleAuraPhase.idle,
    this.child,
    this.onTap,
  });

  final double size;
  final FlumbleAuraPhase phase;
  final Widget? child;
  final VoidCallback? onTap;

  @override
  State<FlumbleAura> createState() => _FlumbleAuraState();
}

class _FlumbleAuraState extends State<FlumbleAura>
    with TickerProviderStateMixin {
  late final AnimationController _orbit;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    _sync();
  }

  @override
  void didUpdateWidget(FlumbleAura oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase) _sync();
  }

  void _sync() {
    final live = widget.phase == FlumbleAuraPhase.sharing;
    if (live) {
      _orbit.repeat();
      _pulse.repeat(reverse: true);
    } else {
      _orbit
        ..stop()
        ..value = 0;
      _pulse
        ..stop()
        ..value = 0.45;
    }
  }

  @override
  void dispose() {
    _orbit.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dimmed = widget.phase == FlumbleAuraPhase.expired;

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([_orbit, _pulse]),
          builder: (context, _) {
            final breath = 1.0 + _pulse.value * 0.018;
            return Opacity(
              opacity: dimmed ? 0.35 : 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size.square(widget.size),
                    painter: _GalaxyPainter(
                      orbit: _orbit.value,
                      pulse: _pulse.value,
                      active: widget.phase == FlumbleAuraPhase.sharing,
                    ),
                  ),
                  Transform.scale(
                    scale: breath,
                    child: widget.child ?? _Core(size: widget.size * 0.34),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Core extends StatelessWidget {
  const _Core({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            AppColors.white,
            AppColors.gold,
            AppColors.goldDeep,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.35),
            blurRadius: 28,
            spreadRadius: 1,
          ),
        ],
      ),
      child: 'F'.toText(
        color: AppColors.background,
        fontSize: size * 0.42,
        fontWeight: AppStyle.w800,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _GalaxyPainter extends CustomPainter {
  _GalaxyPainter({
    required this.orbit,
    required this.pulse,
    required this.active,
  });

  final double orbit;
  final double pulse;
  final bool active;

  static const _starCount = 42;
  static final _stars = List<_Star>.generate(_starCount, (i) {
    final t = i * 0.6180339887;
    return _Star(
      angle: t * math.pi * 2,
      radius: 0.42 + (i % 7) * 0.07 + (t % 0.05),
      size: 0.6 + (i % 5) * 0.35,
      phase: (i * 0.17) % 1.0,
      bright: i % 4 == 0,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final spin = orbit * math.pi * 2;

    // Soft nebula haze (single blurred disc — cheap).
    canvas.drawCircle(
      center,
      radius * 0.9,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.07 + pulse * 0.04)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 36),
    );

    // Soft orbital rings.
    const ringRadii = [0.52, 0.68, 0.84];
    for (var i = 0; i < ringRadii.length; i++) {
      final r = radius * ringRadii[i];
      final alpha = 0.10 + (i == 1 ? 0.06 : 0) + pulse * 0.04;
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = AppColors.gold.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = i == 1 ? 1.4 : 0.9,
      );

      // Sparse arc highlight that drifts with orbit.
      if (active) {
        final start = spin * (i.isEven ? 1 : -0.7) + i;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: r),
          start,
          0.9,
          false,
          Paint()
            ..color = AppColors.gold.withValues(alpha: 0.28)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    // Slow comet trail on outer orbit.
    if (active) {
      final trailAngle = -spin * 0.85;
      final trailR = radius * 0.84;
      for (var i = 0; i < 8; i++) {
        final a = trailAngle - i * 0.08;
        final p = Offset(
          center.dx + trailR * math.cos(a),
          center.dy + trailR * math.sin(a),
        );
        canvas.drawCircle(
          p,
          1.8 - i * 0.15,
          Paint()
            ..color = AppColors.gold.withValues(alpha: 0.22 - i * 0.022),
        );
      }
    }

    // Glowing star points — no per-star blur.
    for (final star in _stars) {
      final drift = active ? spin * (star.bright ? 0.35 : -0.22) : 0.0;
      final a = star.angle + drift;
      final r = radius * star.radius;
      final twinkle =
          0.35 + 0.65 * (0.5 + 0.5 * math.sin((pulse + star.phase) * math.pi * 2));
      final p = Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a));
      final s = star.size * (0.85 + twinkle * 0.25);

      if (star.bright) {
        canvas.drawCircle(
          p,
          s * 2.4,
          Paint()..color = AppColors.gold.withValues(alpha: 0.10 * twinkle),
        );
      }
      canvas.drawCircle(
        p,
        s,
        Paint()
          ..color = (star.bright ? AppColors.gold : AppColors.goldMuted)
              .withValues(alpha: 0.35 + 0.45 * twinkle),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GalaxyPainter oldDelegate) {
    return oldDelegate.orbit != orbit ||
        oldDelegate.pulse != pulse ||
        oldDelegate.active != active;
  }
}

class _Star {
  const _Star({
    required this.angle,
    required this.radius,
    required this.size,
    required this.phase,
    required this.bright,
  });

  final double angle;
  final double radius;
  final double size;
  final double phase;
  final bool bright;
}
