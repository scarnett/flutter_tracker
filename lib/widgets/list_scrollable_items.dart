import 'package:flutter/material.dart';
import 'package:flutter_tracker/widgets/list_divider.dart';

class ListScrollableItems extends StatefulWidget {
  final List<Widget> items;
  final bool disableScroll;

  ListScrollableItems({
    this.items,
    this.disableScroll,
  });

  @override
  _ListScrollableItemsState createState() => _ListScrollableItemsState();
}

class _ListScrollableItemsState extends State<ListScrollableItems> {
  ScrollController _scrollController = ScrollController();
  bool _disableScroll = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if ((_scrollController.offset > 0.0) && !_disableScroll) {
        _setDisableScroll(false);
      } else if (_scrollController.offset == 0.0) {
        _setDisableScroll(true);
      }
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    _setDisableScroll(widget.disableScroll);

    return Expanded(
      flex: 10,
      child: Container(
        child: ListView(
          controller: _scrollController,
          physics: _disableScroll
              ? NeverScrollableScrollPhysics()
              : ClampingScrollPhysics(),
          padding: const EdgeInsets.all(0.0),
          children: getItems(),
        ),
      ),
    );
  }

  List<Widget> getItems() {
    List<Widget> items = [];

    int count = 0;
    for (Widget item in widget.items) {
      items..add(item);

      if ((count + 1) < widget.items.length) {
        items..add(ListDivider());
      }

      count++;
    }

    return items;
  }

  void _setDisableScroll(
    bool status,
  ) {
    setState(() => _disableScroll = status);
  }
}
