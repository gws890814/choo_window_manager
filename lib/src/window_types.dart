part of './window_manager.dart';

/// 窗口动画行为枚举
/// 定义窗口打开和关闭时的动画效果
enum WindowAnimationBehavior {
  /// 无动画，窗口打开和关闭时不显示任何动画效果
  none,

  /// 警告面板动画，用于显示重要警告或提示信息时的动画效果
  alertPanel,

  /// 文档窗口动画，适用于文档编辑器等应用程序的窗口动画
  documentWindow,

  /// 工具窗口动画，用于工具面板或辅助窗口的动画效果
  utilityWindow,
}

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

/// 修饰键标志枚举
/// 定义键盘修饰键的状态
enum ModifierFlags {
  /// 大写锁定键，用于切换大写字母输入
  capsLock,

  /// Shift键，用于输入大写字母或访问符号
  shift,

  /// Control键，通常用于触发系统或应用程序快捷键
  control,

  /// Option键（在Windows上为Alt键），用于访问特殊字符和菜单快捷键
  option,

  /// Command键（在Windows上为Windows键），用于触发系统级快捷键
  command,

  /// 数字小键盘键，用于输入数字和数学运算符
  numericPad,

  /// Help键，用于触发帮助功能
  help,

  /// 功能键（F1-F12），用于触发特定应用程序功能
  function,

  /// 设备独立标志掩码，用于表示与设备无关的修饰键状态
  deviceIndependentFlagsMask,
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

enum WindowButtonType { close, miniaturize, zoom }

/// 窗口标题可见性枚举
/// 控制窗口标题栏的显示方式
enum WindowTitleVisibility {
  /// 隐藏标题，适用于无边框窗口或自定义标题栏的场景
  hidden,

  /// 显示标题，默认值，显示标准窗口标题栏
  visible,
}

/// 窗口事件类型枚举
/// 定义窗口可能触发的各种事件
enum WindowEventType {
  /// 窗口大小改变事件，当用户调整窗口大小时触发
  resize,

  /// 窗口移动事件，当窗口位置改变时触发
  move,

  /// 窗口平移事件，通常用于触摸屏设备的拖拽操作
  pan,

  /// 窗口显示事件，当窗口从隐藏变为可见时触发
  show,

  /// 窗口隐藏事件，当窗口从可见变为隐藏时触发
  hide,

  /// 鼠标悬停事件，当鼠标指针在窗口上悬停时触发
  hover,

  /// 窗口获得焦点事件，当窗口成为活动窗口时触发
  focus,

  /// 窗口失去焦点事件，当窗口不再是活动窗口时触发
  blur,

  /// 窗口即将关闭事件，在窗口关闭前触发
  willClose,

  /// 窗口关闭事件，在窗口关闭时触发
  close,

  /// 窗口最小化事件，当窗口被最小化时触发
  minimize,

  /// 窗口最大化事件，当窗口被最大化时触发
  maximize,

  /// 窗口还原事件，当窗口从最小化或最大化状态恢复时触发
  restore,

  /// 窗口即将进入全屏模式事件
  willEnterFullScreen,

  /// 窗口已进入全屏模式事件
  didEnterFullScreen,

  /// 窗口即将退出全屏模式事件
  willLeaveFullScreen,

  /// 窗口已退出全屏模式事件
  didLeaveFullScreen,

  /// 通用窗口事件，用于处理其他未分类的窗口事件
  event,

  /// 键盘事件，当窗口接收到键盘输入时触发
  keyboard,

  changeTitle,
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

/// 全局偏移量类，继承自Offset，增加了全局坐标信息
class GlobalOffset extends Offset {
  final double _globalDx;
  final double _globalDy;
  double get globalDx => _globalDx;
  double get globalDy => _globalDy;
  GlobalOffset(double globalDx, double globalDy, super.dx, super.dy)
    : _globalDx = globalDx,
      _globalDy = globalDy;

