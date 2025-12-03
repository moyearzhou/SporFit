import 'dart:core';
import 'package:intl/intl.dart'; // 引入DateFormat

class DateUtil {
  static String formatDateTime(String dateTimeString, String format, String dateSeparator, String timeSeparator) {
    // 将输入的日期时间字符串解析为DateTime对象
    DateTime dateTime = DateTime.parse(dateTimeString);
    // 使用DateFormat进行格式化
    DateFormat dateFormat = DateFormat(format);
    return dateFormat.format(dateTime);
  }
}