import 'package:choo_window_manager/choo_window_manager.dart';
import 'package:choo_window_manager/src/window_manager.dart';
import 'package:flutter/widgets.dart';

class WindowPanWidget extends StatefulWidget {
  final Widget child;
  const WindowPanWidget({super.key, required this.child});
  @override
  State<WindowPanWidget> createState() => _WindowPanState();
}

class _WindowPanState extends State<WindowPanWidget> with WindowManagerEvent {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        WindowManagerEvent.addListenPan(this);
      },
      onPanEnd: (details) {
        WindowManagerEvent.removeListenPan(this);
      },
      onPanCancel: () {
        WindowManagerEvent.removeListenPan(this);
      },
      child: MouseRegion(
        onEnter: (event) {
          WindowManagerEvent.addPreListenPan(this);
        },
        onExit: (event) {
          WindowManagerEvent.removePreListenPan(this);
        },
        child: widget.child,
      ),
    );
  }
}
