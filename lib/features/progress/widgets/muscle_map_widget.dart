import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../auth/widgets/onboarding_widgets.dart';
import '../models/muscle_volume_model.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// PUBLIC WIDGET
// ═══════════════════════════════════════════════════════════════════════════════

class MuscleMapWidget extends StatefulWidget {
  final List<MuscleVolumeModel> muscleData;
  final Function(String muscleGroup) onMuscleTap;

  const MuscleMapWidget({
    super.key,
    required this.muscleData,
    required this.onMuscleTap,
  });

  @override
  State<MuscleMapWidget> createState() => _MuscleMapWidgetState();
}

class _MuscleMapWidgetState extends State<MuscleMapWidget> {
  bool _showFront = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Front / Back toggle ───────────────────────────────────────────
        _ViewToggle(
          showFront: _showFront,
          onToggle: (front) => setState(() => _showFront = front),
        ),
        const SizedBox(height: 12),
        // ── Muscle map canvas ─────────────────────────────────────────────
        Expanded(
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              final painter = _BodyPainter(
                showFront: _showFront,
                muscleData: widget.muscleData,
                size: size,
              );
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  final tapped = painter.findMuscle(details.localPosition);
                  if (tapped != null) widget.onMuscleTap(tapped);
                },
                child: CustomPaint(
                  painter: painter,
                  size: size,
                ),
              );
            },
          ),
        ),
        // ── Legend ────────────────────────────────────────────────────────
        const SizedBox(height: 8),
        _Legend(),
      ],
    );
  }
}

// ── Front / Back Toggle ───────────────────────────────────────────────────────

class _ViewToggle extends StatelessWidget {
  final bool showFront;
  final ValueChanged<bool> onToggle;

  const _ViewToggle({required this.showFront, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TogglePill(label: 'Front', active: showFront, onTap: () => onToggle(true)),
        const SizedBox(width: 8),
        _TogglePill(label: 'Back', active: !showFront, onTap: () => onToggle(false)),
      ],
    );
  }
}

class _TogglePill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TogglePill({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [OnboardingTheme.gradientStart, OnboardingTheme.gradientEnd],
                )
              : null,
          color: active ? null : OnboardingTheme.cardDark,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : Colors.white60,
          ),
        ),
      ),
    );
  }
}

// ── Legend ────────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendDot(color: OnboardingTheme.cardMid, label: 'Untrained'),
        const SizedBox(width: 12),
        _LegendDot(
            color: OnboardingTheme.accent.withValues(alpha: 0.5),
            label: 'Low'),
        const SizedBox(width: 12),
        _LegendDot(color: OnboardingTheme.accent, label: 'Medium'),
        const SizedBox(width: 12),
        _LegendDot(color: OnboardingTheme.success, label: 'High'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white60)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CUSTOM PAINTER
// ═══════════════════════════════════════════════════════════════════════════════

class _BodyPainter extends CustomPainter {
  final bool showFront;
  final List<MuscleVolumeModel> muscleData;
  final Size size;

  // Muscle paths built during paint — used for hit testing
  late Map<String, Path> _musclePaths;

  _BodyPainter({
    required this.showFront,
    required this.muscleData,
    required this.size,
  });

  // ── Intensity colour ──────────────────────────────────────────────────────

  Color _muscleColor(String group) {
    if (muscleData.isEmpty) return OnboardingTheme.cardMid;
    final item = muscleData.where((m) => m.muscleGroup == group).firstOrNull;
    if (item == null) return OnboardingTheme.cardMid;

    final maxVol = muscleData.map((m) => m.totalVolumeKg).reduce(math.max);
    if (maxVol <= 0) return OnboardingTheme.cardMid;

    final ratio = item.totalVolumeKg / maxVol;
    if (ratio < 0.33) return OnboardingTheme.accent.withValues(alpha: 0.5);
    if (ratio < 0.67) return OnboardingTheme.accent;
    return OnboardingTheme.success;
  }

  // ── Hit test ──────────────────────────────────────────────────────────────

