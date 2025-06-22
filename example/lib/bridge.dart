import 'package:choo_window_manager/choo_window_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

typedef _JavaScriptHandlerCallback =
    Future<Map<String, dynamic>?> Function(List<dynamic> params);

abstract mixin class InAppWebviewBridge {
  InAppWebViewController? _webviewController;

  InAppWebViewController? get webviewController {
    return _webviewController;
  }

  set webviewController(InAppWebViewController? controller) {
    _webviewController?.dispose();
    _webviewController = controller;
    if (controller == null) {
      return;
    }
    final Map<String, _JavaScriptHandlerCallback> handlers = {
      "getSize": getSize,
      "addPanListener": addPanListener,
      "removePanListener": removePanListener,
      "addPrePanListener": addPrePanListener,
      "removePrePanListener": removePrePanListener,
    };

    for (var key in handlers.keys) {
      controller.addJavaScriptHandler(
        handlerName: key,
        callback: (params) async {
          return handlers[key]!(params);
        },
      );
    }
  }

  Future<Map<String, dynamic>?> getSize(List<dynamic> params) async {
    Size size = await ChooWindowManager.current.getSize();
    return {"width": size.width, "height": size.height};
  }

  Future<Map<String, dynamic>?> addPanListener(List<dynamic> params) async {
    if (this is WindowManagerEvent) {
      print("addPanListener");
      WindowManagerEvent.addPanListener(this as WindowManagerEvent);
    }
    return null;
  }

  Future<Map<String, dynamic>?> removePanListener(List<dynamic> params) async {
    if (this is WindowManagerEvent) {
      print("removePanListener");
      WindowManagerEvent.removePanListener(this as WindowManagerEvent);
    }
    return null;
  }

  Future<Map<String, dynamic>?> addPrePanListener(List<dynamic> params) async {
    if (this is WindowManagerEvent) {
      print("addPrePanListener");
      WindowManagerEvent.addPrePanListener(this as WindowManagerEvent);
    }
    return null;
  }

  Future<Map<String, dynamic>?> removePrePanListener(
    List<dynamic> params,
  ) async {
    if (this is WindowManagerEvent) {
      print("removePrePanListener");
      WindowManagerEvent.removePrePanListener(this as WindowManagerEvent);
    }
    return null;
  }
}
