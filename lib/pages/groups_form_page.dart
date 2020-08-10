import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/app_utils.dart';

class GroupsFormPage extends StatefulWidget {
  GroupsFormPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GroupsFormPageState();
}

class _GroupsFormPageState extends State<GroupsFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _name;

  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) => WillPopScope(
        onWillPop: () {
          StoreProvider.of<AppState>(context).dispatch(NavigatePopAction());
          return Future.value(true);
        },
        child: Scaffold(
          resizeToAvoidBottomPadding: true,
          appBar: AppBar(
            title: Text(
              'Edit Group',
              style: const TextStyle(fontSize: 18.0),
            ),
            titleSpacing: 0.0,
            actions: <Widget>[
              FlatButton(
                textColor: AppTheme.primary,
                onPressed: () => _tapSave(viewModel),
                // onPressed: ((_formKey.currentState != null) &&
                //         _formKey.currentState.validate())
                //     ? () => _tapSave(viewModel)
                //     : null,
                child: Text('Save'),
                shape: CircleBorder(
                  side: BorderSide(color: Colors.transparent),
                ),
              ),
            ],
          ),
          body: _createContent(viewModel),
        ),
      ),
    );
  }

  Widget _createContent(
    GroupsViewModel viewModel,
  ) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                maxLines: 1,
                decoration: InputDecoration(hintText: 'Group name'),
                initialValue: viewModel.activeGroup.name,
                // validator: (value) => GroupValidators.validateName(value),
                onSaved: (String val) => (_name = val),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _tapSave(
    GroupsViewModel viewModel,
  ) {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      StoreProvider.of<AppState>(context).dispatch(
        UpdateGroupAction(
          viewModel.activeGroup.documentId,
          {
            'name': _name,
          },
        ),
      );

      closeKeyboard(context);
      Navigator.pop(context);
    }
  }
}
