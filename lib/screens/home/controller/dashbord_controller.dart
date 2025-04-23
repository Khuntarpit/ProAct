import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardController extends GetxController {
  var eventData = <Map<String, String>>[].obs;
  var progressValue = 0.0.obs;

  void deleteEvent(int index) {
    eventData.removeAt(index);
    updateProgress();
  }

  void saveEvent(int index, Map<String, String> updatedEvent) {
    eventData[index] = updatedEvent;
    updateProgress();
  }

  void markEventAsDone(int index, bool done) {
    eventData[index]['doneStatus'] = done.toString();
    updateProgress();
  }

  void updateProgress() {
    int total = eventData.length;
    if (total == 0) {
      progressValue.value = 0;
      return;
    }
    int doneCount = eventData.where((e) => e['doneStatus'] == 'true').length;
    progressValue.value = doneCount / total;
  }

  void setEvents(List<Map<String, String>> events) {
    eventData.assignAll(events);
    updateProgress();
  }
}
