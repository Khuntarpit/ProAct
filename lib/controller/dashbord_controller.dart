import 'package:get/get.dart';

import '../services/task_service.dart';

class DashboardController extends GetxController {
  Rx<int> totalTask = 0.obs;
  Rx<int> completedTask = 0.obs;

  void updateProgress() async {
    var data = await TasksService.getTaskCounts();
    totalTask.value = data['total'];
    completedTask.value = data['completed'];
  }

  @override
  void onInit() {
    updateProgress();
    super.onInit();
  }
}
