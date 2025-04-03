import 'dart:math';

import 'package:choo_window_manager/choo_window_manager.dart';
import 'package:flutter/services.dart';

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
    _init(options, callback);
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

  Future<Point> getPosition() async {
    Map<String, double> result =
        (await _windowChannel.invokeMethod<Map<Object?, Object?>>(
          'getPosition',
          args,
        ))!.cast<String, double>();
    ;
    return Point(result['x']!, result['y']!);
  }

  Future<void> setPosition(Point position, {bool animate = false}) async {
    final Map<String, dynamic> arguments = {
      'x': position.x,
      'y': position.y,
      'animate': animate,
      ...args,
    };
    await _windowChannel.invokeMethod<void>('setPosition', arguments);
  }

  Future<void> center({bool animate = false}) async {
    final Map<String, dynamic> arguments = {'animate': animate, ...args};
    await _windowChannel.invokeMethod<void>('center', arguments);
  }

  Future<Rect> getBounds() async {
    Map<String, double> result =
        (await _windowChannel.invokeMethod<Map<Object?, Object?>>(
          'getBounds',
          args,
        ))!.cast<String, double>();
    return Rect.fromLTWH(
      result['x']!,
      result['y']!,
      result['width']!,
      result['height']!,
    );
  }

  Future<void> setBounds(Rect rect, {bool animate = false}) async {
    final Map<String, dynamic> arguments = {
      'x': rect.left,
      'y': rect.top,
      'width': rect.width,
      'height': rect.height,
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
}
