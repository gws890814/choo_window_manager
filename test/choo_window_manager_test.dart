import 'package:flutter_test/flutter_test.dart';
import 'package:choo_window_manager/choo_window_manager.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockChooWindowManagerPlatform
    with MockPlatformInterfaceMixin
    {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {


  test('getPlatformVersion', () async {
    MockChooWindowManagerPlatform fakePlatform = MockChooWindowManagerPlatform();
  });
}
