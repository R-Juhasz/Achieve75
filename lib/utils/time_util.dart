// lib/utils/time_util.dart

import 'package:timeago/timeago.dart' as timeago;

void initializeTimeAgo() {
  timeago.setLocaleMessages('en', timeago.EnMessages());
  // Add other locales if needed
}

String timeAgo(DateTime date, {String locale = 'en'}) {
  return timeago.format(date, locale: locale, allowFromNow: true);
}
