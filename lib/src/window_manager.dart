import 'package:choo_window_manager/choo_window_manager.dart';
import 'package:flutter/services.dart';

/// 窗口管理器事件混入类
///
/// 提供了窗口事件的监听和处理功能，包括窗口的移动、调整大小、最小化等操作。
/// 可以被其他类混入以实现窗口事件的处理。
///
/// 该类提供了以下功能：
/// * 窗口基本事件监听（显示、隐藏、焦点等）
/// * 窗口大小和位置变化事件监听
/// * 窗口全屏状态变化事件监听
/// * 鼠标悬停和拖拽事件监听
abstract mixin class WindowManagerEvent {
  /// 存储所有已注册的窗口事件监听器
  static final List<WindowManagerEvent> _eventList = [];

  /// 存储所有已注册的鼠标悬停事件监听器
  static final List<WindowManagerEvent> _hoverEventList = [];

  /// 存储所有已注册的键盘事件监听器
  static final List<WindowManagerEvent> _keyboardEventList = [];

  /// 当前活动的拖拽事件监听器实例
  /// 由于拖拽操作的特殊性，同一时间只允许存在一个拖拽事件监听器
  static WindowManagerEvent? _instance;

  /// 添加窗口事件监听器
  ///
  /// [instance] 要添加的监听器实例
  ///
  /// 当添加第一个监听器时，会自动向原生层注册事件监听
  static void addListener(WindowManagerEvent instance) {
    if (!_eventList.contains(instance)) {
      _eventList.add(instance);
      if (_eventList.length == 1) {
        ChooWindowManager.current._windowChannel.invokeMethod<void>(
          'addListener',
          {"id": ChooWindowManager.current.id},
        );
      }
    }
  }

  /// 移除窗口事件监听器
  ///
  /// [instance] 要移除的监听器实例
  ///
  /// 当移除最后一个监听器时，会自动向原生层注销事件监听
  static void removeListener(WindowManagerEvent instance) {
    if (_eventList.contains(instance)) {
      _eventList.remove(instance);
      if (_eventList.isEmpty) {
        ChooWindowManager.current._windowChannel.invokeMethod<void>(
          'removeListener',
          {"id": ChooWindowManager.current.id},
        );
      }
    }
  }

  /// 添加窗口拖拽事件监听器
  ///
  /// [instance] 要添加的监听器实例
  ///
  /// 注意：同一时间只允许存在一个拖拽事件监听器
  /// 添加监听器后，可以通过[onPan]方法接收拖拽事件
  static void addPanListener(WindowManagerEvent instance) {
    assert(_instance == null, 'Only one listener is allowed');
    _instance = instance;
    ChooWindowManager.current._windowChannel
        .invokeMethod<Map<Object?, Object?>>('addPanListener', {
          "id": ChooWindowManager.current.id,
        })
        .then((value) {
          Offset offset = Offset(value!['x'] as double, value['y'] as double);
          _instance?.onPan(offset);
        });
  }

  /// 移除窗口拖拽事件监听器
  ///
  /// [instance] 要移除的监听器实例
  ///
  /// 只有当前活动的拖拽事件监听器才能被移除
  static void removePanListener(WindowManagerEvent instance) {
    if (_instance == instance) {
      _instance = null;
      ChooWindowManager.current._windowChannel.invokeMethod<void>(
        'removePanListener',
        {"id": ChooWindowManager.current.id},
      );
    }
  }

  /// 添加预拖拽事件监听器
  ///
  /// [instance] 要添加的监听器实例
  ///
  /// 预拖拽事件在实际拖拽开始前触发，可用于准备拖拽相关的状态
  static void addPrePanListener(WindowManagerEvent instance) {
    if (!_hoverEventList.contains(instance)) {
      _hoverEventList.add(instance);
      ChooWindowManager.current._windowChannel.invokeMethod<void>(
        'addPrePanListener',
        {"id": ChooWindowManager.current.id, "eventid": instance.eventid},
      );
    }
  }

  /// 移除预拖拽事件监听器
  ///
  /// [instance] 要移除的监听器实例
  static void removePrePanListener(WindowManagerEvent instance) {
    if (_hoverEventList.contains(instance)) {
      _hoverEventList.remove(instance);
      ChooWindowManager.current._windowChannel.invokeMethod<void>(
        'removePrePanListener',
        {"id": ChooWindowManager.current.id, "eventid": instance.eventid},
      );
    }
  }

  /// 添加鼠标悬停事件监听器
  ///
  /// [instance] 要添加的监听器实例
  ///
  /// 添加后可以通过[onHover]方法接收鼠标悬停事件
  static void addHoverListener(WindowManagerEvent instance) {
    if (!_hoverEventList.contains(instance)) {
      _hoverEventList.add(instance);
      ChooWindowManager.current._windowChannel.invokeMethod<void>(
        'addHoverListener',
        {"id": ChooWindowManager.current.id, "eventid": instance.eventid},
      );
    }
  }

  /// 移除鼠标悬停事件监听器
  ///
  /// [instance] 要移除的监听器实例
  static void removeHoverListener(WindowManagerEvent instance) {
    if (_hoverEventList.contains(instance)) {
      _hoverEventList.remove(instance);
      ChooWindowManager.current._windowChannel.invokeMethod<void>(
        'removeHoverListener',
        {"id": ChooWindowManager.current.id, "eventid": instance.eventid},
      );
    }
  }

  /// 事件监听器的唯一标识符，基于创建时的时间戳
  final int _id = DateTime.now().microsecondsSinceEpoch;

  /// 获取事件监听器的唯一标识符
  int get eventid => _id;

  /// 窗口大小改变事件回调
  /// [size] 新的窗口大小
  void onResize(Size size) {}

  /// 窗口移动事件回调
  /// [offset] 新的窗口位置，包含全局和局部坐标
  void onMove(GlobalOffset offset) {}

  /// 窗口拖拽事件回调
  /// [offset] 拖拽过程中的鼠标位置
  void onPan(Offset offset) {}

  /// 鼠标悬停事件回调
  /// [offset] 鼠标悬停位置
  void onHover(Offset offset) {}

  /// 窗口显示事件回调
  void onShow() {}

  /// 窗口隐藏事件回调
  void onHide() {}

  /// 窗口获得焦点事件回调
  void onFocus() {}

  /// 窗口失去焦点事件回调
  void onBlur() {}

  /// 窗口最小化事件回调
  void onMinimize() {}

  /// 窗口最大化事件回调
  void onMaximize() {}

  /// 窗口还原事件回调
  void onRestore() {}

  /// 窗口即将进入全屏事件回调
  void onWillEnterFullScreen() {}

  /// 窗口已进入全屏事件回调
  void onDidEnterFullScreen() {}

  /// 窗口即将退出全屏事件回调
  void onWillLeaveFullScreen() {}

  /// 窗口已退出全屏事件回调
  void onDidLeaveFullScreen() {}

  /// 窗口即将关闭事件回调
  /// 返回false可以阻止窗口关闭
  Future<bool> onWillClose() => Future.value(true);

  /// 窗口关闭事件回调
  void onClose() {}

  Future<bool> onKeyboard(KeyboardEvent event) => Future.value(true);

  /// 通用事件处理回调
  /// [id] 事件ID
  /// [method] 事件方法名
  /// [arguments] 事件参数
  /// [delivery] 事件传递值
  Future<dynamic> onEvent(
    int id,
    String method, {
    dynamic arguments,
    required dynamic delivery,
  }) => Future.value(delivery);
}

