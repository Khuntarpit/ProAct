import 'package:get/get.dart';
import 'package:proact/blockapps/executables/controllers/apps_controller.dart';
import 'package:proact/blockapps/executables/controllers/home_screen_controller.dart';
import 'package:proact/blockapps/executables/controllers/method_channel_controller.dart';
import 'package:proact/blockapps/executables/controllers/password_controller.dart';
import 'package:proact/blockapps/executables/controllers/permission_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initialize() async {
  final prefs = await SharedPreferences.getInstance();
  Get.lazyPut(() => prefs);
  Get.lazyPut(() => AppsController(prefs: Get.find()));
  Get.lazyPut(() => HomeScreenController(prefs: Get.find()));
  Get.lazyPut(() => MethodChannelController());
  Get.lazyPut(() => PermissionController());
  Get.lazyPut(() => PasswordController(prefs: Get.find()));
  
}
