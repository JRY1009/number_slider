library number_slider;

import 'package:flutter/material.dart';

//scroller initial offset
int _initOffset(String num) {
  if (_isNumber(num)) {
    return int.parse(num);
  }
  return 0;
}

//judge a single digit is number
bool _isNumber(String num) {
  if (num != null && num.length == 1) {
    int digit = num.codeUnitAt(0) - 48;
    if (digit >= 0 && digit <= 9) {
      return true;
    }
  }

  return false;
}

//A controller for updating the single digit displayed by [_DigitSlider]
class _DigitSliderController extends ValueNotifier {
  //The value of single digit.
  String _number;

  _DigitSliderController({String num = '0'}) : super(num) {
    this._number = num;
  }

  String get number => _number;

  set number(String num) {
    this._number = num;
    super.value = num;
  }
}

///A widget for displaying a single digit.
class _DigitSlider extends StatelessWidget {
  //The color of background.
  final Color backgroundColor;

  //The curve of scroll anim.
  final Curve curve;

  //The duration of scroll anim.
  final Duration duration;

  //The initial number.
  final String initialNumber;

  //The scrollController.
  final ScrollController scrollController;

  //The textStyle of number.
  final TextStyle textStyle;

  //The controller of this widget.
  final _DigitSliderController controller;

  _DigitSlider(
      {this.backgroundColor = Colors.transparent,
      this.curve = Curves.ease,
      this.controller,
      this.textStyle,
      this.initialNumber,
      this.duration})
      : scrollController = ScrollController(
            initialScrollOffset:
                textStyle.fontSize * (9 / 10) * _initOffset(initialNumber)),
        assert(controller != null, 'Controller cannot be null.'),
        assert(initialNumber != null, 'Initial number cannot be null.'),
        super(key: Key(controller.toString())) {
    controller.addListener(onValueChanged);
  }

  //Scrolls to the positions of the new number.
  void onValueChanged() {
    if (this.scrollController.hasClients) {
      if (_isNumber(controller.number)) {
        int digit = controller.number.codeUnitAt(0) - 48;
        scrollController.animateTo(digit * textStyle.fontSize * (9 / 10),
            duration: duration, curve: curve);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        return true;
      },
      child: Container(
          color: backgroundColor,
          height: textStyle.fontSize * (9 / 10),
          width: _isNumber(controller.number)
              ? textStyle.fontSize * (6 / 10)
              : textStyle.fontSize * (3 / 10),
          child: Stack(
            children: [
              _isNumber(controller.number)
                  ? ListView(
                      controller: scrollController,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        for (var i in List.generate(10, (index) => index))
                          Container(
                            height: textStyle.fontSize * (9 / 10),
                            child: Center(
                              child: Text("$i", style: textStyle),
                            ),
                          )
                      ],
                    )
                  : Container(
                      height: textStyle.fontSize * (9 / 10),
                      child: Center(
                        child: Text(controller.number, style: textStyle),
                      ),
                    )
            ],
          )),
    );
  }
}

//The controller of NumberSlider.
class NumberSliderController extends ValueNotifier {
  String _number;

  NumberSliderController() : super(0) {
    this._number = '0';
  }

  String get number => _number;

  set number(String num) {
    this._number = num;
    super.value = num;
  }
}

//A widget for displaying the changing number.
class NumberSlider extends StatefulWidget {
  //The color of background.
  final Color backgroundColor;

  //The curve of scroll anim.
  final Curve curve;

  //The initial number.
  final String initialNumber;

  //The duration of scroll anim.
  final Duration duration;

  //The controller of this widget.
  final NumberSliderController controller;

  //The textStyle of number.
  final TextStyle textStyle;

  NumberSlider(
      {this.backgroundColor = Colors.transparent,
      this.curve = Curves.ease,
      this.controller,
      this.textStyle = const TextStyle(color: Colors.black, fontSize: 12),
      this.initialNumber,
      this.duration = const Duration(milliseconds: 300)})
      : assert(controller != null, 'Controller cannot be null.'),
        assert(initialNumber != null, 'Initial number cannot be null.'),
        assert(duration != null, 'Duration cannot be null.') {
    this.controller.number = initialNumber;
  }

