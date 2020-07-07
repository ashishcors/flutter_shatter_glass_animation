import 'dart:math';

import 'package:animationplayground/shatterglass/fragment.dart';
import 'package:delaunay_triangulation/delaunay_triangulation.dart';
import 'package:flutter/material.dart';

class ShatterGlass extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShatterGlass({Key key, this.child, this.duration}) : super(key: key);

  @override
  _ShatterGlassState createState() => _ShatterGlassState(child);
}

class _ShatterGlassState extends State<ShatterGlass>
    with TickerProviderStateMixin {
  final Widget child;

  _ShatterGlassState(this.child);

  AnimationController _controller;
  double posX = 0.0;
  double posY = 0.0;

  DelaunayTriangulation triangulation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(_controller.value);
    if (!_controller.isAnimating || _controller.isCompleted) {
      return GestureDetector(
        onTapDown: (TapDownDetails details) => onTapDown(context, details),
        child: child,
      );
    }
//    return faceToFragment(triangulation.faces.first);
    return Stack(
      children: <Widget>[
        ...triangulation.faces.map((e) {
          return faceToFragment(e);
        }),
      ],
    );
  }

  Fragment faceToFragment(Face face) {
    double dx = (face.centroid.x - posX),
        dy = (face.centroid.y - posY),
        d = sqrt(dx * dx + dy * dy),
        delay = d * 0.003 * _randomRange(0.9, 1.1);
    return Fragment(
        _controller, child, posX, posY, delay, widget.duration.inSeconds, face);
  }

  void onTapDown(BuildContext context, TapDownDetails details) {
    print('${details.globalPosition}');
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    setState(() {
      _controller.reset();
      posX = localOffset.dx;
      posY = localOffset.dy;
      triangulation = _triangulate(posX, posY);
      _controller.forward();
    });
  }

  DelaunayTriangulation _triangulate(double centerX, double centerY) {
    const double TWO_PI = 2 * pi;
    final vertices = List<Offset>();
    vertices.add(Offset(centerX, centerY));
    final rings = [
      [50, 12],
      [150, 12],
      [300, 12],
      [1200, 12]
    ];
    rings.forEach((element) {
      int radius = element[0];
      int count = element[1];
      double variance = radius * 0.25;
      for (var i = 0; i < count; i++) {
        double x = cos((i / count) * TWO_PI) * radius +
            centerX +
            _randomRange(-variance, variance);
        double y = sin((i / count) * TWO_PI) * radius +
            centerY +
            _randomRange(-variance, variance);
        vertices.add(Offset(x, y));
      }
    });
    var triangulation = DelaunayTriangulation(
      vertices.map((e) => Vertex(e.dx, e.dy)),
    );
    return triangulation;
  }

  double _randomRange(min, max) {
    double op = min + (max - min) * Random().nextDouble();
    return op;
  }
}
