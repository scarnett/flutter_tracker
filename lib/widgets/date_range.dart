import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:flutter/material.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/plan.dart';
import 'package:flutter_tracker/utils/date_utils.dart';
import 'package:flutter_tracker/utils/user_utils.dart';

class DateRange extends StatefulWidget {
  final Plan plan;
  final Function(List<DateTime>) onTap;

  DateRange({
    this.plan,
    this.onTap,
  });

  @override
  State createState() => DateRangeState();
}

class DateRangeState extends State<DateRange> {
  List<DateTime> _picked;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        _buildButton(),
        _buildDates(),
      ],
    );
  }

  Widget _buildButton() {
    return FlatButton(
      color: AppTheme.primary,
      splashColor: AppTheme.primaryAccent,
      textColor: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Icon(
              Icons.date_range,
              color: Colors.white,
              size: 16.0,
            ),
          ),
          Text('Date Range'),
        ],
      ),
      shape: StadiumBorder(),
      onPressed: () async {
        Map<String, DateTime> activityRange = getActivityRange(widget.plan);
        _picked = await DateRagePicker.showDatePicker(
          context: context,
          initialFirstDate: getToday(),
          initialLastDate: getToday(),
          firstDate: activityRange['start'],
          lastDate: activityRange['end'],
        );

        widget.onTap(_picked);
      },
    );
  }

  Widget _buildDates() {
    if ((_picked == null) || (_picked.length < 2)) {
      return Container();
    }

    if (_picked[0] == _picked[1]) {
      return _buildDateText(
        _picked[0],
        const EdgeInsets.only(right: 10.0),
        align: TextAlign.center,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: _buildDateText(
              _picked[0],
              const EdgeInsets.only(right: 10.0),
              align: TextAlign.right,
            ),
          ),
          _buildSpacer(),
          Expanded(
            child: _buildDateText(
              _picked[1],
              const EdgeInsets.only(left: 10.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateText(
    DateTime date,
    EdgeInsets padding, {
    TextAlign align = TextAlign.left,
    String format = 'MM/dd/yyyy',
  }) {
    return Padding(
      padding: padding,
      child: Text(
        formatDateTime(date, format),
        style: const TextStyle(
          color: AppTheme.hint,
          fontSize: 12.0,
          fontWeight: FontWeight.w900,
        ),
        textAlign: align,
      ),
    );
  }

  Widget _buildSpacer() {
    return Text(
      '-',
      style: const TextStyle(
        color: AppTheme.hint,
        fontSize: 12.0,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
