import 'package:flutter/foundation.dart';

/// 训练语音播报类型
enum VoiceType {
  actionStart, // 动作开始
  actionEnd, // 动作结束
  setStart, // 一组开始
  setComplete, // 一组完成
  repCount, // 次数播报
  restStart, // 休息开始
  restEnd, // 休息结束
  workoutComplete, // 训练完成
  countdown, // 倒计时
  encouragement, // 鼓励语
}

/// 训练音频服务
/// 负责管理训练过程中的语音播报和背景音乐
class WorkoutAudioService {
  static final WorkoutAudioService _instance = WorkoutAudioService._internal();
  factory WorkoutAudioService() => _instance;
  WorkoutAudioService._internal();
  
  bool _isVoiceEnabled = true;
  bool _isMusicEnabled = true;
  bool _isMusicPlaying = false;
  double _voiceVolume = 1.0;
  double _musicVolume = 0.5;
  
  // 获取状态
  bool get isVoiceEnabled => _isVoiceEnabled;
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isMusicPlaying => _isMusicPlaying;
  double get voiceVolume => _voiceVolume;
  double get musicVolume => _musicVolume;
  
  /// 初始化音频服务
  Future<void> init() async {
    // TODO: 初始化音频播放器
    debugPrint('[WorkoutAudioService] 初始化音频服务');
  }
  
  /// 释放资源
  Future<void> dispose() async {
    await stopMusic();
    debugPrint('[WorkoutAudioService] 释放音频服务资源');
  }
  
  /// 设置语音播报开关
  void setVoiceEnabled(bool enabled) {
    _isVoiceEnabled = enabled;
    debugPrint('[WorkoutAudioService] 语音播报: ${enabled ? "开启" : "关闭"}');
  }
  
  /// 设置背景音乐开关
  void setMusicEnabled(bool enabled) {
    _isMusicEnabled = enabled;
    if (!enabled && _isMusicPlaying) {
      stopMusic();
    }
    debugPrint('[WorkoutAudioService] 背景音乐: ${enabled ? "开启" : "关闭"}');
  }
  
  /// 设置语音音量
  void setVoiceVolume(double volume) {
    _voiceVolume = volume.clamp(0.0, 1.0);
  }
  
  /// 设置音乐音量
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
  }
  
  /// 播放语音播报
  Future<void> speak(VoiceType type, {String? customText, int? number}) async {
    if (!_isVoiceEnabled) return;
    
    String text = customText ?? _getVoiceText(type, number: number);
    debugPrint('[WorkoutAudioService] 语音播报: $text');
    
    // TODO: 使用 TTS 或预录音频播放
    // 可以集成 flutter_tts 或 audioplayers 播放预录音频
  }
  
  /// 播放动作名称
  Future<void> speakActionName(String actionName) async {
    if (!_isVoiceEnabled) return;
    debugPrint('[WorkoutAudioService] 播报动作: $actionName');
  }
  
  /// 播放次数
  Future<void> speakRepCount(int count) async {
    if (!_isVoiceEnabled) return;
    debugPrint('[WorkoutAudioService] 播报次数: $count');
  }
  
  /// 播放倒计时
  Future<void> speakCountdown(int seconds) async {
    if (!_isVoiceEnabled) return;
    if (seconds <= 3 && seconds > 0) {
      debugPrint('[WorkoutAudioService] 倒计时: $seconds');
    }
  }
  
  /// 播放鼓励语
  Future<void> speakEncouragement() async {
    if (!_isVoiceEnabled) return;
    List<String> phrases = [
      '很棒，继续保持！',
      '加油，你可以的！',
      '坚持住！',
      '做得很好！',
      '再来一个！',
    ];
    String phrase = phrases[DateTime.now().millisecond % phrases.length];
    debugPrint('[WorkoutAudioService] 鼓励语: $phrase');
  }
  
  /// 播放背景音乐
  Future<void> playMusic() async {
    if (!_isMusicEnabled) return;
    _isMusicPlaying = true;
    debugPrint('[WorkoutAudioService] 开始播放背景音乐');
    
    // TODO: 使用 audioplayers 或 just_audio 播放背景音乐
  }
  
  /// 暂停背景音乐
  Future<void> pauseMusic() async {
    if (!_isMusicPlaying) return;
    _isMusicPlaying = false;
    debugPrint('[WorkoutAudioService] 暂停背景音乐');
  }
  
  /// 恢复背景音乐
  Future<void> resumeMusic() async {
    if (!_isMusicEnabled || _isMusicPlaying) return;
    _isMusicPlaying = true;
    debugPrint('[WorkoutAudioService] 恢复背景音乐');
  }
  
  /// 停止背景音乐
  Future<void> stopMusic() async {
    _isMusicPlaying = false;
    debugPrint('[WorkoutAudioService] 停止背景音乐');
  }
  
  /// 播放提示音
  Future<void> playBeep() async {
    debugPrint('[WorkoutAudioService] 播放提示音');
  }
  
  /// 播放完成音效
  Future<void> playCompleteSound() async {
    debugPrint('[WorkoutAudioService] 播放完成音效');
  }
  
  /// 获取语音文本
  String _getVoiceText(VoiceType type, {int? number}) {
    switch (type) {
      case VoiceType.actionStart:
        return '动作开始';
      case VoiceType.actionEnd:
        return '动作结束';
      case VoiceType.setStart:
        return number != null ? '第$number组，开始' : '开始';
      case VoiceType.setComplete:
        return number != null ? '第$number组，完成' : '完成';
      case VoiceType.repCount:
        return number?.toString() ?? '';
      case VoiceType.restStart:
        return number != null ? '休息$number秒' : '休息';
      case VoiceType.restEnd:
        return '休息结束，准备开始';
      case VoiceType.workoutComplete:
        return '恭喜你，训练完成！';
      case VoiceType.countdown:
        return number?.toString() ?? '';
      case VoiceType.encouragement:
        return '加油！';
    }
  }
}

