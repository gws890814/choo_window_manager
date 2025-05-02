import 'package:flutter/widgets.dart';

/// 窗口动画行为的枚举类型
///
/// [none] - 无动画效果
/// [alertPanel] - 警告面板动画效果
/// [documentWindow] - 文档窗口动画效果
/// [utilityWindow] - 工具窗口动画效果
enum WindowAnimationBehavior { none, alertPanel, documentWindow, utilityWindow }

extension WindowAnimationBehaviorExtension on WindowAnimationBehavior {
  static WindowAnimationBehavior fromString(String? colorString) {
    switch (colorString) {
      case 'none':
        return WindowAnimationBehavior.none;
      case 'alertPanel':
        return WindowAnimationBehavior.alertPanel;
      case 'documentWindow':
        return WindowAnimationBehavior.documentWindow;
      case 'utilityWindow':
        return WindowAnimationBehavior.utilityWindow;
      default:
        return WindowAnimationBehavior.none;
    }
  }
}

enum ModifierFlags {
  capsLock,
  shift,
  control,
  option,
  command,
  numericPad,
  help,
  function,
  deviceIndependentFlagsMask
}

extension ModifierFlagsExtension on ModifierFlags {
  static ModifierFlags fromString(String? flag) {
    switch (flag) {
      case 'capsLock':
        return ModifierFlags.capsLock;
      case 'shift':
        return ModifierFlags.shift;
      case 'control':
        return ModifierFlags.control;
      case 'option':
        return ModifierFlags.option;
      case 'command':
        return ModifierFlags.command;
      case 'numericPad':
        return ModifierFlags.numericPad;
      case 'help':
        return ModifierFlags.help;
      case 'function':
        return ModifierFlags.function;
      case 'deviceIndependentFlagsMask':
        return ModifierFlags.deviceIndependentFlagsMask;
      default:
        return ModifierFlags.deviceIndependentFlagsMask;
    }
  }
}

/// 窗口标题栏可见性的枚举类型
///
/// [hidden] - 隐藏标题栏
/// [visible] - 显示标题栏
enum WindowTitleVisibility { hidden, visible }

/// 窗口事件类型的枚举
///
/// 定义了窗口可能触发的各种事件类型
enum WindowEventType {
  resize,
  move,
  pan,
  show,
  hide,
  hover,
  focus,
  blur,
  willClose,
  close,
  minimize,
  maximize,
  restore,
  willEnterFullScreen,
  didEnterFullScreen,
  willLeaveFullScreen,
  didLeaveFullScreen,
  event,
  keyboard
}

extension WindowTitleVisibilityExtension on WindowTitleVisibility {
  static WindowTitleVisibility? fromString(String? colorString) {
    switch (colorString) {
      case 'hidden':
        return WindowTitleVisibility.hidden;
      case 'visible':
        return WindowTitleVisibility.visible;
      default:
        return null;
    }
  }
}

/// 全局偏移量类，继承自[Offset]
///
/// 除了普通的x/y偏移量外，还包含了全局坐标系统中的偏移量
class GlobalOffset extends Offset {
  final double _globalDx;
  final double _globalDy;
  double get globalDx => _globalDx;
  double get globalDy => _globalDy;
  GlobalOffset(double globalDx, double globalDy, super.dx, super.dy)
    : _globalDx = globalDx,
      _globalDy = globalDy;

  @override
  GlobalOffset operator +(Offset other) {
    // 先处理父类的dx/dy相加
    final baseOffset = super + other;

    assert(other is GlobalOffset, "other must be GlobalOffset");

    // 同时处理globalX/Y的相加
    return GlobalOffset(
      globalDx + (other as GlobalOffset).globalDx,
      globalDy + other.globalDy,
      baseOffset.dx,
      baseOffset.dy,
    );
  }

  @override
  GlobalOffset operator -(Offset other) {
    // 先处理父类的dx/dy相加
    final baseOffset = super + other;

    assert(other is GlobalOffset, "other must be GlobalOffset");

    // 同时处理globalX/Y的相加
    return GlobalOffset(
      globalDx + (other as GlobalOffset).globalDx,
      globalDy + other.globalDy,
      baseOffset.dx,
      baseOffset.dy,
    );
  }

  @override
  GlobalOffset operator *(double operand) {
    // 先处理父类的dx/dy相加
    final baseOffset = super * operand;

    // 同时处理globalX/Y的相加
    return GlobalOffset(
      globalDx * operand,
      globalDy * operand,
      baseOffset.dx,
      baseOffset.dy,
    );
  }

  @override
  GlobalOffset operator /(double operand) {
    // 先处理父类的dx/dy相加
    final baseOffset = super / operand;

    // 同时处理globalX/Y的相加
    return GlobalOffset(
      globalDx / operand,
      globalDy / operand,
      baseOffset.dx,
      baseOffset.dy,
    );
  }

  @override
  String toString() =>
      'GlobalOffset(${globalDx.toStringAsFixed(1)}, ${globalDy.toStringAsFixed(1)}, ${dx.toStringAsFixed(1)}, ${dy.toStringAsFixed(1)})';
}

/// 窗口配置选项类
///
/// 用于配置窗口的各种属性，如大小、位置、标题等
class ChooWindowOptions {
  final int id;
  final bool center;
  final Size size;
  final Size? minSize;
  final Size? maxSize;
  final Offset? offset;
  final String? title;
  final double? opacity;
  final WindowAnimationBehavior? animationBehavior;
  final WindowTitleVisibility? titleBarStyle;

  ChooWindowOptions(
    this.id, {
    bool? center,
    this.size = const Size(800, 628),
    this.minSize,
    this.maxSize,
    this.offset,
    this.title,
    this.opacity,
    this.animationBehavior,
    this.titleBarStyle,
  }) : center = offset == null ? (center ?? true) : false;
}

/// 窗口事件发射器类
///
/// 用于在窗口事件系统中传递事件和结果
class WindowEmit<T> {
  final int id;
  final String method;
  T result;
  WindowEmit(this.id, this.method, {required this.result});
}

/// 键盘事件类
///
/// 用于表示和处理键盘输入事件，包含按键代码、修饰键状态和字符信息
/// 与macOS原生键盘事件对应，提供跨平台的键盘事件处理能力
class KeyboardEvent {
  /// 按下的修饰键列表
  ///
  /// 可能包含的值有：capsLock, shift, control, option, command等
  final List<ModifierFlags> modifierFlags;
  
  /// 按键产生的字符
  ///
  /// 考虑当前键盘布局和修饰键状态下产生的实际字符
  final String? characters;
  
  /// 忽略修饰键状态下按键产生的字符
  ///
  /// 不考虑shift等修饰键的影响，返回键位对应的基本字符
  final String? charactersIgnoringModifiers;
  
  /// 按键的键码值
  ///
  /// 对应于物理键盘上的特定按键，与操作系统相关
  final int keyCode;
  
  /// 创建一个键盘事件实例
  ///
  /// [keyCode] - 必需参数，指定按键的键码
  /// [modifierFlags] - 可选参数，指定按下的修饰键列表，默认为空列表
  /// [characters] - 可选参数，指定按键产生的字符
  /// [charactersIgnoringModifiers] - 可选参数，指定忽略修饰键状态下按键产生的字符
  KeyboardEvent({required this.keyCode, this.modifierFlags = const [], this.characters, this.charactersIgnoringModifiers});
}