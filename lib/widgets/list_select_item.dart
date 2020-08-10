import 'package:flutter/material.dart';
import 'package:flutter_tracker/colors.dart';

class ListSelectItem extends StatefulWidget {
  final String title;
  final double fontSize;
  final IconData icon;
  final double iconSize;
  final bool disabled;
  final GestureTapCallback onTap;

  ListSelectItem({
    @required this.title,
    @required this.icon,
    this.fontSize: 16.0,
    this.iconSize: 20.0,
    this.disabled: false,
    this.onTap,
  });

  @override
  _ListSelectItemState createState() => _ListSelectItemState();
}

class _ListSelectItemState extends State<ListSelectItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (widget.disabled) {
      return _getItem(disabled: widget.disabled);
    }

    return InkWell(
      onTap: widget.onTap,
      child: _getItem(),
    );
  }

  Widget _getItem({
    bool disabled = false,
  }) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10.0,
          right: 10.0,
          top: 20.0,
          bottom: 20.0,
        ),
        child: Row(
          children: [
            Container(
              width: 30.0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  widget.icon,
                  color: disabled ? AppTheme.inactive() : AppTheme.hint,
                  size: widget.iconSize,
                ),
              ),
            ),
            Text(
              widget.title,
              style: TextStyle(
                color: disabled ? AppTheme.inactive() : AppTheme.text(),
                fontSize: widget.fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