/// 窗口管理器类
///
/// 负责管理窗口的创建、配置和操作，提供了窗口的显示、隐藏、移动、调整大小等功能。
///
/// 主要功能包括：
/// * 窗口的基本操作（显示、隐藏、关闭等）
/// * 窗口大小和位置的调整
/// * 窗口状态的管理（最大化、最小化、全屏等）
/// * 窗口样式的设置（标题栏、透明度等）
/// * 多窗口的创建和管理
class ChooWindowManager {
  /// 全局方法通道，用于处理跨窗口的操作
  static final MethodChannel _globalChannel = const MethodChannel(
    'choo_window_manager',
  );

  /// 当前活动的窗口管理器实例
  static late ChooWindowManager current;

  /// 当前窗口的方法通道，用于处理单个窗口的操作
  final MethodChannel _windowChannel;

  /// 窗口的唯一标识符
  final int id;

  /// 获取包含窗口ID的参数映射
  /// 用于向原生层传递窗口标识
  Map<String, dynamic> get args => {'id': id};

  /// 创建并初始化一个窗口管理器实例
  ///
  /// [options] 窗口的配置选项，包含窗口的大小、位置、样式等设置
  /// [callback] 窗口初始化完成后的回调函数
  ///
  /// 该构造函数会：
  /// 1. 创建窗口专用的方法通道
  /// 2. 设置窗口的初始属性
  /// 3. 注册事件处理器
  /// 4. 完成后调用回调函数
  ChooWindowManager.ready(
    ChooWindowOptions options,
    void Function(ChooWindowManager window) callback,
  ) : id = options.id,
      _windowChannel = MethodChannel('choo_window_manager_${options.id}') {
    current = this;
    _windowChannel.setMethodCallHandler(_windowChannelHandler);
    _init(options, callback);
  }

