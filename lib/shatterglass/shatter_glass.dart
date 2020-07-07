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
    if (!_controller.isAnimating || _controller.isCompleted) {
      return GestureDetector(
        onTapDown: (TapDownDetails details) => onTapDown(context, details),
        child: child,
      );
    }
    final Offset origin = Offset(MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2);

    int index = 0;
    final int size = triangulation.faces.length;
    //TODO create mapIndexed extension
    return Stack(
      children: <Widget>[
        ...triangulation.faces.map((e) {
          double delay = (index++ / size) *
              widget.duration.inSeconds *
              _randomRange(0.8, 0.9);
          return Fragment(_controller, _clip(e, child), posX, posY, delay,
              widget.duration.inSeconds, e, origin);
        }),
      ],
    );
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

  ClipPath _clip(Face face, Widget widget) {
    return ClipPath(
      clipper: MyCustomClipper(face),
      child: widget,
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
