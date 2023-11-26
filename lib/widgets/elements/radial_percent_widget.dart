import 'dart:math';
import 'package:flutter/material.dart';

// class PercentCircle extends StatelessWidget {
//   const PercentCircle({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 50,
//       height: 50,
//       child: RadialPercentWidget(
//         percent: 0.72,
//         fillColor: Colors.deepOrange,
//         lineColor: Colors.blue,
//         freeColor: Colors.grey,
//         lineWidth: 5,
//         child: Text(
//           '72%',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 12,
//           ),
//         ),
//       ),
//     );
//   }
// }

class RadialPercentWidget extends StatelessWidget {
  final Widget child;

  final double percent;
  final Color fillColor;
  final Color lineColor;
  final Color freeColor;
  final double lineWidth;

  const RadialPercentWidget({
    Key? key,
    required this.child,
    required this.percent,
    required this.fillColor,
    required this.lineColor,
    required this.freeColor,
    required this.lineWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: CircularPainter(
            percent: percent,
            fillColor: fillColor,
            freeColor: freeColor,
            lineColor: lineColor,
            lineWidth: lineWidth,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: child,
          ),
        )
      ],
    );
  }
}

class CircularPainter extends CustomPainter {
  final double percent;
  final Color fillColor;
  final Color lineColor;
  final Color freeColor;
  final double lineWidth;

  CircularPainter({
    required this.percent,
    required this.fillColor,
    required this.freeColor,
    required this.lineColor,
    required this.lineWidth,
  });

  // final double percent = 0.72;
  @override
  void paint(Canvas canvas, Size size) {
    final arcRect = calculateRect(size);
    drawBackground(canvas, size);
    drawFreeArc(canvas, arcRect);
    drawFilledArc(canvas, arcRect);
  }

  void drawFilledArc(Canvas canvas, Rect arcRect) {
       final paint = Paint();
    paint.color = lineColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = lineWidth;
    paint.strokeCap = StrokeCap.round;
    canvas.drawArc(
      arcRect,
      -pi / 2,
      pi * 2 * percent,
      false,
      paint,
    );
  }

  void drawFreeArc(Canvas canvas, Rect arcRect) {
     final paint = Paint();
    paint.color = freeColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = lineWidth;
    paint.strokeCap = StrokeCap.round;
    canvas.drawArc(
      arcRect,
      pi * 2 * percent - (pi / 2),
      pi * 2 * (1.0 - percent),
      false,
      paint,
    );
  }

  void drawBackground(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = fillColor;
    paint.style = PaintingStyle.fill;
    canvas.drawOval(Offset.zero & size, paint);
  }

  Rect calculateRect(Size size) {
    final lineMargin = 3;
    final offset = lineWidth / 2 + lineMargin;
    final arcRect = Offset(offset, offset) &
        Size(
          size.width - offset * 2,
          size.height - offset * 2,
        );
    return arcRect;
  }

  @override
  bool shouldRepaint(CircularPainter oldDelegate) => true;

  // @override
  // bool shouldRebuildSemantics(CircularPainter oldDelegate) => true;
}
