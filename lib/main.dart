import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const TtomiruniApp());
}

// 발표 화면과 맞추기 위해 2026년 6월 기준으로 고정했습니다.
// 실제 앱에서는 DateTime.now()로 바꾸면 됩니다.
final DateTime demoToday = DateTime(2026, 6, 6);

enum AppTab { home, calendar, friends, widgetPreview }
enum SeverityLevel { godLife, relaxed, caution, crisis, disaster }

class DeadlineItem {
  DeadlineItem({
    required this.title,
    required this.deadline,
    required this.totalAmount,
    this.doneAmount = 0,
    this.unit = '장',
    this.importance = 3,
  });

  String title;
  DateTime deadline;
  int totalAmount;
  int doneAmount;
  String unit;
  int importance;

  int get remainingAmount => math.max(0, totalAmount - doneAmount);

  int get daysLeft {
    final onlyToday = DateTime(demoToday.year, demoToday.month, demoToday.day);
    final onlyDeadline = DateTime(deadline.year, deadline.month, deadline.day);
    return math.max(1, onlyDeadline.difference(onlyToday).inDays + 1);
  }

  int get dDay {
    final onlyToday = DateTime(demoToday.year, demoToday.month, demoToday.day);
    final onlyDeadline = DateTime(deadline.year, deadline.month, deadline.day);
    return onlyDeadline.difference(onlyToday).inDays;
  }

  int get todayAmount => (remainingAmount / daysLeft).ceil();

  int get tomorrowAmount {
    final tomorrowDays = math.max(1, daysLeft - 1);
    return (remainingAmount / tomorrowDays).ceil();
  }

  int get increasedAmount => math.max(0, tomorrowAmount - todayAmount);

  SeverityLevel get severity {
    final pressure = (todayAmount * importance) / math.max(1, totalAmount);

    if (dDay <= 0 || pressure >= 0.75) return SeverityLevel.disaster;
    if (dDay <= 2 || pressure >= 0.45) return SeverityLevel.crisis;
    if (dDay <= 5 || pressure >= 0.25) return SeverityLevel.caution;
    if (dDay <= 10 || pressure >= 0.12) return SeverityLevel.relaxed;
    return SeverityLevel.godLife;
  }
}

class FriendStatus {
  FriendStatus({required this.name, required this.level});

  String name;
  SeverityLevel level;
}

class SeverityInfo {
  const SeverityInfo({
    required this.label,
    required this.emoji,
    required this.color,
    required this.message,
  });

  final String label;
  final String emoji;
  final Color color;
  final String message;
}

const Map<SeverityLevel, SeverityInfo> severityMap = {
  SeverityLevel.godLife: SeverityInfo(
    label: '갓생',
    emoji: '😇',
    color: Color(0xFF48C76F),
    message: '완벽합니다!',
  ),
  SeverityLevel.relaxed: SeverityInfo(
    label: '여유',
    emoji: '😊',
    color: Color(0xFF9BCB3F),
    message: '아직 괜찮아요.',
  ),
  SeverityLevel.caution: SeverityInfo(
    label: '주의',
    emoji: '😐',
    color: Color(0xFFFFB531),
    message: '슬슬 시작해야 해요.',
  ),
  SeverityLevel.crisis: SeverityInfo(
    label: '위기',
    emoji: '😣',
    color: Color(0xFFFF5D5D),
    message: '지금 바로 집중이 필요해요!',
  ),
  SeverityLevel.disaster: SeverityInfo(
    label: '재난',
    emoji: '👿',
    color: Color(0xFF353238),
    message: '오늘 안 하면 진짜 위험해요.',
  ),
};

class TtomiruniApp extends StatelessWidget {
  const TtomiruniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '또미루니',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFEAF6FF),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6EA8FF)),
        fontFamily: 'Roboto',
      ),
      home: const TtomiruniHomePage(),
    );
  }
}

class TtomiruniHomePage extends StatefulWidget {
  const TtomiruniHomePage({super.key});

  @override
  State<TtomiruniHomePage> createState() => _TtomiruniHomePageState();
}

