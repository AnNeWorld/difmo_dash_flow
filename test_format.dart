import 'package:intl/intl.dart';

void main() {
  var format = NumberFormat.compactCurrency(locale: 'en_US', symbol: '₹');
  print('Result: ${format.format(1250000)}');
}
