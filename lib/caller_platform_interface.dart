import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'caller_method_channel.dart';

abstract class CallerPlatform extends PlatformInterface {
  /// Constructs a CallerPlatform.
  CallerPlatform() : super(token: _token);

  static final Object _token = Object();

  static CallerPlatform _instance = MethodChannelCaller();

  /// The default instance of [CallerPlatform] to use.
  ///
  /// Defaults to [MethodChannelCaller].
  static CallerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CallerPlatform] when
  /// they register themselves.
  static set instance(CallerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }



  Future<void> call(String ussd) {
    throw UnimplementedError('call() has not been implemented.');
  }

  /// request accessibility permission
  /// it will open the accessibility settings page and return `true` once the permission granted.
   Future<bool> requestAccessibilityPermission() async {
    throw UnimplementedError('requestAccessibilityPermission() has not been implemented.');

  }

   Stream<String> get  accessStream {
    throw UnimplementedError('accessStream() has not been implemented.');

  }

  /// check if accessibility permession is enebaled
  Future<bool> isAccessibilityPermissionEnabled() async {
    throw UnimplementedError('isAccessibilityPermissionEnabled() has not been implemented.');

  }
}
