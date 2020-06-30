import 'package:flutter/material.dart';

class RateUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Star(),
        ],
      ),
    );
  }
}

class Star extends StatefulWidget {
  @override
  _StarState createState() => _StarState(false);
}

class _StarState extends State<Star> {
  bool _isVisible;

  _StarState(this._isVisible);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(seconds: 5),
      opacity: _isVisible ? 1.0 : 0.0,
      child: Icon(
        Icons.star,
        color: Colors.orange,
      ),
    );
  }
}