  String? findMuscle(Offset point) {
    for (final entry in _musclePaths.entries) {
      if (entry.value.contains(point)) return entry.key;
    }
    return null;
  }

  // ── Coordinate helpers ────────────────────────────────────────────────────
  // Normalised coordinate system: 200 × 420 units
  // Origin at top-left, x increases right, y increases down.

  static const double _kW = 200;
  static const double _kH = 420;

  Offset _p(double nx, double ny) => Offset(
        nx / _kW * size.width,
        ny / _kH * size.height,
      );

  double _sx(double n) => n / _kW * size.width;
  double _sy(double n) => n / _kH * size.height;

  Rect _r(double l, double t, double r, double b) => Rect.fromLTRB(
        _sx(l),
        _sy(t),
        _sx(r),
        _sy(b),
      );

  RRect _rr(double l, double t, double r, double b, double radius) =>
      RRect.fromRectAndRadius(_r(l, t, r, b), Radius.circular(_sx(radius)));

  // ── Paint ─────────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    _musclePaths = {};
    _drawSilhouette(canvas);
    if (showFront) {
      _drawFront(canvas);
    } else {
      _drawBack(canvas);
    }
  }

  void _drawSilhouette(Canvas canvas) {
    final basePaint = Paint()
      ..color = OnboardingTheme.cardDark
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = OnboardingTheme.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = _sx(1.5);

    // Head
    final headCenter = _p(100, 30);
    final headRadius = _sx(18);
    canvas.drawCircle(headCenter, headRadius, basePaint);
    canvas.drawCircle(headCenter, headRadius, outlinePaint);

    // Neck
    canvas.drawRRect(_rr(90, 46, 110, 58, 3), basePaint);

    // Torso
    final torsoPath = Path()
      ..moveTo(_sx(66), _sy(58))
      ..lineTo(_sx(134), _sy(58))
      ..lineTo(_sx(128), _sy(210))
      ..lineTo(_sx(72), _sy(210))
      ..close();
    canvas.drawPath(torsoPath, basePaint);
    canvas.drawPath(torsoPath, outlinePaint);

    // Upper arms (both sides)
    canvas.drawRRect(_rr(42, 62, 64, 150, 10), basePaint);
    canvas.drawRRect(_rr(42, 62, 64, 150, 10), outlinePaint);
    canvas.drawRRect(_rr(136, 62, 158, 150, 10), basePaint);
    canvas.drawRRect(_rr(136, 62, 158, 150, 10), outlinePaint);

    // Forearms
    canvas.drawRRect(_rr(40, 152, 62, 220, 8), basePaint);
    canvas.drawRRect(_rr(40, 152, 62, 220, 8), outlinePaint);
    canvas.drawRRect(_rr(138, 152, 160, 220, 8), basePaint);
    canvas.drawRRect(_rr(138, 152, 160, 220, 8), outlinePaint);

    // Upper legs
    canvas.drawRRect(_rr(72, 210, 98, 315, 10), basePaint);
    canvas.drawRRect(_rr(72, 210, 98, 315, 10), outlinePaint);
    canvas.drawRRect(_rr(102, 210, 128, 315, 10), basePaint);
    canvas.drawRRect(_rr(102, 210, 128, 315, 10), outlinePaint);

    // Lower legs
    canvas.drawRRect(_rr(72, 318, 96, 410, 8), basePaint);
    canvas.drawRRect(_rr(72, 318, 96, 410, 8), outlinePaint);
    canvas.drawRRect(_rr(104, 318, 128, 410, 8), basePaint);
    canvas.drawRRect(_rr(104, 318, 128, 410, 8), outlinePaint);
  }

  // ── FRONT muscles ─────────────────────────────────────────────────────────

  void _drawFront(Canvas canvas) {
    _drawMuscle(canvas, 'Chest', _chestPath());
    _drawMuscle(canvas, 'Shoulders', _frontShoulderPath());
    _drawMuscle(canvas, 'Biceps', _bicepsPath());
    _drawMuscle(canvas, 'Abs', _absPath());
    _drawMuscle(canvas, 'Quads', _quadsPath());
    _drawMuscle(canvas, 'Calves', _frontCalvesPath());
  }

  Path _chestPath() {
    final p = Path();
    p.addRRect(_rr(70, 65, 95, 105, 8));   // left pec
    p.addRRect(_rr(105, 65, 130, 105, 8));  // right pec
    return p;
  }

  Path _frontShoulderPath() {
    final p = Path();
    // Left deltoid
    p.addOval(_r(44, 58, 68, 90));
    // Right deltoid
    p.addOval(_r(132, 58, 156, 90));
    return p;
  }

  Path _bicepsPath() {
    final p = Path();
    p.addOval(_r(45, 92, 63, 148));   // left
    p.addOval(_r(137, 92, 155, 148)); // right
    return p;
  }

  Path _absPath() {
    final p = Path();
    for (int row = 0; row < 3; row++) {
      final top = 108.0 + row * 30;
      final bot = top + 24;
      p.addRRect(_rr(78, top, 96, bot, 4));   // left column
      p.addRRect(_rr(104, top, 122, bot, 4)); // right column
    }
    return p;
  }

  Path _quadsPath() {
    final p = Path();
    p.addRRect(_rr(73, 213, 97, 308, 8));   // left
    p.addRRect(_rr(103, 213, 127, 308, 8)); // right
    return p;
  }

  Path _frontCalvesPath() {
    final p = Path();
    p.addRRect(_rr(73, 320, 95, 405, 8));  // left
    p.addRRect(_rr(105, 320, 127, 405, 8)); // right
    return p;
  }

  // ── BACK muscles ──────────────────────────────────────────────────────────

  void _drawBack(Canvas canvas) {
    _drawMuscle(canvas, 'Back', _backPath());
    _drawMuscle(canvas, 'Shoulders', _rearShoulderPath());
    _drawMuscle(canvas, 'Triceps', _tricepsPath());
    _drawMuscle(canvas, 'Glutes', _glutesPath());
    _drawMuscle(canvas, 'Hamstrings', _hamstringsPath());
    _drawMuscle(canvas, 'Calves', _backCalvesPath());
  }

  Path _backPath() {
    // Trapezius top + lats combined
    final p = Path()
      ..moveTo(_sx(74), _sy(60))
      ..lineTo(_sx(126), _sy(60))
      ..lineTo(_sx(132), _sy(85))
      ..lineTo(_sx(130), _sy(205))
      ..lineTo(_sx(70), _sy(205))
      ..lineTo(_sx(68), _sy(85))
      ..close();
    return p;
  }

  Path _rearShoulderPath() {
    final p = Path();
    p.addOval(_r(44, 58, 68, 90));
    p.addOval(_r(132, 58, 156, 90));
    return p;
  }

  Path _tricepsPath() {
    final p = Path();
    p.addOval(_r(45, 92, 63, 148)); // left
    p.addOval(_r(137, 92, 155, 148)); // right
    return p;
  }

  Path _glutesPath() {
    final p = Path();
    p.addRRect(_rr(72, 207, 98, 245, 12));   // left glute
    p.addRRect(_rr(102, 207, 128, 245, 12)); // right glute
    return p;
  }

  Path _hamstringsPath() {
    final p = Path();
    p.addRRect(_rr(73, 248, 97, 308, 8));   // left
    p.addRRect(_rr(103, 248, 127, 308, 8)); // right
    return p;
  }

  Path _backCalvesPath() {
    final p = Path();
    p.addRRect(_rr(73, 320, 95, 390, 8));
    p.addRRect(_rr(105, 320, 127, 390, 8));
    return p;
  }

  // ── Draw helper ───────────────────────────────────────────────────────────

  void _drawMuscle(Canvas canvas, String group, Path path) {
    _musclePaths[group] = path;
    final color = _muscleColor(group);

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _sx(0.8);

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(_BodyPainter old) =>
      old.showFront != showFront ||
      old.muscleData != muscleData ||
      old.size != size;
}
