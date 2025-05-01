import 'package:get/get.dart';
import 'package:proact/model/task_model.dart';
import 'package:proact/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../controller/dashbord_controller.dart';

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

  static insertUser(task)async{
    final insertResponse = await client
        .from(tasks)
        .insert(task);
    return insertResponse;
  }

  static Future<List<Map<String, dynamic>>> updateTaskStatus(int taskId, int newStatus) async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from(tasks)
          .update({status: newStatus})
          .eq(id, taskId)
          .select();

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
          .eq(createdBy, userId)
          .order('start_time', ascending: true); // 👈 sort by start_time
      return data;
    } catch (e) {
      print('❗ Error getting tasks: $e');
      throw Exception('Error getting tasks: $e');
    }
  }

  static Future<Map> getTaskCounts() async {
    try {
      final user = await UserService.getCurrentUserData();
      final userId = user.userId;

      final response = await Supabase.instance.client
          .from(tasks)
          .select('id, status')
          .eq(createdBy, userId);

      final List<Map<String, dynamic>> task = List<Map<String, dynamic>>.from(response);

      final totalCount = task.length;
      final completedCount = task.where((task) => task['status'] == 1).length;

      return {
        'total': totalCount,
        'completed': completedCount,
      };
    } catch (e) {
      print('❗ Error getting task counts: $e');
      throw Exception('Error getting task counts: $e');
    }
  }


}