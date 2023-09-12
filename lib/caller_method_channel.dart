import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'caller_platform_interface.dart';

/// An implementation of [CallerPlatform] that uses method channels.
class MethodChannelCaller extends CallerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  static const  methodChannel = MethodChannel('caller/accessibility_channel');
  static const EventChannel _eventChannel = EventChannel('caller/accessibility_event');
  
  static Stream<String>? _stream;


  /// stream the incoming Accessibility events
  @override
   Stream<String>  get  accessStream {
    if (Platform.isAndroid) {
      _stream ??=
          _eventChannel.receiveBroadcastStream().map<String>(
                (event) => event as String
          );
      return _stream!;
    }
    throw Exception("Accessibility API exclusively available on Android!");
  }


  /// request accessibility permission
  /// it will open the accessibility settings page and return `true` once the permission granted.
  @override
   Future<bool> requestAccessibilityPermission() async {
    try {
      return await methodChannel
          .invokeMethod('requestAccessibilityPermission');
    } on PlatformException catch (error) {
      print("$error");
      return Future.value(false);
    }
  }

  /// check if accessibility permession is enebaled
  @override
   Future<bool> isAccessibilityPermissionEnabled() async {
    try {
      return await methodChannel
          .invokeMethod('isAccessibilityPermissionEnabled');
    } on PlatformException catch (error) {
      print("$error");
      return false;
    }
  }
  @override
  Future<void> call(String ussd) async {

    final args = <String, dynamic>{'ussd': ussd,};
     await methodChannel.invokeMethod<String>('call',args);
  }
}
