import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/app_utils.dart';
import 'package:flutter_tracker/validators/common_validators.dart';
import 'package:flutter_tracker/widgets/text_field.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class GroupsCreateContent extends StatefulWidget {
  GroupsCreateContent();

  @override
  _GroupsCreateContentState createState() => _GroupsCreateContentState();
}

class _GroupsCreateContentState extends State<GroupsCreateContent>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String _name;

  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) {
        return _createContent(context, viewModel);
      },
    );
  }

  Widget _createContent(
    BuildContext context,
    GroupsViewModel viewModel,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: CustomTextField(
              hintText: 'Group name',
              icon: Icons.group,
              validator: (value) => CommonValidators.validateName(
                value,
                text: 'the group',
              ),
              onChanged: (String val) {
                setState(() {
                  _name = val;
                });
              },
              onSaved: (String val) => (_name = val),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              'Ex: Family, Friends, Vacation group...',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.normal,
              ),
            ),
          ),
          DialogButton(
            child: Text(
              'Create',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.0,
              ),
            ),
            onPressed: _hasName() ? () => _tapCreate(viewModel) : null,
            color: _hasName() ? AppTheme.primary : AppTheme.inactive(),
          ),
        ],
      ),
    );
  }

  bool _hasName() {
    return (_name != null) && (_name != '');
  }

  // TODO: Button spinner
  void _tapCreate(
    GroupsViewModel viewModel,
  ) {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      StoreProvider.of<AppState>(context).dispatch(
        SaveGroupAction(
          Group.create(
            _name,
            viewModel.user,
            viewModel.configValue('invite_code_valid_days'),
          ),
        ),
      );

      closeKeyboard(context);
      Navigator.pop(context);
    }
  }
}