class _TtomiruniHomePageState extends State<TtomiruniHomePage> {
  AppTab selectedTab = AppTab.home;

  final List<DeadlineItem> deadlines = [
    DeadlineItem(
      title: '모바일 프로그래밍',
      deadline: DateTime(2026, 6, 3),
      totalAmount: 10,
      doneAmount: 0,
      unit: '장',
      importance: 2,
    ),
    DeadlineItem(
      title: '기말고사',
      deadline: DateTime(2026, 6, 10),
      totalAmount: 12,
      doneAmount: 2,
      unit: '단원',
      importance: 4,
    ),
    DeadlineItem(
      title: '과제 마감',
      deadline: DateTime(2026, 6, 14),
      totalAmount: 30,
      doneAmount: 10,
      unit: '쪽',
      importance: 3,
    ),
    DeadlineItem(
      title: '재입학 신청',
      deadline: DateTime(2026, 6, 24),
      totalAmount: 1,
      doneAmount: 0,
      unit: '건',
      importance: 1,
    ),
  ];

  final List<FriendStatus> friends = [
    FriendStatus(name: '신승민', level: SeverityLevel.crisis),
    FriendStatus(name: '김은민', level: SeverityLevel.caution),
    FriendStatus(name: '정의현', level: SeverityLevel.relaxed),
    FriendStatus(name: '홍길동', level: SeverityLevel.crisis),
  ];

