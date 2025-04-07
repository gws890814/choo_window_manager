import 'package:choo_window_manager/choo_window_manager.dart';
import 'package:flutter/services.dart';

abstract mixin class WindowManagerEvent {
  static final List<WindowManagerEvent> _eventList = [];
  static final List<WindowManagerEvent> _hoverEventList = [];
  static WindowManagerEvent? _instance;

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

  static void addListenPan(WindowManagerEvent instance) {
    assert(_instance == null, 'Only one listener is allowed');
    _instance = instance;
    ChooWindowManager.current._windowChannel
        .invokeMethod<Map<Object?, Object?>>('addListenPan', {
          "id": ChooWindowManager.current.id,
        })
        .then((value) {
          Offset offset = Offset(value!['x'] as double, value['y'] as double);
          _instance?.onPan(offset);
        });
  }

  static void removeListenPan(WindowManagerEvent instance) {
    if (_instance == instance) {
      _instance = null;
      ChooWindowManager.current._windowChannel.invokeMethod<void>(
        'removeListenPan',
        {"id": ChooWindowManager.current.id},
      );
    }
  }

  static void addPreListenPan(WindowManagerEvent instance) {
    if (!_hoverEventList.contains(instance)) {
      _hoverEventList.add(instance);
      ChooWindowManager.current._windowChannel.invokeMethod<void>(
        'addPreListenPan',
        {"id": ChooWindowManager.current.id, "eventid": instance.eventid},
      );
    }
  }

  static void removePreListenPan(WindowManagerEvent instance) {
    if (_hoverEventList.contains(instance)) {
      _hoverEventList.remove(instance);
      ChooWindowManager.current._windowChannel.invokeMethod<void>(
        'removePreListenPan',
        {"id": ChooWindowManager.current.id, "eventid": instance.eventid},
      );
    }
  }

  static void addListenHover(WindowManagerEvent instance) {
    if (!_hoverEventList.contains(instance)) {
      _hoverEventList.add(instance);
      ChooWindowManager.current._windowChannel.invokeMethod<void>(
        'addListenHover',
        {"id": ChooWindowManager.current.id, "eventid": instance.eventid},
      );
    }
  }

  static void removeListenHover(WindowManagerEvent instance) {
    if (_hoverEventList.contains(instance)) {
      _hoverEventList.remove(instance);
      ChooWindowManager.current._windowChannel.invokeMethod<void>(
        'removeListenHover',
        {"id": ChooWindowManager.current.id, "eventid": instance.eventid},
      );
    }
  }

  final int _id = DateTime.now().microsecondsSinceEpoch;

  int get eventid => _id;

  void onResize(Size size) {}
  void onMove(GlobalOffset offset) {}
  void onPan(Offset offset) {}
  void onHover(Offset offset) {}
  void onShow() {}
  void onHide() {}
  void onFocus() {}
  void onBlur() {}
  void onMinimize() {}
  void onMaximize() {}
  void onRestore() {}
  void onWillEnterFullScreen() {}
  void onDidEnterFullScreen() {}
  void onWillLeaveFullScreen() {}
  void onDidLeaveFullScreen() {}
  Future<bool> onWillClose() => Future.value(true);
  void onClose() {}
  Future<dynamic> onEvent(
    int id,
    String method, {
    dynamic arguments,
    required dynamic delivery,
  }) => Future.value(delivery);
}

class ChooWindowManager {
  static final MethodChannel _globalChannel = const MethodChannel(
    'choo_window_manager',
  );
  static late ChooWindowManager current;
  final MethodChannel _windowChannel;
  final int id;
  Map<String, dynamic> get args => {'id': id};

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

  static Future<bool> closeWindow(int windowId) async {
    return closeWindows(ids: [windowId]);
  }

  static Future<bool> closeWindows({List<int>? ids}) async {
    return (await _globalChannel.invokeMethod<bool>("closeWindows", {
      "ids": ids,
    }))!;
  }

  static Future<void> destroy() async {
    await _globalChannel.invokeMethod<void>("destroy");
  }
}

extension ChooCurrentWindowManager on ChooWindowManager {
  Future<void> show() async {
    await _windowChannel.invokeMethod<void>('show', args);
  }

  Future<void> hide() async {
    await _windowChannel.invokeMethod<void>('hide', args);
  }

  Future<void> focus() async {
    await _windowChannel.invokeMethod<void>('focus', args);
  }

  Future<void> blur() async {
    await _windowChannel.invokeMethod<void>('blur', args);
  }

  Future<void> close() async {
    await _windowChannel.invokeMethod<void>('close', args);
  }

  Future<bool> isVisible() async {
    return (await _windowChannel.invokeMethod<bool>('isVisible', args))!;
  }

