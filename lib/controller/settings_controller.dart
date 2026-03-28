import 'package:get/get.dart';
import '../model/sync_mod.dart';
import '../services/settings_service.dart';

class SettingsController extends GetxController {

  var syncMode = SyncMode.automatic.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSyncMode();
  }

  void _loadSyncMode() async {
    final mode = await SettingsService.getSyncMode();
    syncMode.value = mode;
  }

  void changeSyncMode(SyncMode mode) async {
    syncMode.value = mode;
    await SettingsService.setSyncMode(mode);
  }
}