  DeadlineItem get mostUrgent {
    final sorted = [...deadlines]
      ..sort((a, b) {
        final severityCompare = b.severity.index.compareTo(a.severity.index);
        if (severityCompare != 0) return severityCompare;
        return a.dDay.compareTo(b.dDay);
      });
    return sorted.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFEFA),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF99C7FF), width: 3),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 20,
                    offset: Offset(0, 8),
                    color: Color(0x22000000),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(painter: PixelBackgroundPainter()),
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: TopMenu(
                          selectedTab: selectedTab,
                          onAddPressed: _showAddDeadlineDialog,
                          onCalendarPressed: () => setState(() => selectedTab = AppTab.calendar),
                          onFriendsPressed: () => setState(() => selectedTab = AppTab.friends),
                        ),
                      ),
                      Expanded(child: _buildSelectedBody()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedBody() {
    switch (selectedTab) {
      case AppTab.home:
        return HomeDashboard(
          deadlines: deadlines,
          urgentItem: mostUrgent,
          onOpenWidgetPreview: () => setState(() => selectedTab = AppTab.widgetPreview),
        );
      case AppTab.calendar:
        return CalendarDashboard(deadlines: deadlines);
      case AppTab.friends:
        return FriendsDashboard(
          friends: friends,
          onAddFriend: _showAddFriendDialog,
        );
      case AppTab.widgetPreview:
        return WidgetPreviewDashboard(item: mostUrgent);
    }
  }

  Future<void> _showAddDeadlineDialog() async {
    final titleController = TextEditingController(text: '모바일 프로그래밍');
    final amountController = TextEditingController(text: '10');
    int day = 20;
    int importance = 3;
    String unit = '장';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('일정 추가'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: '과목명/일정명'),
                    ),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '해야 할 양'),
                    ),
                    DropdownButtonFormField<String>(
                      value: unit,
                      decoration: const InputDecoration(labelText: '단위'),
                      items: const [
                        DropdownMenuItem(value: '장', child: Text('장')),
                        DropdownMenuItem(value: '쪽', child: Text('쪽')),
                        DropdownMenuItem(value: '단원', child: Text('단원')),
                        DropdownMenuItem(value: '건', child: Text('건')),
                      ],
                      onChanged: (value) => setDialogState(() => unit = value ?? '장'),
                    ),
                    DropdownButtonFormField<int>(
                      value: day,
                      decoration: const InputDecoration(labelText: '마감일: 2026년 6월'),
                      items: List.generate(
                        30,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}일'),
                        ),
                      ),
                      onChanged: (value) => setDialogState(() => day = value ?? 20),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('중요도'),
                        Expanded(
                          child: Slider(
                            value: importance.toDouble(),
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: '$importance',
                            onChanged: (value) => setDialogState(() => importance = value.round()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                FilledButton(
                  onPressed: () {
                    final amount = int.tryParse(amountController.text.trim()) ?? 1;
                    setState(() {
                      deadlines.add(
                        DeadlineItem(
                          title: titleController.text.trim().isEmpty
                              ? '새 일정'
                              : titleController.text.trim(),
                          deadline: DateTime(2026, 6, day),
                          totalAmount: amount,
                          unit: unit,
                          importance: importance,
                        ),
                      );
                      selectedTab = AppTab.calendar;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddFriendDialog() async {
    final nameController = TextEditingController(text: '새 친구');
    SeverityLevel level = SeverityLevel.caution;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('친구 추가'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: '이름'),
                  ),
                  DropdownButtonFormField<SeverityLevel>(
                    value: level,
                    decoration: const InputDecoration(labelText: '현재 상태'),
                    items: SeverityLevel.values.map((value) {
                      final info = severityMap[value]!;
                      return DropdownMenuItem(
                        value: value,
                        child: Text('${info.emoji} ${info.label}'),
                      );
                    }).toList(),
                    onChanged: (value) => setDialogState(() => level = value ?? SeverityLevel.caution),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      friends.add(FriendStatus(name: nameController.text.trim(), level: level));
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('추가'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class TopMenu extends StatelessWidget {
  const TopMenu({
    super.key,
    required this.selectedTab,
    required this.onAddPressed,
    required this.onCalendarPressed,
    required this.onFriendsPressed,
  });

  final AppTab selectedTab;
  final VoidCallback onAddPressed;
  final VoidCallback onCalendarPressed;
  final VoidCallback onFriendsPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PixelMenuButton(
            label: '일정 추가',
            emoji: '🗓️',
            color: const Color(0xFF35B56B),
            selected: false,
            onTap: onAddPressed,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: PixelMenuButton(
            label: '캘린더',
            emoji: '📅',
            color: const Color(0xFF368BFF),
            selected: selectedTab == AppTab.calendar,
            onTap: onCalendarPressed,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: PixelMenuButton(
            label: '친구목록',
            emoji: '👥',
            color: const Color(0xFF8D65E8),
            selected: selectedTab == AppTab.friends,
            onTap: onFriendsPressed,
          ),
        ),
      ],
    );
  }
}

class PixelMenuButton extends StatelessWidget {
  const PixelMenuButton({
    super.key,
    required this.label,
    required this.emoji,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? color : const Color(0xFFC3DEFF),
            width: selected ? 3 : 2,
          ),
          boxShadow: const [
            BoxShadow(blurRadius: 10, offset: Offset(0, 5), color: Color(0x12000000)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(
                label,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF10204B)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    super.key,
    required this.deadlines,
    required this.urgentItem,
    required this.onOpenWidgetPreview,
  });

  final List<DeadlineItem> deadlines;
  final DeadlineItem urgentItem;
  final VoidCallback onOpenWidgetPreview;

  @override
  Widget build(BuildContext context) {
    final currentLevel = urgentItem.severity;
    final info = severityMap[currentLevel]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘의 압박도',
            style: TextStyle(fontSize: 31, fontWeight: FontWeight.w900, color: Color(0xFF10204B)),
          ),
          const SizedBox(height: 6),
          const Text(
            '마감까지 힘내요!',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF69718F)),
          ),
          const SizedBox(height: 18),
          Center(
            child: PressureFace(
              level: currentLevel,
              size: 210,
              showRing: true,
            ),
          ),
          const SizedBox(height: 24),
          SeverityStepper(selected: currentLevel),
          const SizedBox(height: 24),
          InkWell(
            onTap: onOpenWidgetPreview,
            borderRadius: BorderRadius.circular(18),
            child: PixelCard(
              child: Row(
                children: [
                  const Text('⏰', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '예정된 마감 ${deadlines.length}건',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF10204B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '가장 임박한 마감은 D-${math.max(0, urgentItem.dDay)} 입니다.',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF69718F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 34, color: Color(0xFF3E87FF)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${info.emoji} 현재 상태: ${info.label} · ${info.message}',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: info.color),
          ),
        ],
      ),
    );
  }
}

class SeverityStepper extends StatelessWidget {
  const SeverityStepper({super.key, required this.selected});

  final SeverityLevel selected;

  @override
  Widget build(BuildContext context) {
    const levels = [
      SeverityLevel.godLife,
      SeverityLevel.relaxed,
      SeverityLevel.caution,
      SeverityLevel.crisis,
      SeverityLevel.disaster,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: levels.map((level) {
        final info = severityMap[level]!;
        final isSelected = selected == level;
        return Expanded(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  PressureFace(level: level, size: isSelected ? 54 : 42, showRing: isSelected),
                  if (isSelected)
                    const Positioned(
                      bottom: -12,
                      child: Icon(Icons.arrow_drop_up_rounded, color: Color(0xFFFFB531), size: 26),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              FittedBox(
                child: Text(
                  info.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: info.color,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class PressureFace extends StatelessWidget {
  const PressureFace({
    super.key,
    required this.level,
    required this.size,
    this.showRing = false,
  });

  final SeverityLevel level;
  final double size;
  final bool showRing;

  @override
  Widget build(BuildContext context) {
    final info = severityMap[level]!;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showRing)
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: _progressValue(level),
                strokeWidth: math.max(4, size / 22),
                backgroundColor: const Color(0xFFE7F1FF),
                color: info.color,
              ),
            ),
          Container(
            width: size * 0.82,
            height: size * 0.82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: info.color,
              border: Border.all(color: _borderColor(level), width: math.max(2, size / 40)),
              boxShadow: const [BoxShadow(blurRadius: 10, color: Color(0x22000000), offset: Offset(0, 4))],
            ),
            child: Center(
              child: Text(
                info.emoji,
                style: TextStyle(fontSize: size * 0.36),
              ),
            ),
          ),
          if (level == SeverityLevel.godLife)
            Positioned(
              top: size * 0.04,
              child: Container(
                width: size * 0.42,
                height: size * 0.11,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: const Color(0xFFFFC836), width: 3),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _progressValue(SeverityLevel level) {
    switch (level) {
      case SeverityLevel.godLife:
        return 0.08;
      case SeverityLevel.relaxed:
        return 0.25;
      case SeverityLevel.caution:
        return 0.5;
      case SeverityLevel.crisis:
        return 0.74;
      case SeverityLevel.disaster:
        return 1.0;
    }
  }

  Color _borderColor(SeverityLevel level) {
    if (level == SeverityLevel.disaster) return Colors.black;
    return Colors.white;
  }
}

class CalendarDashboard extends StatelessWidget {
  const CalendarDashboard({super.key, required this.deadlines});

  final List<DeadlineItem> deadlines;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PixelSmallButton(icon: Icons.chevron_left_rounded, onTap: () {}),
              const Row(
                children: [
                  Text('✨', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text(
                    '2026년 6월',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF10204B)),
                  ),
                  SizedBox(width: 8),
                  Text('💠', style: TextStyle(fontSize: 18)),
                ],
              ),
              PixelSmallButton(icon: Icons.chevron_right_rounded, onTap: () {}),
            ],
          ),
          const SizedBox(height: 18),
          PixelCard(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                const CalendarWeekHeader(),
                const Divider(color: Color(0xFFD5E5FF), height: 12),
                CalendarGrid(deadlines: deadlines),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PixelCard(
            child: Row(
              children: [
                const Text('⏰', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '예정된 마감 3건',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF10204B)),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '가장 임박한 마감은 D-2 입니다.',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF69718F)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF3E87FF), size: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarWeekHeader extends StatelessWidget {
  const CalendarWeekHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const labels = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      children: labels.map((label) {
        final isSunday = label == '일';
        final isSaturday = label == '토';
        return Expanded(
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: isSunday
                    ? const Color(0xFFFF3F3F)
                    : isSaturday
                        ? const Color(0xFF2F7DFF)
                        : const Color(0xFF10204B),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({super.key, required this.deadlines});

  final List<DeadlineItem> deadlines;

  @override
  Widget build(BuildContext context) {
    final cells = <int?>[null, ...List.generate(30, (index) => index + 1), 1, 2, 3, 4];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.78,
      ),
      itemCount: 35,
      itemBuilder: (context, index) {
        final day = cells[index];
        final isNextMonth = index >= 31;
        final events = _eventsForDay(day, isNextMonth);
        final weekday = index % 7;

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E9F8), width: 0.8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  day == null ? '31' : '$day',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: day == null || isNextMonth
                        ? const Color(0xFFB7BDC9)
                        : weekday == 0
                            ? const Color(0xFFFF3F3F)
                            : weekday == 6
                                ? const Color(0xFF2F7DFF)
                                : const Color(0xFF10204B),
                  ),
                ),
                const SizedBox(height: 6),
                ...events.map((event) => CalendarChip(event: event)).take(2),
              ],
            ),
          ),
        );
      },
    );
  }

  List<_CalendarEvent> _eventsForDay(int? day, bool isNextMonth) {
    if (day == null || isNextMonth) return const [];

    final events = <_CalendarEvent>[];
    for (final item in deadlines) {
      if (item.deadline.year == 2026 && item.deadline.month == 6 && item.deadline.day == day) {
        events.add(_CalendarEvent('📘 ${item.title}', const Color(0xFFDCEEFF), const Color(0xFF3578DE)));
      }
    }

    if (day == 10) {
      events.add(const _CalendarEvent('✏️ 기말고사', Color(0xFFFFE4E7), Color(0xFFFF6C7A)));
    }
    if (day == 14) {
      events.add(const _CalendarEvent('📄 과제 마감', Color(0xFFDFF8D8), Color(0xFF52B750)));
    }
    if (day == 24) {
      events.add(const _CalendarEvent('✉️ 재입학 신청', Color(0xFFEEDCFF), Color(0xFF9D6BEE)));
    }
    return events;
  }
}

class _CalendarEvent {
  const _CalendarEvent(this.label, this.background, this.border);
  final String label;
  final Color background;
  final Color border;
}

class CalendarChip extends StatelessWidget {
  const CalendarChip({super.key, required this.event});

  final _CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: event.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: event.border, width: 1.2),
      ),
      child: FittedBox(
        alignment: Alignment.centerLeft,
        fit: BoxFit.scaleDown,
        child: Text(
          event.label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF10204B)),
        ),
      ),
    );
  }
}

