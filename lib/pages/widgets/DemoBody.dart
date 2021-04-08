import 'dart:math';
import 'package:vector_math/vector_math.dart' as Vector;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
class DemoBody extends StatefulWidget {
  final Size size;
  final int xOffset;
  final int yOffset;
  final Color color;
  final AnimationController controller;

  DemoBody(
      {Key key, @required this.size, this.xOffset, this.yOffset, this.color, this.controller})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _DemoBodyState();
  }
}

class _DemoBodyState extends State<DemoBody> with TickerProviderStateMixin {
  AnimationController animationController;
  List<Offset> animList1 = [];

  @override
  void initState() {
    super.initState();
    animationController = widget.controller;

    animationController.addListener(() {
      animList1.clear();
      for (int i = -2 - widget.xOffset;
      i <= widget.size.width.toInt() + 2;
      i++) {
        animList1.add(new Offset(
            i.toDouble() + widget.xOffset,
            sin((animationController.value * 180 - i) %
                360 *
                Vector.degrees2Radians) *
                20 +
                20 +
                widget.yOffset));
      }
    });
    animationController.forward(from: 100);
  }

  @override
  void dispose() {
//    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.grey[100],
      alignment: Alignment.center,
      child: new AnimatedBuilder(
        animation: new CurvedAnimation(
          parent: animationController,
          curve: Curves.easeInOut,
        ),
        builder: (context, child) => new ClipPath(
          child: widget.color == null
              ? Image.asset(
            'images/demo5bg.jpg',
            width: widget.size.width,
            height: widget.size.height,
            fit: BoxFit.cover,
          )
              : new Container(
            width: widget.size.width,
            height: widget.size.height,
            color: widget.color,
          ),
          clipper: new WaveClipper(animationController.value, animList1),
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double animation;

  List<Offset> waveList1 = [];

  WaveClipper(this.animation, this.waveList1);

  @override
  Path getClip(Size size) {
    Path path = new Path();

    path.addPolygon(waveList1, false);

    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) =>
      animation != oldClipper.animation;
}