import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/state.dart';
import 'package:redux/redux.dart';

class FamilyViewModel {
  final User user;
  final List<Group> groups;

  FamilyViewModel({
    this.user,
    this.groups,
  });

  static FamilyViewModel fromStore(
    Store<AppState> store,
  ) {
    return FamilyViewModel(
      user: store.state.user,
      groups: store.state.groups,
    );
  }
}