class FriendsDashboard extends StatelessWidget {
  const FriendsDashboard({super.key, required this.friends, required this.onAddFriend});

  final List<FriendStatus> friends;
  final VoidCallback onAddFriend;

  @override
  Widget build(BuildContext context) {
    final dangerCount = friends.where((friend) => friend.level.index >= SeverityLevel.crisis.index).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          PixelCard(
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('👥', style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '친구목록',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF10204B)),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onAddFriend,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('친구추가'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...friends.map((friend) => FriendTile(friend: friend)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PixelCard(
            borderColor: const Color(0xFFFFA5B3),
            child: Row(
              children: [
                const Text('💖', style: TextStyle(fontSize: 42)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '관심이 필요한 친구 $dangerCount명',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF10204B)),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        '친구들을 살펴보고 응원해 주세요!',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF69718F)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFFF6B7D), size: 32),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '뒷공부 방지 모드: 친구의 성실함을 보고 같이 갓생 살기',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF69718F)),
          ),
        ],
      ),
    );
  }
}

class FriendTile extends StatelessWidget {
  const FriendTile({super.key, required this.friend});

  final FriendStatus friend;

  @override
  Widget build(BuildContext context) {
    final info = severityMap[friend.level]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC3DEFF), width: 2),
      ),
      child: Row(
        children: [
          const Text('🧑‍🎓', style: TextStyle(fontSize: 34)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              friend.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF10204B)),
            ),
          ),
          PressureFace(level: friend.level, size: 46),
          const SizedBox(width: 10),
          Text(
            info.label,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: info.color),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF3E87FF), size: 28),
        ],
      ),
    );
  }
}

