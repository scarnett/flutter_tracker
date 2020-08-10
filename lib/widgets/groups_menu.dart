import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/group.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/group_utils.dart';
import 'package:flutter_tracker/utils/common_utils.dart';
import 'package:flutter_tracker/widgets/backdrop.dart';
import 'package:flutter_tracker/widgets/groups_member_cluster.dart';
import 'package:flutter_tracker/widgets/list_divider.dart';

/*
 * Usage:
 * 
 * Stack(
 *   children: <Widget>[
 *     GroupsMenu(),
 *   ],
 * );
 */
class GroupsMenu extends StatefulWidget {
  GroupsMenu({
    Key key,
  }) : super(key: key);

  @override
  State createState() => GroupsMenuState();
}

class GroupsMenuState extends State<GroupsMenu> with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Offset> _menuPositionAnimation;
  Animation<double> _menuOpacity;

  final alphaTween = Tween(begin: 0.0, end: 1.0);
  bool _menuActive = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 350),
      );

      _animationController.addStatusListener((status) {
        if (status == AnimationStatus.forward) {
          _menuActive = true;
        } else if (status == AnimationStatus.dismissed) {
          _menuActive = false;
        }
      });

      _menuPositionAnimation = Tween<Offset>(
        begin: const Offset(0.0, -1.0),
        end: const Offset(0.0, 0.0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.decelerate,
      ));

      _menuOpacity = alphaTween.animate(_animationController);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      //onInit: (store) => store
      //    .dispatch(RequestGroupPlacesAction(store.state.user.activeGroup)),
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) => AnimatedBuilder(
        animation: _animationController,
        builder: (
          BuildContext context,
          Widget _widget,
        ) {
          List<Widget> children = [
            backdrop(),
            menu(context, viewModel),
            button(viewModel),
          ];

          return Stack(
            children: filterNullWidgets(children),
          );
        },
      ),
    );
  }

  Widget backdrop() {
    return showBackdrop(
      _animationController,
      condition: _menuActive,
      opacity: 0.5,
      onTap: () => this.close(),
    );
  }

  Widget button(
    GroupsViewModel viewModel,
  ) {
    return Positioned(
      left: 70.0,
      right: 70.0,
      top: 30.0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
        child: InkWell(
          onTap: () {
            if (_animationController.isDismissed) {
              this.open();
            } else {
              this.close();
            }
          },
          child: Opacity(
            opacity: 0.9,
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(18.0)),
                boxShadow: [
                  const BoxShadow(
                    color: Colors.black45,
                    blurRadius: 2.0,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 8.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (viewModel.activeGroup == null)
                          ? ''
                          : viewModel.activeGroup.name,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.background(),
                      ),
                    ),
                    Container(
                      child: AnimatedBuilder(
                        animation: _animationController,
                        child: const Icon(
                          Icons.arrow_drop_down,
                          color: AppTheme.primary,
                          size: 20.0,
                        ),
                        builder: (
                          BuildContext context,
                          Widget _widget,
                        ) =>
                            Transform.rotate(
                          angle: (_animationController.value * 3.15),
                          child: _widget,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget menu(
    BuildContext context,
    GroupsViewModel viewModel,
  ) {
    double initialSlide = 0.0;
    double distance = 0.0;

    return GestureDetector(
      onPanStart: (DragStartDetails details) {
        initialSlide = details.globalPosition.dy;
      },
      onPanUpdate: (DragUpdateDetails details) {
        distance = (initialSlide + details.globalPosition.dy);
      },
      onPanEnd: (DragEndDetails details) {
        initialSlide = 0.0;

        if (distance > 100.0) {
          this.close();
        }
      },
      child: SlideTransition(
        position: _menuPositionAnimation,
        child: FadeTransition(
          opacity: _menuOpacity,
          child: menuItems(context, viewModel),
        ),
      ),
    );
  }

  Widget menuItems(
    BuildContext context,
    GroupsViewModel viewModel,
  ) {
    final store = StoreProvider.of<AppState>(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          const BoxShadow(
            color: Colors.black45,
            blurRadius: 2.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: AppTheme.light(),
            ),
            height: 100.0,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
                child: RawMaterialButton(
                  constraints: BoxConstraints.tight(Size(70.0, 40.0)),
                  onPressed: () => showInviteCode(context),
                  child: const Icon(
                    Icons.person_add,
                    color: AppTheme.primary,
                  ),
                  shape: CircleBorder(),
                  padding: const EdgeInsets.all(10.0),
                ),
              ),
            ),
          ),
          getGroupTiles(viewModel),
          getButtons(context, store),
        ],
      ),
    );
  }

  Widget getGroupTiles(
    GroupsViewModel viewModel,
  ) {
    List<Widget> tiles = [];

    if ((viewModel.groups != null) && (viewModel.user != null)) {
      for (Group group in viewModel.groups) {
        tiles..add(ListDivider());

        bool isActive = (group.documentId == viewModel.user.activeGroup);
        Container container = Container(
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
            child: ListTile(
              onTap: isActive
                  ? null
                  : viewModel.activationCallback(group, this.close),
              leading: GroupsMemberCluster(members: group.members),
              title: Text(
                group.name,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
              subtitle: Text(
                'Owner: ${(viewModel.user.documentId != group.owner.uid) ? group.owner.name : 'Me'}',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.2),
                  fontSize: 12.0,
                ),
              ),
              trailing: isActive
                  ? Icon(
                      Icons.check,
                      color: AppTheme.primary,
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
            ),
          ),
        );

        tiles..add(container);
      }
    }

    tiles..add(ListDivider());

    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: tiles,
    );
  }

  Widget getButtons(
    BuildContext context,
    final store,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.light(),
      ),
      child: Center(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
                child: FlatButton(
                  color: AppTheme.primary,
                  splashColor: AppTheme.primaryAccent,
                  textColor: Colors.white,
                  child: Text('Create a Group'),
                  shape: StadiumBorder(),
                  onPressed: () {
                    showCreateGroup(context, store);
                    this.close();
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                child: FlatButton(
                  color: AppTheme.primary,
                  splashColor: AppTheme.primaryAccent,
                  textColor: Colors.white,
                  child: Text('Join a Group'),
                  shape: StadiumBorder(),
                  onPressed: () {
                    showJoinGroup(context);
                    this.close();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  open() {
    if (_animationController.isDismissed) {
      _animationController.forward();
    }
  }

  close() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    }
  }
}
