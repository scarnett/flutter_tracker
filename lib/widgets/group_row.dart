import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/widgets/groups_member_cluster.dart';
import 'package:flutter_tracker/widgets/list_show_more.dart';

class GroupsRow extends StatefulWidget {
  final Group group;
  final Function tap;

  GroupsRow({
    this.group,
    this.tap,
  });

  @override
  State createState() => GroupsRowState();
}

class GroupsRowState extends State<GroupsRow> with TickerProviderStateMixin {
  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) {
        bool isActive = (widget.group.documentId == viewModel.user.activeGroup);

        return Container(
          color: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              color: isActive ? Colors.grey[100] : Colors.transparent,
              border: Border(
                left: BorderSide(
                  width: 4.0,
                  color: isActive ? AppTheme.primary : Colors.transparent,
                ),
              ),
            ),
            child: Material(
              child: InkWell(
                onTap: widget.tap,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10.0,
                    top: 10.0,
                    left: 10.0,
                    right: 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          child: Wrap(
                            direction: Axis.vertical,
                            children: [
                              Row(
                                children: <Widget>[
                                  GroupsMemberCluster(
                                    members: widget.group.members,
                                    icon: isActive
                                        ? Icon(
                                            Icons.check,
                                            color: AppTheme.primary,
                                            size: 12.0,
                                          )
                                        : null,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.max,
                                          children: _buildGroupInfo(viewModel),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      ListShowMore(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildGroupInfo(
    GroupsViewModel viewModel,
  ) {
    List<Widget> widgets = [
      Text(
        (widget.group == null) || (widget.group.name == null)
            ? ''
            : widget.group.name,
        style: const TextStyle(
          fontSize: 15.0,
          color: Colors.black,
          fontWeight: FontWeight.w400,
        ),
      ),
      Text(
        'Owner: ${(viewModel.user.documentId != widget.group.owner.uid) ? widget.group.owner.name : 'Me'}',
        style: TextStyle(
          color: AppTheme.hint,
          fontSize: 12.0,
        ),
      ),
    ];

    return widgets;
  }
}
