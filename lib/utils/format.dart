import 'package:intl/intl.dart';

final _rupee = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
final _date = DateFormat('d MMM yyyy, h:mm a');

/// 129900 -> ₹1,29,900
String rupees(int amount) => _rupee.format(amount);

String formatDate(DateTime date) => _date.format(date);
