import 'package:flutter/material.dart';
import '../../../../public.dart';
import 'workout_model.dart';

/// 动作编排弹窗 - 支持拖拽排序
class ActionArrangeSheet extends StatefulWidget {
  final List<WorkoutAction> actions;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(int index) onDelete;

  const ActionArrangeSheet({
    Key? key,
    required this.actions,
    required this.onReorder,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<ActionArrangeSheet> createState() => _ActionArrangeSheetState();
}

class _ActionArrangeSheetState extends State<ActionArrangeSheet> {
  late List<WorkoutAction> _localActions;

  @override
  void initState() {
    super.initState();
    _localActions = List.from(widget.actions);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _localActions.isEmpty
                ? _buildEmptyView()
                : _buildReorderableList(),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, color: Color(0xFF666666)),
          ),
          const Expanded(
            child: Center(
              child: Text(
                '动作编排',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24), // 平衡关闭按钮的宽度
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 48,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无动作',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReorderableList() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _localActions.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final action = _localActions.removeAt(oldIndex);
          _localActions.insert(newIndex, action);
        });
        widget.onReorder(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        return _buildActionItem(_localActions[index], index);
      },
    );
  }

  Widget _buildActionItem(WorkoutAction action, int index) {
    return Container(
      key: ValueKey(action.id),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖动手柄
            ReorderableDragStartListener(
              index: index,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.drag_handle,
                  color: Color(0xFF999999),
                ),
              ),
            ),
            const SizedBox(width: 8),
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
          ],
        ),
        title: Text(
          action.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Text(
          '${action.totalSets} 组',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF999999),
          ),
        ),
        trailing: GestureDetector(
          onTap: () => _showDeleteConfirm(index),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.delete_outline,
              color: Color(0xFFFF6B6B),
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Text(
            '长按拖动调整动作顺序',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除动作'),
        content: Text('确定要删除 "${_localActions[index].name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _localActions.removeAt(index);
              });
              widget.onDelete(index);
            },
            child: const Text(
              '删除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

