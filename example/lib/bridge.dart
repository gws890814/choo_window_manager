import 'dart:convert';

import 'package:choo_window_manager/choo_window_manager.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

abstract mixin class WebviewBridge {
  static Future<int> createWindow(Map<String, dynamic>? args) async {
    return await ChooWindowManager.createWindow(args);
  }

  static Future<bool> closeWindow(int id) async {
    return await ChooWindowManager.closeWindow(id);
  }

  static Future<bool> closeWindows({List<int>? ids}) async {
    return await ChooWindowManager.closeWindows(ids: ids);
  }

  InAppWebViewController? _webviewController;
  InAppWebViewController? get webviewController => _webviewController;
  set webviewController(InAppWebViewController? controller) {
    _webviewController = controller;
    Map<String, dynamic Function(List<dynamic>)> handlers = {
      "addPrePanListener": _addPrePanListener,
      "removePrePanListener": _removePrePanListener,
      "addPanListener": _addPanListener,
      "removePanListener": _removePanListener,
      "addHoverListener": _addHoverListener,
      "removeHoverListener": _removeHoverListener,
      "addListener": _addListener,
      "removeListener": _removeListener,
      "show": _show,
      "hide": _hide,
      "focus": _focus,
      "blur": _blur,
      "close": _close,
      "isVisible": _isVisible,
      "isMaximized": _isMaximized,
      "maximize": _maximize,
      "unmaximize": _unmaximize,
      "isMinimized": _isMinimized,
      "minimize": _minimize,
      "restore": _restore,
      "isFullScreen": _isFullScreen,
      "setFullScreen": _setFullScreen,
      "getSize": _getSize,
      "setSize": _setSize,
      "getMinSize": _getMinSize,
      "setMinSize": _setMinSize,
      "getMaxSize": _getMaxSize,
      "setMaxSize": _setMaxSize,
      "getScreenSize": _getScreenSize,
      "getPosition": _getPosition,
      "setPosition": _setPosition,
      "center": _center,
      "getBounds": _getBounds,
      "setBounds": _setBounds,
      "getTitle": _getTitle,
      "setTitle": _setTitle,
      "getAnimationBehavior": _getAnimationBehavior,
      "setAnimationBehavior": _setAnimationBehavior,
      "getTitleStyle": _getTitleStyle,
      "setTitleStyle": _setTitleStyle,
      "getOpacity": _getOpacity,
      "setOpacity": _setOpacity,
      "getMousePoint": _getMousePoint,
      "setWindowButtonHidden": _setWindowButtonHidden,
      "setWindowButtonEnabled": _setWindowButtonEnabled,
      "getWindowButtonRegionPosition": _getWindowButtonRegionPosition,
      "setWindowButtonRegionPosition": _setWindowButtonRegionPosition,
      "getWindowButtonRegionSize": _getWindowButtonRegionSize,
      "setWindowButtonRegionHeight": _setWindowButtonRegionHeight,
      "getWindowButtonSpacing": _getWindowButtonSpacing,
      "setWindowButtonSpacing": _setWindowButtonSpacing,
      "getWindowButtonSize": _getWindowButtonSize,
      "setWindowButtonSize": _setWindowButtonSize,
      "emit": _emit,
    };

    // 注册JavaScript处理器
    handlers.forEach((name, handler) {
      _webviewController?.addJavaScriptHandler(
        handlerName: name,
        callback: (args) async {
          try {
            return await handler(args);
          } catch (e) {
            return {'error': e.toString()};
          }
        },
      );
    });
  }

  Future<bool> _webviewqDispatchEvent(
    String eventName, {
    Map<String, dynamic>? params = const {},
    Map<String, dynamic>? detail,
  }) async {
    bool result = await _webviewController?.evaluateJavascript(
      source: """
(function(eventName, params, detail) {
  const event = new CustomEvent(eventName, {
    ...params,
    detail,
    bubbles: true,
    cancelable: true,
  })
  return window.dispatchEvent(event)
})("$eventName", ${jsonEncode(params)}, ${detail == null ? null : jsonEncode(detail)})
""",
    );
    return result;
  }

  void _addListener(List<dynamic> params) {
    if (this is WindowManagerEvent) {
      WindowManagerEvent.addListener(this as WindowManagerEvent);
    }
  }

  void _removeListener(List<dynamic> params) {
    if (this is WindowManagerEvent) {
      WindowManagerEvent.removeListener(this as WindowManagerEvent);
    }
  }

  void _addHoverListener(List<dynamic> params) {
    if (this is WindowManagerEvent) {
      WindowManagerEvent.addHoverListener(this as WindowManagerEvent);
    }
  }

  void _removeHoverListener(List<dynamic> params) {
    if (this is WindowManagerEvent) {
      WindowManagerEvent.removeHoverListener(this as WindowManagerEvent);
    }
  }

  void _addPanListener(List<dynamic> params) {
    if (this is WindowManagerEvent) {
      WindowManagerEvent.addPanListener(this as WindowManagerEvent);
    }
  }

  void _removePanListener(List<dynamic> params) {
    if (this is WindowManagerEvent) {
      WindowManagerEvent.removePanListener(this as WindowManagerEvent);
    }
  }

  void _addPrePanListener(List<dynamic> params) {
    if (this is WindowManagerEvent) {
      WindowManagerEvent.addPrePanListener(this as WindowManagerEvent);
    }
  }

  void _removePrePanListener(List<dynamic> params) {
    if (this is WindowManagerEvent) {
      WindowManagerEvent.removePrePanListener(this as WindowManagerEvent);
    }
  }

  Future<void> _show(List<dynamic> params) async {
    await ChooWindowManager.current.show();
  }

  Future<void> _hide(List<dynamic> params) async {
    await ChooWindowManager.current.hide();
  }

  Future<void> _focus(List<dynamic> params) async {
    await ChooWindowManager.current.focus();
  }

  Future<void> _blur(List<dynamic> params) async {
    await ChooWindowManager.current.blur();
  }

  Future<void> _close(List<dynamic> params) async {
    await ChooWindowManager.current.close();
  }

  Future<bool> _isVisible(List<dynamic> params) async {
    return await ChooWindowManager.current.isVisible();
  }

  Future<bool> _isMaximized(List<dynamic> params) async {
    return await ChooWindowManager.current.isMaximized();
  }

  Future<void> _maximize(List<dynamic> params) async {
    await ChooWindowManager.current.maximize();
  }

  Future<void> _unmaximize(List<dynamic> params) async {
    await ChooWindowManager.current.unmaximize();
  }

  Future<bool> _isMinimized(List<dynamic> params) async {
    return await ChooWindowManager.current.isMinimized();
  }

  Future<void> _minimize(List<dynamic> params) async {
    await ChooWindowManager.current.minimize();
  }

  Future<void> _restore(List<dynamic> params) async {
    await ChooWindowManager.current.restore();
  }

  Future<bool> _isFullScreen(List<dynamic> params) async {
    return await ChooWindowManager.current.isFullScreen();
  }

  Future<void> _setFullScreen(List<dynamic> params) async {
    await ChooWindowManager.current.setFullScreen(isFullScreen: params[0]);
  }

  Future<String> _getSize(List<dynamic> params) async {
    Size size = await ChooWindowManager.current.getSize();
    return jsonEncode({"width": size.width, "height": size.height});
  }

  Future<void> _setSize(List<dynamic> params) async {
    return await ChooWindowManager.current.setSize(
      params[0] as Size,
      animate: params[1] as bool? ?? false,
    );
  }

  Future<String> _getMinSize(List<dynamic> params) async {
    Size size = await ChooWindowManager.current.getMinSize();
    return jsonEncode({"width": size.width, "height": size.height});
  }

  Future<void> _setMinSize(List<dynamic> params) async {
    return await ChooWindowManager.current.setMinSize(params[0] as Size);
  }

  Future<String> _getMaxSize(List<dynamic> params) async {
    Size size = await ChooWindowManager.current.getMaxSize();
    return jsonEncode({"width": size.width, "height": size.height});
  }

  Future<void> _setMaxSize(List<dynamic> params) async {
    return await ChooWindowManager.current.setMaxSize(params[0] as Size);
  }

  Future<String> _getScreenSize(List<dynamic> params) async {
    Size size = await ChooWindowManager.current.getScreenSize();
    return jsonEncode({"width": size.width, "height": size.height});
  }

  Future<String> _getPosition(List<dynamic> params) async {
    Offset offset = await ChooWindowManager.current.getPosition(
      global: params[0] as bool? ?? false,
    );
    if (offset is GlobalOffset) {
      return jsonEncode({
        "globalX": offset.globalDx,
        "globalY": offset.globalDx,
        "x": offset.dx,
        "y": offset.dy,
      });
    } else {
      return jsonEncode({"x": offset.dx, "y": offset.dy});
    }
  }

  Future<void> _setPosition(List<dynamic> params) async {
    return await ChooWindowManager.current.setPosition(
      params[0] as Offset,
      global: params[1] as bool? ?? false,
      animate: params[2] as bool? ?? false,
    );
  }

  Future<void> _center(List<dynamic> params) async {
    await ChooWindowManager.current.center(
      animate: params[0] as bool? ?? false,
    );
  }

  Future<String> _getBounds(List<dynamic> params) async {
    Rect rect = await ChooWindowManager.current.getBounds(
      global: params[0] as bool? ?? false,
    );

    return jsonEncode({
      "width": rect.width,
      "height": rect.height,
      "x": rect.left,
      "y": rect.top,
    });
  }

  Future<void> _setBounds(List<dynamic> params) async {
    return await ChooWindowManager.current.setBounds(
      params[0] as Rect,
      global: params[1] as bool? ?? false,
      animate: params[2] as bool? ?? false,
    );
  }

  Future<String> _getTitle(List<dynamic> params) async {
    return await ChooWindowManager.current.getTitle();
  }

  Future<void> _setTitle(List<dynamic> params) async {
    return await ChooWindowManager.current.setTitle(params[0] as String);
  }

  Future<String?> _getAnimationBehavior(List<dynamic> params) async {
    return (await ChooWindowManager.current.getAnimationBehavior())?.name;
  }

  Future<void> _setAnimationBehavior(List<dynamic> params) async {
    return await ChooWindowManager.current.setAnimationBehavior(
      params[0] as WindowAnimationBehavior,
    );
  }

  Future<String> _getTitleStyle(List<dynamic> params) async {
    return (await ChooWindowManager.current.getTitleStyle()).name;
  }

  Future<void> _setTitleStyle(List<dynamic> params) async {
    return await ChooWindowManager.current.setTitleStyle(
      params[0] as WindowTitleVisibility,
    );
  }

  Future<double> _getOpacity(List<dynamic> params) async {
    return await ChooWindowManager.current.getOpacity();
  }

  Future<void> _setOpacity(List<dynamic> params) async {
    return await ChooWindowManager.current.setOpacity(params[0] as double);
  }

  Future<String> _getMousePoint(List<dynamic> params) async {
    Offset offset = await ChooWindowManager.current.getMousePoint();
    return jsonEncode({"x": offset.dx, "y": offset.dy});
  }

  Future<void> _setWindowButtonHidden(List<dynamic> params) async {
    return await ChooWindowManager.current.setWindowButtonHidden(
      types: params[0] as List<WindowButtonType>? ?? [],
      state: params[1] as bool,
    );
  }

  Future<void> _setWindowButtonEnabled(List<dynamic> params) async {
    return await ChooWindowManager.current.setWindowButtonEnabled(
      types: params[0] as List<WindowButtonType>? ?? [],
      state: params[1] as bool,
    );
  }

  Future<String> _getWindowButtonRegionPosition(List<dynamic> params) async {
    WindowButtonRegionPosition offset =
        await ChooWindowManager.current.getWindowButtonRegionPosition();
    return jsonEncode({"x": offset.x, "y": offset.y});
  }

  Future<void> _setWindowButtonRegionPosition(List<dynamic> params) async {
    return await ChooWindowManager.current.setWindowButtonRegionPosition(
      params[0] as WindowButtonRegionPosition,
    );
  }

  Future<String> _getWindowButtonRegionSize(List<dynamic> params) async {
    Size size = await ChooWindowManager.current.getWindowButtonRegionSize();
    return jsonEncode({"width": size.width, "height": size.height});
  }

  Future<void> _setWindowButtonRegionHeight(List<dynamic> params) async {
    return await ChooWindowManager.current.setWindowButtonRegionHeight(
      params[0] as double,
    );
  }

  Future<double> _getWindowButtonSpacing(List<dynamic> params) async {
    return await ChooWindowManager.current.getWindowButtonSpacing();
  }

  Future<void> _setWindowButtonSpacing(List<dynamic> params) async {
    return await ChooWindowManager.current.setWindowButtonSpacing(
      params[0] as double,
    );
  }

  Future<String> _getWindowButtonSize(List<dynamic> params) async {
    Size size = await ChooWindowManager.current.getWindowButtonSize();
    return jsonEncode({"width": size.width, "height": size.height});
  }

  Future<void> _setWindowButtonSize(List<dynamic> params) async {
    return await ChooWindowManager.current.setWindowButtonSize(
      params[0] as Size,
    );
  }

  Future<String?> _emit(List<dynamic> params) async {
    WindowEmit? emit = await ChooWindowManager.current.emit(
      params[0] as int,
      params[1] as String,
      params.length > 2 ? params[2] as Map<String, dynamic>? : null,
    );
    if (emit == null) {
      return null;
    }
    return jsonEncode({
      "id": emit.id,
      "method": emit.method,
      "arguments": emit.result,
    });
  }

  void onResize(Size size) {
    _webviewqDispatchEvent(
      "onWindowResize",
      detail: {"width": size.width, "height": size.height},
    );
  }

  /// 窗口移动回调。
  /// @param offset 新的窗口全局/局部坐标。
  void onMove(GlobalOffset offset) {
    _webviewqDispatchEvent(
      "onWindowMove",
      detail: {
        "x": offset.dx,
        "y": offset.dy,
        "gx": offset.globalDx,
        "gy": offset.globalDy,
      },
    );
  }

  /// 拖拽事件回调。
  /// @param offset 拖拽时的全局坐标。
  void onPan(Offset offset) {
    _webviewqDispatchEvent(
      "onWindowPan",
      detail: {"x": offset.dx, "y": offset.dy},
    );
  }

  /// 悬停事件回调。
  /// @param offset 悬停时的全局坐标。
  void onHover(Offset offset) {
    _webviewqDispatchEvent(
      "onWindowHover",
      detail: {"x": offset.dx, "y": offset.dy},
    );
  }

  /// 窗口显示回调。
  void onShow() {
    _webviewqDispatchEvent("onWindowShow");
  }

  /// 窗口隐藏回调。
  void onHide() {
    _webviewqDispatchEvent("onWindowHide");
  }

  /// 窗口获得焦点回调。
  void onFocus() {
    _webviewqDispatchEvent("onWindowFocus");
  }

  /// 窗口失去焦点回调。
  void onBlur() {
    _webviewqDispatchEvent("onWindowBlur");
  }

  /// 窗口最小化回调。
  void onMinimize() {
    _webviewqDispatchEvent("onWindowMinimize");
  }

  /// 窗口最大化回调。
  void onMaximize() {
    _webviewqDispatchEvent("onWindowMaximize");
  }

  /// 窗口还原回调。
  void onRestore() {
    _webviewqDispatchEvent("onWindowRestore");
  }

  /// 即将进入全屏回调。
  void onWillEnterFullScreen() {
    _webviewqDispatchEvent("onWindowWillEnterFullScreen");
  }

  /// 已进入全屏回调。
  void onDidEnterFullScreen() {
    _webviewqDispatchEvent("onWindowDidEnterFullScreen");
  }

  /// 即将离开全屏回调。
  void onWillLeaveFullScreen() {
    _webviewqDispatchEvent("onWindowWillLeaveFullScreen");
  }

  /// 已离开全屏回调。
  void onDidLeaveFullScreen() {
    _webviewqDispatchEvent("onWindowDidLeaveFullScreen");
  }

  void changeTitle(String title) {
    _webviewqDispatchEvent("onWindowChangeTitle", detail: {"title": title});
  }
}
