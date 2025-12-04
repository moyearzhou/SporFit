import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../public.dart';

/// 动作选择模式
enum ActionPickerMode {
  single, // 单选
  multiple, // 多选
}

/// 动作选择结果
class ActionPickerResult {
  final List<Map<String, dynamic>> selectedActions;
  
  ActionPickerResult({required this.selectedActions});
}

/// 通用动作选择页面
/// 支持单选和多选模式
class ActionPickerPage extends StatefulWidget {
  final ActionPickerMode mode;
  final List<String>? initialSelectedIds; // 初始选中的动作ID
  final int? maxSelectCount; // 最大选择数量，null表示不限制
  final String? title; // 自定义标题

  const ActionPickerPage({
    Key? key,
    this.mode = ActionPickerMode.multiple,
    this.initialSelectedIds,
    this.maxSelectCount,
    this.title,
  }) : super(key: key);

  /// 静态方法：打开动作选择页面
  static Future<ActionPickerResult?> show(
    BuildContext context, {
    ActionPickerMode mode = ActionPickerMode.multiple,
    List<String>? initialSelectedIds,
    int? maxSelectCount,
    String? title,
  }) async {
    return await Navigator.push<ActionPickerResult>(
      context,
      MaterialPageRoute(
        builder: (context) => ActionPickerPage(
          mode: mode,
          initialSelectedIds: initialSelectedIds,
          maxSelectCount: maxSelectCount,
          title: title,
        ),
      ),
    );
  }

  @override
  State<ActionPickerPage> createState() => _ActionPickerPageState();
}

class _ActionPickerPageState extends State<ActionPickerPage> {
  Map<String, dynamic> actionsData = {};
  String selectedBodyPart = 'chest';
  String selectedEquipment = 'dumbbell';
  int selectedFilterTab = 0; // 0: 全部, 1: 居家
  String searchText = '';
  TextEditingController searchController = TextEditingController();
  
  // 选中的动作列表 - 保持选择顺序
  List<Map<String, dynamic>> selectedActions = [];
  
  @override
  void initState() {
    super.initState();
    _loadActionsData();
  }
  
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadActionsData() async {
    try {
      final String jsonString = await rootBundle.loadString('res/demo/actions_data.json');
      setState(() {
        actionsData = json.decode(jsonString);
        // 初始化已选动作
        if (widget.initialSelectedIds != null && widget.initialSelectedIds!.isNotEmpty) {
          _initSelectedActions();
        }
      });
    } catch (e) {
      print('Error loading actions data: $e');
    }
  }
  
  void _initSelectedActions() {
    // 从数据中查找初始选中的动作
    if (actionsData['actions'] == null) return;
    
    for (String actionId in widget.initialSelectedIds!) {
      Map<String, dynamic>? action = _findActionById(actionId);
      if (action != null) {
        selectedActions.add(action);
      }
    }
  }
  
  Map<String, dynamic>? _findActionById(String actionId) {
    Map actions = actionsData['actions'] ?? {};
    for (var bodyPartActions in actions.values) {
      if (bodyPartActions is Map) {
        for (var equipmentActions in bodyPartActions.values) {
          if (equipmentActions is List) {
            for (var action in equipmentActions) {
              if (action['id'] == actionId) {
                return Map<String, dynamic>.from(action);
              }
            }
          }
        }
      }
    }
    return null;
  }
  
  bool _isSelected(String actionId) {
    return selectedActions.any((a) => a['id'] == actionId);
  }
  
  int _getSelectionOrder(String actionId) {
    int index = selectedActions.indexWhere((a) => a['id'] == actionId);
    return index >= 0 ? index + 1 : 0;
  }
  
  void _toggleSelection(Map<String, dynamic> action) {
    String actionId = action['id'];
    
    if (widget.mode == ActionPickerMode.single) {
      // 单选模式：直接返回结果
      Navigator.pop(context, ActionPickerResult(
        selectedActions: [Map<String, dynamic>.from(action)],
      ));
      return;
    }
    
    // 多选模式
    setState(() {
      if (_isSelected(actionId)) {
        selectedActions.removeWhere((a) => a['id'] == actionId);
      } else {
        // 检查是否超过最大选择数量
        if (widget.maxSelectCount != null && 
            selectedActions.length >= widget.maxSelectCount!) {
          Toast.show('最多选择 ${widget.maxSelectCount} 个动作');
          return;
        }
        selectedActions.add(Map<String, dynamic>.from(action));
      }
    });
  }
  
