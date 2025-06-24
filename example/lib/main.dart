import 'dart:async';

import 'package:choo_window_manager_example/bridge.dart';
import 'package:flutter/material.dart';
import 'package:choo_window_manager/choo_window_manager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main(List<dynamic> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  int windowId = int.parse(args[0]);
  ChooWindowManager.ready(
    ChooWindowOptions(
      windowId,
      title: "测试一下",
      titleBarStyle: WindowTitleVisibility.hidden,
      buttonOptions: WindowButtonOptions(
        height: 60,
        regionPosition: WindowButtonRegionPosition(y: 0, x: 15),
        // enabledButtons: [WindowButtonType.close, WindowButtonType.zoom],
        // buttonSize: Size(   12, 12),
        // spacing: 50,
        // height: 40,
        // hiddenButtons: [WindowButtonType.close],
      ),
      // offset: Offset(0, 0),
      // size: Size(500, 300),
      animationBehavior: WindowAnimationBehavior.documentWindow,
      // titleBarStyle: WindowTitleVisibility.hidden,
    ),
    (window) async {
      await window.show();
      await window.focus();

      // await Future.delayed(Duration(milliseconds: 3000), () {
      //   ChooWindowManager.current.setWindowButtonEnabled(
      //     types: [WindowButtonType.close],
      //     state: false,
      //   );
      // });
      // await Future.delayed(Duration(milliseconds: 1000), () {
      //   ChooWindowManager.current.setWindowButtonSize(Size(20, 20));
      // });
      // await Future.delayed(Duration(milliseconds: 1000), () async {
      //   ChooWindowManager.current.setWindowButtonHidden(
      //     types: [WindowButtonType.close],
      //     state: false,
      //   );
      //   Size size = await ChooWindowManager.current.getWindowButtonSize();
      //   print('width: ${size.width}, height: ${size.height}');
      //   ChooWindowManager.current.setWindowButtonSize(Size(30, 30));
      // });
      // await Future.delayed(Duration(milliseconds: 1000), () {
      //   ChooWindowManager.current.setWindowButtonHidden(
      //     state: true,
      //     types: [WindowButtonType.zoom],
      //   );
      // });
      // await Future.delayed(Duration(milliseconds: 3000), () {
      //   ChooWindowManager.current.setWindowButtonHidden(
      //     state: false,
      //     types: [WindowButtonType.zoom],
      //   );
      // });
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

  // UnimplementedError: opaque is not implemented on macOS See also

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
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
    with WindowManagerEvent, WebviewBridge, WidgetsBindingObserver {
  String title = '';
  int webProgress = 100;
  // final _chooWindowManagerPlugin = ChooWindowManager();
  @override
  void initState() {
    super.initState();
    WindowManagerEvent.addListener(this);
    ChooWindowManager.current.getTitle().then((value) {
      setState(() {
        title = value;
      });
    });
  }

  // @override
  // void onFocus() {
  //   super.onFocus();
  // }

  // @override
  // void onShow() {
  //   // TODO: implement onShow
  //   super.onShow();
  //   // print('!!!!!!onshow');
  // }

  // void onHide() {}

  // @override
  // void onMove(GlobalOffset offset) {}

  // @override
  // void changeTitle(String title) {
  //   super.changeTitle(title);
  //   setState(() {
  //     this.title = title;
  //   });
  // }

  // @override
  // Future<bool> onWillClose() async {
  //   print("这里第二次触发了关闭窗口的回调， 嘿！阻止你关！${ChooWindowManager.current.id}");
  //   return true;
  // }

  // @override
  // Future<bool> onKeyboard(event) async {
  //   print("我收到了喔");
  //   // TODO: implement onKeyboard
  //   // if (event.modifierFlags.contains(ModifierFlags.command)) {
  //   //   if ([0, 13].contains(event.keyCode)) {
  //   //     return true;
  //   //   } else if (12 == event.keyCode) {
  //   //     ChooWindowManager.destroy();
  //   //     return false;
  //   //   }
  //   // }
  //   return true;
  // }

  // @override
  // Future<dynamic> onEvent(int id, String method, {arguments, delivery}) async {
  //   await Future.delayed(Duration(seconds: 2));
  //   return {"b": false};
  // }

  // @override
  // void onPan(Offset offset) {
  //   // TODO: implement onPan
  //   super.onPan(offset);
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.red,
      home: Scaffold(
        backgroundColor: Colors.red,
        // appBar: AppBar(title: const Text('Plugin example app')),
        // appBar: ChooAppBar(
        //   // height: 40,
        //   child: Builder(
        //     builder: (context) {
        //       return Container(
        //         height: double.infinity,
        //         // color: Color.fromRGBO(
        //         //   58,
        //         //   62,
        //         //   64,
        //         //   1,
        //         // ), // Colors.red, // Color.fromRGBO(58, 62, 64, 1),
        //         decoration: BoxDecoration(
        //           gradient: LinearGradient(
        //             begin: Alignment.topCenter,
        //             end: Alignment.bottomCenter,
        //             colors: [
        //               Color.fromRGBO(61, 61, 61, 1),
        //               Color.fromRGBO(61, 61, 61, 1),
        //             ], // 渐变颜色
        //           ),
        //         ),
        //         child: Center(
        //           child: MouseRegion(
        //             child: GestureDetector(
        //               child: Text(
        //                 title,
        //                 style: TextStyle(fontSize: 13, color: Colors.white),
        //               ),
        //               onTap: () async {
        //                 ChooWindowManager.createWindow({});
        //                 print('click');
        //               },
        //             ),
        //             // onEnter: (event) {
        //             //   ChooAppBar.of(context)?.spread = false;
        //             // },
        //             // onExit: (event) {
        //             //   ChooAppBar.of(context)?.spread = true;
        //             // },
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // ),
        body: Center(
          child: InAppWebView(
            onWebViewCreated: (controller) {
              webviewController = controller;
            },
            initialUrlRequest: URLRequest(
              url: WebUri("http://localhost:5173/"),
            ),
          ),
        ),
      ),
    );
  }
}