class WidgetPreviewDashboard extends StatelessWidget {
  const WidgetPreviewDashboard({super.key, required this.item});

  final DeadlineItem item;

  @override
  Widget build(BuildContext context) {
    final info = severityMap[item.severity]!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 20),
      child: Column(
        children: [
          const Text(
            '홈 화면 위젯 미리보기',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: Color(0xFF10204B)),
          ),
          const SizedBox(height: 18),
          PixelCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        '현재 심각도',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF10204B)),
                      ),
                      const SizedBox(height: 12),
                      PressureFace(level: item.severity, size: 110),
                      const SizedBox(height: 8),
                      Text(
                        info.label,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: info.color),
                      ),
                    ],
                  ),
                ),
                Container(width: 2, height: 160, color: const Color(0xFFD5E5FF)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📘 오늘 공부량',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF10204B)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${item.title}\n${item.todayAmount}${item.unit}',
                          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Color(0xFF267DFF)),
                        ),
                        const Divider(height: 24, color: Color(0xFFD5E5FF)),
                        const Text(
                          '⏰ 오늘 안 하면',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF10204B)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '내일 ${item.tomorrowAmount}${item.unit}로 증가',
                          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Color(0xFFFF9F24)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            '실제 OS 홈 화면 위젯은 iOS WidgetKit, Android App Widget 또는 home_widget 패키지로 확장할 수 있습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF69718F)),
          ),
        ],
      ),
    );
  }
}

