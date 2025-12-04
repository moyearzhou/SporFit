import 'package:flutter/material.dart';
import '../../../../public.dart';
import 'workout_model.dart';

/// 记录模式组件
class RecordModeWidget extends StatefulWidget {
  final WorkoutSession session;
  final VoidCallback onSessionChanged;

  const RecordModeWidget({
    Key? key,
    required this.session,
    required this.onSessionChanged,
  }) : super(key: key);

  @override
  State<RecordModeWidget> createState() => _RecordModeWidgetState();
}

class _RecordModeWidgetState extends State<RecordModeWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.session.actions.isEmpty) {
      return _buildEmptyView();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.session.actions.length,
      itemBuilder: (context, index) {
        return _buildActionCard(widget.session.actions[index], index);
      },
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

  Widget _buildActionCard(WorkoutAction action, int actionIndex) {
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
      child: Column(
        children: [
          // 动作头部
          _buildActionHeader(action, actionIndex),
          // 组数列表
          ...action.sets.asMap().entries.map((entry) {
            return _buildSetRow(action, entry.key, entry.value);
          }),
          // 难度选择
          _buildDifficultySelector(action),
          // 底部操作
          _buildActionFooter(action),
        ],
      ),
    );
  }

  Widget _buildActionHeader(WorkoutAction action, int actionIndex) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 序号
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${actionIndex + 1}'.padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5FC48F),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 动作图片
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: action.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: action.image!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Icon(
                        Icons.fitness_center,
                        color: Color(0xFFCCCCCC),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.fitness_center,
                        color: Color(0xFFCCCCCC),
                      ),
                    ),
                  )
                : const Icon(
                    Icons.fitness_center,
                    color: Color(0xFFCCCCCC),
                  ),
          ),
          const SizedBox(width: 12),
          // 动作名称和备注
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      action.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${action.completedSets}/${action.totalSets}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _showNoteDialog(action),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.edit_note,
                        size: 14,
                        color: Color(0xFF999999),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        action.note ?? '点击图标输入备注',
                        style: TextStyle(
                          fontSize: 12,
                          color: action.note != null
                              ? const Color(0xFF666666)
                              : const Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 设置按钮
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF666666)),
            onPressed: () => _showActionSettings(action),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(WorkoutAction action, int setIndex, WorkoutSet set) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 组号
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text(
              '${setIndex + 1}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 重量输入
          Expanded(
            child: _buildInputField(
              value: set.weight,
              unit: 'kg',
              onChanged: (value) {
                setState(() {
                  set.weight = value;
                });
                widget.onSessionChanged();
              },
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'X',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(width: 8),
          // 次数输入
          Expanded(
            child: _buildInputField(
              value: set.reps.toDouble(),
              unit: '次',
              onChanged: (value) {
                setState(() {
                  set.reps = value.toInt();
                });
                widget.onSessionChanged();
              },
            ),
          ),
          const SizedBox(width: 12),
          // 完成勾选
          GestureDetector(
            onTap: () {
              setState(() {
                set.isCompleted = !set.isCompleted;
              });
              widget.onSessionChanged();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: set.isCompleted
                    ? const Color(0xFF5FC48F)
                    : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.check,
                color: set.isCompleted ? Colors.white : const Color(0xFFCCCCCC),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 更多操作
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF666666)),
            onSelected: (value) {
              if (value == 'delete') {
                setState(() {
                  action.removeSet(setIndex);
                });
                widget.onSessionChanged();
              } else if (value == 'copy') {
                setState(() {
                  action.sets.insert(
                    setIndex + 1,
                    WorkoutSet(
                      setIndex: setIndex + 2,
                      weight: set.weight,
                      reps: set.reps,
                    ),
                  );
                  // 重新编号
                  for (int i = 0; i < action.sets.length; i++) {
                    action.sets[i].setIndex = i + 1;
                  }
                });
                widget.onSessionChanged();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 18),
                    SizedBox(width: 8),
                    Text('复制这组'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('删除这组', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required double value,
    required String unit,
    required Function(double) onChanged,
  }) {
    return GestureDetector(
      onTap: () => _showNumberInputDialog(value, unit, onChanged),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              unit == '次' ? value.toInt().toString() : value.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySelector(WorkoutAction action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDifficultyChip(action, 0, '😊', '简单'),
          const SizedBox(width: 24),
          _buildDifficultyChip(action, 1, '😐', '正常'),
          const SizedBox(width: 24),
          _buildDifficultyChip(action, 2, '😓', '困难'),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(
    WorkoutAction action,
    int difficulty,
    String emoji,
    String label,
  ) {
    bool isSelected = action.difficulty == difficulty;
    return GestureDetector(
      onTap: () {
        setState(() {
          action.difficulty = difficulty;
        });
        widget.onSessionChanged();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF5FC48F) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected
                    ? const Color(0xFF5FC48F)
                    : const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionFooter(WorkoutAction action) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                action.addSet();
              });
              widget.onSessionChanged();
            },
            child: Row(
              children: const [
                Icon(Icons.add_circle_outline,
                    size: 20, color: Color(0xFF5FC48F)),
                SizedBox(width: 4),
                Text(
                  '新增一组',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5FC48F),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Toast.show('查看动作历史');
            },
            child: Row(
              children: const [
                Icon(Icons.history, size: 20, color: Color(0xFF666666)),
                SizedBox(width: 4),
                Text(
                  '动作历史',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNoteDialog(WorkoutAction action) {
    final controller = TextEditingController(text: action.note);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加备注'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '输入备注内容',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                action.note = controller.text.isEmpty ? null : controller.text;
              });
              widget.onSessionChanged();
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showNumberInputDialog(
    double currentValue,
    String unit,
    Function(double) onChanged,
  ) {
    final controller = TextEditingController(
      text: unit == '次'
          ? currentValue.toInt().toString()
          : currentValue.toStringAsFixed(1),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('输入$unit'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            suffixText: unit,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text) ?? currentValue;
              onChanged(value);
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showActionSettings(WorkoutAction action) {
    Toast.show('动作设置: ${action.name}');
  }
}

