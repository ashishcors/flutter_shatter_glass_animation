import 'dart:math';

import 'package:delaunay_triangulation/delaunay_triangulation.dart';
import 'package:flutter/material.dart';

///Inspired by https://codepen.io/willhelm/pen/GqBVRA

class Fragment extends StatefulWidget {
  final Widget child;
  final double posX;
  final double posY;
  final Offset center;
  final double delay;
  final int duration;
  final Face face;
  final AnimationController controller;

  const Fragment(this.controller, this.child, this.posX, this.posY, this.delay,
      this.duration, this.face, this.center,
      {Key key})
      : super(key: key);

  @override
  _FragmentState createState() => _FragmentState();
}

class _FragmentState extends State<Fragment>
    with SingleTickerProviderStateMixin {
  Animation<double> _rx;
  Animation<double> _opacity;
  Interval curve;

  @override
  void initState() {
    super.initState();
    curve = Interval(
      (widget.delay / widget.duration),
      1.0,
      curve: Curves.fastOutSlowIn,
    );
    double signX = _sign(widget.face.centroid.x - widget.posX);
    print(signX);
    _rx = Tween(begin: 0.0, end: 60.0 * signX).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: curve,
      ),
    );
    _opacity = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: curve,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      AnimatedBuilder(
        animation: widget.controller,
        builder: _buildAnimation,
      ),
    ]);
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Stack(
      children: [
        Transform(
          origin: Offset(widget.center.dx, widget.center.dy * 2),
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.01)
            ..setRotationX(_rx.value * pi / 180),
          child: Opacity(
            opacity: _opacity.value,
            child: widget.child,
          ),
        ),
      ],
    );
  }

  double _sign(x) {
    return x < 0 ? -1 : 1;
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
