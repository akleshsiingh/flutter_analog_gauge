import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DialGauge extends StatefulWidget {
  const DialGauge({Key? key}) : super(key: key);

  @override
  _DialGaugeState createState() => _DialGaugeState();
}

class _DialGaugeState extends State<DialGauge> {
  var _sliderValue = 0.0;
//  final items = [0, 5, 10, 25, 50, 52, 250, 500, 1000];
  final items =
      [0, 5, 10, 25, 50, 100, 250, 500, 1000].map((e) => e * 2).toList();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20.0),
          width: double.infinity,
          height: MediaQuery.of(context).size.height * .3,
          alignment: Alignment.center,
          child: CustomPaint(
            child: Container(),
            painter: SpeedChecker(value: _sliderValue, items: items),
          ),
        ),
        _fakeDataFeeder(context),
      ],
    );
  }

  SliderTheme _fakeDataFeeder(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.lightBlue,
        inactiveTrackColor: Colors.yellow,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15.0),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 30.0),
      ),
      child: Slider(
        value: _sliderValue,
        min: 0.0,
        max: 100.0,
        onChanged: (value) {
          setState(() {
            _sliderValue = value;
          });
        },
      ),
    );
  }
}

class SpeedChecker extends CustomPainter {
  final double value;
  final List items;
  SpeedChecker({required this.value, required this.items});

  var _centerX = 0.0;
  var _centerY = 0.0;
  var startFromAngle = 180; // this should be multiple of 30.0
  var _arcRadius = 180.0;
  var handHeight = 150;

  @override
  void paint(Canvas canvas, Size size) {
    _centerX = size.width / 2;
    _centerY = size.height - 10;

    var circle = 360;
    var hemisphere = circle / 2;
    var sweepAngle = circle + hemisphere - 2 * startFromAngle;

    var center = Offset(_centerX, _centerY);

    final mainPaint = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;

    var rect = Rect.fromCircle(center: center, radius: _arcRadius);

    canvas.drawArc(rect, startFromAngle.toRadian(), sweepAngle.toRadian(),
        false, mainPaint);

    for (var num = 0; num < 12; num++) {
      var ang = num * circle / 12 + startFromAngle;
      if (ang >= sweepAngle + startFromAngle + 30.0) {
        continue;
      }

      _drawNumbers(canvas, size, ang, items.length > num ? items[num] : 1000,
          _arcRadius + 40.0);

      _drawStrokedMinLines(canvas, _arcRadius + 20.0, ang, _arcRadius + 10.0,
          ang >= sweepAngle + startFromAngle);
    }

    // drawing pointers
    var angle = value * sweepAngle ~/ 100 + startFromAngle;
    var x = _centerX + handHeight * math.cos(angle.toRadian());
    var y = _centerY + handHeight * math.sin(angle.toRadian());

// drawing pointer needle // hand
    canvas.drawLine(
      center,
      Offset(x, y),
      Paint()
        ..strokeWidth = 10.0
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // draw text at showPercentage
    _drawPercentage(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void _drawNumbers(
      Canvas canvas, Size size, double angle, int num, double radius) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 30.0,
    );
    final textSpan = TextSpan(
      text: num.toString(),
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    final double h = textPainter.height;

    var x = _centerX + radius * math.cos(angle.toRadian());
    var y = _centerY + radius * math.sin(angle.toRadian());

    var offset = Offset(x, y);
    // at center
    if ((x - _centerX).abs() < 5.0) {
      offset = Offset(x - textPainter.width / 2, y - h * .8);
    } else if (x < _centerX) {
      offset = Offset(x - textPainter.width, y - h / 2);
    } else {
      offset = Offset(x, y - h / 2);
    }

    textPainter.paint(canvas, offset);
  }

  void _drawStrokedMinLines(Canvas canvas, double radius2, double angle,
      double radius, bool drawOnlyHand) {
    if (drawOnlyHand) {
      _drawStrokedLine(canvas, radius, radius2, angle);
      return;
    }

    for (var newAngle = angle; newAngle < angle + 30; newAngle += 6) {
      if (newAngle == angle) {
        _drawStrokedLine(canvas, radius, radius2, newAngle);
      } else {
        var x = _centerX + radius * math.cos(newAngle.toRadian());
        var y = _centerY + radius * math.sin(newAngle.toRadian());

        var x2 = _centerX + radius2 * math.cos(newAngle.toRadian());
        var y2 = _centerY + radius2 * math.sin(newAngle.toRadian());

        canvas.drawLine(
            Offset(x, y), Offset(x2, y2), Paint()..color = Colors.white);
      }
    }
  }

  void _drawStrokedLine(
      Canvas canvas, double radius, double radius2, double angle) {
    var x = _centerX + radius * math.cos(angle.toRadian());
    var y = _centerY + radius * math.sin(angle.toRadian());

    var x2 = _centerX + radius2 * math.cos(angle.toRadian());
    var y2 = _centerY + radius2 * math.sin(angle.toRadian());
    canvas.drawLine(
        Offset(x, y),
        Offset(x2, y2),
        Paint()
          ..color = Colors.red
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..strokeWidth = 05.0);
  }

  void _drawPercentage(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 30.0,
    );
    final textSpan = TextSpan(
      text: (value.round()).toString(),
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    textPainter.paint(
        canvas, Offset(_centerX - textPainter.width / 2, _centerY - 50));
  }
}

extension DoubleExtensions on double {
  double toRadian() {
    return this * math.pi / 180;
  }
}

extension IntExtensions on int {
  double toRadian() {
    return this * math.pi / 180;
  }
}
