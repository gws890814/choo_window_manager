import 'package:choo_window_manager/choo_window_manager.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

part 'window_types.dart';

const uuid = Uuid();

/// 窗口管理器事件抽象类，用于处理窗口相关的事件
abstract mixin class WindowManagerEvent {
  /// 窗口事件监听器列表
  /// 用于存储所有窗口事件监听器实例
  static final List<WindowManagerEvent> _eventList = [];

  /// 悬停/预拖拽事件监听器列表
  /// 用于存储所有悬停和预拖拽事件监听器实例
  static final List<WindowManagerEvent> _hoverEventList = [];

  static WindowManagerEvent? _instance;

  /// 添加窗口事件监听器
  ///
  /// @param instance 要添加的事件监听器实例，通常为实现了本抽象类的对象。
  /// @usage WindowManagerEvent.addListener(this);
  /// @note 若首次添加，将通知原生端注册监听。
  static void addListener(WindowManagerEvent instance) {
    if (!_eventList.contains(instance)) {
      _eventList.add(instance);
      if (_eventList.length == 1) {
        // 首次添加监听器时，通知原生端注册事件监听
        ChooWindowManager.current._windowChannel.invokeMethod<void>(
          'addListener',
          {"id": ChooWindowManager.current.id},
        );
      }
    }
  }

  /// 移除窗口事件监听器
  ///
  /// @param instance 要移除的事件监听器实例。
  /// @usage WindowManagerEvent.removeListener(this);
  /// @note 若移除后无监听器，将通知原生端注销监听。
  static void removeListener(WindowManagerEvent instance) {
    if (_eventList.contains(instance)) {
      _eventList.remove(instance);
      if (_eventList.isEmpty) {
        // 最后一个监听器被移除时，通知原生端注销事件监听
        ChooWindowManager.current._windowChannel.invokeMethod<void>(
          'removeListener',
          {"id": ChooWindowManager.current.id},
        );
      }
    }
  }

  /// 添加拖拽事件监听器
  ///
  /// @param instance 要添加的拖拽事件监听器实例。
  /// @throws AssertionError 若已存在拖拽监听器。
  /// @usage WindowManagerEvent.addPanListener(this);
  /// @note 仅允许一个拖拽监听器存在。
  static void addPanListener(WindowManagerEvent instance) {
    assert(_instance == null, 'Only one listener is allowed');
    _instance = instance;
    // 通知原生端注册拖拽监听，并在回调中触发onPan
    ChooWindowManager.current._windowChannel
        .invokeMethod<Map<Object?, Object?>>('addPanListener', {
          "id": ChooWindowManager.current.id,
        })
        .then((value) {
          Offset offset = Offset(value!['x'] as double, value['y'] as double);
          _instance?.onPan(offset);
        });
  }

  /// 移除拖拽事件监听器
  ///
  /// @param instance 要移除的拖拽事件监听器实例。
  /// @usage WindowManagerEvent.removePanListener(this);
  static void removePanListener(WindowManagerEvent instance) {
    if (_instance == instance) {
      _instance = null;
      // 通知原生端移除拖拽监听
      ChooWindowManager.current._windowChannel.invokeMethod<void>(
        'removePanListener',
        {"id": ChooWindowManager.current.id},
      );
    }
  }

  /// 添加预拖拽事件监听器
  ///
  /// @param instance 要添加的预拖拽事件监听器实例。
  /// @usage WindowManagerEvent.addPrePanListener(this);
  static void addPrePanListener(WindowManagerEvent instance) {
    if (!_hoverEventList.contains(instance)) {
      _hoverEventList.add(instance);
      if (_hoverEventList.length == 1) {
        // 通知原生端注册预拖拽监听
        ChooWindowManager.current._windowChannel.invokeMethod<void>(
          'addPrePanListener',
          {"id": ChooWindowManager.current.id, "eventid": instance.eventid},
        );
      }
    }
  }

  /// 移除预拖拽事件监听器
  ///
  /// @param instance 要移除的预拖拽事件监听器实例。
  /// @usage WindowManagerEvent.removePrePanListener(this);
  static void removePrePanListener(WindowManagerEvent instance) {
    if (_hoverEventList.contains(instance)) {
      _hoverEventList.remove(instance);
      // 通知原生端移除预拖拽监听
      if (_hoverEventList.isEmpty) {
        ChooWindowManager.current._windowChannel.invokeMethod<void>(
          'removePrePanListener',
          {"id": ChooWindowManager.current.id, "eventid": instance.eventid},
        );
      }
    }
  }

  /// 添加悬停事件监听器
  ///
  /// @param instance 要添加的悬停事件监听器实例。
  /// @usage WindowManagerEvent.addHoverListener(this);
  static void addHoverListener(WindowManagerEvent instance) {
    if (!_hoverEventList.contains(instance)) {
      _hoverEventList.add(instance);
      if (_hoverEventList.length == 1) {
        // 通知原生端注册悬停监听
        ChooWindowManager.current._windowChannel.invokeMethod<void>(
          'addHoverListener',
          {"id": ChooWindowManager.current.id, "eventid": instance.eventid},
        );
      }
    }
  }

  /// 移除悬停事件监听器
  ///
  /// @param instance 要移除的悬停事件监听器实例。
  /// @usage WindowManagerEvent.removeHoverListener(this);
  static void removeHoverListener(WindowManagerEvent instance) {
    if (_hoverEventList.contains(instance)) {
      _hoverEventList.remove(instance);
      // 通知原生端移除悬停监听
      if (_hoverEventList.isEmpty) {
        ChooWindowManager.current._windowChannel.invokeMethod<void>(
          'removeHoverListener',
          {"id": ChooWindowManager.current.id, "eventid": instance.eventid},
        );
      }
    }
  }

  /// 事件监听器的唯一标识符，使用当前时间戳生成。
  final String _id = uuid.v4();

  /// 获取事件监听器的唯一标识符。
  /// @return 事件监听器的唯一标识符，类型为int。
  String get eventid => _id;

  /// 窗口尺寸变化回调。
  /// @param size 新的窗口尺寸。
  void onResize(Size size) {}

  /// 窗口移动回调。
  /// @param offset 新的窗口全局/局部坐标。
  void onMove(GlobalOffset offset) {}

  /// 拖拽事件回调。
  /// @param offset 拖拽时的全局坐标。
  void onPan(Offset offset) {}

  /// 悬停事件回调。
  /// @param offset 悬停时的全局坐标。
  void onHover(Offset offset) {}

  /// 窗口初始化完成回调。
  void onReady() {}

  /// 窗口显示回调。
  void onShow() {}

  /// 窗口隐藏回调。
  void onHide() {}

  /// 窗口获得焦点回调。
  void onFocus() {}

  /// 窗口失去焦点回调。
  void onBlur() {}

  /// 窗口最小化回调。
  void onMinimize() {}

  /// 窗口最大化回调。
  void onMaximize() {}

  /// 窗口还原回调。
  void onRestore() {}

  /// 即将进入全屏回调。
  void onWillEnterFullScreen() {}

  /// 已进入全屏回调。
  void onDidEnterFullScreen() {}

  /// 即将离开全屏回调。
  void onWillLeaveFullScreen() {}

  /// 已离开全屏回调。
  void onDidLeaveFullScreen() {}

  void changeTitle(String title) {}

  /// 窗口关闭前回调。
  /// @return 是否允许关闭，返回false可阻止关闭。
  Future<bool> onWillClose() => Future.value(true);

  /// 窗口关闭回调。
  void onClose() {}

  /// 键盘事件回调。
  /// @param event 键盘事件对象。
  /// @return 是否继续传递事件，返回false则不再传递。
  Future<bool> onKeyboard(KeyboardEvent event) => Future.value(true);

  /// 通用事件回调。
  /// @param id 事件ID。
  /// @param method 事件方法名。
  /// @param arguments 事件参数。
  /// @param delivery 上一监听器的返回值。
  /// @return 可自定义返回值，用于事件链传递。
  Future<dynamic> onEvent(
    int id,
    String method, {
    dynamic arguments,
    required dynamic delivery,
  }) => Future.value(delivery);
}

