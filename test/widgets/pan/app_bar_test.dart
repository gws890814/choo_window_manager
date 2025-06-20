import 'dart:async';
import 'package:choo_window_manager/choo_window_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Mock ChooWindowManager
class MockChooWindowManager extends Mock implements ChooWindowManager {
  @override
  Future<bool> isMaximized() async => false;

  @override
  Future<void> maximize() async {}

  @override
  Future<void> unmaximize() async {}

  @override
  Future<void> setWindowButtonRegionHeight(double height) async {}
}

void main() {
  late MockChooWindowManager mockChooWindowManager;

  setUp(() {
    mockChooWindowManager = MockChooWindowManager();
    // Initialize ChooWindowManager.current for testing
    ChooWindowManager.current = mockChooWindowManager;
  });

  testWidgets('ChooAppBar renders correctly and handles double tap', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: ChooAppBar(
            child: const Text('Test Title'),
          ),
        ),
      ),
    );

    // Wait for any pending async operations
    await tester.pumpAndSettle();

    // Verify that the title is displayed.
    expect(find.text('Test Title'), findsOneWidget);

    // Verify that the ChooAppBar widget is present
    expect(find.byType(ChooAppBar), findsOneWidget);

    // Find the gesture detector that handles double tap
    final gestureDetector = find.byType(GestureDetector).first;
    
    // Simulate a double tap on the title area
    await tester.tap(gestureDetector);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(gestureDetector);
    
    // Wait for any async operations to complete
    await tester.pumpAndSettle();
    
    // Test passes if no exceptions are thrown during double tap
  });
}