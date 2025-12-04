import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../public.dart';
import 'workout_model.dart';
import 'record_mode_widget.dart';
import 'follow_mode_widget.dart';
import 'action_arrange_sheet.dart';
import 'action_picker_page.dart';

/// 跟练配置页面
class WorkoutConfigPage extends StatefulWidget {
  final Map<String, dynamic>? initialAction;

  const WorkoutConfigPage({
    Key? key,
    this.initialAction,
  }) : super(key: key);

  @override
  State<WorkoutConfigPage> createState() => _WorkoutConfigPageState();
}

class _WorkoutConfigPageState extends State<WorkoutConfigPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late WorkoutSession _session;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initSession();
  }

  void _initSession() {
    _session = WorkoutSession();
    // 如果有初始动作，添加到session
    if (widget.initialAction != null) {
      _session.addAction(WorkoutAction(
        id: widget.initialAction!['id'] ?? '',
        name: widget.initialAction!['name'] ?? '',
        image: widget.initialAction!['image'],
      ));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() {
      _isTimerRunning = !_isTimerRunning;
      if (_isTimerRunning) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _elapsedSeconds++;
          });
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _onAddAction() async {
    // 获取当前已有动作的ID列表
    List<String> existingIds = _session.actions.map((a) => a.id).toList();
    
    // 跳转到动作选择页面（多选模式）
    final result = await ActionPickerPage.show(
      context,
      mode: ActionPickerMode.multiple,
      initialSelectedIds: existingIds,
    );
    
    if (result != null && result.selectedActions.isNotEmpty) {
      setState(() {
        // 添加新选择的动作（排除已存在的）
        for (var actionData in result.selectedActions) {
          String actionId = actionData['id'] ?? '';
          if (!existingIds.contains(actionId)) {
            _session.addAction(WorkoutAction(
              id: actionId,
              name: actionData['name'] ?? '',
              image: actionData['image'],
            ));
          }
        }
      });
      
      int addedCount = result.selectedActions.length - existingIds.length;
      if (addedCount > 0) {
        Toast.show('已添加 $addedCount 个动作');
      }
    }
  }

  void _onArrangeActions() {
    if (_session.actions.isEmpty) {
      Toast.show('请先添加动作');
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ActionArrangeSheet(
        actions: _session.actions,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            _session.reorderAction(oldIndex, newIndex);
          });
        },
        onDelete: (index) {
          setState(() {
            _session.removeAction(index);
          });
        },
      ),
    );
  }

  void _onMinimize() {
    Toast.show('最小化');
    Navigator.pop(context);
  }

  void _onExperience() {
    Toast.show('体会');
  }

  void _onFinish() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('完成训练'),
        content: Text(
          '本次训练时长: ${_formatTime(_elapsedSeconds)}\n'
          '完成组数: ${_session.completedSets}/${_session.totalSets}\n'
          '总容量: ${_session.totalVolume.toStringAsFixed(1)} kg',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('继续训练'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 关闭对话框
              Navigator.pop(context); // 返回上一页
            },
            child: const Text('确认完成'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildSummaryBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  RecordModeWidget(
                    session: _session,
                    onSessionChanged: () => setState(() {}),
                  ),
                  FollowModeWidget(
                    session: _session,
                    onStartFollow: _startFollowTraining,
                  ),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          // 记录/跟练 Tab
          Container(
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TabBar(
              controller: _tabController,
              dividerHeight: 0,
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    // offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: const Color(0xFF333333),
              unselectedLabelColor: const Color(0xFF999999),
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
              tabs: const [
                Tab(text: '记录'),
                Tab(text: '跟练'),
              ],
              labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),
          const Spacer(),
          // 计时器
          GestureDetector(
            onTap: _toggleTimer,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isTimerRunning ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(_elapsedSeconds),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 完成按钮
          GestureDetector(
            onTap: _onFinish,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF5FC48F),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '完成',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    String actionNames = _session.actions.isEmpty
        ? '暂无动作'
        : _session.actions.map((a) => a.name).join('、');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.edit, size: 16, color: Color(0xFF5FC48F)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              actionNames,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF333333),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${_session.totalSets} 组',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${_session.totalActions} 动作',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${_session.totalVolume.toStringAsFixed(0)} 容量',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomButton(
            icon: Icons.remove_circle_outline_outlined,
            label: '最小化',
            onTap: _onMinimize,
          ),
          _buildBottomButton(
            icon: Icons.lightbulb_outline,
            label: '体会',
            onTap: _onExperience,
          ),
          _buildBottomButton(
            icon: Icons.add_circle_outline,
            label: '加动作',
            onTap: _onAddAction,
          ),
          _buildBottomButton(
            icon: Icons.swap_vert,
            label: '动作编排',
            onTap: _onArrangeActions,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: const Color(0xFF333333)),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  void _startFollowTraining() {
    if (_session.actions.isEmpty) {
      Toast.show('请先添加动作');
      return;
    }
    Toast.show('开始跟练');
    // TODO: 进入跟练执行页面
  }
}

