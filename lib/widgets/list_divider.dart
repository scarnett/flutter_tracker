import 'package:flutter/material.dart';
import 'package:flutter_tracker/colors.dart';

class ListDivider extends StatefulWidget {
  ListDivider();

  @override
  _ListDividerState createState() => _ListDividerState();
}

class _ListDividerState extends State<ListDivider> {
  @override
  Widget build(
    BuildContext context,
  ) {
    return Divider(
      height: 1.0,
      color: AppTheme.inactive(),
    );
  }
}
