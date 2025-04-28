import 'package:choo_window_manager/choo_window_manager.dart';
import 'package:choo_window_manager/src/window_manager.dart';
import 'package:flutter/widgets.dart';

/// 窗口拖拽控件，用于实现窗口的拖拽移动功能
///
/// 该控件会监听用户的拖拽手势，并通过[WindowManagerEvent]实现窗口的移动
/// 使用方式:
/// ```dart
/// WindowPanWidget(
///   child: YourWidget(),
/// )
/// ```
class WindowPanWidget extends StatefulWidget {
  final Widget child;
  const WindowPanWidget({super.key, required this.child});
  @override
  State<WindowPanWidget> createState() => _WindowPanState();
}

/// 窗口拖拽控件的状态类
///
/// 实现了[WindowManagerEvent]以处理窗口拖拽事件
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
