import 'package:get/get.dart';
import '../model/sync_mod.dart';
import '../services/settings_service.dart';

class SettingsController extends GetxController {
  var syncMode = SyncMode.automatic.obs;

  @override
  void onInit() {
    super.onInit();
    loadSyncMode();
  }

  void loadSyncMode() async {
    syncMode.value = await SettingsService.getSyncMode();
  }

  Future<void> changeSyncMode(SyncMode mode) async {
    syncMode.value = mode;
    await SettingsService.setSyncMode(mode);
  }
}