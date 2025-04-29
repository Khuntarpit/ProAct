import 'package:get/get.dart';
import 'package:proact/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TasksController extends GetxController {
  Rx<bool> isLoading = false.obs;
  RxList<Map<String, dynamic>> tasksList = <Map<String, dynamic>>[].obs;

  static var client = Supabase.instance.client;
  static var tasks = "Tasks";
  static var createdBy = "created_by";
  static var title = "title";
  static var description = "description";
  static var startTime = "start_time";
  static var endTime = "end_time";
  static var status = "status";

  Future<void> loadUserTasks() async {
    isLoading.value = true;

    try {
      final user = await UserService.getCurrentUserData();
      final userId = user.userId;

      final data = await Supabase.instance.client
          .from(tasks)
          .select()
          .eq(createdBy, userId);

      tasksList.value = List<Map<String, dynamic>>.from(data);
      print("✅ Fetched tasks: ${tasksList.value}");
    } catch (e) {
      print('❗ Error fetching tasks: $e');
      tasksList.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    loadUserTasks();
    super.onInit();
  }

}