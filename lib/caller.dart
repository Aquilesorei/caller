import 'caller_platform_interface.dart';

class Caller {
  /// stream the incoming Accessibility events
  static Stream<String> get accessStream =>
      CallerPlatform.instance.accessStream;

  /// request accessibility permission
  /// it will open the accessibility settings page and return `true` once the permission granted.
  static Future<bool> requestAccessibilityPermission() async =>
      CallerPlatform.instance.requestAccessibilityPermission();

  /// check if accessibility permession is enebaled
  static Future<bool> isAccessibilityPermissionEnabled() async =>
      CallerPlatform.instance.isAccessibilityPermissionEnabled();
  void call(String ussd) => CallerPlatform.instance.call(ussd);
}
//*144*2*1*num*montant*pin#