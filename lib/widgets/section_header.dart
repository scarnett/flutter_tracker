import 'package:flutter/material.dart';
import 'package:flutter_tracker/colors.dart';

class SectionHeader extends StatefulWidget {
  final String text;
  final bool safeArea;

  SectionHeader({
    @required this.text,
    this.safeArea: false,
  });

  @override
  _SectionHeaderState createState() => _SectionHeaderState();
}

class _SectionHeaderState extends State<SectionHeader> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.light(),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.inactive(),
          ),
        ),
      ),
      padding: const EdgeInsets.only(
          left: 14.0, right: 10.0, bottom: 10.0, top: 10.0),
      child: widget.safeArea ? SafeArea(child: _buildtext()) : _buildtext(),
    );
  }

  Widget _buildtext() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Text(
          widget.text,
          style: TextStyle(
            fontSize: 14.0,
            color: AppTheme.hint,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