  Future<dynamic> _windowChannelHandler(MethodCall call) async {
    String method = call.method;
    dynamic arguments = call.arguments;
    if (method == "pan") {
      if (WindowManagerEvent._instance != null) {
        Offset offset = Offset(arguments['globalX'], arguments['globalY']);
        WindowManagerEvent._instance!.onPan(offset);
      }
    } else if (method == "hover") {
      for (var element in WindowManagerEvent._hoverEventList) {
        Offset offset = Offset(arguments['x'], arguments['y']);
        element.onHover(offset);
      }
    } else if (WindowEventType.values.map((v) => v.name).contains(method)) {
      dynamic onEventValue;
      KeyboardEvent? keyboardEvent;
      if (method == 'keyboard') {
        List<ModifierFlags> modifierFlags =
            (arguments["modifierFlags"] as List<Object?>)
                .cast<String>()
                .toList()
                .map((e) => ModifierFlagsExtension.fromString(e))
                .toList();
        keyboardEvent = KeyboardEvent(
          keyCode: arguments['keyCode'],
          modifierFlags: modifierFlags,
          characters: arguments['characters'],
          charactersIgnoringModifiers: arguments['charactersIgnoringModifiers'],
        );
      }
      for (var element in WindowManagerEvent._eventList) {
        Map<String, Function> eventMap = {
          "show": element.onShow,
          "hide": element.onHide,
          "focus": element.onFocus,
          "blur": element.onBlur,
          "minimize": element.onMinimize,
          "maximize": element.onMaximize,
          "restore": element.onRestore,
          "willEnterFullScreen": element.onWillEnterFullScreen,
          "didEnterFullScreen": element.onDidEnterFullScreen,
          "willLeaveFullScreen": element.onWillLeaveFullScreen,
          "didLeaveFullScreen": element.onDidLeaveFullScreen,
          "close": element.onClose,
          "keyboard": element.onKeyboard,
        };
        if (method == "resize") {
          Size size = Size(arguments['width'], arguments['height']);
          element.onResize(size);
        } else if (method == "move") {
          GlobalOffset offset = GlobalOffset(
            arguments['globalX'],
            arguments['globalY'],
            arguments['x'],
            arguments['y'],
          );
          element.onMove(offset);
        } else if (method == "event") {
          int id = arguments['id'];
          String eventName = arguments['method'];
          dynamic args = arguments['arguments'];
          onEventValue = await element.onEvent(
            id,
            eventName,
            arguments: args,
            delivery: onEventValue,
          );
          if (WindowManagerEvent._eventList.last == element) {
            return onEventValue;
          }
        } else if (method == 'keyboard') {
          bool isNext = await element.onKeyboard(keyboardEvent!);
          if (!isNext) {
            return false;
          } else if (WindowManagerEvent._eventList.last == element) {
            return true;
          }
        } else if (method == 'willClose') {
          bool isClose = await element.onWillClose();
          if (!isClose) {
            return false;
          } else if (WindowManagerEvent._eventList.last == element) {
            return true;
          }
        } else if (eventMap[method] != null) {
          eventMap[method]!();
        }
      }
    }
    return null;
  }

  Future<void> _init(
    ChooWindowOptions options,
    void Function(ChooWindowManager window) callback,
  ) async {
    await _windowChannel.invokeMethod<void>("flutterReady", args);
    await setSize(options.size, animate: false);
    if (options.minSize != null) {
      await setMinSize(options.minSize!);
    }
    if (options.maxSize != null) {
      await setMaxSize(options.maxSize!);
    }
    if (options.title != null) await setTitle(options.title!);
    if (options.animationBehavior != null) {
      await setAnimationBehavior(options.animationBehavior!);
    }
    if (options.titleBarStyle != null) {
      await setTitleStyle(options.titleBarStyle!);
    }
    if (options.center) {
      await center();
    } else if (options.offset != null) {
      await setPosition(options.offset!);
    }
    await _windowChannel.invokeMethod<void>("windowReady", args);
    callback(this);
  }

