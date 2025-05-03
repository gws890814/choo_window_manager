import 'package:choo_window_manager/choo_window_manager.dart';
import 'package:choo_window_manager/src/window_manager.dart';
import 'package:flutter/widgets.dart';

/// 窗口拖动控件，用于实现窗口的拖动功能
/// 通过包裹子控件来实现拖动功能
class WindowPanWidget extends StatefulWidget {
  /// 子控件
  final Widget child;

  /// 构造函数
  /// @param key - 控件key
  /// @param child - 子控件
  const WindowPanWidget({super.key, required this.child});

  @override
  State<WindowPanWidget> createState() => _WindowPanState();
}

/// 窗口拖动控件的状态管理类
class _WindowPanState extends State<WindowPanWidget> with WindowManagerEvent {
  @override
  Widget build(BuildContext context) {
    // 构建窗口拖动控件
    // 使用GestureDetector处理拖动手势
    return GestureDetector(
      // 开始拖动时添加监听器
      onPanStart: (details) {
        WindowManagerEvent.addPanListener(this);
      },
      // 结束拖动时移除监听器
      onPanEnd: (details) {
        WindowManagerEvent.removePanListener(this);
      },
      // 取消拖动时移除监听器
      onPanCancel: () {
        WindowManagerEvent.removePanListener(this);
      },
      child: MouseRegion(
        // 鼠标进入区域时添加预拖动监听器
        onEnter: (event) {
          WindowManagerEvent.addPrePanListener(this);
        },
        // 鼠标离开区域时移除预拖动监听器
        onExit: (event) {
          WindowManagerEvent.removePrePanListener(this);
        },
        child: GestureDetector(
          // 处理拖动手势事件
          onPanStart: (details) {},
          onPanEnd: (details) {},
          onPanCancel: () {},
          child: widget.child,
        ),
      ),
    );
  }
}
