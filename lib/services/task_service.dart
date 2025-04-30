import 'package:get/get.dart';
import 'package:proact/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TasksService {

  static var client = Supabase.instance.client;
  static var tasks = "Tasks";
  static var id = "id";
  static var createdBy = "created_by";
  static var title = "title";
  static var description = "description";
  static var startTime = "start_time";
  static var endTime = "end_time";
  static var status = "status";

  static Future<List<Map<String, dynamic>>> updateTaskStatus(int taskId, int newStatus) async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from(tasks)
          .update({status: newStatus})
          .eq(id, taskId)
          .select(); // Add this to get updated data back

      print('✅ Task status updated: $response');
      return response;
    } catch (e) {
      print('❗ Error updating task status: $e');
      throw Exception('Error updating task status: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getTasks() async {
    try {
      final user = await UserService.getCurrentUserData();
      final userId = user.userId;
      final data = await Supabase.instance.client
          .from(tasks)
          .select()
          .eq(createdBy, userId);
      return data;
    } catch (e) {
      print('❗ Error updating task status: $e');
      throw Exception('Error getting task status: $e');
    }
  }


}