library speedometer;

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:speedometer/handpainter.dart';
import 'package:speedometer/linepainter.dart';
import 'package:speedometer/speedtextpainter.dart';
import 'package:rxdart/rxdart.dart';

class SpeedOMeter extends StatefulWidget {
  int start;
  int end;
  double highlightStart;
  double highlightEnd;
  ThemeData themeData;

  PublishSubject<double> eventObservable;
  PublishSubject<double> eventObservableStop;

  SpeedOMeter(
      {this.start,
      this.end,
      this.highlightStart,
      this.highlightEnd,
      this.themeData,
      this.eventObservable,
      this.eventObservableStop}) {}

  _SpeedOMeterState createState() => new _SpeedOMeterState(
      this.start,
      this.end,
      this.highlightStart,
      this.highlightEnd,
      this.eventObservable,
      this.eventObservableStop);
}

class _SpeedOMeterState extends State<SpeedOMeter>
    with TickerProviderStateMixin {
  int start;
  int end;
  double highlightStart;
  double highlightEnd;
  PublishSubject<double> eventObservable;
  PublishSubject<double> eventObservableStop;

  double val = 0.0;
  double newVal;
  double textVal = 0.0;
  AnimationController percentageAnimationController;
  StreamSubscription<double> subscription;
  StreamSubscription<double> subscriptionStop;

  _SpeedOMeterState(
      int start,
      int end,
      double highlightStart,
      double highlightEnd,
      PublishSubject<double> eventObservable,
      PublishSubject<double> eventObservableStop) {
    this.start = start;
    this.end = end;
    this.highlightStart = highlightStart;
    this.highlightEnd = highlightEnd;
    this.eventObservable = eventObservable;
    this.eventObservableStop = eventObservableStop;

    percentageAnimationController = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 1000))
      ..addListener(() {
        setState(() {
          val = lerpDouble(val, newVal, percentageAnimationController.value);
        });
      });

    subscription = this.eventObservable.listen((value) {
      textVal = value;
      (value >= this.end) ? reloadData(this.end.toDouble()) : reloadData(value);
    });

    subscriptionStop = this.eventObservableStop.listen((value) {
      print("Disposing controller");
      percentageAnimationController.dispose();
    }); //(value) => reloadData(value));
  }

  reloadData(double value) {
    print(value);
    newVal = value;
    percentageAnimationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context).isCurrent == false) {
      return Text("");
    }
    return new Center(
      child: new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return new Container(
          height: constraints.maxWidth,
          width: constraints.maxWidth,
          child: new Stack(fit: StackFit.expand, children: <Widget>[
            new Container(
              child: new CustomPaint(
                  foregroundPainter: new LinePainter(
                      lineColor: this.widget.themeData.backgroundColor,
                      completeColor: this.widget.themeData.primaryColor,
                      startValue: this.start,
                      endValue: this.end,
                      startPercent: this.widget.highlightStart,
                      endPercent: this.widget.highlightEnd,
                      width: 40.0)),
            ),
            new Center(
                //   aspectRatio: 1.0,
                child: new Container(
                    height: constraints.maxWidth,
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    child: new Stack(fit: StackFit.expand, children: <Widget>[
                      new CustomPaint(
                        painter: new HandPainter(
                            value: val,
                            start: this.start,
                            end: this.end,
                            color: this.widget.themeData.accentColor),
                      ),
                    ]))),
            new Center(
              child: new Container(
                width: 30.0,
                height: 30.0,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: this.widget.themeData.backgroundColor,
                ),
              ),
            ),
            new CustomPaint(
                painter: new SpeedTextPainter(
                    start: this.start, end: this.end, value: this.textVal)),
          ]),
        );
      }),
    );
  }
}
