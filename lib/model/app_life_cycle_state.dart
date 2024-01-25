import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

late AppLifecycleState actuaApplState;

class LifecycleEventHandler extends WidgetsBindingObserver {

  LifecycleEventHandler({
    required this.resumeCallBack,
    required this.suspendingCallBack,
  }) {
    actuaApplState = AppLifecycleState.resumed;
  }
  final AsyncCallback resumeCallBack;
  final AsyncCallback suspendingCallBack;

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    actuaApplState = state;
    print(actuaApplState);
    switch (state) {
      case AppLifecycleState.resumed:
        await resumeCallBack();
            case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        await suspendingCallBack();
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
          }
  }
}
