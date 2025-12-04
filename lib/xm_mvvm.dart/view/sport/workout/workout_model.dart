/// 训练动作组模型
class WorkoutSet {
  int setIndex;
  double weight; // 重量 kg
  int reps; // 次数
  bool isCompleted; // 是否完成

  WorkoutSet({
    required this.setIndex,
    this.weight = 0,
    this.reps = 12,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'setIndex': setIndex,
        'weight': weight,
        'reps': reps,
        'isCompleted': isCompleted,
      };

  factory WorkoutSet.fromJson(Map<String, dynamic> json) => WorkoutSet(
        setIndex: json['setIndex'] ?? 0,
        weight: (json['weight'] ?? 0).toDouble(),
        reps: json['reps'] ?? 12,
        isCompleted: json['isCompleted'] ?? false,
      );
}

/// 训练动作模型
class WorkoutAction {
  String id;
  String name;
  String? image;
  String? note; // 备注
  List<WorkoutSet> sets; // 组数
  int difficulty; // 难度 0-简单 1-正常 2-困难
  
  // 跟练设置
  int repInterval; // 动作次数间隔（秒）
  int setRestTime; // 组间休息时间（秒）
  int actionInterval; // 与下个动作的间隔（秒）

  WorkoutAction({
    required this.id,
    required this.name,
    this.image,
    this.note,
    List<WorkoutSet>? sets,
    this.difficulty = 1,
    this.repInterval = 4,
    this.setRestTime = 30,
    this.actionInterval = 60,
  }) : sets = sets ?? [WorkoutSet(setIndex: 1), WorkoutSet(setIndex: 2)];

  int get completedSets => sets.where((s) => s.isCompleted).length;
  int get totalSets => sets.length;

  void addSet() {
    sets.add(WorkoutSet(setIndex: sets.length + 1));
  }

  void removeSet(int index) {
    if (sets.length > 1 && index < sets.length) {
      sets.removeAt(index);
      // 重新编号
      for (int i = 0; i < sets.length; i++) {
        sets[i].setIndex = i + 1;
      }
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'note': note,
        'sets': sets.map((s) => s.toJson()).toList(),
        'difficulty': difficulty,
        'repInterval': repInterval,
        'setRestTime': setRestTime,
        'actionInterval': actionInterval,
      };

  factory WorkoutAction.fromJson(Map<String, dynamic> json) => WorkoutAction(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        image: json['image'],
        note: json['note'],
        sets: (json['sets'] as List?)
            ?.map((s) => WorkoutSet.fromJson(s))
            .toList(),
        difficulty: json['difficulty'] ?? 1,
        repInterval: json['repInterval'] ?? 4,
        setRestTime: json['setRestTime'] ?? 30,
        actionInterval: json['actionInterval'] ?? 60,
      );
}

/// 训练会话模型
class WorkoutSession {
  List<WorkoutAction> actions;
  int elapsedSeconds; // 已经过的秒数
  bool isRunning;

  WorkoutSession({
    List<WorkoutAction>? actions,
    this.elapsedSeconds = 0,
    this.isRunning = false,
  }) : actions = actions ?? [];

  int get totalSets => actions.fold(0, (sum, a) => sum + a.totalSets);
  int get completedSets => actions.fold(0, (sum, a) => sum + a.completedSets);
  int get totalActions => actions.length;

  // 计算总容量 (重量 x 次数)
  double get totalVolume {
    double volume = 0;
    for (var action in actions) {
      for (var set in action.sets) {
        if (set.isCompleted) {
          volume += set.weight * set.reps;
        }
      }
    }
    return volume;
  }

  void addAction(WorkoutAction action) {
    actions.add(action);
  }

  void removeAction(int index) {
    if (index < actions.length) {
      actions.removeAt(index);
    }
  }

  void reorderAction(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final action = actions.removeAt(oldIndex);
    actions.insert(newIndex, action);
  }
}

