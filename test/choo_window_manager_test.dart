import 'package:flutter_test/flutter_test.dart';
import 'package:choo_window_manager/choo_window_manager.dart';
import 'package:choo_window_manager/choo_window_manager_platform_interface.dart';
import 'package:choo_window_manager/choo_window_manager_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockChooWindowManagerPlatform
    with MockPlatformInterfaceMixin
    implements ChooWindowManagerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ChooWindowManagerPlatform initialPlatform = ChooWindowManagerPlatform.instance;

  test('$MethodChannelChooWindowManager is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelChooWindowManager>());
  });

  test('getPlatformVersion', () async {
    ChooWindowManager chooWindowManagerPlugin = ChooWindowManager();
    MockChooWindowManagerPlatform fakePlatform = MockChooWindowManagerPlatform();
    ChooWindowManagerPlatform.instance = fakePlatform;

    expect(await chooWindowManagerPlugin.getPlatformVersion(), '42');
  });
}
