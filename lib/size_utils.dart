import 'package:flutter/material.dart';

// This is where the magic happens.
// This functions are responsible to make UI responsive across all the mobile devices.

// ignore: deprecated_member_use
Size size = WidgetsBinding.instance.window.physicalSize /
    // ignore: deprecated_member_use
    WidgetsBinding.instance.window.devicePixelRatio;

// Caution! If you think these are static values and are used to build a static UI,  you mustn’t.
// These are the Viewport values of your Figma Design.
// These are used in the code as a reference to create your UI Responsively.
const num FIGMA_DESIGN_WIDTH = 428;
const num FIGMA_DESIGN_HEIGHT = 926;
const num FIGMA_DESIGN_STATUS_BAR = 47;

///This method is used to get device viewport width.
///This method is something special , the reason is while debugging lots of time this method with another few method get called but these methods are not more than 3 count.
///this method get called even after PostMethod call
get width {
  return size.width;
}

///This method is used to get device viewport height.
///this method is one of the 3 method which get call repeatedly
///
get height {
  num statusBar =
      // ignore: deprecated_member_use
      ///this method is one of the 3 method which get call repeatedly
      ///similary this also get called after getting called the PostMethod with filleddata
      ///
      ///similary this also get called after getting called the PostMethod with filleddata
      MediaQueryData.fromView(WidgetsBinding.instance.window).viewPadding.top;
  // ignore: deprecated_member_use
  num bottomBar = MediaQueryData.fromView(WidgetsBinding.instance.window)
      .viewPadding
      .bottom;
  num screenHeight = size.height - statusBar - bottomBar;
  return screenHeight;
}

///This method is used to set padding/margin (for the left and Right side) & width of the screen or widget according to the Viewport width.
///this method is one of the 3 method which get call repeatedly
double getHorizontalSize(double px) {
  return ((px * width) / FIGMA_DESIGN_WIDTH);
}

///This method is used to set padding/margin (for the top and bottom side) & height of the screen or widget according to the Viewport height.
///this method is one of 3 methods who get called repeatedly.
double getVerticalSize(double px) {
  return ((px * height) / (FIGMA_DESIGN_HEIGHT - FIGMA_DESIGN_STATUS_BAR));
}

///This method is used to set smallest px in image height and width
double getSize(double px) {
  var height = getVerticalSize(px);
  var width = getHorizontalSize(px);
  if (height < width) {
    return height.toInt().toDouble();
  } else {
    return width.toInt().toDouble();
  }
}

///This method is used to set text font size according to Viewport
double getFontSize(double px) {
  return getSize(px);
}

///This method is used to set padding responsively
///here is also call arieved.
EdgeInsetsGeometry getPadding({
  double? all,
  double? left,
  double? top,
  double? right,
  double? bottom,
}) {
  return getMarginOrPadding(
    all: all,
    left: left,
    top: top,
    right: right,
    bottom: bottom,
  );
}

///This method is used to set margin responsively
EdgeInsetsGeometry getMargin({
  double? all,
  double? left,
  double? top,
  double? right,
  double? bottom,
}) {
  return getMarginOrPadding(
    all: all,
    left: left,
    top: top,
    right: right,
    bottom: bottom,
  );
}

///This method is used to get padding or margin responsively
EdgeInsetsGeometry getMarginOrPadding({
  double? all,
  double? left,
  double? top,
  double? right,
  double? bottom,
}) {
  if (all != null) {
    left = all;
    top = all;
    right = all;
    bottom = all;
  }
  return EdgeInsets.only(
    left: getHorizontalSize(
      left ?? 0,
    ),
    top: getVerticalSize(
      top ?? 0,
    ),
    right: getHorizontalSize(
      right ?? 0,
    ),
    bottom: getVerticalSize(
      bottom ?? 0,
    ),
  );
}
