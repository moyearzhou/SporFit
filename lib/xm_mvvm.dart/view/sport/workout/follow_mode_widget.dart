import 'package:flutter/material.dart';
import 'workout_model.dart';

/// 跟练模式组件 (动作设置页面)
class FollowModeWidget extends StatefulWidget {
  final WorkoutSession session;
  final VoidCallback onStartFollow;

  const FollowModeWidget({
    Key? key,
    required this.session,
    required this.onStartFollow,
  }) : super(key: key);

  @override
  State<FollowModeWidget> createState() => _FollowModeWidgetState();
}

class _FollowModeWidgetState extends State<FollowModeWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: widget.session.actions.isEmpty
              ? _buildEmptyView()
              : _buildActionsList(),
        ),
        _buildStartButton(),
      ],
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无训练动作',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方"加动作"添加训练动作',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.session.actions.length,
      itemBuilder: (context, index) {
        return _buildActionCard(widget.session.actions[index]);
      },
    );
  }

  Widget _buildActionCard(WorkoutAction action) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 动作名称
          Text(
            action.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          // 时间设置
          Row(
            children: [
              Expanded(
                child: _buildTimeSettingItem(
                  value: action.repInterval,
                  label: '动作次数间隔',
                  onTap: () => _showTimePickerDialog(
                    title: '动作次数间隔',
                    currentValue: action.repInterval,
                    onChanged: (value) {
                      setState(() {
                        action.repInterval = value;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: _buildTimeSettingItem(
                  value: action.setRestTime,
                  label: '组间休息时间',
                  onTap: () => _showTimePickerDialog(
                    title: '组间休息时间',
                    currentValue: action.setRestTime,
                    onChanged: (value) {
                      setState(() {
                        action.setRestTime = value;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: _buildTimeSettingItem(
                  value: action.actionInterval,
                  label: '与下个动作的间隔',
                  isHighlighted: true,
                  onTap: () => _showTimePickerDialog(
                    title: '与下个动作的间隔',
                    currentValue: action.actionInterval,
                    onChanged: (value) {
                      setState(() {
                        action.actionInterval = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSettingItem({
    required int value,
    required String label,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? const Color(0xFF333333)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: isHighlighted ? Colors.white : const Color(0xFF333333),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '秒',
                    style: TextStyle(
                      fontSize: 12,
                      color: isHighlighted
                          ? Colors.white.withOpacity(0.7)
                          : const Color(0xFF999999),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: GestureDetector(
        onTap: widget.onStartFollow,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF333333),
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: const Text(
            '开始跟练',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showTimePickerDialog({
    required String title,
    required int currentValue,
    required Function(int) onChanged,
  }) {
    int selectedValue = currentValue;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 顶部拖动条
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // 标题
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                // 时间选择器
                SizedBox(
                  height: 200,
                  child: ListWheelScrollView(
                    itemExtent: 50,
                    physics: const FixedExtentScrollPhysics(),
                    controller: FixedExtentScrollController(
                      initialItem: selectedValue,
                    ),
                    onSelectedItemChanged: (index) {
                      setSheetState(() {
                        selectedValue = index;
                      });
                    },
                    children: List.generate(181, (index) {
                      bool isSelected = index == selectedValue;
                      return Center(
                        child: Text(
                          '$index 秒',
                          style: TextStyle(
                            fontSize: isSelected ? 20 : 16,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFF333333)
                                : const Color(0xFF999999),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                // 确认按钮
                Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      onChanged(selectedValue);
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5FC48F),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '确定',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