  /// 重载加法运算符，用于计算两个GlobalOffset对象的和
  ///
  /// [other]: 要相加的另一个Offset对象，必须是GlobalOffset类型
  /// 返回一个新的GlobalOffset对象，包含相加后的全局和局部坐标
  @override
  GlobalOffset operator +(Offset other) {
    final baseOffset = super + other;
    assert(other is GlobalOffset, "other must be GlobalOffset");
    return GlobalOffset(
      globalDx + (other as GlobalOffset).globalDx,
      globalDy + other.globalDy,
      baseOffset.dx,
      baseOffset.dy,
    );
  }

  /// 重载减法运算符，用于计算两个GlobalOffset对象的差
  ///
  /// [other]: 要相减的另一个Offset对象，必须是GlobalOffset类型
  /// 返回一个新的GlobalOffset对象，包含相减后的全局和局部坐标
  @override
  GlobalOffset operator -(Offset other) {
    final baseOffset = super + other;
    assert(other is GlobalOffset, "other must be GlobalOffset");
    return GlobalOffset(
      globalDx + (other as GlobalOffset).globalDx,
      globalDy + other.globalDy,
      baseOffset.dx,
      baseOffset.dy,
    );
  }

  /// 重载乘法运算符，用于缩放GlobalOffset对象的坐标
  ///
  /// [operand]: 缩放倍数
  /// 返回一个新的GlobalOffset对象，包含缩放后的全局和局部坐标
  @override
  GlobalOffset operator *(double operand) {
    final baseOffset = super * operand;
    return GlobalOffset(
      globalDx * operand,
      globalDy * operand,
      baseOffset.dx,
      baseOffset.dy,
    );
  }

  /// 重载除法运算符，用于缩放GlobalOffset对象的坐标
  ///
  /// [operand]: 缩放分母
  /// 返回一个新的GlobalOffset对象，包含缩放后的全局和局部坐标
  @override
  GlobalOffset operator /(double operand) {
    final baseOffset = super / operand;
    return GlobalOffset(
      globalDx / operand,
      globalDy / operand,
      baseOffset.dx,
      baseOffset.dy,
    );
  }

  /// 重载toString方法，返回格式化的字符串表示
  ///
  /// 返回格式为'GlobalOffset(globalDx, globalDy, dx, dy)'的字符串
  /// 所有坐标值保留一位小数
  @override
  String toString() =>
      'GlobalOffset(${globalDx.toStringAsFixed(1)}, ${globalDy.toStringAsFixed(1)}, ${dx.toStringAsFixed(1)}, ${dy.toStringAsFixed(1)})';
}

class WindowButtonOptions {
  final List<WindowButtonType> enabledButtons;
  final List<WindowButtonType> hiddenButtons;
  final double? height;
  final WindowButtonRegionPosition? regionPosition;
  final Size? buttonSize;
  final double? spacing;

  WindowButtonOptions({
    this.enabledButtons = const [
      WindowButtonType.close,
      WindowButtonType.miniaturize,
      WindowButtonType.zoom,
    ],
    this.hiddenButtons = const [],
    this.height,
    this.regionPosition,
    this.buttonSize,
    this.spacing,
  });

  void _exec() async {
    List<WindowButtonType> allTypes = [
      WindowButtonType.close,
      WindowButtonType.miniaturize,
      WindowButtonType.zoom,
    ];
    List<WindowButtonType> enabledTypes =
        allTypes
            .where((buttonType) => !enabledButtons.contains(buttonType))
            .toList();
    if (enabledTypes.isNotEmpty) {
      await ChooWindowManager.current.setWindowButtonEnabled(
        types: enabledTypes,
        state: false,
      );
    }

    if (hiddenButtons.isNotEmpty) {
      await ChooWindowManager.current.setWindowButtonHidden(
        types: hiddenButtons,
        state: true,
      );
    }

    if (height != null) {
      await ChooWindowManager.current.setWindowButtonRegionHeight(height!);
    }

    if (regionPosition != null) {
      await ChooWindowManager.current.setWindowButtonRegionPosition(
        regionPosition!,
      );
    }

    if (buttonSize != null) {
      await ChooWindowManager.current.setWindowButtonSize(buttonSize!);
    }
    if (spacing != null) {
      await ChooWindowManager.current.setWindowButtonSpacing(spacing!);
    }
  }
}

/// 窗口选项类，用于配置窗口的初始参数
/// 通过此类可以设置窗口的大小、位置、标题、动画效果等属性
/// 通常在创建新窗口时使用
class ChooWindowOptions {
  /// 窗口的唯一标识符
  /// 用于在系统中唯一识别该窗口
  /// 通常由系统自动生成或开发者指定
  final int id;