class PixelSmallButton extends StatelessWidget {
  const PixelSmallButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC3DEFF), width: 2),
        ),
        child: Icon(icon, color: const Color(0xFF10204B), size: 26),
      ),
    );
  }
}

class PixelCard extends StatelessWidget {
  const PixelCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor = const Color(0xFFC3DEFF),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 2.4),
        boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 5), color: Color(0x11000000))],
      ),
      child: child,
    );
  }
}

class PixelBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cloudPaint = Paint()..color = Colors.white.withOpacity(0.7);
    final starPaint = Paint()..color = const Color(0xFFFFC83D);
    final blueStarPaint = Paint()..color = const Color(0xFF51BDEB);

    _drawPixelCloud(canvas, cloudPaint, const Offset(22, 20));
    _drawPixelCloud(canvas, cloudPaint, const Offset(82, 24), scale: 0.65);
    _drawPixelStar(canvas, starPaint, Offset(size.width - 76, 24));
    _drawPixelStar(canvas, blueStarPaint, Offset(32, size.height * 0.62), size: 5);
    _drawPixelStar(canvas, starPaint, Offset(size.width - 36, 38), size: 5);

    final floorPaint = Paint()..color = const Color(0xFFE6F4FF);
    canvas.drawRect(Rect.fromLTWH(0, size.height - 40, size.width, 40), floorPaint);
  }

  void _drawPixelCloud(Canvas canvas, Paint paint, Offset offset, {double scale = 1}) {
    final unit = 8.0 * scale;
    final rects = [
      Rect.fromLTWH(offset.dx, offset.dy + unit, unit * 5, unit * 2),
      Rect.fromLTWH(offset.dx + unit, offset.dy, unit * 2, unit * 2),
      Rect.fromLTWH(offset.dx + unit * 3, offset.dy + unit * 0.5, unit * 2, unit * 2.5),
    ];
    for (final rect in rects) {
      canvas.drawRect(rect, paint);
    }
  }

  void _drawPixelStar(Canvas canvas, Paint paint, Offset center, {double size = 6}) {
    canvas.drawRect(Rect.fromCenter(center: center, width: size * 0.8, height: size * 3), paint);
    canvas.drawRect(Rect.fromCenter(center: center, width: size * 3, height: size * 0.8), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
