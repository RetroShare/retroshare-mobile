
import 'package:retroshare/model/location.dart';
import 'package:retroshare/redux/actions/app_actions.dart';

List<Location> UpdateLocations(
    List<Location> locations, action) {
  return action is UpdateLocationsAction
      ? List.from(action.locations)
      : locations;
}