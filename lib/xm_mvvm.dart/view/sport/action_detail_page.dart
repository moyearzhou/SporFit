import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../public.dart';
import 'workout/workout_config_page.dart';

/// 动作详情页面
class ActionDetailPage extends StatefulWidget {
  final String actionId;
  final Map<String, dynamic>? actionBasicInfo;

  const ActionDetailPage({
    Key? key,
    required this.actionId,
    this.actionBasicInfo,
  }) : super(key: key);

  @override
  State<ActionDetailPage> createState() => _ActionDetailPageState();
}

class _ActionDetailPageState extends State<ActionDetailPage> {
  Map<String, dynamic>? actionDetail;
  bool isLoading = true;
  bool isFavorite = false;
  bool isLiked = false;
  int likeCount = 0;

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
        if (actionDetail != null) {
          isFavorite = actionDetail!['isFavorite'] ?? false;
          likeCount = actionDetail!['likeCount'] ?? 0;
        }
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : actionDetail == null
              ? _buildNoDataView()
              : _buildContent(),
      bottomNavigationBar: actionDetail != null ? _buildBottomBar() : null,
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 64, color: Color(0xFFCCCCCC)),
          SizedBox(height: 16),
          Text('暂无动作详情数据', style: TextStyle(color: Color(0xFF999999))),
          SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('返回'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        // 自定义AppBar
        _buildSliverAppBar(),
        // 内容区域
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 动作图片
              _buildActionImage(),
              // 标签和收藏
              _buildTagsAndFavorite(),
              Divider(height: 1, color: Color(0xFFEEEEEE)),
              // 操作步骤
              _buildStepsSection(),
              _buildDivider(),
              // 肌肉信息
              _buildMuscleSection(),
              _buildDivider(),
              // 技术要点
              _buildTipsSection('技术要点', actionDetail!['tips'] ?? [], Icons.lightbulb_outline, Color(0xFF5FC48F)),
              _buildDivider(),
              // 常见错误
              _buildTipsSection('常见错误', actionDetail!['commonMistakes'] ?? [], Icons.cancel_outlined, Color(0xFFFF6B6B)),
              _buildDivider(),
              // 安全提示
              _buildTipsSection('安全提示', actionDetail!['safetyTips'] ?? [], Icons.security, Color(0xFFFFB347)),
              _buildDivider(),
              // 平替动作
              _buildAlternativeActions(),
              SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Color(0xFF333333), size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        actionDetail!['name'] ?? '',
        style: TextStyle(
          color: Color(0xFF333333),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Color(0xFFFF6B6B) : Color(0xFF333333),
            size: 24,
          ),
          onPressed: () {
            setState(() {
              isLiked = !isLiked;
              likeCount += isLiked ? 1 : -1;
            });
            Toast.show(isLiked ? '已点赞' : '已取消点赞');
          },
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildActionImage() {
    return Container(
      width: double.infinity,
      height: 280,
      color: Color(0xFFF8F8F8),
      child: CachedNetworkImage(
        imageUrl: actionDetail!['image'] ?? '',
        fit: BoxFit.contain,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (context, url, error) => Icon(
          Icons.fitness_center,
          size: 80,
          color: Color(0xFFCCCCCC),
        ),
      ),
    );
  }

  Widget _buildTagsAndFavorite() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 器械标签
          _buildTag(
            actionDetail!['equipmentName'] ?? '',
            Color(0xFFF0F0F0),
            Color(0xFF666666),
          ),
          SizedBox(width: 8),
          // 部位标签
          _buildTag(
            actionDetail!['bodyPartName'] ?? '',
            Color(0xFFF0F0F0),
            Color(0xFF666666),
          ),
          Spacer(),
          // 收藏按钮
          GestureDetector(
            onTap: () {
              setState(() {
                isFavorite = !isFavorite;
              });
              Toast.show(isFavorite ? '已收藏' : '已取消收藏');
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isFavorite ? Color(0xFF5FC48F) : Color(0xFFDDDDDD),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    size: 16,
                    color: isFavorite ? Color(0xFF5FC48F) : Color(0xFF999999),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '收藏',
                    style: TextStyle(
                      fontSize: 12,
                      color: isFavorite ? Color(0xFF5FC48F) : Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
      color: Color(0xFFF5F5F5),
    );
  }

  Widget _buildStepsSection() {
    final steps = actionDetail!['steps'] as Map<String, dynamic>?;
    if (steps == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('操作步骤', Icons.list_alt),
          SizedBox(height: 16),
          _buildStepItem('准备姿势', steps['preparation'] ?? ''),
          _buildStepItem('起始姿势', steps['startPosition'] ?? ''),
          _buildStepItem('动作过程', steps['movement'] ?? ''),
          _buildStepItem('回程动作', steps['return'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Color(0xFF5FC48F)),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(String title, String content) {
    if (content.isEmpty) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 8),
          ...content.split('\n').map((line) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 6),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Color(0xFF999999),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        line.trim(),
                        style: TextStyle(
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

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '主要肌肉',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 14, color: Color(0xFF999999)),
              SizedBox(width: 8),
              Text(
                '协同肌肉',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 14, color: Color(0xFF999999)),
              Spacer(),
              GestureDetector(
                onTap: () {
                  Toast.show('查看肌肉详情');
                },
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 16, color: Color(0xFF5FC48F)),
                    SizedBox(width: 4),
                    Text(
                      '$likeCount',
                      style: TextStyle(fontSize: 12, color: Color(0xFF5FC48F)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // 肌肉图示
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.accessibility_new,
                    size: 120,
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
                      Text(
                        '主要肌肉',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF6B6B),
                        ),
                      ),
                      SizedBox(height: 4),
                      ...primaryMuscles.map((muscle) => Padding(
                            padding: EdgeInsets.only(bottom: 2),
                            child: Text(
                              '· $muscle',
                              style: TextStyle(
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
                      Text(
                        '协同肌肉',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFB347),
                        ),
                      ),
                      SizedBox(height: 4),
                      ...secondaryMuscles.map((muscle) => Padding(
                            padding: EdgeInsets.only(bottom: 2),
                            child: Text(
                              '$muscle ·',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF666666),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                // VIP提示（暂时正常显示）
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xFF333333).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(8),
                      ),
                    ),
                    child: Row(
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
      ),
    );
  }

  Widget _buildTipsSection(String title, List tips, IconData icon, Color iconColor) {
    if (tips.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...tips.map((tip) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 6),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: iconColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip.toString(),
                        style: TextStyle(
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

  Widget _buildAlternativeActions() {
    final alternatives = actionDetail!['alternativeActions'] as List? ?? [];
    if (alternatives.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '平替动作',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: alternatives.length,
            itemBuilder: (context, index) {
              final action = alternatives[index] as Map<String, dynamic>;
              return _buildAlternativeCard(action);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeCard(Map<String, dynamic> action) {
    return GestureDetector(
      onTap: () {
        // 跳转到另一个动作详情
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ActionDetailPage(
              actionId: action['id'] ?? '',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Color(0xFFEEEEEE)),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8),
                    child: CachedNetworkImage(
                      imageUrl: action['image'] ?? '',
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.fitness_center,
                        color: Color(0xFFCCCCCC),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Text(
                    action['name'] ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
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
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Color(0xFF5FC48F),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    'HOT',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
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
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () {
            // 使用统一路由跳转到跟练配置页面
            xmPush(WorkoutConfigPage(
              initialAction: {
                'id': widget.actionId,
                'name': actionDetail!['name'],
                'image': actionDetail!['image'],
              },
            ));
          },
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Color(0xFF5FC48F),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                '练一练',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