  void _onConfirm() {
    if (selectedActions.isEmpty) {
      Toast.show('请至少选择一个动作');
      return;
    }
    Navigator.pop(context, ActionPickerResult(selectedActions: selectedActions));
  }

  @override
  Widget build(BuildContext context) {
    if (actionsData.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
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
          // 底部确认栏（多选模式）
          if (widget.mode == ActionPickerMode.multiple)
            _buildBottomBar(),
        ],
      ),
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF333333), size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.title ?? (widget.mode == ActionPickerMode.single ? '选择动作' : '添加动作'),
        style: const TextStyle(
          color: Color(0xFF333333),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }
  
  /// 搜索栏和筛选Tab
  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 搜索框
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
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
                decoration: const InputDecoration(
                  hintText: '输入动作',
                  hintStyle: TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Color(0xFFBBBBBB), size: 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 筛选Tab
          Container(
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildFilterTabItem('全部', 0),
                _buildFilterTabItem('居家', 1),
              ],
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ] : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? const Color(0xFF333333) : const Color(0xFF999999),
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
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(
          right: BorderSide(color: Color(0xFFEEEEEE), width: 0.5),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
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
                      color: isSelected ? const Color(0xFF5FC48F) : Colors.transparent,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        part['name'],
                        style: TextStyle(
                          color: hasData 
                              ? (isSelected ? const Color(0xFF333333) : const Color(0xFF666666))
                              : const Color(0xFFCCCCCC),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 0.5),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
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
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 图标容器
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFD4E8FF) : const Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: _buildEquipmentIcon(item['id'], isSelected),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 器械名称
                  Text(
                    item['name'],
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF333333) : const Color(0xFF666666),
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
    Color iconColor = isSelected ? const Color(0xFF3D7CFF) : const Color(0xFF5FC48F);
    
    switch (equipmentId) {
      case 'dumbbell':
        return Icon(Icons.fitness_center, color: iconColor, size: 22);
      case 'resistance_band':
        return const Text('🎗', style: TextStyle(fontSize: 20));
      case 'kettlebell':
        return const Text('🏋', style: TextStyle(fontSize: 18));
      case 'bodyweight':
        return Icon(Icons.accessibility_new, color: iconColor, size: 22);
      case 'barbell':
        return Icon(Icons.fitness_center, color: iconColor, size: 22);
      default:
        return Icon(Icons.sports, color: iconColor, size: 22);
    }
  }
  
  /// 动作列表
  Widget _buildActionsList() {
    Map? bodyPartActions = actionsData['actions']?[selectedBodyPart];
    if (bodyPartActions == null) {
      return const Center(
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
          children: const [
            Icon(Icons.search_off, size: 48, color: Color(0xFFCCCCCC)),
            SizedBox(height: 12),
            Text('没有找到相关动作', style: TextStyle(color: Color(0xFF999999))),
          ],
        ),
      );
    }
    
    return ListView(
      padding: const EdgeInsets.all(12),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
        const SizedBox(height: 8),
      ],
    );
  }
  
  /// 构建动作卡片
  Widget _buildActionCard(Map action) {
    String actionId = action['id'] ?? '';
    bool isSelected = _isSelected(actionId);
    int order = _getSelectionOrder(actionId);
    
    return GestureDetector(
      onTap: () => _toggleSelection(Map<String, dynamic>.from(action)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF5FC48F) : const Color(0xFFEEEEEE),
            width: isSelected ? 2 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      child: CachedNetworkImage(
                        imageUrl: action['image'] ?? '',
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          color: const Color(0xFFF5F5F5),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: const Color(0xFFF5F5F5),
                          child: const Icon(Icons.fitness_center, color: Color(0xFFCCCCCC), size: 40),
                        ),
                      ),
                    ),
                  ),
                ),
                // 动作名称
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Text(
                    action['name'] ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            // 选中序号角标
            if (isSelected && widget.mode == ActionPickerMode.multiple)
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFF5FC48F),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$order',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  /// 底部确认栏
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 已选数量
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '已选',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${selectedActions.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5FC48F),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 下一步按钮
          Expanded(
            child: GestureDetector(
              onTap: _onConfirm,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: selectedActions.isNotEmpty 
                      ? const Color(0xFF5FC48F) 
                      : const Color(0xFFCCCCCC),
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      '下一步',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