/// ChooWindowManager类用于管理应用窗口的生命周期、事件分发及与原生窗口的通信。
///
/// 主要功能包括：
/// - 创建、关闭、销毁窗口
/// - 维护当前窗口实例
/// - 通过MethodChannel与原生端进行方法调用和事件处理
/// - 初始化窗口参数并同步到原生端
/// - 事件分发（如窗口移动、尺寸变化、键盘、拖拽、悬停等）
///
/// 典型使用场景：
/// 1. 通过ChooWindowManager.ready初始化窗口并注册回调
/// 2. 使用current获取当前窗口实例，进行窗口操作
/// 3. 通过扩展方法调用窗口的显示、隐藏、聚焦、移动等操作
class ChooWindowManager {
  /// 全局通道，用于全局窗口操作（如创建、关闭所有窗口等）
  static final MethodChannel _globalChannel = const MethodChannel(
    'choo_window_manager',
  );

  /// 当前窗口管理器实例，便于全局访问和操作
  static late ChooWindowManager current;

  /// 当前窗口专属的MethodChannel，用于与原生端通信
  final MethodChannel _windowChannel;

  /// 当前窗口的唯一标识符
  final int id;

  /// 获取当前窗口的参数（如id），便于方法调用时传参
  Map<String, dynamic> get args => {'id': id};

