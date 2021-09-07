import 'dart:ui';
import 'dart:math' as Math;

import 'package:flutter/cupertino.dart';

import 'ioscustomcontrols.dart';

/// A circular progress bar
class CircleProgressBar extends StatelessWidget {
  final Color backgroundColor;
  final Color foregroundColor;
  final double value;
  final double thickness;
  final double internalThickness;
  final String text;
  final double angleSpan;
  final bool dashboardMode;

  /// Creates a new circular progress indicator, with the specified
  /// [backgroundColor], [foregroundColor] and value.
  ///
  /// Value can vary from 0 to 1.
  const CircleProgressBar({
    Key key,
    this.backgroundColor,
    this.text = '',
    this.angleSpan = 1,
    this.thickness = 6,
    this.internalThickness,
    this.dashboardMode = false,
    @required this.foregroundColor,
    @required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = this.backgroundColor;
    final foregroundColor = this.foregroundColor;
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        child: Container(
          alignment: Alignment.center,
          child: Text(
            this.text,
            style: CustomCupertinoTextStyles.blackStyle,
          ),
        ),
        foregroundPainter: CircleProgressBarPainter(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            percentage: this.value,
            bPercentage: this.angleSpan,
            strokeWidth: this.thickness,
            internalStrokeWidth: this.internalThickness,
            dashboardMode: this.dashboardMode),
      ),
    );
  }
}

/// Draws a circular progress indicator given the [percentage],
/// the [strokeWidth] and the colors.
class CircleProgressBarPainter extends CustomPainter {
  final double percentage;
  final double bPercentage;
  final double strokeWidth;
  final double internalStrokeWidth;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool dashboardMode;

  CircleProgressBarPainter({
    this.backgroundColor,
    @required this.foregroundColor,
    @required this.percentage,
    this.bPercentage = 1,
    this.strokeWidth = 6,
    this.internalStrokeWidth,
    this.dashboardMode = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final Size constrainedSize =
        size - Offset(this.strokeWidth, this.strokeWidth);
    final shortestSide =
        Math.min(constrainedSize.width, constrainedSize.height);
    final foregroundPaint = Paint()
      ..color = this.foregroundColor
      ..strokeWidth = this.strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final radius = (shortestSide / 2);

    // Start at the top. 0 radians represents the right edge
    final double startAngle = -((dashboardMode ? 5 : 2) * Math.pi * 0.25);
    final double sweepAngle =
        (2 * Math.pi * (this.percentage ?? 0)) * bPercentage;

    // Don't draw the background if we don't have a background color
    if (this.backgroundColor != null) {
      final backgroundPaint = Paint()
        ..color = this.backgroundColor
        ..strokeWidth = this.internalStrokeWidth ?? this.strokeWidth / 2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final double sweepBAngle = (2 * Math.pi * (this.bPercentage ?? 0));
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepBAngle,
        false,
        backgroundPaint,
      );
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    final oldPainter = (oldDelegate as CircleProgressBarPainter);
    return oldPainter.percentage != this.percentage ||
        oldPainter.backgroundColor != this.backgroundColor ||
        oldPainter.foregroundColor != this.foregroundColor ||
        oldPainter.strokeWidth != this.strokeWidth;
  }
}
