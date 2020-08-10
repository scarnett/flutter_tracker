import 'dart:math' as math;

double round(
  double val,
  double places,
) {
  double mod = math.pow(10.0, places);
  return ((val * mod).round().toDouble() / mod);
}
