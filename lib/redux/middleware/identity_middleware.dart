import 'package:retroshare/redux/actions/app_actions.dart';
import 'package:retroshare/redux/model/app_state.dart';
import 'package:redux/redux.dart';
import 'package:retroshare/services/identity.dart';

class IdentityMiddleware implements MiddlewareClass<AppState> {
  @override
  Future<void> call(Store<AppState> store, action, next) async {
    if(action is RequestUnknownIdAction){
      requestIdentity(action.unknownId.mId);
    }
    next(action);
  }
}