import 'package:flutter/material.dart';
import 'CustomPointMode.dart';

class DrawingArea {
  Offset point;
  Paint areaPaint;
  CustomPointMode pointMode;

  DrawingArea(
      {this.point, this.areaPaint, this.pointMode = CustomPointMode.point});
}