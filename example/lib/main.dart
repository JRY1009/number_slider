import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:number_slider/number_slider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer _timer;

  Random rng = Random();

  NumberSliderController nsController1 = NumberSliderController();
  NumberSliderController nsController2 = NumberSliderController();
  NumberSliderController nsController3 = NumberSliderController();

  var numList1 = [
    '32133.32',
    '32146.67',
    '32146.67',
    '53146.44',
    '72146.12',
    '32045.42',
    '12143.61',
    '32146.09'
  ];
  var numList2 = [
    '-2,133.32',
    '-3,246.67',
    '-2,146.67',
    '-3,146.44',
    '-2,146.12',
    '-2,045.42',
    '-2,143.61',
    '-2,146.09'
  ];
  var numList3 = [
    '32,133.32',
    '32,146.67',
    '2,146.67',
    '3,146.44',
    '7,146.12',
    '32,045.42',
    '12,143.61',
    '32,146.09'
  ];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      nsController1.number = numList1[rng.nextInt(numList1.length)];
      nsController2.number = numList2[rng.nextInt(numList2.length)];
      nsController3.number = numList3[rng.nextInt(numList3.length)];
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('number_slider example'),
        ),
        body: ListView(
          children: [
            SizedBox(height: 20),
            NumberSlider(
                controller: nsController1,
                initialNumber: numList1[0],
                textStyle: TextStyle(
                    color: Color(0xFFEC3944),
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                    height: 1.0)),
            SizedBox(height: 20),
            NumberSlider(
                controller: nsController2,
                initialNumber: numList2[0],
                textStyle: TextStyle(
                    color: Color(0xFF22C29B),
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                    height: 1.0)),
            SizedBox(height: 20),
            NumberSlider(
                controller: nsController3,
                initialNumber: numList3[0],
                textStyle: TextStyle(
                    color: Color(0xff333A50),
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                    height: 1.0)),
          ],
        ),
      ),
    );
  }
}
