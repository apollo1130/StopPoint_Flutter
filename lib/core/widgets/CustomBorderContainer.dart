
import 'package:flutter/material.dart';

class CustomBorderContainer extends StatelessWidget {
  final _GradientPainter _painter;
  final Widget _child;
  final double width;
  final double height;
  CustomBorderContainer({
    @required double strokeWidth,
    @required Gradient gradient,
    @required Widget child,
    double width,
    double height
  })  : this._painter = _GradientPainter(strokeWidth: strokeWidth, gradient: gradient),
        this._child = child,
        this.width = width,
        this.height = height;

  @override
  Widget build(BuildContext context) {

    return CustomPaint(
      painter: _painter,
      child: Container(
        width: width,
        height: height,
        child: Center(
          child: _child
        ),
      ),
    );
  }
}

class _GradientPainter extends CustomPainter {
  final Paint _paint = Paint();
  final double strokeWidth;
  final Gradient gradient;

  _GradientPainter({@required double strokeWidth, @required Gradient gradient})
      : this.strokeWidth = strokeWidth,
        this.gradient = gradient;

  @override
  void paint(Canvas canvas, Size size) {
    // create outer rectangle equals size

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Path path = Path();
    path.lineTo(size.width/2, 0);
    path.moveTo(0, 0);
    path.lineTo(0, size.height/2);
    path.moveTo(size.width, size.height);
    path.lineTo(size.width, size.height/2);
    path.moveTo(size.width, size.height);
    path.lineTo(size.width/2, size.height);
    canvas.drawPath(path, paint);


  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}
