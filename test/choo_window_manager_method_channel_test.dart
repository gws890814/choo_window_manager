import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:choo_window_manager/choo_window_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('choo_window_manager');
  const MethodChannel windowChannel = MethodChannel('choo_window_manager_1');

  setUp(() {
    // Mock global channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return {'result': true};
        });

    // Mock window-specific channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowChannel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'flutterReady':
              return {'result': true};
            case 'setSize':
              return {'result': true};
            case 'center':
              return {'result': true};
            case 'show':
              return {'result': true};
            case 'hide':
              return {'result': true};
            case 'close':
              return {'result': true};
            case 'focus':
              return {'result': true};
            case 'blur':
              return {'result': true};
            case 'minimize':
              return {'result': true};
            case 'maximize':
              return {'result': true};
            case 'restore':
              return {'result': true};
            case 'isVisible':
              return true;
            case 'isMaximized':
              return false;
            case 'isMinimized':
              return false;
            case 'getSize':
              return {'width': 800.0, 'height': 600.0};
            case 'getPosition':
              return {'x': 100.0, 'y': 100.0};
            case 'getTitle':
              return 'Test Window';
            case 'getOpacity':
              return 1.0;
            case 'addListener':
              return {'result': true};
            case 'removeListener':
              return {'result': true};
            case 'addPanListener':
              return {'x': 0.0, 'y': 0.0};
            case 'removePanListener':
              return {'result': true};
            case 'addPrePanListener':
              return {'result': true};
            case 'removePrePanListener':
              return {'result': true};
            case 'addHoverListener':
              return {'result': true};
            case 'removeHoverListener':
              return {'result': true};
            default:
              return {'result': true};
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(windowChannel, null);
  });

  group('ChooWindowManager', () {
    test('constructor initializes correctly', () async {
      final options = ChooWindowOptions(1, size: const Size(800, 600));
      final completer = Completer<void>();

      ChooWindowManager.ready(options, (window) {
        try {
          expect(window.id, equals(1));
          expect(window.args, equals({'id': 1}));
          completer.complete();
        } catch (e) {
          completer.completeError(e);
        }
      });

      await completer.future;
    });

    test('show calls method channel', () async {
      final List<MethodCall> log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowChannel, (
            MethodCall methodCall,
          ) async {
            log.add(methodCall);
            return {'result': true};
          });

      final options = ChooWindowOptions(1);
      final completer = Completer<void>();

      ChooWindowManager.ready(options, (window) async {
        try {
          await window.show();

          expect(log.any((call) => call.method == 'show'), isTrue);
          final showCall = log.firstWhere((call) => call.method == 'show');
          expect(showCall.arguments, equals({'id': 1}));
          completer.complete();
        } catch (e) {
          completer.completeError(e);
        }
      });

      await completer.future;
    });

    test('hide calls method channel', () async {
      final List<MethodCall> log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowChannel, (
            MethodCall methodCall,
          ) async {
            log.add(methodCall);
            return {'result': true};
          });

      final options = ChooWindowOptions(1);
      final completer = Completer<void>();

      ChooWindowManager.ready(options, (window) async {
        try {
          await window.hide();

          expect(log.any((call) => call.method == 'hide'), isTrue);
          final hideCall = log.firstWhere((call) => call.method == 'hide');
          expect(hideCall.arguments, equals({'id': 1}));
          completer.complete();
        } catch (e) {
          completer.completeError(e);
        }
      });

      await completer.future;
    });

    test('getSize returns correct size', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowChannel, (
            MethodCall methodCall,
          ) async {
            if (methodCall.method == 'getSize') {
              return {'width': 1024.0, 'height': 768.0};
            }
            return {'result': true};
          });

      final options = ChooWindowOptions(1);
      final completer = Completer<void>();

      ChooWindowManager.ready(options, (window) async {
        try {
          final size = await window.getSize();

          expect(size.width, equals(1024.0));
          expect(size.height, equals(768.0));
          completer.complete();
        } catch (e) {
          completer.completeError(e);
        }
      });

      await completer.future;
    });

    test('setSize calls method channel with correct arguments', () async {
      final List<MethodCall> log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowChannel, (
            MethodCall methodCall,
          ) async {
            log.add(methodCall);
            return {'result': true};
          });

      final options = ChooWindowOptions(1);
      final completer = Completer<void>();

      ChooWindowManager.ready(options, (window) async {
        try {
          await window.setSize(const Size(1200, 800), animate: true);

          expect(log.any((call) => call.method == 'setSize'), isTrue);
          final setSizeCall = log.firstWhere(
            (call) => call.method == 'setSize',
          );
          expect(setSizeCall.arguments['width'], equals(1200.0));
          expect(setSizeCall.arguments['height'], equals(800.0));
          expect(setSizeCall.arguments['animate'], equals(true));
          expect(setSizeCall.arguments['id'], equals(1));
          completer.complete();
        } catch (e) {
          completer.completeError(e);
        }
      });

      await completer.future;
    });

    test('isVisible returns correct value', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowChannel, (
            MethodCall methodCall,
          ) async {
            if (methodCall.method == 'isVisible') {
              return true;
            }
            return {'result': true};
          });

      final options = ChooWindowOptions(1);
      final completer = Completer<void>();

      ChooWindowManager.ready(options, (window) async {
        try {
          final isVisible = await window.isVisible();
          expect(isVisible, isTrue);
          completer.complete();
        } catch (e) {
          completer.completeError(e);
        }
      });

      await completer.future;
    });
  });

  group('WindowManagerEvent', () {
    late _MockWindowManagerEvent mockEvent;

    setUp(() {
      mockEvent = _MockWindowManagerEvent();
    });

    tearDown(() {
      // Clean up any listeners
      WindowManagerEvent.removeListener(mockEvent);
      WindowManagerEvent.removePanListener(mockEvent);
      WindowManagerEvent.removePrePanListener(mockEvent);
      WindowManagerEvent.removeHoverListener(mockEvent);
    });

    test('addListener calls method channel', () async {
      final List<MethodCall> log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowChannel, (
            MethodCall methodCall,
          ) async {
            log.add(methodCall);
            return {'result': true};
          });

      // Initialize window manager first
      final options = ChooWindowOptions(1);
      final completer = Completer<void>();

      ChooWindowManager.ready(options, (window) {
        try {
          WindowManagerEvent.addListener(mockEvent);

          expect(log.any((call) => call.method == 'addListener'), isTrue);
          final addListenerCall = log.firstWhere(
            (call) => call.method == 'addListener',
          );
          expect(addListenerCall.arguments, equals({'id': 1}));
          completer.complete();
        } catch (e) {
          completer.completeError(e);
        }
      });

      await completer.future;
    });

    test('removeListener calls method channel', () async {
      final List<MethodCall> log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowChannel, (
            MethodCall methodCall,
          ) async {
            log.add(methodCall);
            return {'result': true};
          });

      // Initialize window manager first
      final options = ChooWindowOptions(1);
      final completer = Completer<void>();

      ChooWindowManager.ready(options, (window) {
        try {
          WindowManagerEvent.addListener(mockEvent);
          log.clear(); // Clear the addListener call

          WindowManagerEvent.removeListener(mockEvent);

          expect(log.any((call) => call.method == 'removeListener'), isTrue);
          final removeListenerCall = log.firstWhere(
            (call) => call.method == 'removeListener',
          );
          expect(removeListenerCall.arguments, equals({'id': 1}));
          completer.complete();
        } catch (e) {
          completer.completeError(e);
        }
      });

      await completer.future;
    });

    test('addPanListener calls method channel', () async {
      final List<MethodCall> log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowChannel, (
            MethodCall methodCall,
          ) async {
            log.add(methodCall);
            if (methodCall.method == 'addPanListener') {
              return {'x': 10.0, 'y': 20.0};
            }
            return {'result': true};
          });

      // Initialize window manager first
      final options = ChooWindowOptions(1);
      final completer = Completer<void>();

      ChooWindowManager.ready(options, (window) {
        try {
          WindowManagerEvent.addPanListener(mockEvent);

          expect(log.any((call) => call.method == 'addPanListener'), isTrue);
          final addPanListenerCall = log.firstWhere(
            (call) => call.method == 'addPanListener',
          );
          expect(addPanListenerCall.arguments, equals({'id': 1}));
          completer.complete();
        } catch (e) {
          completer.completeError(e);
        }
      });

      await completer.future;
    });

    test('event callbacks are triggered by platform messages', () async {
      // Initialize window manager first
      final options = ChooWindowOptions(1);
      final completer = Completer<void>();

      ChooWindowManager.ready(options, (window) async {
        try {
          WindowManagerEvent.addListener(mockEvent);

          // Simulate onResize event from platform
          final codec = const StandardMethodCodec();
          final resizeData = codec.encodeMethodCall(
            MethodCall('resize', {'id': 1, 'width': 1024.0, 'height': 768.0}),
          );
          await TestDefaultBinaryMessengerBinding
              .instance
              .defaultBinaryMessenger
              .handlePlatformMessage(
                'choo_window_manager_1',
                resizeData,
                (data) {},
              );

          expect(mockEvent.resizedSize, equals(const Size(1024.0, 768.0)));

          // Simulate onFocus event
          final focusData = codec.encodeMethodCall(
            MethodCall('focus', {'id': 1}),
          );
          await TestDefaultBinaryMessengerBinding
              .instance
              .defaultBinaryMessenger
              .handlePlatformMessage(
                'choo_window_manager_1',
                focusData,
                (data) {},
              );

          expect(mockEvent.focused, isTrue);

          // Simulate onMove event
          final moveData = codec.encodeMethodCall(
            MethodCall('move', {
              'id': 1,
              'globalX': 100.0,
              'globalY': 200.0,
              'x': 50.0,
              'y': 75.0,
            }),
          );
          await TestDefaultBinaryMessengerBinding
              .instance
              .defaultBinaryMessenger
              .handlePlatformMessage(
                'choo_window_manager_1',
                moveData,
                (data) {},
              );

          expect(mockEvent.movedOffset?.globalDx, equals(100.0));
          expect(mockEvent.movedOffset?.globalDy, equals(200.0));
          expect(mockEvent.movedOffset?.dx, equals(50.0));
          expect(mockEvent.movedOffset?.dy, equals(75.0));
          completer.complete();
        } catch (e) {
          completer.completeError(e);
        }
      });

      await completer.future;
    });
  });
}

class _MockWindowManagerEvent with WindowManagerEvent {
  Size? resizedSize;
  GlobalOffset? movedOffset;
  Offset? panOffset;
  Offset? hoverOffset;
  bool shown = false;
  bool hidden = false;
  bool focused = false;
  bool blurred = false;
  bool minimized = false;
  bool maximized = false;

  @override
  void onResize(Size size) {
    resizedSize = size;
  }

  @override
  void onMove(GlobalOffset offset) {
    movedOffset = offset;
  }

  @override
  void onPan(Offset offset) {
    panOffset = offset;
  }

  @override
  void onHover(Offset offset) {
    hoverOffset = offset;
  }

  @override
  void onShow() {
    shown = true;
  }

  @override
  void onHide() {
    hidden = true;
  }

  @override
  void onFocus() {
    focused = true;
  }

  @override
  void onBlur() {
    blurred = true;
  }

  @override
  void onMinimize() {
    minimized = true;
  }

  @override
  void onMaximize() {
    maximized = true;
  }
}
