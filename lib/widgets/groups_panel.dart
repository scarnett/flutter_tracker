import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/message.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/utils/common_utils.dart';
import 'package:flutter_tracker/utils/auth_utils.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/utils/date_utils.dart';
import 'package:flutter_tracker/utils/shadow_utils.dart';
import 'package:flutter_tracker/utils/slide_panel_utils.dart';
import 'package:flutter_tracker/widgets/group_row.dart';
import 'package:flutter_tracker/widgets/groups_member_row.dart';
import 'package:flutter_tracker/widgets/date_range.dart';
import 'package:flutter_tracker/widgets/empty_state_message.dart';
import 'package:flutter_tracker/widgets/list_scrollable_items.dart';
import 'package:flutter_tracker/widgets/section_header.dart';
import 'package:flutter_tracker/widgets/user_activity_row.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/widgets/slide_up_panel.dart';
import 'package:flutter_tracker/widgets/groups_map.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class GroupsPanel extends StatefulWidget {
  final PanelController panelController;

  GroupsPanel({
    Key key,
    this.panelController,
  }) : super(key: key);

  @override
  State createState() => GroupsPanelState();
}

class GroupsPanelState extends State<GroupsPanel>
    with TickerProviderStateMixin {
  GroupsMap _map;
  double _panelHeightMax;
  bool _isViewingGroupMember = false;
  bool _isPanelOpened = false;

  final SlidableController _slidableController = SlidableController();
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2, // TODO: Can this be dynamic?
      vsync: this,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      StoreConnector<AppState, GroupsViewModel>(
        onInit: (store) {
          _map = GroupsMap();
          _setPanelMaxHeight();
        },
        converter: (store) => GroupsViewModel.fromStore(store),
        builder: (_, viewModel) {
          if (viewModel.activeGroup == null) {
            return Container();
          }

          if (viewModel.activeGroupMember != null) {
            if (!_isViewingGroupMember) {
              try {
                _isViewingGroupMember = !_isViewingGroupMember;
                _setPanelMaxHeight(viewModel);
              } catch (e) {
                // logger.e(e);
              }
            }
          } else if (_isViewingGroupMember) {
            _isViewingGroupMember = !_isViewingGroupMember;
            _setPanelMaxHeight(viewModel);
          }

          List<Widget> children = [
            SlidingUpPanel(
              controller: widget.panelController,
              maxHeight: _panelHeightMax,
              minHeight: DEFAULT_PANEL_MIN_HEIGHT_BOTTOM_BAR,
              boxShadow: [
                const BoxShadow(
                  blurRadius: 0.0,
                  color: Colors.transparent,
                ),
              ],
              panelSnapping: false,
              panel: _buildPanel(context, viewModel),
              body: _map,
              border: Border(
                top: BorderSide(
                  color: AppTheme.inactive(),
                ),
              ),
              // onPanelSlide: (double pos) => _onPanelSlide(viewModel, pos),
              onPanelOpened: () {
                if (mounted && !_isPanelOpened) {
                  setState(() {
                    _isPanelOpened = true;
                  });
                }
              },
              onPanelClosed: () {
                if (mounted && _isPanelOpened) {
                  setState(() {
                    _isPanelOpened = false;
                  });
                }
              },
            ),
          ];

          return Stack(
            children: children,
          );
        },
      );

  SlideUpPanel _buildPanel(
    BuildContext context,
    GroupsViewModel viewModel,
  ) {
    List<Widget> tabBodies = List<Widget>();
    tabBodies
      ..add(
        _buildActiveGroupPanelBody(context, viewModel),
      )
      ..add(
        _buildGroupsPanelBody(context, viewModel),
      );

    return SlideUpPanel(
      body: <Widget>[]
        ..add(
          _buildPanelTabs(viewModel),
        )
        ..add(
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: tabBodies,
            ),
          ),
        ),
    );
  }

  Widget _buildPanelTabs(
    GroupsViewModel viewModel,
  ) {
    /*
    if ((viewModel.user != null) &&
        (viewModel.user.activeGroupMember != null)) {
      return Container();
    }
    */

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.inactive().withOpacity(0.5),
          ),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 1.0),
      child: DefaultTabController(
        length: 2,
        child: Material(
          color: AppTheme.light(),
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.inactive(),
            indicator: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.primary,
                  width: 2.0,
                ),
              ),
            ),
            tabs: [
              Tab(
                child: Text(
                  'Members',
                  style: const TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'My Groups',
                  style: const TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveGroupPanelBody(
    BuildContext context,
    GroupsViewModel viewModel,
  ) {
    final store = StoreProvider.of<AppState>(context);

    List<Widget> body = List<Widget>();
    Widget _panelHeader;
    List<Widget> _panelItems = [];

    if ((viewModel.user != null) && (viewModel.user.activeGroup != null)) {
      GroupMember member = viewModel.activeGroupMember;
      if (member != null) {
        _panelHeader = Container(
          child: _buildGroupMemberRow(viewModel, member),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppTheme.inactive(),
              ),
            ),
          ),
        );

        if (member.activityDetection.status) {
          _panelItems
            ..add(_buildactiveGroupMemberHeader(store, viewModel))
            ..addAll(_buildactiveGroupMemberActivityItems(store, viewModel));
        } else {
          _panelItems..add(_buildDisabledActivityDetection());
        }
      } else {
        _panelItems..addAll(_buildActiveGroupItems(context, store, viewModel));
      }

      /*
      if (needsUpgrade(viewModel.activePlan, 'advertisements_enabled', true)) {
        panelItems..add(bannerAd(viewModel));
      }
      */
    }

    if (_panelHeader != null) {
      body..add(_panelHeader);
    }

    body
      ..add(
        ListScrollableItems(
          items: _panelItems,
          disableScroll: !_isPanelOpened,
        ),
      );

    return Column(children: body);
  }

  Widget _buildGroupsPanelBody(
    BuildContext context,
    GroupsViewModel viewModel,
  ) {
    final store = StoreProvider.of<AppState>(context);

    List<Widget> body = List<Widget>();
    List<Widget> _panelItems = [];
    _panelItems..addAll(_buildGroupsItems(context, store, viewModel));

    body
      ..add(
        ListScrollableItems(
          items: _panelItems,
          disableScroll: !_isPanelOpened,
        ),
      );

    return Column(children: body);
  }

  Widget _buildGroupMemberRow(
    GroupsViewModel viewModel,
    GroupMember member,
  ) {
    bool isUser = (member.uid == viewModel.user.documentId);

    return Slidable(
      key: ValueKey(member.uid),
      controller: _slidableController,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: GroupsMemberRow(
        user: viewModel.user,
        member: member,
        tap: () => _tapGroupMember(viewModel, member),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Check-In',
          color: AppTheme.secondary,
          foregroundColor:
              isUser ? Colors.white.withOpacity(0.3) : Colors.white,
          icon: Icons.check,
          onTap: isUser ? null : () => _tapCheckin(viewModel, member),
        ),
      ],
    );
  }

  Widget _buildGroupRow(
    GroupsViewModel viewModel,
    Group group,
  ) {
    return Slidable(
      key: ValueKey(group.documentId),
      controller: _slidableController,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: GroupsRow(
        group: group,
        tap: () => _tapGroup(group),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Add Member',
          color: AppTheme.secondary,
          foregroundColor: Colors.white,
          icon: Icons.add,
          onTap: () => showInviteCode(
            context,
            groupId: group.documentId,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActiveGroupItems(
    BuildContext context,
    final store,
    GroupsViewModel viewModel,
  ) {
    List<Widget> panelItems = [];
    List<Widget> actionItems = [];

    Group activeGroup = viewModel.activeGroup;
    if ((activeGroup != null) && (activeGroup.members != null)) {
      for (GroupMember member in activeGroup.members) {
        panelItems
          ..add(
            _buildGroupMemberRow(viewModel, member),
          );
      }
    }

    if (isAdministrator(viewModel.activeGroup, viewModel.user)) {
      actionItems
        ..add(
          menuActionButton(
            'Add Member',
            Icons.add,
            AppTheme.primary,
            () => showInviteCode(
              context,
              groupId: viewModel.activeGroup.documentId,
            ),
          ),
        );
    }

    actionItems
      ..add(
        menuActionButton(
          'Settings',
          Icons.settings,
          AppTheme.hint,
          () => _tapSettings(),
          showSpacer: true,
        ),
      );

    panelItems..add(buildMenuActions(actionItems));
    return panelItems;
  }

  List<Widget> _buildGroupsItems(
    BuildContext context,
    final store,
    GroupsViewModel viewModel,
  ) {
    List<Widget> panelItems = [];
    List<Widget> actionItems = [];

    for (Group group in viewModel.groups) {
      panelItems
        ..add(
          _buildGroupRow(viewModel, group),
        );
    }

    if (isAdministrator(viewModel.activeGroup, viewModel.user)) {
      actionItems
        ..add(
          menuActionButton(
            'Add Group',
            Icons.group_add,
            AppTheme.primary,
            () => showCreateGroup(context, store),
          ),
        );
    }

    actionItems
      ..add(
        menuActionButton(
          'Settings',
          Icons.settings,
          AppTheme.hint,
          () => _tapSettings(),
          showSpacer: true,
        ),
      );

    panelItems..add(buildMenuActions(actionItems));
    return panelItems;
  }

  Widget _buildactiveGroupMemberHeader(
    final store,
    GroupsViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: DateRange(
        plan: viewModel.activePlan,
        onTap: (List<DateTime> picked) {
          if ((picked != null) && (picked.length == 2)) {
            store.dispatch(CancelUserActivityAction());
            store.dispatch(
              RequestUserActivityDataAction(
                viewModel.activeGroupMember.uid,
                startGt: picked[0],
                endLte: picked[1]
                    .add(Duration(days: 1))
                    .subtract(Duration(seconds: 1)),
              ),
            );
          }
        },
      ),
    );
  }

  List<Widget> _buildactiveGroupMemberActivityItems(
    final store,
    GroupsViewModel viewModel,
  ) {
    List<Widget> panelItems = [];
    Map<String, List<dynamic>> activityData =
        _buildactiveGroupMemberActivitySections(viewModel);
    if (activityData == null) {
      panelItems..add(_buildLoading());
    } else if (activityData.length == 0) {
      panelItems
        ..add(EmptyStateMessage(
          icon: Icons.av_timer,
          title: null,
          message: 'Waiting for some activity...',
        ));
    } else {
      activityData.forEach((key, value) {
        List<Widget> items = [];
        value.forEach((activity) => items..add(activity));

        panelItems
          ..add(
            StickyHeader(
              header: SectionHeader(text: key),
              content: Column(children: items),
            ),
          );
      });
    }

    return panelItems;
  }

  Map<String, List<dynamic>> _buildactiveGroupMemberActivitySections(
    GroupsViewModel viewModel,
  ) {
    List<UserActivity> activities = viewModel.userActivity;
    if (activities == null) {
      return null;
    }

    String dateStr;
    Map<String, List<dynamic>> entires = Map<String, List<dynamic>>();
    int count = 0;

    /*
    if (needsUpgrade(viewModel.activePlan, 'advertisements_enabled', true)) {
      activities = injectAd<dynamic>(
        activities,
        bannerAd(viewModel),
        minEntriesNeeded: 5,
      );
    }
    */

    activities.forEach((UserActivity activity) {
      bool isLast = (activities.length == (count + 1));

      if (activity.runtimeType == UserActivity) {
        dateStr = formatTimestamp(activity.startTime, 'MM/dd/yyyy');

        if (activity.startTime != null) {
          if (entires.containsKey(dateStr)) {
            entires[dateStr]
              ..add(
                _wrapActivityRow(
                  UserActivityRow(
                    activity: activity,
                    tap: _canTapActivity(activity)
                        ? () => _tapactiveGroupMemberActivityDetails(activity)
                        : null,
                  ),
                  isLast,
                ),
              );
          } else {
            entires[dateStr] = [
              _wrapActivityRow(
                UserActivityRow(
                  activity: activity,
                  tap: _canTapActivity(activity)
                      ? () => _tapactiveGroupMemberActivityDetails(activity)
                      : null,
                ),
                isLast,
              ),
            ];
          }
        }
      } else if (dateStr != null) {
        entires[dateStr]..add(activity);
      }

      count++;
    });

    return entires;
  }

  Widget _wrapActivityRow(
    UserActivityRow _row,
    bool isLast,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.light(),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0.0 : 10.0),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: cardBoxShadow(),
          ),
          child: _row,
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(
          top: 20.0,
          bottom: 20.0,
        ),
        width: 50.0,
        height: 50.0,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
        ),
      ),
    );
  }

  Widget _buildDisabledActivityDetection() {
    return ListTile(
      title: Text(
        'Activity detection disabled',
        style: TextStyle(
          color: AppTheme.inactive(),
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
    );
  }

  void _tapGroupMember(
    GroupsViewModel viewModel,
    GroupMember member,
  ) {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(ActivateGroupMemberAction(member.uid));
    store.dispatch(CancelUserActivityAction());
    store.dispatch(RequestUserActivityDataAction(member.uid));

    if (widget.panelController.panelPosition < DEFAULT_PANEL_ACTIVE_HEIGHT) {
      widget.panelController
          .animatePanelToPosition(DEFAULT_PANEL_ACTIVE_HEIGHT);
    }
  }

  void _tapGroup(
    Group group,
  ) {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(ActivateGroupAction(group.documentId));
  }

  void _tapactiveGroupMemberActivityDetails(
    UserActivity activity,
  ) {
    StoreProvider.of<AppState>(context).dispatch(NavigatePushAction(
      AppRoutes.activityMap,
      arguments: {
        'activity': activity,
      },
    ));
  }

  void _tapCheckin(
    GroupsViewModel viewModel,
    GroupMember member,
  ) {
    // Checkin with the group member
    StoreProvider.of<AppState>(context).dispatch(PushMessageAction(
      viewModel.user.documentId,
      member.uid,
      viewModel.activeGroup.documentId,
      PushMessageType.CHECKIN,
    ));
  }

  void _tapSettings() {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(SetSelectedTabIndexAction(TAB_SETTINGS));
  }

  bool _canTapActivity(
    UserActivity activity,
  ) {
    switch (activity.type) {
      case ActivityType.CHECKIN_RECEIVER:
      case ActivityType.CHECKIN_SENDER:
        return true;
        break;

      default:
        return false;
        break;
    }
  }

  void _setPanelMaxHeight([
    GroupsViewModel viewModel,
  ]) {
    double windowHeight = MediaQuery.of(context).size.height;
    if ((viewModel != null) &&
        (viewModel.user != null) &&
        (viewModel.user.activeGroupMember != null)) {
      _panelHeightMax =
          (windowHeight - (APPBAR_HEIGHT - 1.0)); // Accounts for 1px border

      if (widget.panelController.panelPosition < DEFAULT_PANEL_ACTIVE_HEIGHT) {
        widget.panelController
            .animatePanelToPosition(DEFAULT_PANEL_ACTIVE_HEIGHT);
      }
    } else {
      _panelHeightMax = windowHeight;
    }
  }
}
