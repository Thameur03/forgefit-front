import 'dart:math';
import 'package:flutter/material.dart';

class ProgressRingWidget extends StatelessWidget {
  final double value;
  final double maxValue;
  final Color ringColor;
  final String centerText;
  final String centerSubText;
  final String label;
  final String? subLabel;
  final double size;
  final double strokeWidth;
  final Animation<double> animation;

  const ProgressRingWidget({
    super.key,
    required this.value,
    required this.maxValue,
    required this.ringColor,
    required this.centerText,
    required this.centerSubText,
    required this.label,
    this.subLabel,
    this.size = 72,
    this.strokeWidth = 6,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final progress = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;

    return SizedBox(
      width: size + 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return SizedBox(
                width: size,
                height: size,
                child: CustomPaint(
                  painter: _RingPainter(
                    progress: progress * animation.value,
                    ringColor: ringColor,
                    trackColor: ringColor.withAlpha(40),
                    strokeWidth: strokeWidth,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          centerText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          centerSubText,
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 9,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subLabel != null)
            Text(
              subLabel!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withAlpha(130),
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color trackColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.ringColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.ringColor != ringColor;
  }
}
