import 'package:choo_window_manager/choo_window_manager.dart';
import 'package:flutter/material.dart';

class ChooAppBar extends AppBar {
  // set spread(bool? value) {}
  static of(BuildContext context) => WindowPanWidget.of(context);
  ChooAppBar({required Widget child, double height = 50, super.key})
    : super(
        toolbarHeight: height,
        title: GestureDetector(
          onDoubleTap: () async {
            bool isMaximized = await ChooWindowManager.current.isMaximized();
            if (isMaximized) {
              await ChooWindowManager.current.unmaximize();
            } else {
              await ChooWindowManager.current.maximize();
            }
          },
          child: SizedBox(
            width: double.maxFinite,
            height: height,
            child: WindowPanWidget(spread: true, child: child),
          ),
        ),
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      );
}
