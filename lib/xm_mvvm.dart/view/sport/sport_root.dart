import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../public.dart';
import 'sport_data.dart';
import 'action_detail_page.dart';

class SportPage extends StatefulWidget {
  SportPage({Key? key}) : super(key: key);

  _SportPageState createState() => _SportPageState();
}

class _SportPageState extends State<SportPage>  with TickerProviderStateMixin {
  late TabController tabCtr;
  var tabs = ['现在开始', '动作'];
  
  // 动作库页面状态
  Map<String, dynamic> actionsData = {};
  String selectedBodyPart = 'chest';
  String selectedEquipment = 'dumbbell';
  int selectedFilterTab = 1; // 0: 全部, 1: 居家
  String searchText = '';
  TextEditingController searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    tabCtr = TabController(
      length: tabs.length,
      vsync: this,
    );
    _loadActionsData();
  }
  
  Future<void> _loadActionsData() async {
    try {
      final String jsonString = await rootBundle.loadString('res/demo/actions_data.json');
      setState(() {
        actionsData = json.decode(jsonString);
      });
    } catch (e) {
      print('Error loading actions data: $e');
    }
  }

  _body() {
    return ListView(
      padding: EdgeInsets.all(0),
      children: <Widget>[
        Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  width: 16,
                  height: 44,
                ),
                Text(
                  '下午好，',
                  style: TextStyle(color: XMColor.lightGray, fontSize: 14),
                ),
                Text(
                  sportData['userInfo']['name'],
                  style: TextStyle(color: XMColor.lightGray, fontSize: 16),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.fromLTRB(18, 10, 0, 16),
              child: Row(
                children: <Widget>[
                  Image(
                    height: 18,
                    image: AssetImage('res/imgs/sport_set_goals.png'),
                    fit: BoxFit.fill,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    '订个目标 ，开始运动! ',
                    style: TextStyle(
                        color: XMColor.deepGray,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            dividerWidget(),
            ListTile(
                title: Text(
                  '已累计运动1862分钟',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Container(
                  width: xmDp(22).toDouble(),
                  height: xmDp(44).toDouble(),
                  child: Image(
                    image: AssetImage('res/imgs/comm_detail.png'),
                  ),
                ))
          ],
        ),
        _grayGap(),
        _myTeam(),
        _grayGap(),
        _myClass(),
        _grayGap(),
        _eventPromotion(),
      ],
    );
  }

  _eventPromotion() {
    Map secInfo = sportData['sections'][4];
    List promotions = secInfo['promotions'];
    return Column(
      children: <Widget>[
        _sectionView(secInfo['sectionName'], false),
        CarouselSlider(
          // viewportFraction: 1.0,
          // aspectRatio: 2.0,
          // autoPlay: false,
          // enlargeCenterPage: false,
          items: promotions.map((v) {
            var img = v['picture'];
            return new Builder(
              builder: (BuildContext context) {
                return Container(
                  padding: EdgeInsets.fromLTRB(
                      xmDp(30).toDouble(), xmDp(2).toDouble(), xmDp(30).toDouble(), xmDp(2).toDouble()),
                  child: ListView(
                    padding: EdgeInsets.all(0),
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      Container(
                        width: xmDp(xmSW() - 10 * 2).toDouble(),
                        child: ClipRRect(
                          child: CachedNetworkImage(
                            imageUrl: img,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        v['title'],
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Text(
                        v['text'],
                        style:
                            TextStyle(fontSize: 14, color: XMColor.lightGray),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
          options: CarouselOptions(
            height: 240.0,
            viewportFraction: 1.0,
            aspectRatio: 2.0,
            autoPlay: false,
            enlargeCenterPage: false,
          ),
          // height: 280.0,
        ),
        Container(
            width: Screen.width,
            height: 44,
            color: XMColor.bgGray,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('- 没有更多了 -',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: XMColor.deepGray)),
              ],
            ))
      ],
    );
  }

  _myClass() {
    Map sec3 = sportData['sections'][3];
    List cls = sec3['joinedCoursesV2'];

    return Column(
      children: <Widget>[
        _sectionView(sec3['sectionName'], true),
        Container(
          child: Column(
            children: cls.map((v) {
              var diffTime = RelativeDateFormat.format(
                  DateTime.parse(v['lastTrainingDate']));
              bool isVip = v['hasPlus'];
              return Column(
                children: <Widget>[
                  SizedBox(height: 15),
                  Container(
                    height: 24,
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 16,
                          height: 24,
                        ),
                        Text(
                          v['name'],
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        isVip
                            ? Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                    color: Color(0xffe9d399),
                                    borderRadius: BorderRadius.circular(3)),
                                child: Text(
                                  '会员精讲',
                                  style: TextStyle(fontSize: 10),
                                ),
                              )
                            : Text(''),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                '${v['averageDuration']} 分钟 · K${v['difficulty']}',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(
                                width: 16,
                                height: 48,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    height: 24,
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 16,
                        ),
                        Text(
                          '上次训练 $diffTime  ${v['liveUserCount']}人正在练',
                          style:
                              TextStyle(fontSize: 12, color: XMColor.lightGray),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                '已下载',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(
                                width: 16,
                                height: 48,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  dividerWidget(),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  _myTeam() {
    Map sec1 = sportData['sections'][1];
    Map squad = sec1['squad'];
    Map week = squad['week'];
    String des = '第 ${week['weekIndex']} 周：   ${week['introduction']}';
    List teams = squad['dynamicItems'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 50,
          child: ListTile(
              title: Text(
            sec1['sectionName'],
            style: TextStyle(
                fontSize: ScreenUtil().setSp(18), color: Colors.black),
          )),
        ),
        Container(
          width: Screen.width,
          padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                  image: NetworkImage(squad['picture']), fit: BoxFit.cover)),
          child: Column(
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
                title: Text(
                  squad['name'],
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(18), color: Colors.white),
                ),
                subtitle: Text(
                  des,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(14), color: Colors.white),
                ),
                trailing: Container(
                  width: 24,
                  height: 24,
                  child: Image.asset('res/imgs/explore_class_section_right.png',
                      fit: BoxFit.fill),
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white),
                child: ListView(
                  padding: EdgeInsets.all(0),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    _teamCell(week, 0),
                    dividerWidget(),
                    _teamCell(week, 1),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Container(
                width: Screen.width - 20 * 2,
                height: 50,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: <Widget>[
                    _finishedTeamers(teams)[0],
                    _finishedTeamers(teams)[1],
                    _finishedTeamers(teams)[2],
                    Positioned(
                      left: 80,
                      child: Container(
                        height: 30,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Image.asset(
                              'res/imgs/sport_punch.png',
                              fit: BoxFit.cover,
                            ),
                            Text(
                              '完成了今天全部打卡',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      child: InkWell(
                        onTap: () {
                          Toast.show('加油加油!');
                        },
                        child: Container(
                          height: 30,
                          child: Image.asset(
                            'res/imgs/sport_like.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }

  _teamCell(Map week, idx) {
    Map info = week['taskList'][idx];
    return InkWell(
      onTap: () {
        setState(() {
          String flag = info['flag'];
          info['flag'] = flag == '1' ? '0' : '1';
        });
      },
      child: Container(
        height: 60,
        child: Row(
          children: <Widget>[
            SizedBox(width: 20),
            Container(
              width: 20,
              height: 20,
              child: Image.asset('res/imgs/sport_check_${info['flag']}.png'),
            ),
            SizedBox(width: 20),
            Text(
              info['task']['title'],
              style: TextStyle(fontSize: 16),
            )
          ],
        ),
      ),
    );
  }

  _finishedTeamers(teams) {
    return teams.map((v) {
      double w = 30;
      int idx = teams.indexOf(v);
      double x = (w - 10) * (2 - idx.toDouble());
      return Positioned(
        left: x,
        width: w,
        height: w,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white,
                width: 2,
              )),
          child: CircleAvatar(
            backgroundImage: NetworkImage(v['avatar']),
            radius: 20,
          ),
        ),
      );
    }).toList();
  }

  _sectionView(title, bool showDetail) {
    return InkWell(
      onTap: () {
        setState(() {
          // widget.inde = 1;
        });
      },
      child: Row(
        children: <Widget>[
          SizedBox(
            width: xmDp(28).toDouble(),
            height: xmDp(56).toDouble(),
          ),
          Text(
            title,
            style: TextStyle(
                fontSize: ScreenUtil().setSp(18), color: XMColor.deepGray),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  child: showDetail
                      ? Container(
                          padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
                          decoration: BoxDecoration(
                              color: Color(0xff5fc48f),
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            '发现课程',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        )
                      : Text(''),
                ),
                SizedBox(
                  width: xmDp(28).toDouble(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _grayGap() {
    return Container(
      height: xmDp(22).toDouble(),
      color: XMColor.bgGray,
    );
  }

  Widget _tabBar() {
    return TabBar(
      isScrollable: true,
      controller: tabCtr,
      labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      unselectedLabelColor: XMColor.kgray,
      indicatorColor: XMColor.deepGray,
      labelColor: XMColor.darkGray,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorWeight: 2,
      dividerHeight: 0,
      indicatorPadding: EdgeInsets.fromLTRB(8, 0, 8, 5),
      tabs: tabs
          .map(
            (e) => Tab(text: e),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('运动',
            style: TextStyle(
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.w500)),
        bottom: PreferredSize(
          child: _tabBar(),
          preferredSize: Size(xmSW().toDouble(), 40),
        ),
        actions: <Widget>[
          Container(
            width: 35,
            height: 35,
            child: IconButton(
              icon: Image.asset('res/imgs/sport_nav_right_kxwy.png'),
              onPressed: () {
                Toast.show('创意工坊');
              },
            ),
          ),
          SizedBox(width: 10),
          Container(
            width: 35,
            height: 35,
            child: IconButton(
              icon: Image.asset('res/imgs/sport_nav_right_wristband.png'),
              onPressed: () {
                Toast.show('智能设备');
              },
            ),
          ),
          Container(
            width: 35,
            height: 35,
            child: IconButton(
              icon: Image.asset('res/imgs/sport_nav_right_search.png'),
              onPressed: () {
                Toast.show('搜索');
              },
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: TabBarView(
          controller: tabCtr,
          children: tabs
              .map(
                (e) {
                  if (e == '动作') {
                    return actionsPage();
                  }
                  return startNowPage();
                }
              )
              .toList()),
    );
  }

  Widget startNowPage() {
    return Container(
      color: Colors.white,
      child: _body(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    tabCtr.dispose();
  }

  Widget dividerWidget({double indent = 16}) {
    return Divider(
      indent: indent,
      height: 0.5,
      color: Colors.grey.shade200,
    );
  }

  Widget actionsPage() {
    if (actionsData.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // 顶部搜索栏和筛选
          _buildSearchAndFilterBar(),
          // 主体内容区域
          Expanded(
            child: Row(
              children: [
                // 左侧身体部位分类
                _buildBodyPartsList(),
                // 右侧内容区域
                Expanded(
                  child: Column(
                    children: [
                      // 器械分类
                      _buildEquipmentTabs(),
                      // 动作列表
                      Expanded(
                        child: _buildActionsList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// 搜索栏和筛选Tab
  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 搜索框
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: '输入动作',
                  hintStyle: TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Color(0xFFBBBBBB), size: 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          // 筛选Tab
          Container(
            height: 32,
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildFilterTabItem('全部', 0),
                _buildFilterTabItem('居家', 1),
              ],
            ),
          ),
          SizedBox(width: 12),
          // 添加按钮
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF333333), width: 1.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, size: 20, color: Color(0xFF333333)),
          ),
        ],
      ),
    );
  }
  
  /// 筛选Tab项
  Widget _buildFilterTabItem(String text, int index) {
    bool isSelected = selectedFilterTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilterTab = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ] : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Color(0xFF333333) : Color(0xFF999999),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  /// 左侧身体部位列表
  Widget _buildBodyPartsList() {
    List bodyParts = actionsData['bodyParts'] ?? [];
    
    return Container(
      width: 70,
      decoration: BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(
          right: BorderSide(color: Color(0xFFEEEEEE), width: 0.5),
        ),
      ),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: bodyParts.length,
        itemBuilder: (context, index) {
          Map part = bodyParts[index];
          bool isSelected = selectedBodyPart == part['id'];
          bool hasData = actionsData['actions']?[part['id']] != null;
          
          return GestureDetector(
            onTap: hasData ? () {
              setState(() {
                selectedBodyPart = part['id'];
              });
            } : null,
            child: Container(
              height: 44,
              child: Row(
                children: [
                  // 选中指示器
                  Container(
                    width: 3,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFF5FC48F) : Colors.transparent,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        part['name'],
                        style: TextStyle(
                          color: hasData 
                              ? (isSelected ? Color(0xFF333333) : Color(0xFF666666))
                              : Color(0xFFCCCCCC),
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  /// 器械分类Tab
  Widget _buildEquipmentTabs() {
    List equipment = actionsData['equipment'] ?? [];
    
    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 0.5),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemCount: equipment.length,
        itemBuilder: (context, index) {
          Map item = equipment[index];
          bool isSelected = selectedEquipment == item['id'];
          
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedEquipment = item['id'];
              });
            },
            child: Container(
              width: 70,
              margin: EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 图标容器
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFFD4E8FF) : Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: _buildEquipmentIcon(item['id'], isSelected),
                    ),
                  ),
                  SizedBox(height: 4),
                  // 器械名称
                  Text(
                    item['name'],
                    style: TextStyle(
                      color: isSelected ? Color(0xFF333333) : Color(0xFF666666),
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  /// 根据器械类型构建图标
  Widget _buildEquipmentIcon(String equipmentId, bool isSelected) {
    Color iconColor = isSelected ? Color(0xFF3D7CFF) : Color(0xFF5FC48F);
    
    switch (equipmentId) {
      case 'dumbbell':
        return Icon(Icons.fitness_center, color: iconColor, size: 22);
      case 'resistance_band':
        return Text('🎗', style: TextStyle(fontSize: 20));
      case 'kettlebell':
        return Text('🏋', style: TextStyle(fontSize: 18));
      case 'bodyweight':
        return Icon(Icons.accessibility_new, color: iconColor, size: 22);
      default:
        return Icon(Icons.sports, color: iconColor, size: 22);
    }
  }
  
  /// 动作列表
  Widget _buildActionsList() {
    Map? bodyPartActions = actionsData['actions']?[selectedBodyPart];
    if (bodyPartActions == null) {
      return Center(
        child: Text('暂无数据', style: TextStyle(color: Color(0xFF999999))),
      );
    }
    
    List<Widget> sections = [];
    
    // 置顶区域
    List pinnedActions = bodyPartActions['pinned'] ?? [];
    if (pinnedActions.isNotEmpty) {
      List filteredPinned = _filterActions(pinnedActions);
      if (filteredPinned.isNotEmpty) {
        sections.add(_buildActionSection('置顶', filteredPinned));
      }
    }
    
    // 当前选中器械的动作
    List equipmentActions = bodyPartActions[selectedEquipment] ?? [];
    if (equipmentActions.isNotEmpty) {
      List filteredEquipment = _filterActions(equipmentActions);
      if (filteredEquipment.isNotEmpty) {
        String equipmentName = _getEquipmentName(selectedEquipment);
        sections.add(_buildActionSection(equipmentName, filteredEquipment));
      }
    }
    
    if (sections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Color(0xFFCCCCCC)),
            SizedBox(height: 12),
            Text('没有找到相关动作', style: TextStyle(color: Color(0xFF999999))),
          ],
        ),
      );
    }
    
    return ListView(
      padding: EdgeInsets.all(12),
      children: sections,
    );
  }
  
  /// 筛选动作
  List _filterActions(List actions) {
    return actions.where((action) {
      // 居家筛选
      if (selectedFilterTab == 1 && action['isHome'] != true) {
        return false;
      }
      // 搜索筛选
      if (searchText.isNotEmpty) {
        String name = action['name'] ?? '';
        return name.toLowerCase().contains(searchText.toLowerCase());
      }
      return true;
    }).toList();
  }
  
  /// 获取器械名称
  String _getEquipmentName(String equipmentId) {
    List equipment = actionsData['equipment'] ?? [];
    for (var item in equipment) {
      if (item['id'] == equipmentId) {
        return item['name'];
      }
    }
    return equipmentId;
  }
  
  /// 构建动作区域
  Widget _buildActionSection(String title, List actions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title,
            style: TextStyle(
              color: Color(0xFF333333),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            return _buildActionCard(actions[index]);
          },
        ),
        SizedBox(height: 8),
      ],
    );
  }
  
  /// 构建动作卡片
  Widget _buildActionCard(Map action) {
    return GestureDetector(
      onTap: () {
        // 跳转到动作详情页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActionDetailPage(
              actionId: action['id'] ?? '',
              actionBasicInfo: Map<String, dynamic>.from(action),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Color(0xFFEEEEEE), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 动作图片
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                      child: CachedNetworkImage(
                        imageUrl: action['image'] ?? '',
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          color: Color(0xFFF5F5F5),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Color(0xFFF5F5F5),
                          child: Icon(Icons.fitness_center, color: Color(0xFFCCCCCC), size: 40),
                        ),
                      ),
                    ),
                  ),
                ),
                // 动作名称
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Text(
                    action['name'] ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            // HOT标签
            if (action['isHot'] == true)
              Positioned(
                left: 0,
                top: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Color(0xFF5FC48F),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    'HOT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

}
