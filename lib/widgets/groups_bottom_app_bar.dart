import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/state.dart';

class GroupsBottomAppBarItem {
  IconData iconData;
  String text;
  bool disabled;

  GroupsBottomAppBarItem({
    this.iconData,
    this.text,
    this.disabled: false,
  });
}

class GroupsBottomAppBar extends StatefulWidget {
  final List<GroupsBottomAppBarItem> items;
  final double height;
  final double verboseHeight;
  final double iconSize;
  final double verboseIconSize;
  final Color color;
  final Color selectedColor;
  final ValueChanged<int> onTabSelected;
  final bool verbose;

  GroupsBottomAppBar({
    this.items,
    this.height: 45.0,
    this.verboseHeight: 60.0,
    this.iconSize: 24.0,
    this.verboseIconSize: 28.0,
    this.color,
    this.selectedColor,
    this.onTabSelected,
    this.verbose: false,
  }) {
    assert((this.items.length == 2) || (this.items.length == 4));
  }

  @override
  State<StatefulWidget> createState() => GroupsBottomAppBarState();
}

class GroupsBottomAppBarState extends State<GroupsBottomAppBar>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) {
        List<Widget> items = List.generate(widget.items.length, (int index) {
          return _buildTabItem(
            viewModel: viewModel,
            item: widget.items[index],
            index: index,
            onPressed: _updateIndex,
          );
        });

        items..insert(items.length >> 1, _buildMiddleTabItem());

        return Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: AnimatedContainer(
            decoration: BoxDecoration(
              color: AppTheme.background(),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            alignment: Alignment.topCenter,
            duration: const Duration(milliseconds: 250),
            height: _getHeight(viewModel),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items,
            ),
          ),
        );
      },
    );
  }

  void _updateIndex(
    int index,
  ) {
    widget.onTabSelected(index);
    StoreProvider.of<AppState>(context)
        .dispatch(SetSelectedTabIndexAction(index));
  }

  Widget _buildMiddleTabItem() {
    return IconButton(
      highlightColor: Colors.transparent,
      onPressed: () => _tapGroupMenu(),
      tooltip: 'Dashboard',
      icon: Icon(
        Icons.add_circle_outline,
        color: AppTheme.primary,
        size: widget.verbose ? 40.0 : 30.0,
      ),
    );
  }

  Widget _buildTabItem({
    GroupsViewModel viewModel,
    GroupsBottomAppBarItem item,
    int index,
    ValueChanged<int> onPressed,
  }) {
    return Material(
      type: MaterialType.transparency,
      child: _buildButton(
        viewModel,
        item,
        index,
        onPressed,
      ),
    );
  }

  Widget _buildButton(
    GroupsViewModel viewModel,
    GroupsBottomAppBarItem item,
    int index,
    ValueChanged<int> onPressed,
  ) {
    Color color = (viewModel.selectedTabIndex == index)
        ? widget.selectedColor
        : widget.color;

    if (widget.verbose) {
      return InkWell(
        highlightColor: Colors.transparent,
        onTap: item.disabled ? null : () => onPressed(index),
        child: Opacity(
          opacity: item.disabled ? 0.3 : 1.0,
          child: Container(
            constraints: BoxConstraints.tight(Size(60.0, 60.0)),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  item.iconData,
                  color: color,
                  size:
                      widget.verbose ? widget.verboseIconSize : widget.iconSize,
                ),
                (widget.verbose && (item.text != null))
                    ? Text(
                        item.text,
                        style: TextStyle(color: color),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      );
    }

    return Opacity(
      opacity: item.disabled ? 0.3 : 1.0,
      child: IconButton(
        highlightColor: Colors.transparent,
        onPressed: item.disabled ? null : () => onPressed(index),
        tooltip: item.disabled || widget.verbose ? null : item.text,
        icon: Icon(
          item.iconData,
          color: color,
          size: widget.verbose ? widget.verboseIconSize : widget.iconSize,
        ),
      ),
    );
  }

  void _tapGroupMenu() {
    StoreProvider.of<AppState>(context)
        .dispatch(NavigatePushAction(AppRoutes.groupMenu));
  }

  double _getHeight(
    GroupsViewModel viewModel,
  ) {
    if ((viewModel.activeGroupMember == null) &&
        (viewModel.activePlace == null)) {
      return widget.verbose ? widget.verboseHeight : widget.height;
    }

    return 0.0;
  }
}
