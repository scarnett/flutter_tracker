import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_tracker/colors.dart';

class ListShowMore extends StatefulWidget {
  ListShowMore();

  @override
  _ListShowMoreState createState() => _ListShowMoreState();
}

class _ListShowMoreState extends State<ListShowMore> {
  SlidableState state;
  bool opened = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    state = Slidable.of(context);

    return Container(
      height: 40.0,
      width: 40.0,
      child: Tooltip(
        message: 'Show More',
        preferBelow: false,
        child: RawMaterialButton(
          onPressed: () => (opened) ? _tapShowLess() : _tapShowMore(),
          child: const Icon(
            Icons.more_vert,
            color: AppTheme.hint,
            size: 20.0,
          ),
          shape: CircleBorder(),
          padding: const EdgeInsets.all(6.0),
        ),
      ),
    );
  }

  void _tapShowMore() {
    state.open(
      actionType: SlideActionType.secondary,
    );

    setState(() {
      opened = true;
    });
  }

  void _tapShowLess() {
    state.close();

    setState(() {
      opened = false;
    });
  }
}