  Future<bool> isMaximized() async {
    return (await _windowChannel.invokeMethod<bool>('isMaximized', args))!;
  }

  Future<void> maximize() async {
    _windowChannel.invokeMethod<void>('maximize', args);
  }

  Future<void> unmaximize() async {
    _windowChannel.invokeMethod<void>('unmaximize', args);
  }

  Future<bool> isMinimized() async {
    return (await _windowChannel.invokeMethod<bool>('isMinimized', args))!;
  }

  Future<void> minimize() async {
    _windowChannel.invokeMethod<void>('minimize', args);
  }

  Future<void> restore() async {
    _windowChannel.invokeMethod<void>('restore', args);
  }

  Future<Size> getSize() async {
    final Map<Object?, Object?>? result = await _windowChannel
        .invokeMethod<Map<Object?, Object?>>('getSize', args);
    assert(result != null, 'getSize Error');
    return Size(result!['width'] as double, result['height'] as double);
  }

  Future<void> setSize(Size size, {bool animate = false}) async {
    final Map<String, dynamic> arguments = {
      'width': size.width,
      'height': size.height,
      'animate': animate,
      ...args,
    };
    await _windowChannel.invokeMethod<void>('setSize', arguments);
  }

  Future<Size> getMinSize() async {
    Map<String, double> result =
        (await _windowChannel.invokeMethod<Map<Object?, Object?>>(
          'getMinSize',
          args,
        ))!.cast<String, double>();
    return Size(result['width']!, result['height']!);
  }

  Future<void> setMinSize(Size size) async {
    final Map<String, dynamic> arguments = {
      'width': size.width,
      'height': size.height,
      ...args,
    };
    await _windowChannel.invokeMethod<void>('setMinSize', arguments);
  }

  Future<Size> getMaxSize() async {
    Map<String, double> result =
        (await _windowChannel.invokeMethod<Map<Object?, Object?>>(
          'getMaxSize',
          args,
        ))!.cast<String, double>();
    return Size(result['width']!, result['height']!);
  }

  Future<void> setMaxSize(Size size) async {
    final Map<String, dynamic> arguments = {
      'width': size.width,
      'height': size.height,
      ...args,
    };
    await _windowChannel.invokeMethod<void>('setMaxSize', arguments);
  }

  Future<Size> getScreenSize() async {
    Map<String, double> result =
        (await _windowChannel.invokeMethod<Map<Object?, Object?>>(
          'getScreenSize',
          args,
        ))!.cast<String, double>();
    return Size(result['width']!, result['height']!);
  }

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

  Future<void> center({bool animate = false}) async {
    final Map<String, dynamic> arguments = {'animate': animate, ...args};
    await _windowChannel.invokeMethod<void>('center', arguments);
  }

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

  Future<void> getTitle() async {
    await _windowChannel.invokeMethod<void>('getTitle', args);
  }

  Future<void> setTitle(String title) async {
    final Map<String, dynamic> arguments = {'title': title, ...args};
    await _windowChannel.invokeMethod<void>('setTitle', arguments);
  }

  Future<WindowAnimationBehavior?> getAnimationBehavior() async {
    return WindowAnimationBehaviorExtension.fromString(
      await _windowChannel.invokeMethod<String>('getAnimationBehavior', args),
    );
  }

  Future<void> setAnimationBehavior(
    WindowAnimationBehavior animationBehavior,
  ) async {
    final Map<String, dynamic> arguments = {
      'animationBehavior': animationBehavior.name,
      ...args,
    };
    await _windowChannel.invokeMethod<void>('setAnimationBehavior', arguments);
  }

  Future<WindowTitleVisibility> getTitleStyle() async {
    return WindowTitleVisibilityExtension.fromString(
      await _windowChannel.invokeMethod<String>('getTitleBarStyle', args),
    )!;
  }

  Future<void> setTitleStyle(WindowTitleVisibility titleBarStyle) async {
    final Map<String, dynamic> arguments = {
      'titleBarStyle': titleBarStyle.name,
      ...args,
    };
    await _windowChannel.invokeMethod<void>('setTitleBarStyle', arguments);
  }

  Future<double> getOpacity() async {
    return (await _windowChannel.invokeMethod<double>('getOpacity', args))!;
  }

  Future<void> setOpacity(double opacity) async {
    final Map<String, dynamic> arguments = {'opacity': opacity, ...args};
    await _windowChannel.invokeMethod<void>('setOpacity', arguments);
  }

  Future<Offset> getMousePoint() async {
    Map<String, double> result =
        (await _windowChannel.invokeMethod<Map<Object?, Object?>>(
          'getMousePoint',
          args,
        ))!.cast<String, double>();
    return Offset(result["x"]!, result["y"]!);
  }

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