  /// 构造函数：初始化窗口管理器并注册回调
  ///
  /// @param options 窗口初始化参数
  /// @param callback 初始化完成后的回调，返回窗口实例
  ChooWindowManager.ready(
    ChooWindowOptions options,
    void Function(ChooWindowManager window) callback,
  ) : id = options.id,
      _windowChannel = MethodChannel('choo_window_manager_${options.id}') {
    current = this;
    _windowChannel.setMethodCallHandler(_windowChannelHandler);
    _init(options, callback);
  }

  /// 处理原生端发来的MethodCall事件，根据事件类型分发到对应的回调或事件处理方法
  ///
  /// @param call 原生端发来的方法调用
  /// @return 处理结果，部分事件有返回值
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
          "resize": element.onResize,
          "willEnterFullScreen": element.onWillEnterFullScreen,
          "didEnterFullScreen": element.onDidEnterFullScreen,
          "willLeaveFullScreen": element.onWillLeaveFullScreen,
          "didLeaveFullScreen": element.onDidLeaveFullScreen,
          "close": element.onClose,
          "keyboard": element.onKeyboard,
          "changeTitle": element.changeTitle,
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
        } else if (method == 'changeTitle') {
          eventMap[method]!(arguments['title'] ?? '');
        } else if (eventMap[method] != null) {
          eventMap[method]!();
        }
      }
    }
    return null;
  }

  /// 初始化窗口参数并同步到原生端，完成后回调callback
  ///
  /// @param options 窗口初始化参数
  /// @param callback 初始化完成后的回调
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

    if (options.buttonOptions != null) {
      options.buttonOptions!._exec();
    }

    await _windowChannel.invokeMethod<void>("windowReady", args);

    for (var element in WindowManagerEvent._eventList) {
      element.onReady();
    }

    callback(this);
  }

  /// 创建新窗口，返回新窗口的id
  ///
  /// @param args 新窗口参数
  /// @return 新窗口id
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

  /// 关闭指定窗口
  ///
  /// @param windowId 要关闭的窗口id
  /// @return 是否关闭成功
  static Future<bool> closeWindow(int windowId) async {
    return closeWindows(ids: [windowId]);
  }

  /// 关闭多个窗口
  ///
  /// @param ids 要关闭的窗口id列表
  /// @return 是否全部关闭成功
  static Future<bool> closeWindows({List<int>? ids}) async {
    return (await _globalChannel.invokeMethod<bool>("closeWindows", {
      "ids": ids,
    }))!;
  }

  /// 销毁所有窗口
  static Future<void> destroy() async {
    await _globalChannel.invokeMethod<void>("destroy");
  }

  /// 获取所有窗口ID
  ///
  /// @return 所有窗口的ID列表。
  static Future<List<int>> getWindowIds() async {
    final result = await _globalChannel.invokeMethod<List<Object?>>('getWindowIds');
    if (result == null) return [];
    return result.cast<int>();
  }

  /// 向所有窗口广播事件
  ///
  /// @param method 事件方法名。
  /// @param arguments 可选的事件参数。
  /// @param self 是否向自身也发送事件，默认为 false。
  static Future<void> broadcast(
    String method, [
    Map<String, dynamic>? arguments,
    bool self = false,
  ]) async {
    final ids = await getWindowIds();
    for (final id in ids) {
      if (!self && id == current.id) continue;
      await current.emit(id, method, arguments);
    }
  }
}

extension ChooCurrentWindowManager on ChooWindowManager {
  /// 显示窗口。
  ///
  /// 使窗口可见。
  Future<void> show() async {
    await _windowChannel.invokeMethod<void>('show', args);
  }

