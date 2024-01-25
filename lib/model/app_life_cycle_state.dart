import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

AppLifecycleState actuaApplState;

class LifecycleEventHandler extends WidgetsBindingObserver {

  LifecycleEventHandler({
    this.resumeCallBack,
    this.suspendingCallBack,
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
          }
  }
}
