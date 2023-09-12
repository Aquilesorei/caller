import 'package:flutter_test/flutter_test.dart';
import 'package:caller/caller.dart';
import 'package:caller/caller_platform_interface.dart';
import 'package:caller/caller_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCallerPlatform
    with MockPlatformInterfaceMixin
    implements CallerPlatform {

  @override
  Future<String?> call() => Future.value('42');
}

void main() {
  final CallerPlatform initialPlatform = CallerPlatform.instance;

  test('$MethodChannelCaller is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCaller>());
  });

  test('getPlatformVersion', () async {
    Caller callerPlugin = Caller();
    MockCallerPlatform fakePlatform = MockCallerPlatform();
    CallerPlatform.instance = fakePlatform;

    expect(await callerPlugin.call(), '42');
  });
}