  /// 隐藏窗口。
  ///
  /// 使窗口不可见。
  Future<void> hide() async {
    await _windowChannel.invokeMethod<void>('hide', args);
  }

  /// 使窗口获得焦点。
  ///
  /// 将窗口置于前台并激活。
  Future<void> focus() async {
    await _windowChannel.invokeMethod<void>('focus', args);
  }

  /// 使窗口失去焦点。
  ///
  /// 将窗口置于后台并取消激活状态。
  Future<void> blur() async {
    await _windowChannel.invokeMethod<void>('blur', args);
  }

  /// 关闭窗口。
  ///
  /// @param force 是否强制关闭，若为true则忽略onWillClose回调直接关闭。
  Future<void> close({bool force = false}) async {
    await _windowChannel.invokeMethod<void>('close', {...args, "force": force});
  }

  /// 检查窗口是否可见。
  ///
  /// @return 窗口是否可见。
  Future<bool> isVisible() async {
    return (await _windowChannel.invokeMethod<bool>('isVisible', args))!;
  }

  /// 检查窗口是否最大化。
  ///
  /// @return 窗口是否处于最大化状态。
  Future<bool> isMaximized() async {
    return (await _windowChannel.invokeMethod<bool>('isMaximized', args))!;
  }

  /// 最大化窗口。
  ///
  /// 将窗口扩展到最大可用尺寸。
  Future<void> maximize() async {
    _windowChannel.invokeMethod<void>('maximize', args);
  }

  /// 取消窗口最大化。
  ///
  /// 将窗口从最大化状态还原。
  Future<void> unmaximize() async {
    _windowChannel.invokeMethod<void>('unmaximize', args);
  }

  /// 检查窗口是否最小化。
  ///
  /// @return 窗口是否处于最小化状态。
  Future<bool> isMinimized() async {
    return (await _windowChannel.invokeMethod<bool>('isMinimized', args))!;
  }

  /// 最小化窗口。
  ///
  /// 将窗口最小化到任务栏。
  Future<void> minimize() async {
    _windowChannel.invokeMethod<void>('minimize', args);
  }

  /// 还原窗口。
  ///
  /// 将窗口从最小化或最大化状态还原到正常状态。
  Future<void> restore() async {
    _windowChannel.invokeMethod<void>('restore', args);
  }

  Future<bool> isFullScreen() async {
    return (await _windowChannel.invokeMethod<bool>('isFullScreen', args))!;
  }

  Future<void> setFullScreen({required bool isFullScreen}) async {
    _windowChannel.invokeMethod<void>('setFullScreen', {
      ...args,
      "isFullScreen": isFullScreen,
    });
  }

  /// 获取窗口尺寸。
  ///
  /// @return 窗口的当前尺寸。
  /// @throws AssertionError 如果获取尺寸失败。
  Future<Size> getSize() async {
    final Map<Object?, Object?>? result = await _windowChannel
        .invokeMethod<Map<Object?, Object?>>('getSize', args);
    assert(result != null, 'getSize Error');
    return Size(result!['width'] as double, result['height'] as double);
  }

  /// 设置窗口尺寸。
  ///
  /// @param size 要设置的窗口尺寸。
  /// @param animate 是否使用动画效果，默认为false。
  Future<void> setSize(Size size, {bool animate = false}) async {
    final Map<String, dynamic> arguments = {
      'width': size.width,
      'height': size.height,
      'animate': animate,
      ...args,
    };
    await _windowChannel.invokeMethod<void>('setSize', arguments);
  }

  /// 获取窗口最小尺寸。
  ///
  /// @return 窗口允许的最小尺寸。
  Future<Size> getMinSize() async {
    Map<String, double> result =
        (await _windowChannel.invokeMethod<Map<Object?, Object?>>(
          'getMinSize',
          args,
        ))!.cast<String, double>();
    return Size(result['width']!, result['height']!);
  }

  /// 设置窗口最小尺寸。
  ///
  /// @param size 要设置的最小尺寸。
  Future<void> setMinSize(Size size) async {
    final Map<String, dynamic> arguments = {
      'width': size.width,
      'height': size.height,
      ...args,
    };
    await _windowChannel.invokeMethod<void>('setMinSize', arguments);
  }

  /// 获取窗口最大尺寸。
  ///
  /// @return 窗口允许的最大尺寸。
  Future<Size> getMaxSize() async {
    Map<String, double> result =
        (await _windowChannel.invokeMethod<Map<Object?, Object?>>(
          'getMaxSize',
          args,
        ))!.cast<String, double>();
    return Size(result['width']!, result['height']!);
  }

