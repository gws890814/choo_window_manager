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
      final options = ChooWindowOptions(1, title: 'Test Window');
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
      final options = ChooWindowOptions(2, title: 'Another Window');
      ChooWindowManager.ready(options, (window) {});
      await Future.delayed(Duration.zero);
      expect(ChooWindowManager.current.id, 2);
    });
  });
}
  group('WindowManagerEvent', () {
    late MethodChannel mockWindowChannel;

    setUp(() {
      mockWindowChannel = MethodChannel('choo_window_manager_mock');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(mockWindowChannel, (
            MethodCall methodCall,
          ) async {
            return null;
          });
      // Mock ChooWindowManager.current for static methods
      ChooWindowManager.current = ChooWindowManager.mock(mockWindowChannel, 0);
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(mockWindowChannel, null);
    });

    test('addListener and removeListener work correctly', () async {
      final listener1 = MockWindowManagerEvent();
      final listener2 = MockWindowManagerEvent();

      WindowManagerEvent.addListener(listener1);
      expect(WindowManagerEvent.eventList.length, 1);
      expect(WindowManagerEvent.eventList.contains(listener1), isTrue);

      WindowManagerEvent.addListener(listener2);
      expect(WindowManagerEvent.eventList.length, 2);
      expect(WindowManagerEvent.eventList.contains(listener2), isTrue);

      WindowManagerEvent.removeListener(listener1);
      expect(WindowManagerEvent.eventList.length, 1);
      expect(WindowManagerEvent.eventList.contains(listener1), isFalse);

      WindowManagerEvent.removeListener(listener2);
      expect(WindowManagerEvent.eventList.isEmpty, isTrue);
    });

    test('addPanListener and removePanListener work correctly', () async {
      final panListener = MockWindowManagerEvent();

      WindowManagerEvent.addPanListener(panListener);
      expect(WindowManagerEvent.instance, panListener);

      WindowManagerEvent.removePanListener(panListener);
      expect(WindowManagerEvent.instance, isNull);
    });

    test('addPrePanListener and removePrePanListener work correctly', () async {
      final prePanListener = MockWindowManagerEvent();

      WindowManagerEvent.addPrePanListener(prePanListener);
      expect(WindowManagerEvent.hoverEventList.length, 1);
      expect(
        WindowManagerEvent.hoverEventList.contains(prePanListener),
        isTrue,
      );

      WindowManagerEvent.removePrePanListener(prePanListener);
      expect(WindowManagerEvent.hoverEventList.isEmpty, isTrue);
    });

    test('addHoverListener and removeHoverListener work correctly', () async {
      final hoverListener = MockWindowManagerEvent();

      WindowManagerEvent.addHoverListener(hoverListener);
      expect(WindowManagerEvent.hoverEventList.length, 1);
      expect(WindowManagerEvent.hoverEventList.contains(hoverListener), isTrue);

      WindowManagerEvent.removeHoverListener(hoverListener);
      expect(WindowManagerEvent.hoverEventList.isEmpty, isTrue);
    });

    test('onWillClose returns true by default', () async {
      final listener = MockWindowManagerEvent();
      expect(await listener.onWillClose(), isTrue);
    });

    test('onKeyboard returns true by default', () async {
      final listener = MockWindowManagerEvent();
      expect(
        await listener.onKeyboard(
          KeyboardEvent(
            type: 'keyDown',
            characters: 'a',
            keyCode: 0,
            modifierFlags: [],
          ),
        ),
        isTrue,
      );
    });

    test('onEvent returns delivery by default', () async {
      final listener = MockWindowManagerEvent();
      expect(
        await listener.onEvent(0, 'testMethod', delivery: 'testDelivery'),
        'testDelivery',
      );
    });
  });
}

class MockWindowManagerEvent with WindowManagerEvent {}

// Add a mock constructor to ChooWindowManager for testing static methods
extension ChooWindowManagerMock on ChooWindowManager {
  static ChooWindowManager mock(MethodChannel channel, int id) {
    final instance = ChooWindowManager.ready(
      ChooWindowOptions(id: id, title: 'Mock Window'),
      (window) {},
    );
    instance._windowChannel = channel; // Directly assign the mock channel
    return instance;
  }
}

// Helper to expose private static lists for testing
extension WindowManagerEventTest on WindowManagerEvent {
  static List<WindowManagerEvent> get eventList =>
      WindowManagerEvent._eventList;
  static List<WindowManagerEvent> get hoverEventList =>
      WindowManagerEvent._hoverEventList;
  static WindowManagerEvent? get instance => WindowManagerEvent._instance;