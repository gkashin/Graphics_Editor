import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:graphics_editor/resources/custom_icons.dart';

import 'MyCustomPainter.dart';
import 'CustomPointMode.dart';
import 'DrawingArea.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graphics Editor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum DrawMode {
  draw,
  drawLine,
  drawRect,
  erase,
}

class _MyHomePageState extends State<MyHomePage> {
  List<DrawingArea> points = [];
  final maxNumberOfTapsToDraw = 1;
  int tapsNeededToDraw;
  double strokeWidth;

  Color selectedColor;
  Color previousColor;
  Color eraseIconButtonColor;
  Color drawLineIconButtonColor;
  Color drawRectIconButtonColor;

  DrawMode currentDrawMode;

  @override
  void initState() {
    super.initState();
    selectedColor = Colors.black;
    previousColor = Colors.black;
    eraseIconButtonColor = Colors.black;
    drawLineIconButtonColor = Colors.black;
    drawRectIconButtonColor = Colors.black;
    tapsNeededToDraw = 1;
    strokeWidth = 2.0;
    currentDrawMode = DrawMode.draw;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    void selectColor() {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return new AlertDialog(
              title: const Text('Color Picker'),
              content: SingleChildScrollView(
                child: BlockPicker(
                  pickerColor: Colors.green,
                  onColorChanged: (color) {
                    this.setState(() {
                      if (currentDrawMode == DrawMode.erase) {
                        previousColor = color;
                      } else {
                        selectedColor = color;
                        previousColor = color;
                      }
                    });
                  },
                ),
              ),
              actions: <Widget>[
                // ignore: deprecated_member_use
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Close"))
              ],
            );
          });
    }

    void onPanDownAction(details) {
      CustomPointMode pointMode = CustomPointMode.point;
      if (currentDrawMode == DrawMode.drawLine) {
        if (tapsNeededToDraw == 0) {
          pointMode = CustomPointMode.endOfLine;
          tapsNeededToDraw = maxNumberOfTapsToDraw;
        } else {
          pointMode = CustomPointMode.startOfLine;
          tapsNeededToDraw--;
        }
      } else if (currentDrawMode == DrawMode.drawRect) {
        if (tapsNeededToDraw == 0) {
          pointMode = CustomPointMode.endOfRect;
          tapsNeededToDraw = maxNumberOfTapsToDraw;
        } else {
          pointMode = CustomPointMode.startOfRect;
          tapsNeededToDraw--;
        }
      }

      points.add(DrawingArea(
          point: details.localPosition,
          areaPaint: Paint()
            ..strokeCap = StrokeCap.round
            ..isAntiAlias = true
            ..color = selectedColor
            ..strokeWidth = strokeWidth,
          pointMode: pointMode));
    }

    onPanUpdateAction(details) {
      points.add(DrawingArea(
          point: details.localPosition,
          areaPaint: Paint()
            ..strokeCap = StrokeCap.round
            ..isAntiAlias = true
            ..color = selectedColor
            ..strokeWidth = strokeWidth));
    }

    void lineButtonAction() {
      if (currentDrawMode == DrawMode.drawLine) {
        currentDrawMode = DrawMode.draw;
        drawLineIconButtonColor = Colors.black;
      } else if (currentDrawMode == DrawMode.draw) {
        drawLineIconButtonColor = Colors.yellow;
        currentDrawMode = DrawMode.drawLine;
        tapsNeededToDraw = maxNumberOfTapsToDraw;
      }
    }

    void squareButtonAction() {
      if (currentDrawMode == DrawMode.drawRect) {
        currentDrawMode = DrawMode.draw;
        drawRectIconButtonColor = Colors.black;
      } else if (currentDrawMode == DrawMode.draw) {
        drawRectIconButtonColor = Colors.yellow;
        currentDrawMode = DrawMode.drawRect;
        tapsNeededToDraw = maxNumberOfTapsToDraw;
      }
    }

    void eraserButtonAction() {
      if (currentDrawMode == DrawMode.erase) {
        selectedColor = previousColor;
        eraseIconButtonColor = Colors.black;
        currentDrawMode = DrawMode.draw;
      } else if (currentDrawMode == DrawMode.draw) {
        previousColor = selectedColor;
        selectedColor = Colors.white;
        eraseIconButtonColor = Colors.yellow;
        currentDrawMode = DrawMode.erase;
      }
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Color.fromRGBO(138, 35, 135, 1.0),
                  Color.fromRGBO(233, 64, 87, 1.0),
                  Color.fromRGBO(242, 113, 33, 1.0),
                ])),
          ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: width,
                    height: 0.9 * height,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 5.0,
                            spreadRadius: 1.0,
                          )
                        ]),
                    child: GestureDetector(
                      onPanDown: (details) {
                        this.setState(() {
                          onPanDownAction(details);
                        });
                      },
                      onPanUpdate: (details) {
                        this.setState(() {
                          onPanUpdateAction(details);
                        });
                      },
                      onPanEnd: (details) {
                        this.setState(() {
                          points.add(null);
                        });
                      },
                      child: SizedBox.expand(
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          child: CustomPaint(
                            painter: MyCustomPainter(points: points),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 0.8 * width,
                height: 0.2 * height,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    // Palette
                    // ignore: missing_required_param
                    FloatingActionButton(
                      child: IconButton(
                          icon: Icon(
                            Icons.color_lens,
                            color: previousColor,
                          ),
                          onPressed: () {
                            selectColor();
                          }),
                    ),
                    // Slider
                    Expanded(
                      child: Slider(
                        min: 1.0,
                        max: 10.0,
                        label: "Stroke $strokeWidth",
                        activeColor: previousColor,
                        value: strokeWidth,
                        onChanged: (double value) {
                          this.setState(() {
                            strokeWidth = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.all(0.025 * width),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  // Straight line
                  // ignore: missing_required_param
                  FloatingActionButton(
                    child: IconButton(
                        icon: Icon(
                          Icons.horizontal_rule,
                          color: drawLineIconButtonColor,
                        ),
                        onPressed: () {
                          this.setState(() {
                            lineButtonAction();
                          });
                        }),
                  ),
                  SizedBox(height: 20),
                  // Rectangle
                  // ignore: missing_required_param
                  FloatingActionButton(
                    child: IconButton(
                        icon: Icon(
                          Icons.crop_square,
                          color: drawRectIconButtonColor,
                        ),
                        onPressed: () {
                          this.setState(() {
                            squareButtonAction();
                          });
                        }),
                  ),
                  SizedBox(height: 20),
                  // Eraser
                  // ignore: missing_required_param
                  FloatingActionButton(
                    child: IconButton(
                        icon: Icon(
                          CustomIcons.eraser,
                          color: eraseIconButtonColor,
                        ),
                        onPressed: () {
                          this.setState(() {
                            eraserButtonAction();
                          });
                        }),
                  ),
                  SizedBox(height: 20),
                  // Clear all
                  // ignore: missing_required_param
                  FloatingActionButton(
                    child: IconButton(
                        icon: Icon(
                          Icons.layers_clear,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          this.setState(() {
                            points.clear();
                            tapsNeededToDraw = maxNumberOfTapsToDraw;
                          });
                        }),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