  /// 设置窗口最大尺寸。
  ///
  /// @param size 要设置的最大尺寸。
  Future<void> setMaxSize(Size size) async {
    final Map<String, dynamic> arguments = {
      'width': size.width,
      'height': size.height,
      ...args,
    };
    await _windowChannel.invokeMethod<void>('setMaxSize', arguments);
  }

  /// 获取屏幕尺寸。
  ///
  /// @return 当前屏幕的尺寸。
  Future<Size> getScreenSize() async {
    Map<String, double> result =
        (await _windowChannel.invokeMethod<Map<Object?, Object?>>(
          'getScreenSize',
          args,
        ))!.cast<String, double>();
    return Size(result['width']!, result['height']!);
  }

  /// 获取窗口位置。
  ///
  /// @param global 是否获取全局坐标，默认为false。
  /// @return 窗口的位置，如果global为true则返回GlobalOffset，否则返回Offset。
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

  /// 设置窗口位置。
  ///
  /// @param position 要设置的位置坐标。
  /// @param global 是否使用全局坐标，默认为false。
  /// @param animate 是否使用动画效果，默认为false。
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

  /// 将窗口居中显示。
  ///
  /// @param animate 是否使用动画效果，默认为false。
  Future<void> center({bool animate = false}) async {
    final Map<String, dynamic> arguments = {'animate': animate, ...args};
    await _windowChannel.invokeMethod<void>('center', arguments);
  }

  /// 获取窗口边界。
  ///
  /// @param global 是否使用全局坐标，默认为false。
  /// @return 窗口的边界矩形。
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

  Future<void> setWindowButtonHidden({
    List<WindowButtonType> types = const [],
    required bool state,
  }) async {
    final Map<String, dynamic> arguments = {
      'types': types.map((type) => type.name).toList(),
      'state': state,
      ...args,
    };
    await _windowChannel.invokeMethod<Map<Object?, Object?>>(
      'setWindowButtonHidden',
      arguments,
    );
  }

  Future<void> setWindowButtonEnabled({
    List<WindowButtonType> types = const [],
    required bool state,
  }) async {
    final Map<String, dynamic> arguments = {
      'types': types.map((type) => type.name).toList(),
      'state': state,
      ...args,
    };
    await _windowChannel.invokeMethod<Map<Object?, Object?>>(
      'setWindowButtonEnabled',
      arguments,
    );
  }

  Future<WindowButtonRegionPosition> getWindowButtonRegionPosition() async {
    final Map<String, dynamic> arguments = {...args};
    Map<String, double?> result =
        (await _windowChannel.invokeMethod<Map<Object?, Object?>>(
          'getWindowButtonRegionPosition',
          arguments,
        ))!.cast<String, double>();
    return WindowButtonRegionPosition(y: result['y']!, x: result['x']);
  }

  Future<void> setWindowButtonRegionPosition(
    WindowButtonRegionPosition position,
  ) async {
    final Map<String, dynamic> arguments = {
      ...args,
      'x': position.x,
      'y': position.y,
    };
    await _windowChannel.invokeMethod<Map<Object?, Object?>>(
      'setWindowButtonRegionPosition',
      arguments,
    );
  }

  Future<Size> getWindowButtonRegionSize() async {
    final Map<String, dynamic> arguments = {...args};
    Map<String, double?> result =
        (await _windowChannel.invokeMethod<Map<Object?, Object?>>(
          'getWindowButtonRegionSize',
          arguments,
        ))!.cast<String, double>();
    return Size(result['width']!, result['height']!);
  }

  Future<void> setWindowButtonRegionHeight(double height) async {
    final Map<String, dynamic> arguments = {...args, 'height': height};
    await _windowChannel.invokeMethod<Map<Object?, Object?>>(
      'setWindowButtonRegionHeight',
      arguments,
    );
  }

  Future<double> getWindowButtonSpacing() async {
    final Map<String, dynamic> arguments = {...args};
    return (await _windowChannel.invokeMethod<double>(
      'getWindowButtonSpacing',
      arguments,
    ))!;
  }

  Future<void> setWindowButtonSpacing(double spacing) async {
    final Map<String, dynamic> arguments = {...args, 'spacing': spacing};
    await _windowChannel.invokeMethod<Map<Object?, Object?>>(
      'setWindowButtonSpacing',
      arguments,
    );
  }