  @override
  _NumberSliderState createState() => _NumberSliderState();
}

class _NumberSliderState extends State<NumberSlider>
    with SingleTickerProviderStateMixin {
  //The animation controller for animating the removed or added [_DigitSlider].
  AnimationController animationController;

  //The current number string.
  String currentNumString;

  //The indicator of whether the new number is longer or shorter than the current one.
  bool shorter = false, longer = false;

  ///The list of [_DigitSliderController].
  List<_DigitSliderController> digitControllers = [];

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    var numString = widget.initialNumber;

    currentNumString = numString;

    for (int i = 0; i < numString.length; i++) {
      var digit = numString[i];
      digitControllers.insert(i, _DigitSliderController(num: digit));
    }

    widget.controller.addListener(onNumberChanged);

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          if (shorter) {
            while (currentNumString.length < digitControllers.length) {
              digitControllers.removeLast();
            }
          }

          this.longer = false;
          this.shorter = false;
        });
        animationController.value = 0;
      }
    });

    super.initState();
  }

  ///Updates the number when notified.
  onNumberChanged() {
    if (animationController.isAnimating) {
      animationController.notifyStatusListeners(AnimationStatus.completed);
    }

    var numString = widget.controller.number;

    bool shorter = false;
    bool longer = false;

    if (numString.length < currentNumString.length) {
      int shortLength = currentNumString.length - numString.length;
      for (int i = digitControllers.length - 1; i >= shortLength; i--) {
        digitControllers[i].number = '';
      }

      shorter = true;
    } else if (numString.length > currentNumString.length) {
      for (int i = 0; i < numString.length - currentNumString.length; i++) {
        digitControllers.insert(i, _DigitSliderController(num: numString[i]));
      }

      longer = true;
    }

    int startIndex = 0;

    if (longer) {
      startIndex = numString.length - currentNumString.length;
    }

    for (int i = startIndex; i < numString.length; i++) {
      var digit = numString[i];
      var oldDigit =
          longer ? currentNumString[i - startIndex] : currentNumString[i];

      if (digit != oldDigit) {
        digitControllers[i].number = digit;
      }
    }

    currentNumString = numString;

    if (shorter || longer) {
      animationController.forward();
    }
    this.shorter = shorter;
    this.longer = longer;
  }

  @override
  Widget build(BuildContext context) {
    var width = widget.textStyle.fontSize * (6 / 10);
    return AnimatedBuilder(
        animation: animationController,
        builder: (_, __) {
          return Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    color: widget.backgroundColor,
                    width: longer ? (animationController.value) * width : width,
                    child: digitControllers.first == null
                        ? Text(' ')
                        : _DigitSlider(
                            backgroundColor: widget.backgroundColor,
                            controller: digitControllers.first,
                            curve: widget.curve,
                            duration: widget.duration,
                            textStyle: widget.textStyle,
                            initialNumber: currentNumString[0],
                          )),
                for (int i = 1; i < digitControllers.length - 1; i++)
                  digitControllers[i] == null
                      ? Text(' ')
                      : _DigitSlider(
                          backgroundColor: widget.backgroundColor,
                          controller: digitControllers[i],
                          curve: widget.curve,
                          duration: widget.duration,
                          textStyle: widget.textStyle,
                          initialNumber: i == currentNumString.length
                              ? '0'
                              : currentNumString[i]),
                if (digitControllers.length > 1)
                  Container(
                    width: shorter
                        ? (1 - animationController.value) * width
                        : width,
                    child: digitControllers.last == null
                        ? Text(' ')
                        : _DigitSlider(
                            backgroundColor: widget.backgroundColor,
                            controller: digitControllers.last,
                            curve: widget.curve,
                            duration: widget.duration,
                            textStyle: widget.textStyle,
                            initialNumber:
                                currentNumString[currentNumString.length - 1]),
                  ),
              ],
            ),
          );
        });
  }
}