  /// 创建一个新的窗口
  ///
  /// [args] 创建窗口时的参数配置
  ///
  /// 返回新创建窗口的ID
  /// 新窗口会继承当前窗口的一些基本设置
  static Future<int> createWindow(Map<String, dynamic>? args) async {
    args ??= {};
    args['beforeWindowId'] = current.id;
    int? windowId = await _globalChannel.invokeMethod<int?>(
      "createWindow",
      args,
    );
    assert(windowId != null, 'create window Error');
    return windowId!;
  }

  /// 关闭指定ID的窗口
  ///
  /// [windowId] 要关闭的窗口ID
  ///
  /// 返回是否成功关闭窗口
  static Future<bool> closeWindow(int windowId) async {
    return closeWindows(ids: [windowId]);
  }

  /// 批量关闭窗口
  ///
  /// [ids] 要关闭的窗口ID列表
  /// 如果不指定ID列表，则关闭所有窗口
  ///
  /// 返回是否成功关闭所有指定的窗口
  static Future<bool> closeWindows({List<int>? ids}) async {
    return (await _globalChannel.invokeMethod<bool>("closeWindows", {
      "ids": ids,
    }))!;
  }

  /// 销毁窗口管理器
  ///
  /// 会关闭所有窗口并清理相关资源
  static Future<void> destroy() async {
    await _globalChannel.invokeMethod<void>("destroy");
  }
}

/// 当前窗口管理器的扩展类
///
/// 提供了对当前窗口进行操作的各种方法，包括：
/// * 窗口的显示和隐藏
/// * 窗口焦点的控制
/// * 窗口大小的获取和设置
/// * 窗口位置的调整
/// * 窗口状态的切换（最大化、最小化等）
/// * 窗口样式的设置（标题、透明度等）
extension ChooCurrentWindowManager on ChooWindowManager {
  /// 显示窗口
  ///
  /// 如果窗口处于隐藏状态，调用此方法将使其显示
  Future<void> show() async {
    await _windowChannel.invokeMethod<void>('show', args);
  }

  /// 隐藏窗口
  ///
  /// 窗口将被隐藏但不会被关闭，可以通过[show]方法重新显示
  Future<void> hide() async {
    await _windowChannel.invokeMethod<void>('hide', args);
  }

  /// 使窗口获得焦点
  ///
  /// 窗口将被置于前台并获得输入焦点
  Future<void> focus() async {
    await _windowChannel.invokeMethod<void>('focus', args);
  }

  /// 使窗口失去焦点
  ///
  /// 窗口将失去输入焦点
  Future<void> blur() async {
    await _windowChannel.invokeMethod<void>('blur', args);
  }

  /// 关闭窗口
  ///
  /// 窗口将被完全关闭，如果需要阻止关闭，请使用[WindowManagerEvent.onWillClose]
  Future<void> close({bool force = false}) async {
    await _windowChannel.invokeMethod<void>('close', {...args, "force": force});
  }

  /// 检查窗口是否可见
  ///
  /// 返回窗口的可见状态
  Future<bool> isVisible() async {
    return (await _windowChannel.invokeMethod<bool>('isVisible', args))!;
  }

  /// 检查窗口是否最大化
  ///
  /// 返回窗口的最大化状态
  Future<bool> isMaximized() async {
    return (await _windowChannel.invokeMethod<bool>('isMaximized', args))!;
  }

  /// 最大化窗口
  ///
  /// 窗口将被调整至最大尺寸
  Future<void> maximize() async {
    _windowChannel.invokeMethod<void>('maximize', args);
  }

  /// 取消窗口最大化
  ///
  /// 窗口将恢复到最大化前的大小
  Future<void> unmaximize() async {
    _windowChannel.invokeMethod<void>('unmaximize', args);
  }

  /// 检查窗口是否最小化
  ///
  /// 返回窗口的最小化状态
  Future<bool> isMinimized() async {
    return (await _windowChannel.invokeMethod<bool>('isMinimized', args))!;
  }

  /// 最小化窗口
  ///
  /// 窗口将被最小化到任务栏
  Future<void> minimize() async {
    _windowChannel.invokeMethod<void>('minimize', args);
  }

  /// 还原窗口
  ///
  /// 将最小化或最大化的窗口恢复到正常状态
  Future<void> restore() async {
    _windowChannel.invokeMethod<void>('restore', args);
  }