  /// 窗口是否居中显示
  /// 设置为true时，窗口将在屏幕中央打开
  /// 默认值为true
  final bool center;

  /// 窗口的初始大小
  /// 指定窗口打开时的宽度和高度
  /// 默认值为800x628
  final Size size;

  /// 窗口的最小尺寸限制
  /// 设置窗口可调整的最小宽度和高度
  /// 如果未设置，则窗口可调整到任意大小
  final Size? minSize;

  /// 窗口的最大尺寸限制
  /// 设置窗口可调整的最大宽度和高度
  /// 如果未设置，则窗口可调整到任意大小
  final Size? maxSize;

  /// 窗口的初始位置偏移量
  /// 指定窗口打开时相对于屏幕左上角的位置
  /// 如果未设置，则窗口将根据center属性决定位置
  final Offset? offset;

  /// 窗口的标题文本
  /// 显示在窗口的标题栏中
  /// 如果未设置，则显示默认标题
  final String? title;

  /// 窗口的透明度
  /// 取值范围为0.0（完全透明）到1.0（完全不透明）
  /// 如果未设置，则窗口完全不透明
  final double? opacity;

  /// 窗口的动画效果
  /// 指定窗口打开和关闭时的动画效果
  /// 如果未设置，则使用默认动画
  final WindowAnimationBehavior? animationBehavior;

  /// 窗口标题栏的显示样式
  /// 控制标题栏是否显示
  /// 如果未设置，则显示默认标题栏
  final WindowTitleVisibility? titleBarStyle;

  final WindowButtonOptions? buttonOptions;

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
    this.buttonOptions,
  }) : center = offset == null ? (center ?? true) : false;
}

/// 窗口事件发射类，用于封装窗口事件的相关信息
class WindowEmit<T> {
  /// 窗口的唯一标识符
  /// 用于在系统中唯一识别该窗口
  /// 通常由系统自动生成或开发者指定
  final int id;
  final String method;
  T result;
  WindowEmit(this.id, this.method, {required this.result});
}

/// 键盘事件类，用于封装键盘事件的相关信息
/// 键盘事件类，用于表示窗口接收到的键盘输入事件
/// 包含按键代码、修饰键状态、字符输入等信息
/// 典型使用场景：
/// - 处理用户键盘输入
/// - 实现快捷键功能
/// - 处理特殊按键事件
class KeyboardEvent {
  final List<ModifierFlags> modifierFlags;

  /// 输入的字符，可能包含多个字符（如长按按键时）
  /// 示例：当用户按住'a'键时，可能返回'aaa'
  final String? characters;

  /// 忽略修饰键的字符输入，通常用于获取按键的基础字符
  /// 示例：Shift+a返回'A'，但此属性返回'a'
  final String? charactersIgnoringModifiers;

  /// 按键代码，表示物理按键的唯一标识
  /// 示例：回车键的keyCode为13
  final int keyCode;

  /// 构造函数
  /// [keyCode]: 必需参数，表示按键代码
  /// [modifierFlags]: 修饰键状态列表，默认空列表
  /// [characters]: 输入的字符，可选
  /// [charactersIgnoringModifiers]: 忽略修饰键的字符输入，可选
  KeyboardEvent({
    required this.keyCode,
    this.modifierFlags = const [],
    this.characters,
    this.charactersIgnoringModifiers,
  });
}

class WindowButtonRegionPosition {
  final double? x;
  final double y;

  WindowButtonRegionPosition({this.x, required this.y});
}
