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
      // offset: Point(0, 0),
      size: Size(500, 300),
      animationBehavior: WindowAnimationBehavior.documentWindow,
      // titleBarStyle: WindowTitleVisibility.hidden,
    ),
    (window) async {
      // Point position = await window.getPosition();
      // await window.setPosition(Point(0, 0));
      // position = await window.getPosition();
      await window.show();
      await window.focus();
      window.setTitle("title");
      // await window.getPosition(Point(0, 0));
      // print(await window.getPosition());
      // Future.delayed(Duration(milliseconds: 1000), () {
      //   // window.center(animate: true);
      //   window.setPosition(Point(0, 0), animate: true);

      //   Future.delayed(Duration(milliseconds: 1000), () {
      //     // window.center(animate: true);
      //     window.center(animate: true);
      //   });
      // });
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
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  // final _chooWindowManagerPlugin = ChooWindowManager();

  @override
  void initState() {
    super.initState();
    // initPlatformState();
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
        body: GestureDetector(
          onTap: () async {
            await ChooWindowManager.createWindow(null);
            // await ChooWindowManager.current.setBounds(
            //   Rect.fromLTWH(0, 0, 300, 300),
            //   animate: true,
            // );
            // if (await ChooWindowManager.current.getTitleStyle() ==
            //     WindowTitleVisibility.hidden) {
            //   await ChooWindowManager.current.setTitleStyle(
            //     WindowTitleVisibility.visible,
            //   );
            // } else {
            //   await ChooWindowManager.current.setTitleStyle(
            //     WindowTitleVisibility.hidden,
            //   );
            // }
            // await ChooWindowManager.current.center(animate: true);
            // print(windowId);
            // windowManager?.close();
            // ChooWindowManager.destroy();
          },
          child: Center(child: Text('Running on: $_platformVersion\n')),
        ),
      ),
    );
  }
}