  /// 获取窗口的当前大小
  ///
  /// 返回包含窗口宽度和高度的[Size]对象
  Future<Size> getSize() async {
    final Map<Object?, Object?>? result = await _windowChannel
        .invokeMethod<Map<Object?, Object?>>('getSize', args);
    assert(result != null, 'getSize Error');
    return Size(result!['width'] as double, result['height'] as double);
  }

  /// 设置窗口的大小
  ///
  /// [size] 要设置的窗口大小
  /// [animate] 是否使用动画效果
  Future<void> setSize(Size size, {bool animate = false}) async {
    final Map<String, dynamic> arguments = {
      'width': size.width,
      'height': size.height,
      'animate': animate,
      ...args,
    };
    await _windowChannel.invokeMethod<void>('setSize', arguments);
  }

  /// 获取窗口允许的最小大小
  ///
  /// 返回包含最小宽度和高度的[Size]对象
  Future<Size> getMinSize() async {
    Map<String, double> result =
        (await _windowChannel.invokeMethod<Map<Object?, Object?>>(
          'getMinSize',
          args,
        ))!.cast<String, double>();
    return Size(result['width']!, result['height']!);
  }

  /// 设置窗口允许的最小大小
  ///
  /// [size] 要设置的最小窗口大小
  Future<void> setMinSize(Size size) async {
    final Map<String, dynamic> arguments = {
      'width': size.width,
      'height': size.height,
      ...args,
    };
    await _windowChannel.invokeMethod<void>('setMinSize', arguments);
  }

  /// 获取窗口允许的最大大小
  ///
  /// 返回包含最大宽度和高度的[Size]对象
  Future<Size> getMaxSize() async {
    Map<String, double> result =
        (await _windowChannel.invokeMethod<Map<Object?, Object?>>(
          'getMaxSize',
          args,
        ))!.cast<String, double>();
    return Size(result['width']!, result['height']!);
  }

  /// 设置窗口允许的最大大小
  ///
  /// [size] 要设置的最大窗口大小
  Future<void> setMaxSize(Size size) async {
    final Map<String, dynamic> arguments = {
      'width': size.width,
      'height': size.height,
      ...args,
    };
    await _windowChannel.invokeMethod<void>('setMaxSize', arguments);
  }

  /// 获取屏幕的大小
  ///
  /// 返回当前屏幕的分辨率大小
  Future<Size> getScreenSize() async {
    Map<String, double> result =
        (await _windowChannel.invokeMethod<Map<Object?, Object?>>(
          'getScreenSize',
          args,
        ))!.cast<String, double>();
    return Size(result['width']!, result['height']!);
  }

  /// 获取窗口的当前位置
  ///
  /// [global] 是否返回全局坐标（相对于整个屏幕）
  ///
  /// 返回窗口左上角的坐标位置
  Future<Offset> getPosition({bool global = false}) async {
    final Map<String, dynamic> arguments = {'global': global, ...args};
    Map<String, double> result =
        (await _windowChannel.invokeMethod<Map<Object?, Object?>>(
          'getPosition',
          arguments,
        ))!.cast<String, double>();
    if (global) {
      return GlobalOffset(
        result['globalX']!,
        result['globalY']!,
        result['x']!,
        result['y']!,
      );
    }
    return Offset(result['x']!, result['y']!);
  }

  /// 设置窗口的位置
  ///
  /// [position] 要设置的窗口位置
  /// [global] 是否使用全局坐标（相对于整个屏幕）
  /// [animate] 是否使用动画效果
  Future<void> setPosition(
    Offset position, {
    bool global = false,
    bool animate = false,
  }) async {
    final Map<String, dynamic> arguments = {
      'x': position.dx,
      'y': position.dy,
      'global': global,
      'animate': animate,
      ...args,
    };
    await _windowChannel.invokeMethod<void>('setPosition', arguments);
  }

  /// 将窗口居中显示
  ///
  /// [animate] 是否使用动画效果
  Future<void> center({bool animate = false}) async {
    final Map<String, dynamic> arguments = {'animate': animate, ...args};
    await _windowChannel.invokeMethod<void>('center', arguments);
  }

  /// 获取窗口的边界矩形
  ///
  /// [global] 是否返回全局坐标（相对于整个屏幕）
  ///
  /// 返回包含窗口位置和大小的矩形
  Future<Rect> getBounds({bool global = false}) async {
    final Map<String, dynamic> arguments = {'global': global, ...args};
    Map<String, double> result =
        (await _windowChannel.invokeMethod<Map<Object?, Object?>>(
          'getBounds',
          arguments,
        ))!.cast<String, double>();
    return Rect.fromLTWH(
      result['x']!,
      result['y']!,
      result['width']!,
      result['height']!,
    );
  }

