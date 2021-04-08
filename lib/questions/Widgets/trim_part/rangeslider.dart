import 'package:flutter/material.dart';

class CustomRangeThumbShape extends RangeSliderThumbShape {
  static const double _thumbSize = 10.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(_thumbSize, _thumbSize);

  @override
  void paint(PaintingContext context, Offset center,
      {Animation<double> activationAnimation,
      Animation<double> enableAnimation,
      bool isDiscrete,
      bool isEnabled,
      bool isOnTop,
      TextDirection textDirection,
      SliderThemeData sliderTheme,
      Thumb thumb,
      bool isPressed}) {
    final Canvas canvas = context.canvas;

    Path thumbPath;
    switch (textDirection) {
      case TextDirection.rtl:
        switch (thumb) {
          case Thumb.start:
            thumbPath = _rangePointer(_thumbSize, center);
            break;
          case Thumb.end:
            thumbPath = _rangePointer(_thumbSize, center);
            break;
        }
        break;
      case TextDirection.ltr:
        switch (thumb) {
          case Thumb.start:
            thumbPath = _rangePointer(_thumbSize, center);
            break;
          case Thumb.end:
            thumbPath = _rangePointer(_thumbSize, center);
            break;
        }
        break;
    }
    canvas.drawPath(thumbPath, Paint()..color = Colors.white);
  }
}

Path _rangePointer(double size, Offset thumbCenter) {
  final Path thumbPath = Path();
  thumbPath.addRect(Rect.fromCenter(center: thumbCenter, width: 15.0, height: 30.0));
  thumbPath.close();
  return thumbPath;
}
