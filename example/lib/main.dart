import 'dart:async';

import 'package:flutter/material.dart';
import 'package:choo_window_manager/choo_window_manager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main(List<dynamic> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  int windowId = int.parse(args[0]);
  print('windowId: $windowId');
  ChooWindowManager.ready(
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
      // await window.focus();
      // Offset position = await window.getPosition();
      // print(position);
      // position = await window.getPosition();
      // await window.setPosition(Offset(0, 0), global: true);
      // await window.setBounds(Rect.fromLTWH(0, 0, 200, 300), global: false);
      // window.setTitle("title");
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
  runApp(MyApp(windowId: windowId));
}

class MyApp extends StatefulWidget with WindowManagerEvent {
  final int windowId;
  MyApp({required this.windowId, super.key}) {
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
    print("这里第一次触发了关闭窗口的回调， 嘿！让你关！${ChooWindowManager.current.id}");
    return true;
  }

  @override
  Future<bool> onKeyboard(event) async {
    // TODO: implement onKeyboard
    if (event.keyCode == 13 &&
        event.modifierFlags.contains(ModifierFlags.command)) {
      print('捕捉到了关闭，让他往下走::${ChooWindowManager.current.id}');
      // return false;
    }
    return true;
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
    with WindowManagerEvent, WidgetsBindingObserver {
  bool init = false;
  String title = '';
  // final _chooWindowManagerPlugin = ChooWindowManager();
  @override
  void initState() {
    super.initState();
    WindowManagerEvent.addListener(this);
    ChooWindowManager.current.getTitle().then((value) {
      print(value);
      setState(() {
        title = value;
      });
    });
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
  void changeTitle(String title) {
    super.changeTitle(title);
    setState(() {
      this.title = title;
    });
  }

  @override
  Future<bool> onWillClose() async {
    print("这里第二次触发了关闭窗口的回调， 嘿！阻止你关！${ChooWindowManager.current.id}");
    return true;
  }

  @override
  Future<bool> onKeyboard(event) async {
    // TODO: implement onKeyboard
    if (event.keyCode == 13 &&
        event.modifierFlags.contains(ModifierFlags.command)) {
      print('第二次捕捉到了模拟关闭，让他往下走::${ChooWindowManager.current.id}');
    }
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

  //   The class 'InAppWebViewController' doesn't have an unnamed constructor.
  // Try using one of the named constructors defined in 'InAppWebViewController'.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // appBar: AppBar(title: const Text('Plugin example app')),
        appBar: ChooAppBar(
          height: 30,
          child: Builder(
            builder: (context) {
              return Container(
                height: double.infinity,
                color: Colors.red,
                child: Center(
                  child: MouseRegion(
                    child: GestureDetector(
                      child: Text(title, style: TextStyle(fontSize: 13)),
                      onTap: () async {
                        print('click');
                      },
                    ),
                    // onEnter: (event) {
                    //   ChooAppBar.of(context)?.spread = false;
                    // },
                    // onExit: (event) {
                    //   ChooAppBar.of(context)?.spread = true;
                    // },
                  ),
                ),
              );
            },
          ),
        ),
        body: InAppWebView(
          initialSettings: InAppWebViewSettings(
            javaScriptCanOpenWindowsAutomatically: true,
          ),
          initialUrlRequest: URLRequest(url: WebUri("https://www.google.com")),
        ),
      ),
    );
  }
}
