import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:choo_window_manager/src/window_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChooWindowManager', () {
    const MethodChannel globalChannel = MethodChannel('choo_window_manager');
    late MethodChannel windowChannel;

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(globalChannel, (
            MethodCall methodCall,
          ) async {
            switch (methodCall.method) {
              case 'createWindow':
                return {'id': 1};
              default:
                return null;
            }
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(globalChannel, null);
      if (ChooWindowManager.current != null) {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(windowChannel, null);
      }
    });

    test('ChooWindowManager.ready initializes correctly', () async {
      final options = ChooWindowOptions(id: 1, title: 'Test Window');
      ChooWindowManager? initializedWindow;

      ChooWindowManager.ready(options, (window) {
        initializedWindow = window;
      });

      // Simulate the async initialization completing
      await Future.delayed(Duration.zero);

      expect(initializedWindow, isNotNull);
      expect(initializedWindow!.id, 1);
      expect(ChooWindowManager.current, initializedWindow);

      windowChannel = MethodChannel('choo_window_manager_1');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowChannel, (
            MethodCall methodCall,
          ) async {
            return null;
          });
    });

    test('ChooWindowManager.current is set after ready', () async {
      final options = ChooWindowOptions(id: 2, title: 'Another Window');
      ChooWindowManager.ready(options, (window) {});
      await Future.delayed(Duration.zero);
      expect(ChooWindowManager.current.id, 2);
    });
  });

  });
}
