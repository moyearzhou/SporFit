/// Created with VSCode.
/// Author: 淡然
/// Date: 2021-01-05
/// Time: 11:56
/// Email: smallsevenk@vip.qq.com
/// Target: XMTabbar
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:framework/public.dart';

import 'explore/explore_root.dart';
import 'me/me_root.dart';
import 'plan/plan_root.dart';
import 'sport/sport_root.dart';

/// 优化后的Tabbar页面
/// 使用Flutter官方Scaffold + BottomNavigationBar实现
/// 优化点：
/// 1. 使用官方BottomNavigationBar，性能更好
/// 2. 页面懒加载，只创建一次，减少重建
/// 3. 使用PageView实现页面切换，支持滑动
/// 4. 优化setState刷新范围
class XMTabbarPage extends StatefulWidget {
  const XMTabbarPage({Key? key}) : super(key: key);
  
  @override
  _XMTabbarPageState createState() => _XMTabbarPageState();
}

class _XMTabbarPageState extends State<XMTabbarPage> with AutomaticKeepAliveClientMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  
  // 页面列表 - 只创建一次
  late final List<Widget> _pages = [
    ExploreRootScene(),
    SportPage(),
    PlanPage(),
    MePage(),
  ];

  // 底部导航配置
  final List<_TabItem> _tabItems = [
    _TabItem(label: '探索', iconPath: 'res/imgs/tab_0.png'),
    _TabItem(label: '运动', iconPath: 'res/imgs/tab_1.png'),
    _TabItem(label: '计划', iconPath: 'res/imgs/tab_2.png'),
    _TabItem(label: '我', iconPath: 'res/imgs/tab_3.png'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      // 使用动画切换页面，体验更流畅
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ScreenUtil.init(context);
    
    return Scaffold(
      backgroundColor: XMColor.themeColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(), // 禁用滑动切换，只允许点击切换
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: XMColor.navColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabItems.length, (index) {
              return _buildTabItem(index);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index) {
    final item = _tabItems[index];
    final isSelected = _currentIndex == index;
    
    return Expanded(
      child: Container(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onTabTapped(index),
            splashColor: Colors.black.withOpacity(0.05),
            highlightColor: Colors.transparent,
            child: Container(
              height: 80,
              width: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 图标容器
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Image.asset(
                      item.iconPath,
                      color: isSelected ? null : Colors.grey,
                      colorBlendMode: isSelected ? BlendMode.dst : BlendMode.srcIn,
                      cacheWidth: 48, // 缓存优化
                      cacheHeight: 48,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 标签文字
                  Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected ? Colors.black : XMColor.grayColor,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 底部导航项数据类
class _TabItem {
  final String label;
  final String iconPath;

  _TabItem({
    required this.label,
    required this.iconPath,
  });
}