  /// 设置窗口的边界矩形
  ///
  /// [rect] 要设置的窗口边界矩形
  /// [global] 是否使用全局坐标（相对于整个屏幕）
  /// [animate] 是否使用动画效果
  Future<void> setBounds(
    Rect rect, {
    bool global = false,
    bool animate = false,
  }) async {
    final Map<String, dynamic> arguments = {
      'x': rect.left,
      'y': rect.top,
      'width': rect.width,
      'height': rect.height,
      'global': global,
      'animate': animate,
      ...args,
    };
    await _windowChannel.invokeMethod<void>('setBounds', arguments);
  }

  /// 获取窗口的标题
  Future<void> getTitle() async {
    await _windowChannel.invokeMethod<void>('getTitle', args);
  }

  /// 设置窗口的标题
  ///
  /// [title] 要设置的窗口标题文本
  Future<void> setTitle(String title) async {
    final Map<String, dynamic> arguments = {'title': title, ...args};
    await _windowChannel.invokeMethod<void>('setTitle', arguments);
  }

  /// 获取窗口的动画行为
  ///
  /// 返回当前设置的窗口动画行为类型
  Future<WindowAnimationBehavior?> getAnimationBehavior() async {
    return WindowAnimationBehaviorExtension.fromString(
      await _windowChannel.invokeMethod<String>('getAnimationBehavior', args),
    );
  }

  /// 设置窗口的动画行为
  ///
  /// [animationBehavior] 要设置的动画行为类型
  Future<void> setAnimationBehavior(
    WindowAnimationBehavior animationBehavior,
  ) async {
    final Map<String, dynamic> arguments = {
      'animationBehavior': animationBehavior.name,
      ...args,
    };
    await _windowChannel.invokeMethod<void>('setAnimationBehavior', arguments);
  }

  /// 获取窗口标题栏的样式
  ///
  /// 返回当前设置的标题栏可见性类型
  Future<WindowTitleVisibility> getTitleStyle() async {
    return WindowTitleVisibilityExtension.fromString(
      await _windowChannel.invokeMethod<String>('getTitleBarStyle', args),
    )!;
  }

  /// 设置窗口标题栏的样式
  ///
  /// [titleBarStyle] 要设置的标题栏可见性类型
  Future<void> setTitleStyle(WindowTitleVisibility titleBarStyle) async {
    final Map<String, dynamic> arguments = {
      'titleBarStyle': titleBarStyle.name,
      ...args,
    };
    await _windowChannel.invokeMethod<void>('setTitleBarStyle', arguments);
  }

  /// 获取窗口的透明度
  ///
  /// 返回当前窗口的透明度值（0.0到1.0之间）
  Future<double> getOpacity() async {
    return (await _windowChannel.invokeMethod<double>('getOpacity', args))!;
  }

  /// 设置窗口的透明度
  ///
  /// [opacity] 要设置的透明度值（0.0到1.0之间）
  Future<void> setOpacity(double opacity) async {
    final Map<String, dynamic> arguments = {'opacity': opacity, ...args};
    await _windowChannel.invokeMethod<void>('setOpacity', arguments);
  }

  /// 获取鼠标指针的当前位置
  ///
  /// 返回相对于窗口的鼠标坐标
  Future<Offset> getMousePoint() async {
    Map<String, double> result =
        (await _windowChannel.invokeMethod<Map<Object?, Object?>>(
          'getMousePoint',
          args,
        ))!.cast<String, double>();
    return Offset(result["x"]!, result["y"]!);
  }

  /// 向指定窗口发送事件
  ///
  /// [id] 目标窗口的ID
  /// [method] 事件的方法名
  /// [arguments] 事件的参数
  ///
  /// 返回事件的响应结果
  Future<WindowEmit<T>?> emit<T>(
    int id,
    String method, [
    Map<String, dynamic>? arguments,
  ]) async {
    Map<String, dynamic>? result =
        (await _windowChannel.invokeMethod('emit', {
          ...args,
          'targetId': id,
          'method': method,
          'arguments': arguments,
        }))?.cast<String, dynamic>();
    if (result == null) {
      return null;
    }
    return WindowEmit<T>(
      result['id'] as int,
      result['method'] as String,
      result: result['arguments'] as T,
    );
  }
}
