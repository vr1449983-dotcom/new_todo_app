import 'package:workmanager/workmanager.dart';
import 'notification_service.dart';

const String reminderTask = "reminderTask";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {

    if (task == reminderTask) {
      await NotificationService.instant(); // 🔔 show notification
    }

    return Future.value(true);
  });
}