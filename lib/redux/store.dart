import 'package:redux/redux.dart';

import 'package:retroshare/redux/reducers/app_reducer.dart';
import 'package:retroshare/redux/model/app_state.dart';

import 'middleware/chat_middleware.dart';
import 'middleware/identity_middleware.dart';

Future<Store<AppState>> retroshareStore() async {
  return Store(
    retroshareStateReducers,
    initialState: AppState(),
    middleware: [ChatMiddleware(), IdentityMiddleware()]
  );
}

