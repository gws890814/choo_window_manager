import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:choo_window_manager/choo_window_manager.dart';

ChooWindowManager? windowManager;

void main(List<dynamic> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  int windowId = int.parse(args[0]);
  windowManager = ChooWindowManager.ready(
    ChooWindowOptions(
      windowId,
      title: "测试一下",
      // offset: Offset(0, 0),
      // size: Size(500, 300),
      animationBehavior: WindowAnimationBehavior.documentWindow,
      // titleBarStyle: WindowTitleVisibility.hidden,
    ),
    (window) async {
      await window.show();
      // Offset position = await window.getPosition();
      // print(position);
      // position = await window.getPosition();
      // await window.setPosition(Offset(0, 0), global: false);
      // await window.setBounds(Rect.fromLTWH(0, 0, 200, 300), global: false);
      window.setTitle("title");
    },
  );
  // // await the initialization of the plugin.
  // // Here is an example of how to use ensureInitialized in the main function:
  // await WindowManagerPlus.ensureInitialized(
  //   int.parse((args ?? []).isEmpty ? '0' : '1'),
  // );

  // WindowOptions windowOptions = WindowOptions(
  //   // size: Size(800, 600),
  //   center: true,
  //   backgroundColor: Colors.transparent,
  //   skipTaskbar: false,
  //   titleBarStyle: TitleBarStyle.hidden,
  // );
  // WindowManagerPlus.current.waitUntilReadyToShow(windowOptions, () async {
  //   await WindowManagerPlus.current.show();
  //   await WindowManagerPlus.current.focus();
  // });
  // ChooWindowManager
  // print(await ChooWindowManager().getPlatformVersion());
  runApp(MyApp());
}

class MyApp extends StatefulWidget with WindowManagerEvent {
  MyApp({super.key}) {
    WindowManagerEvent.addListener(this);
  }

  @override
  Future<dynamic> onEvent(int id, String method, {arguments, delivery}) async {
    return {"a": true};
  }

  @override
  void onHover(Offset offset) {}

  @override
  Future<bool> onWillClose() async {
    return false;
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowManagerEvent {
  final String _platformVersion = 'Unknown';
  // final _chooWindowManagerPlugin = ChooWindowManager();
  @override
  void initState() {
    super.initState();
    WindowManagerEvent.addListener(this);
  }

  @override
  void onFocus() {
    super.onFocus();
  }

  @override
  void onShow() {
    // TODO: implement onShow
    super.onShow();
    // print('!!!!!!onshow');
  }

  void onHide() {}

  @override
  void onMove(GlobalOffset offset) {}

  @override
  Future<bool> onWillClose() async {
    return true;
  }

  @override
  Future<dynamic> onEvent(int id, String method, {arguments, delivery}) async {
    await Future.delayed(Duration(seconds: 2));
    return {"b": false};
  }

  @override
  void onPan(Offset offset) {
    // TODO: implement onPan
    super.onPan(offset);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initPlatformState() async {
  //   String platformVersion;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   // We also handle the message potentially returning null.
  //   try {
  //     platformVersion =
  //         await _chooWindowManagerPlugin.getPlatformVersion() ??
  //         'Unknown platform version';
  //   } on PlatformException {
  //     platformVersion = 'Failed to get platform version.';
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;

  //   setState(() {
  //     _platformVersion = platformVersion;
  //   });

  //   Future.delayed(Duration(seconds: 2), () {
  //     _chooWindowManagerPlugin.getPlatformVersion();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: WindowPanWidget(
          child: SizedBox(
            child: GestureDetector(
              onPanStart: (details) {},
              onPanEnd: (details) {},
              onPanCancel: () {},
              onTap: () async {
                await ChooWindowManager.createWindow(null);
              },
              child: Center(child: Text('Running on: $_platformVersion')),
            ),
          ),
        ),
      ),
    );
  }
}
