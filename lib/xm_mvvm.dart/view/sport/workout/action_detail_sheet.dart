import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../public.dart';

/// 动作详情底部弹窗
class ActionDetailSheet extends StatefulWidget {
  final String actionId;
  final String actionName;
  final String? actionImage;

  const ActionDetailSheet({
    Key? key,
    required this.actionId,
    required this.actionName,
    this.actionImage,
  }) : super(key: key);

  /// 显示动作详情弹窗
  static Future<void> show(
    BuildContext context, {
    required String actionId,
    required String actionName,
    String? actionImage,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ActionDetailSheet(
        actionId: actionId,
        actionName: actionName,
        actionImage: actionImage,
      ),
    );
  }

  @override
  State<ActionDetailSheet> createState() => _ActionDetailSheetState();
}

class _ActionDetailSheetState extends State<ActionDetailSheet> {
  Map<String, dynamic>? actionDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActionDetail();
  }

  Future<void> _loadActionDetail() async {
    try {
      final String jsonString =
          await rootBundle.loadString('res/demo/actions_data.json');
      final data = json.decode(jsonString);
      final details = data['actionDetails'] as Map<String, dynamic>?;

      setState(() {
        actionDetail = details?[widget.actionId];
        isLoading = false;
      });
    } catch (e) {
      print('Error loading action detail: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildContent(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              actionDetail?['name'] ?? widget.actionName,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, color: Color(0xFF666666), size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ScrollController scrollController) {
    if (actionDetail == null) {
      return _buildBasicContent(scrollController);
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // 动作图片
        _buildActionImage(),
        const SizedBox(height: 16),
        // 标签
        _buildTags(),
        const SizedBox(height: 16),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        const SizedBox(height: 16),
        // 操作步骤
        _buildStepsSection(),
        _buildDivider(),
        // 肌肉信息
        _buildMuscleSection(),
        _buildDivider(),
        // 技术要点
        _buildTipsSection(
          '技术要点',
          actionDetail!['tips'] ?? [],
          Icons.lightbulb_outline,
          const Color(0xFF5FC48F),
        ),
        _buildDivider(),
        // 常见错误
        _buildTipsSection(
          '常见错误',
          actionDetail!['commonMistakes'] ?? [],
          Icons.cancel_outlined,
          const Color(0xFFFF6B6B),
        ),
        _buildDivider(),
        // 安全提示
        _buildTipsSection(
          '安全提示',
          actionDetail!['safetyTips'] ?? [],
          Icons.security,
          const Color(0xFFFFB347),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildBasicContent(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // 动作图片
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: widget.actionImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: widget.actionImage!,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.fitness_center,
                      size: 64,
                      color: Color(0xFFCCCCCC),
                    ),
                  ),
                )
              : const Icon(
                  Icons.fitness_center,
                  size: 64,
                  color: Color(0xFFCCCCCC),
                ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            '暂无详细动作说明',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: actionDetail!['image'] ?? widget.actionImage ?? '',
          fit: BoxFit.contain,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          errorWidget: (context, url, error) => const Icon(
            Icons.fitness_center,
            size: 64,
            color: Color(0xFFCCCCCC),
          ),
        ),
      ),
    );
  }

  Widget _buildTags() {
    return Row(
      children: [
        // 器械标签
        if (actionDetail!['equipmentName'] != null)
          _buildTag(
            actionDetail!['equipmentName'],
            const Color(0xFFF0F0F0),
            const Color(0xFF666666),
          ),
        if (actionDetail!['equipmentName'] != null) const SizedBox(width: 8),
        // 部位标签
        if (actionDetail!['bodyPartName'] != null)
          _buildTag(
            actionDetail!['bodyPartName'],
            const Color(0xFFF0F0F0),
            const Color(0xFF666666),
          ),
        const Spacer(),
        // 备注按钮
        GestureDetector(
          onTap: () {
            Toast.show('添加备注');
          },
          child: Row(
            children: const [
              Icon(Icons.edit_note, size: 18, color: Color(0xFF999999)),
              SizedBox(width: 4),
              Text(
                '备注',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF999999),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: textColor),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 8,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFFF5F5F5),
    );
  }

  Widget _buildStepsSection() {
    final steps = actionDetail!['steps'] as Map<String, dynamic>?;
    if (steps == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('操作步骤', Icons.list_alt),
        const SizedBox(height: 16),
        _buildStepItem('准备姿势', steps['preparation'] ?? ''),
        _buildStepItem('起始姿势', steps['startPosition'] ?? ''),
        _buildStepItem('动作过程', steps['movement'] ?? ''),
        _buildStepItem('回程动作', steps['return'] ?? ''),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF5FC48F)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(String title, String content) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          ...content.split('\n').map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF999999),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        line.trim(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMuscleSection() {
    final primaryMuscles = actionDetail!['primaryMuscles'] as List? ?? [];
    final secondaryMuscles = actionDetail!['secondaryMuscles'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '主要肌肉',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 14, color: Color(0xFF999999)),
            const SizedBox(width: 8),
            const Text(
              '协同肌肉',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.visibility, size: 16, color: Color(0xFF5FC48F)),
                const SizedBox(width: 4),
                Text(
                  '${actionDetail!['likeCount'] ?? 0}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF5FC48F)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 肌肉图示
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.accessibility_new,
                  size: 100,
                  color: Color(0xFFDDDDDD),
                ),
              ),
              // 肌肉标签
              Positioned(
                left: 16,
                top: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '主要肌肉',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...primaryMuscles.map((muscle) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '· $muscle',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF666666),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                top: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '协同肌肉',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFB347),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...secondaryMuscles.map((muscle) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '$muscle ·',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF666666),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              // VIP提示
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFF333333).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        '开启Pro解锁更完美的数据权益',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection(
    String title,
    List tips,
    IconData icon,
    Color iconColor,
  ) {
    if (tips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip.toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

