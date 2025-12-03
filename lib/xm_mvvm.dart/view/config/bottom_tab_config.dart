import 'package:flutter/cupertino.dart';

class BottomTabConfig {
  final String iconPath;
  final String label;
  final String? pageRoute;

  BottomTabConfig({
    required this.label,
    required this.iconPath,
    this.pageRoute,
  });
}

List<BottomTabConfig> defaultBottomTabConfig = [
  BottomTabConfig(label: '探索', iconPath: 'res/imgs/tab_0.png'),
];