import 'dart:math';

import 'package:delaunay_triangulation/delaunay_triangulation.dart';
import 'package:flutter/material.dart';

///Inspired by https://codepen.io/willhelm/pen/GqBVRA

class Fragment extends StatefulWidget {
  final Widget child;
  final double posX;
  final double posY;
  final double delay;
  final int duration;
  final Face face;
  final AnimationController controller;

  const Fragment(this.controller, this.child, this.posX, this.posY, this.delay,
      this.duration, this.face,
      {Key key})
      : super(key: key);

  @override
  _FragmentState createState() => _FragmentState();
}

class _FragmentState extends State<Fragment>
    with SingleTickerProviderStateMixin {
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Interval(
          (widget.delay / widget.duration),
          1.0,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Anim value " + _animation.value.toString());
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget child) {
        Face face = widget.face;
        double dx = (face.centroid.x - widget.posX) * (_animation.value),
            dy = (face.centroid.y - widget.posY) * (_animation.value),
            d = sqrt(dx * dx + dy * dy),
            rx = 30 * _sign(dy) * _animation.value,
            ry = 90 * -_sign(dx) * _animation.value;
        return Transform(
          origin: Offset(face.centroid.x, face.centroid.y),
          transform: Matrix4.translationValues(dx, dy, d)
            ..rotateX(rx * pi / 180)
            ..rotateY(ry * pi / 180),
          child: _clip(face, widget.child),
        );
      },
    );
  }

  double _sign(x) {
    return x < 0 ? -1 : 1;
  }

  ClipPath _clip(Face face, Widget widget) {
    return ClipPath(
      clipper: MyCustomClipper(face),
      child: widget,
    );
  }
}

class Point extends StatelessWidget {
  final x;
  final y;

  Point(this.x, this.y);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: y,
      left: x,
      child: Container(
        width: 5,
        height: 5,
        color: Colors.red,
      ),
    );
  }
}

class MyCustomClipper extends CustomClipper<Path> {
  MyCustomClipper(this._face);

  final Face _face;

  @override
  Path getClip(Size size) {
    List<Offset> points = [
      Offset(_face.a.x, _face.a.y),
      Offset(_face.b.x, _face.b.y),
      Offset(_face.c.x, _face.c.y),
    ];
    Path path = Path();
    path.addPolygon(points, false);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
