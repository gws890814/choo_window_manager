import 'package:choo_window_manager/src/widgets/pan.dart';
import 'package:flutter/material.dart';

class ChooAppBar extends AppBar {
  // set spread(bool? value) {}
  static of(BuildContext context) => WindowPanWidget.of(context);
  ChooAppBar({required Widget child, double height = 50, super.key})
    : super(
        toolbarHeight: height,
        title: SizedBox(
          width: double.maxFinite,
          height: height,
          child: WindowPanWidget(spread: true, child: child),
        ),
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      );
}
