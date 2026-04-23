import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

import '../res/strings.dart';
import '../widgets/views.dart';

class Permissions {
  Permissions._();

  static Future<bool> checkSystemAlertWindow() async {
    return Permission.systemAlertWindow.isGranted;
  }

  static Future<bool> checkStorage() async {
    return await Permission.storage.isGranted;
  }

  static void camera(Function()? onGranted) async {
    if (await Permission.camera.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    }
    if (await Permission.camera.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
    }
  }

  static void storage(Function()? onGranted) async {
    if (await Permission.storage.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    }
    if (await Permission.storage.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
    }
  }

  static void manageExternalStorage(Function()? onGranted) async {
    if (await Permission.manageExternalStorage.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    }
    if (await Permission.storage.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
    }
  }

  static void microphone(
    Function()? onGranted, {
    Function()? onDenied,
    Function()? onPermanentlyDenied,
  }) async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      onGranted?.call();
      return;
    }
    IMViews.showToast('${StrRes.microphone}权限未开启');
    if (status.isPermanentlyDenied) {
      onPermanentlyDenied?.call();
      await openAppSettings();
      return;
    }
    onDenied?.call();
  }

  static void location(Function()? onGranted) async {
    if (await Permission.location.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    }
    if (await Permission.location.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
    }
  }

  static void speech(Function()? onGranted) async {
    if (await Permission.speech.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    }
    if (await Permission.speech.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
    }
  }

  static void photos(Function()? onGranted) async {
    if (await Permission.photos.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    }
    if (await Permission.photos.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
    }
  }

  static void gallery(Function()? onGranted) async {
    if (Platform.isAndroid) {
      final photosStatus = await Permission.photos.request();
      final storageStatus = await Permission.storage.request();
      if (photosStatus.isGranted || storageStatus.isGranted) {
        onGranted?.call();
      }
      return;
    }
    photos(onGranted);
  }

  static Future<bool> notification() async {
    if (await Permission.notification.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      return true;
    }
    if (await Permission.notification.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
    }

    return false;
  }

  static void ignoreBatteryOptimizations(Function()? onGranted) async {
    if (await Permission.ignoreBatteryOptimizations.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      onGranted?.call();
    }
    if (await Permission.ignoreBatteryOptimizations.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
    }
  }

  static void cameraAndMicrophone(Function()? onGranted) async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      // Permission.speech,
    ];
    bool isAllGranted = true;
    for (var permission in permissions) {
      final state = await permission.request();
      isAllGranted = isAllGranted && state.isGranted;
    }
    if (isAllGranted) {
      onGranted?.call();
    }
  }

  static Future<bool> media() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.photos,
    ];
    bool isAllGranted = true;
    for (var permission in permissions) {
      final state = await permission.request();
      isAllGranted = isAllGranted && state.isGranted;
    }

    return Future.value(isAllGranted);
  }

  static void storageAndMicrophone(Function()? onGranted) async {
    final microphoneStatus = await Permission.microphone.request();
    if (microphoneStatus.isGranted) {
      onGranted?.call();
    }
  }

  static Future<Map<Permission, PermissionStatus>> request(
      List<Permission> permissions) async {
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    return statuses;
  }
}
