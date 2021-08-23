
/// In this file are defined the funcions related to the interaction between
/// retroshare-service, the flutter app and the operating system.
/// This functions can't be defined on the repo-lib because they have flutter
/// dependencies

import 'package:flutter/services.dart';
import 'package:retroshare_api_wrapper/retroshare.dart' as rs;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart'
    if (dart.library.cli_util) 'dummy.dart';

import 'android_config.dart';

const rsPlatform = const MethodChannel(rs.RETROSHARE_CHANNEL_NAME);

void setControlCallbacks() {
  rs.setStartCallback(RsServiceControl.startRetroshareLoop);
}

/// Inspired by https://github.com/JulianAssmann/flutter_background/ thanks :)
class RsServiceControl {
  static bool _isInitialized = false;
  static bool _isBackgroundExecutionEnabled = false;

  /// Initializes the plugin.
  /// May request the necessary permissions from the user in order to run in the background.
  ///
  /// Does nothing and returns true if the permissions are already granted.
  /// Returns true, if the user grants the permissions, otherwise false.
  /// May throw a [PlatformException].
  static Future<bool> initialize(
      {FlutterRetroshareServiceAndroidConfig androidConfig =
          const FlutterRetroshareServiceAndroidConfig()}) async {
    _isInitialized = await rsPlatform.invokeMethod<bool>('initialize', {
          'android.notificationTitle': androidConfig.notificationTitle,
          'android.notificationText': androidConfig.notificationText,
          'android.notificationImportance': _androidNotificationImportanceToInt(
              androidConfig.notificationImportance),
          'android.notificationIconName': androidConfig.notificationIcon.name,
          'android.notificationIconDefType':
              androidConfig.notificationIcon.defType,
        }) ==
        true;
    return _isInitialized;
  }

  /// Enables the execution of the flutter app in the background.
  /// You must to call [RsServiceControl.initialize()] before calling this function.
  ///
  /// Returns true if successful, otherwise false.
  /// Throws an [Exception] if the plugin is not initialized by calling [FlutterBackground.initialize()] first.
  /// May throw a [PlatformException].
  static Future<bool> enableBackgroundExecution() async {
    if (_isInitialized) {
      final success =
          await rsPlatform.invokeMethod<bool>('enableBackgroundExecution');
      _isBackgroundExecutionEnabled = true;
      return success == true;
    } else {
      throw Exception(
          'RsServiceControl plugin must be initialized before calling enableBackgroundExecution()');
    }
  }

  /// Disables the execution of the flutter app in the background.
  /// You must to call [FlutterBackground.initialize()] before calling this function.
  ///
  /// Returns true if successful, otherwise false.
  /// Throws an [Exception] if the plugin is not initialized by calling [FlutterBackground.initialize()] first.
  /// May throw a [PlatformException].
  static Future<bool> disableBackgroundExecution() async {
    if (_isInitialized) {
      final success =
          await rsPlatform.invokeMethod<bool>('disableBackgroundExecution');
      _isBackgroundExecutionEnabled = false;
      return success == true;
    } else {
      throw Exception(
          'RsServiceControl plugin must be initialized before calling disableBackgroundExecution()');
    }
  }

  /// Indicates whether or not the user has given the necessary permissions in order to run in the background.
  ///
  /// Returns true, if the user has granted the permission, otherwise false.
  /// May throw a [PlatformException].
  static Future<bool> get hasPermissions async {
    return await rsPlatform.invokeMethod<bool>('hasPermissions') == true;
  }

  /// Indicates whether background execution is currently enabled.
  static bool get isBackgroundExecutionEnabled => _isBackgroundExecutionEnabled;

  static int _androidNotificationImportanceToInt(
      AndroidNotificationImportance importance) {
    switch (importance) {
      case AndroidNotificationImportance.Low:
        return -1;
      case AndroidNotificationImportance.Min:
        return -2;
      case AndroidNotificationImportance.High:
        return 1;
      case AndroidNotificationImportance.Max:
        return 2;
      case AndroidNotificationImportance.Default:
      default:
        return 0;
    }
  }

  /// Start Retroshare Service with a countdown of 20 tries by default
  ///
  /// Enables sticky notification. The problem could be that the sticky
  /// notification crashes and RetroShare still running???
  static Future<bool> startRetroshareLoop([int countdown = 20]) async {
    if (_isInitialized) {
      for (int attempts = countdown; attempts >= 0; attempts--) {
        print("Starting Retroshare Service. Attempts countdown $attempts");
        try {
          bool isUp = await rs.isRetroshareRunning();
          if (isUp) {
            _isBackgroundExecutionEnabled = true;
            return _isBackgroundExecutionEnabled;
          }
          await enableBackgroundExecution();

          await Future.delayed(Duration(seconds: 2));
        } catch (err) {
          await Future.delayed(Duration(seconds: 2));
        }
      }
      return false;
    } else {
      throw Exception(
          'RsServiceControl plugin must be initialized before calling startRetroshareLoop()');
    }
  }

  /// Stop RetroShare and disable the sticky notification
  static Future<void> stopRetroshare() async {
    try {
      await disableBackgroundExecution();

      await Future.delayed(Duration(milliseconds: 3000));
      if (await rs.isRetroshareRunning())
        throw Exception("The service did not stop after a while");
    } catch (err) {
      throw Exception("The service could not be stopped");
    }
  }

  Future<String> getRetrosharePath() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final pathComponents = path.split(appDocDir.path);
    pathComponents.removeLast();
    final rsPath =
        path.join(path.joinAll(pathComponents), "files", ".retroshare");
    return rsPath;
  }
}
