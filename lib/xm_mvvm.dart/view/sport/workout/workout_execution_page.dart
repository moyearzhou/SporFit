import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../public.dart';
import 'workout_model.dart';
import 'workout_audio_service.dart';
import 'action_detail_sheet.dart';

/// 跟练执行状态
enum ExecutionState {
  preparing, // 准备中
  exercising, // 运动中
  resting, // 休息中
  paused, // 暂停
  completed, // 完成
}

/// 跟练执行页面
class WorkoutExecutionPage extends StatefulWidget {
  final WorkoutSession session;

  const WorkoutExecutionPage({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  State<WorkoutExecutionPage> createState() => _WorkoutExecutionPageState();
}

class _WorkoutExecutionPageState extends State<WorkoutExecutionPage>
    with TickerProviderStateMixin {
  final WorkoutAudioService _audioService = WorkoutAudioService();
  
  // 当前状态
  ExecutionState _state = ExecutionState.preparing;
  int _currentActionIndex = 0;
  int _currentSetIndex = 0;
  int _currentRep = 0;
  
  // 计时器
  Timer? _timer;
  int _elapsedSeconds = 0; // 总训练时长
  int _countdownSeconds = 0; // 倒计时秒数
  
  // 动画控制
  late AnimationController _progressController;
  
  // 是否已初始化
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _initializeWorkout();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _audioService.stopMusic();
    super.dispose();
  }
  
  Future<void> _initializeWorkout() async {
    await _audioService.init();
    await _audioService.playMusic();
    
    setState(() {
      _isInitialized = true;
      _state = ExecutionState.exercising;
    });
    
    // 播报第一个动作
    _speakCurrentAction();
    _startExerciseTimer();
  }
  
  WorkoutAction get _currentAction => widget.session.actions[_currentActionIndex];
  WorkoutSet get _currentSet => _currentAction.sets[_currentSetIndex];
  int get _totalActions => widget.session.actions.length;
  int get _totalReps => _currentSet.reps;
  
  /// 开始运动计时
  void _startExerciseTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state == ExecutionState.exercising) {
        setState(() {
          _elapsedSeconds++;
          
          // 自动增加次数（根据次数间隔）
          if (_elapsedSeconds % _currentAction.repInterval == 0 && 
              _currentRep < _totalReps) {
            _currentRep++;
            _audioService.speakRepCount(_currentRep);
            
            // 完成一组
            if (_currentRep >= _totalReps) {
              _onSetComplete();
            }
          }
        });
      } else if (_state == ExecutionState.resting) {
        setState(() {
          _countdownSeconds--;
          
          // 倒计时播报
          if (_countdownSeconds <= 3 && _countdownSeconds > 0) {
            _audioService.speakCountdown(_countdownSeconds);
          }
          
          // 休息结束
          if (_countdownSeconds <= 0) {
            _onRestComplete();
          }
        });
      }
    });
  }
  
  /// 播报当前动作
  void _speakCurrentAction() {
    _audioService.speakActionName(_currentAction.name);
    _audioService.speak(VoiceType.setStart, number: _currentSetIndex + 1);
  }
  
  /// 完成一组
  void _onSetComplete() {
    _audioService.speak(VoiceType.setComplete, number: _currentSetIndex + 1);
    _audioService.playCompleteSound();
    
    _currentSet.isCompleted = true;
    
    // 判断是否还有下一组
    if (_currentSetIndex < _currentAction.sets.length - 1) {
      // 进入组间休息
      _startRestTimer(_currentAction.setRestTime);
    } else {
      // 判断是否还有下一个动作
      if (_currentActionIndex < _totalActions - 1) {
        // 进入动作间休息
        _startRestTimer(_currentAction.actionInterval);
      } else {
        // 训练完成
        _onWorkoutComplete();
      }
    }
  }
  
  /// 开始休息计时
  void _startRestTimer(int seconds) {
    setState(() {
      _state = ExecutionState.resting;
      _countdownSeconds = seconds;
    });
    _audioService.speak(VoiceType.restStart, number: seconds);
  }
  
  /// 休息结束
  void _onRestComplete() {
    _audioService.speak(VoiceType.restEnd);
    
    setState(() {
      _currentRep = 0;
      
      // 判断下一步
      if (_currentSetIndex < _currentAction.sets.length - 1) {
        // 下一组
        _currentSetIndex++;
      } else if (_currentActionIndex < _totalActions - 1) {
        // 下一个动作
        _currentActionIndex++;
        _currentSetIndex = 0;
      }
      
      _state = ExecutionState.exercising;
    });
    
    _speakCurrentAction();
  }
  
  /// 训练完成
  void _onWorkoutComplete() {
    _timer?.cancel();
    _audioService.speak(VoiceType.workoutComplete);
    _audioService.stopMusic();
    
    setState(() {
      _state = ExecutionState.completed;
    });
    
    // 显示完成对话框
    _showCompleteDialog();
  }
  
  /// 暂停/继续
  void _togglePause() {
    if (_state == ExecutionState.completed) return;
    
    setState(() {
      if (_state == ExecutionState.paused) {
        _state = ExecutionState.exercising;
        _audioService.resumeMusic();
      } else {
        _state = ExecutionState.paused;
        _audioService.pauseMusic();
      }
    });
  }
  
  /// 上一个动作/组
  void _previousAction() {
    if (_currentSetIndex > 0) {
      setState(() {
        _currentSetIndex--;
        _currentRep = 0;
      });
    } else if (_currentActionIndex > 0) {
      setState(() {
        _currentActionIndex--;
        _currentSetIndex = _currentAction.sets.length - 1;
        _currentRep = 0;
      });
    }
    _speakCurrentAction();
  }
  
  /// 下一个动作/组
  void _nextAction() {
    if (_currentSetIndex < _currentAction.sets.length - 1) {
      setState(() {
        _currentSetIndex++;
        _currentRep = 0;
      });
      _speakCurrentAction();
    } else if (_currentActionIndex < _totalActions - 1) {
      setState(() {
        _currentActionIndex++;
        _currentSetIndex = 0;
        _currentRep = 0;
      });
      _speakCurrentAction();
    } else {
      _onWorkoutComplete();
    }
  }
  
  /// 手动增加次数
  void _incrementRep() {
    if (_currentRep < _totalReps) {
      setState(() {
        _currentRep++;
      });
      _audioService.speakRepCount(_currentRep);
      
      if (_currentRep >= _totalReps) {
        _onSetComplete();
      }
    }
  }
  
  /// 返回/退出确认
  Future<bool> _onWillPop() async {
    if (_state == ExecutionState.completed) {
      return true;
    }
    
    // 暂停训练
    if (_state == ExecutionState.exercising || _state == ExecutionState.resting) {
      setState(() {
        _state = ExecutionState.paused;
      });
      _audioService.pauseMusic();
    }
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '退出训练',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          '训练尚未完成，确定要退出吗？\n退出后本次训练记录将不会保存。',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
              // 恢复训练
              setState(() {
                _state = ExecutionState.exercising;
              });
              _audioService.resumeMusic();
            },
            child: const Text(
              '继续训练',
              style: TextStyle(
                color: Color(0xFF5FC48F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _timer?.cancel();
              _audioService.stopMusic();
              Navigator.pop(context, true);
            },
            child: const Text(
              '确认退出',
              style: TextStyle(
                color: Color(0xFFFF6B6B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  /// 完成训练
  void _finishWorkout() async {
    if (_state == ExecutionState.completed) {
      Navigator.pop(context);
      return;
    }
    
    final shouldExit = await _onWillPop();
    if (shouldExit) {
      Navigator.pop(context);
    }
  }
  
  /// 显示完成对话框
  void _showCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Color(0xFF5FC48F)),
            SizedBox(width: 8),
            Text('训练完成！'),
          ],
        ),
        content: Text(
          '恭喜你完成了本次训练！\n\n'
          '训练时长: ${_formatTime(_elapsedSeconds)}\n'
          '完成动作: $_totalActions 个\n'
          '完成组数: ${widget.session.completedSets} 组',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }
  
  /// 显示动作详情
  void _showActionDetail() {
    // 暂停训练
    if (_state == ExecutionState.exercising) {
      setState(() {
        _state = ExecutionState.paused;
      });
      _audioService.pauseMusic();
    }
    
    ActionDetailSheet.show(
      context,
      actionId: _currentAction.id,
      actionName: _currentAction.name,
      actionImage: _currentAction.image,
    ).then((_) {
      // 弹窗关闭后恢复训练
      if (_state == ExecutionState.paused) {
        setState(() {
          _state = ExecutionState.exercising;
        });
        _audioService.resumeMusic();
      }
    });
  }
  
  /// 显示设置弹窗
  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSettingsSheet(),
    );
  }
  
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              _buildProgressIndicator(),
              Expanded(child: _buildActionImage()),
              _buildControlPanel(),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 顶部栏
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 返回按钮
          GestureDetector(
            onTap: _finishWorkout,
            child: const Icon(Icons.arrow_back_ios, color: Color(0xFF333333), size: 20),
          ),
          const SizedBox(width: 16),
          // 动作名称
          Expanded(
            child: Text(
              _currentAction.name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          // 完成按钮
          GestureDetector(
            onTap: _finishWorkout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF5FC48F),
                borderRadius: BorderRadius.circular(16),
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
  
  /// 进度指示器
  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 进度条
          Row(
            children: List.generate(_totalActions, (index) {
              bool isCurrent = index == _currentActionIndex;
              bool isCompleted = index < _currentActionIndex;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < _totalActions - 1 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? const Color(0xFF5FC48F)
                        : (isCurrent ? const Color(0xFF5FC48F).withOpacity(0.5) : const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          // 当前进度文字
          Text(
            '${_currentActionIndex + 1}/$_totalActions',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 动作图片展示
  Widget _buildActionImage() {
    return GestureDetector(
      onTap: _state == ExecutionState.exercising ? _incrementRep : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 动作图片和休息提示
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 动作图片
                Expanded(
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: _currentAction.image ?? '',
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.fitness_center,
                        size: 120,
                        color: Color(0xFFCCCCCC),
                      ),
                    ),
                  ),
                ),
                // 休息提示
                if (_state == ExecutionState.resting)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        const Text(
                          '休息中',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5FC48F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_countdownSeconds 秒',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            // 动作详情入口按钮 - 左下角
            Positioned(
              left: 0,
              bottom: _state == ExecutionState.resting ? 100 : 0,
              child: GestureDetector(
                onTap: _showActionDetail,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 控制面板
  Widget _buildControlPanel() {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 拖动指示器
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // 设置按钮行
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _showSettings,
                child: const Icon(Icons.settings, color: Color(0xFF666666), size: 24),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 进度条
          _buildRepProgress(),
          const SizedBox(height: 16),
          // 时间和组数
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTime(_elapsedSeconds),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              Text(
                '${_currentSetIndex + 1}/${_currentAction.sets.length} 组',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 播放控制
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 上一个
              _buildControlButton(
                icon: Icons.skip_previous,
                size: 32,
                onTap: _previousAction,
              ),
              const SizedBox(width: 32),
              // 暂停/播放
              _buildPlayButton(),
              const SizedBox(width: 32),
              // 下一个
              _buildControlButton(
                icon: Icons.skip_next,
                size: 32,
                onTap: _nextAction,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 次数进度条
  Widget _buildRepProgress() {
    double progress = _totalReps > 0 ? _currentRep / _totalReps : 0;
    
    return Column(
      children: [
        // 进度条
        Stack(
          children: [
            // 背景
            Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            // 进度
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF5FC48F),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
              ),
            ),
            // 文字（当进度条太短时显示）
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    '$_currentRep/$_totalReps',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withAlpha(80),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  /// 控制按钮
  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: size, color: const Color(0xFF333333)),
      ),
    );
  }
  
  /// 播放/暂停按钮
  Widget _buildPlayButton() {
    bool isPaused = _state == ExecutionState.paused;
    
    return GestureDetector(
      onTap: _togglePause,
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          color: Color(0xFF333333),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isPaused ? Icons.play_arrow : Icons.pause,
          size: 36,
          color: Colors.white,
        ),
      ),
    );
  }
  
  /// 设置面板
  Widget _buildSettingsSheet() {
    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              const Center(
                child: Text(
                  '设置',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // 语音播报开关
              _buildSettingSwitch(
                title: '语音播报',
                value: _audioService.isVoiceEnabled,
                onChanged: (value) {
                  setSheetState(() {
                    _audioService.setVoiceEnabled(value);
                  });
                },
              ),
              const SizedBox(height: 16),
              // 背景音乐开关
              _buildSettingSwitch(
                title: '背景音乐',
                value: _audioService.isMusicEnabled,
                onChanged: (value) {
                  setSheetState(() {
                    _audioService.setMusicEnabled(value);
                    if (value) {
                      _audioService.playMusic();
                    }
                  });
                },
              ),
              const SizedBox(height: 24),
              // 次数间隔
              Text(
                '次数间隔: ${_currentAction.repInterval}秒',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF333333),
                ),
              ),
              Slider(
                value: _currentAction.repInterval.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: const Color(0xFF5FC48F),
                onChanged: (value) {
                  setSheetState(() {
                    _currentAction.repInterval = value.toInt();
                  });
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSettingSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF333333),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF5FC48F),
        ),
      ],
    );
  }
}