  Future<Size> getWindowButtonSize() async {
    final Map<String, dynamic> arguments = {...args};
    Map<String, double?> result =
        (await _windowChannel.invokeMethod<Map<Object?, Object?>>(
          'getWindowButtonSize',
          arguments,
        ))!.cast<String, double>();
    return Size(result['width']!, result['height']!);
  }

  Future<void> setWindowButtonSize(Size size) async {
    final Map<String, dynamic> arguments = {
      ...args,
      'width': size.width,
      'height': size.height,
    };
    await _windowChannel.invokeMethod<Map<Object?, Object?>>(
      'setWindowButtonSize',
      arguments,
    );
  }

  /// 设置窗口边界。
  ///
  /// @param rect 要设置的边界矩形。
  /// @param global 是否使用全局坐标，默认为false。
  /// @param animate 是否使用动画效果，默认为false。
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

  /// 获取窗口标题。
  Future<String> getTitle() async {
    return await _windowChannel.invokeMethod<String>('getTitle', args) ?? '';
  }

  /// 设置窗口标题。
  ///
  /// @param title 要设置的标题文本。
  Future<void> setTitle(String title) async {
    final Map<String, dynamic> arguments = {'title': title, ...args};
    await _windowChannel.invokeMethod<void>('setTitle', arguments);
  }

  /// 获取窗口动画行为。
  ///
  /// @return 当前的窗口动画行为。
  Future<WindowAnimationBehavior?> getAnimationBehavior() async {
    return WindowAnimationBehaviorExtension.fromString(
      await _windowChannel.invokeMethod<String>('getAnimationBehavior', args),
    );
  }

  /// 设置窗口动画行为。
  ///
  /// @param animationBehavior 要设置的动画行为。
  Future<void> setAnimationBehavior(
    WindowAnimationBehavior animationBehavior,
  ) async {
    final Map<String, dynamic> arguments = {
      'animationBehavior': animationBehavior.name,
      ...args,
    };
    await _windowChannel.invokeMethod<void>('setAnimationBehavior', arguments);
  }

  /// 获取标题栏样式。
  ///
  /// @return 当前的标题栏可见性样式。
  Future<WindowTitleVisibility> getTitleStyle() async {
    return WindowTitleVisibilityExtension.fromString(
      await _windowChannel.invokeMethod<String>('getTitleBarStyle', args),
    )!;
  }

  /// 设置标题栏样式。
  ///
  /// @param titleBarStyle 要设置的标题栏可见性样式。
  Future<void> setTitleStyle(WindowTitleVisibility titleBarStyle) async {
    final Map<String, dynamic> arguments = {
      'titleBarStyle': titleBarStyle.name,
      ...args,
    };
    await _windowChannel.invokeMethod<void>('setTitleBarStyle', arguments);
  }

  /// 获取窗口透明度。
  ///
  /// @return 当前的窗口透明度，范围0.0到1.0。
  Future<double> getOpacity() async {
    return (await _windowChannel.invokeMethod<double>('getOpacity', args))!;
  }

  /// 设置窗口透明度。
  ///
  /// @param opacity 要设置的透明度值，范围0.0到1.0。
  Future<void> setOpacity(double opacity) async {
    final Map<String, dynamic> arguments = {'opacity': opacity, ...args};
    await _windowChannel.invokeMethod<void>('setOpacity', arguments);
  }

  /// 获取鼠标指针位置。
  ///
  /// @return 鼠标指针的当前坐标。
  Future<Offset> getMousePoint() async {
    Map<String, double> result =
        (await _windowChannel.invokeMethod<Map<Object?, Object?>>(
          'getMousePoint',
          args,
        ))!.cast<String, double>();
    return Offset(result["x"]!, result["y"]!);
  }

  /// 向指定窗口发送事件。
  ///
  /// @param id 目标窗口的ID。
  /// @param method 事件方法名。
  /// @param arguments 可选的事件参数。
  /// @return 事件发送结果，如果发送成功则返回WindowEmit对象，否则返回null。
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

  /// 向多个窗口发送事件。
  ///
  /// @param ids 目标窗口ID列表。
  /// @param method 事件方法名。
  /// @param arguments 可选的事件参数。
  Future<void> emits(
    List<int> ids,
    String method, [
    Map<String, dynamic>? arguments,
  ]) async {
    for (final id in ids) {
      await emit(id, method, arguments);
    }
  }
}
