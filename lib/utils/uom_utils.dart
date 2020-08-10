import 'package:intl/intl.dart';

double metersToFeet(
  double meters,
) {
  return (meters * 3.2808);
}

String formatMetersToFeet(
  double meters,
) {
  return formatFeet(metersToFeet(meters).toInt());
}

String formatFeet(
  int feet,
) {
  final formatter = NumberFormat('#,##0', 'en_US'); // TODO
  return '${formatter.format(feet)} ft.';
}