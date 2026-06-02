import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lesson.dart';
import '../services/api_service.dart';
import 'lesson_screen.dart';
import 'profile_screen.dart';
import 'budget_screen.dart';

const _kGreen = Color(0xFF58CC02);
const _kGreenDark = Color(0xFF45A800);
const _kGrey = Color(0xFFAFAFAF);
const _kGreyLight = Color(0xFFE5E5E5);

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _HomeTab(),
          _ShopTab(),
          BudgetScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: _kGreen,
          unselectedItemColor: _kGrey,
          type: BottomNavigationBarType.fixed, // Use fixed for 5 items
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront_rounded),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Budget',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Home Tab ─────────────────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  List<Lesson> _lessons = [];
  bool _isLoading = true;
  final Map<String, int> _userStats = {'streak': 0, 'coins': 0, 'gems': 0};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final lessons = await ApiService.fetchLessons();
      lessons.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      if (userId != null) {
        final progress = await ApiService.fetchProgress(userId);
        final stats = await ApiService.getUserStats(userId);
        final completedIds = progress.map((p) => p['lesson_id']).toSet();
        
        if (mounted) {
          setState(() {
            _userStats['streak'] = stats['streak_count'] ?? 0;
            _userStats['coins'] = stats['coins'] ?? 0;
            _userStats['gems'] = stats['gems'] ?? 0;
          });
        }
        
        // Update completion status and locking logic
        for (int i = 0; i < lessons.length; i++) {
          final lesson = lessons[i];
          if (completedIds.contains(lesson.id)) {
            lessons[i].isCompleted = true;
          }
          // Simple locking: lock if previous lesson is not completed (except first)
          if (i > 0 && !lessons[i-1].isCompleted) {
            lessons[i].isLocked = true;
          } else {
            lessons[i].isLocked = false;
          }
        }
      }

      if (mounted) {
        setState(() {
          _lessons = lessons;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _kGreen));
    }
    return Column(
      children: [
        _TopBar(user: _userStats),
        Expanded(
          child: _RoadmapBody(
            lessons: _lessons,
            onRefresh: _loadData,
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  final Map<String, int> user;
  const _TopBar({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 20,
        right: 20,
        bottom: 12,
      ),
      child: Row(
        children: [
          // App title
          const Text(
            'FinLit India',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          // Streak
          _TopBarChip(
            label: '${user["streak"]}',
            emoji: '🔥',
            color: user["streak"]! > 0 ? const Color(0xFFFFE0B2) : const Color(0xFFF5F5F5),
            textColor: user["streak"]! > 0 ? const Color(0xFFE65100) : const Color(0xFF9E9E9E),
          ),
          const SizedBox(width: 8),
          // Coins
          _TopBarChip(
            label: '${user["coins"]}',
            emoji: '💰',
            color: const Color(0xFFFFF9C4),
            textColor: const Color(0xFFF57F17),
          ),
          const SizedBox(width: 8),
          // Gems
          _TopBarChip(
            label: '${user["gems"]}',
            emoji: '💎',
            color: const Color(0xFFE3F2FD),
            textColor: const Color(0xFF1565C0),
          ),
        ],
      ),
    );
  }
}

class _TopBarChip extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final Color textColor;

  const _TopBarChip({
    required this.label,
    required this.emoji,
    required this.color,
    this.textColor = const Color(0xFF1A1A1A),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Roadmap Body ─────────────────────────────────────────────────────────────

class _RoadmapBody extends StatelessWidget {
  final List<Lesson> lessons;
  final VoidCallback onRefresh;

  static const double _itemHeight = 110.0;
  static const double _circleSize = 72.0;

  // x-fractions cycling: left-center, right-center, center, right-center, left-center
  static const List<double> _xPattern = [0.30, 0.70, 0.50, 0.70, 0.30];

  const _RoadmapBody({
    required this.lessons,
    required this.onRefresh,
  });

  double _xFraction(int index) =>
      _xPattern[index % _xPattern.length];

  @override
  Widget build(BuildContext context) {
    final totalLessons = lessons.length;

    // Insert section banners: find first index of each new module
    final List<_RoadmapItem> items = [];
    int? lastModule;
    for (int i = 0; i < totalLessons; i++) {
      final lesson = lessons[i];
      if (lesson.moduleNumber != lastModule) {
        items.add(_RoadmapItem.banner(lesson.moduleNumber, lesson.sectionName));
        lastModule = lesson.moduleNumber;
      }
      items.add(_RoadmapItem.lesson(lesson));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Build list of circle positions for painter (lesson items only)
        final List<Offset> circlePositions = [];
        final List<bool> circleCompleted = [];
        int lessonIndex = 0;
        double y = 0;
        for (final item in items) {
          if (item.isBanner) {
            y += 72; // banner height
          } else {
            final x = width * _xFraction(lessonIndex);
            circlePositions.add(Offset(x, y + _itemHeight / 2));
            circleCompleted.add(item.lesson!.isCompleted);
            lessonIndex++;
            y += _itemHeight;
          }
        }

        final double totalHeight = y;

        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: totalHeight + 40,
            child: Stack(
              children: [
                // Connecting path
                CustomPaint(
                  size: Size(width, totalHeight + 40),
                  painter: _RoadmapPainter(
                    positions: circlePositions,
                    isCompleted: circleCompleted,
                  ),
                ),
                // Items
                Builder(builder: (context) {
                  final List<Widget> widgets = [];
                  double dy = 0;
                  int lIdx = 0;
                  for (final item in items) {
                    if (item.isBanner) {
                      widgets.add(Positioned(
                        top: dy,
                        left: 0,
                        right: 0,
                        child: _SectionBanner(
                          moduleNumber: item.moduleNumber!,
                          sectionName: item.sectionName!,
                        ),
                      ));
                      dy += 72;
                    } else {
                      final lesson = item.lesson!;
                      final x = width * _xFraction(lIdx) - _circleSize / 2;
                      widgets.add(Positioned(
                        top: dy + (_itemHeight - _circleSize) / 2,
                        left: x,
                        child: _LessonCircle(
                          lesson: lesson,
                          index: lIdx,
                          onRefresh: onRefresh,
                        ),
                      ));
                      dy += _itemHeight;
                      lIdx++;
                    }
                  }
                  return Stack(children: widgets);
                }),
              ],
            ),
          ),
        ),
        );
      },
    );
  }
}

class _RoadmapItem {
  final bool isBanner;
  final Lesson? lesson;
  final int? moduleNumber;
  final String? sectionName;

  const _RoadmapItem.banner(this.moduleNumber, this.sectionName)
      : isBanner = true,
        lesson = null;

  const _RoadmapItem.lesson(this.lesson)
      : isBanner = false,
        moduleNumber = null,
        sectionName = null;
}

class _RoadmapPainter extends CustomPainter {
  final List<Offset> positions;
  final List<bool> isCompleted;

  const _RoadmapPainter({required this.positions, required this.isCompleted});

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2) return;

    for (int i = 0; i < positions.length - 1; i++) {
      final p1 = positions[i];
      final p2 = positions[i + 1];
      
      final paint = Paint()
        ..color = isCompleted[i] ? _kGreen : const Color(0xFFE5E5E5)
        ..strokeWidth = 14
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..cubicTo(
          p1.dx,
          p1.dy + (p2.dy - p1.dy) * 0.4,
          p2.dx,
          p1.dy + (p2.dy - p1.dy) * 0.6,
          p2.dx,
          p2.dy,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RoadmapPainter old) =>
      old.positions != positions || old.isCompleted != isCompleted;
}

// ─── Section Banner ────────────────────────────────────────────────────────────

class _SectionBanner extends StatelessWidget {
  final int moduleNumber;
  final String sectionName;

  const _SectionBanner({
    required this.moduleNumber,
    required this.sectionName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF58CC02), Color(0xFF45A800)],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Module $moduleNumber',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            sectionName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 28),
        ],
      ),
    );
  }
}

// ─── Lesson Circle ─────────────────────────────────────────────────────────────

class _LessonCircle extends StatelessWidget {
  final Lesson lesson;
  final int index;
  final VoidCallback onRefresh;

  const _LessonCircle({
    required this.lesson,
    required this.index,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = lesson.isCompleted;
    final isLocked = lesson.isLocked;

    Color outerColor;
    Color innerColor;
    Widget centerContent;

    if (isCompleted) {
      outerColor = _kGreenDark;
      innerColor = _kGreen;
      centerContent = Text(
        '${index + 1}',
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    } else if (isLocked) {
      outerColor = const Color(0xFFE0E0E0);
      innerColor = const Color(0xFFEEEEEE);
      centerContent = Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '${index + 1}',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const Positioned(
            bottom: 0,
            right: 0,
            child: Icon(
              Icons.lock_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      );
    } else {
      // Current / available
      outerColor = _kGreenDark;
      innerColor = _kGreen;
      centerContent = Text(
        '${index + 1}',
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }

    return GestureDetector(
      onTap: isLocked
          ? () => _showLockedDialog(context)
          : () async {
              try {
                final questions = await ApiService.fetchQuiz(lesson.id);
                lesson.questions = questions;
                if (context.mounted) {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LessonScreen(lesson: lesson),
                    ),
                  );
                  onRefresh();
                }
              } catch (e) {
                // Handle error
              }
            },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Outer ring + inner circle
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: outerColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: outerColor.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: innerColor,
                  shape: BoxShape.circle,
                ),
                child: Center(child: centerContent),
              ),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 90,
            child: Text(
              lesson.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isLocked ? _kGrey : const Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_rounded, color: _kGrey),
            SizedBox(width: 8),
            Text('Lesson Locked'),
          ],
        ),
        content: const Text(
          'Complete the previous lessons to unlock this one.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: _kGreen, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shop Tab (placeholder) ────────────────────────────────────────────────────

class _ShopTab extends StatelessWidget {
  const _ShopTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Shop',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Spend your coins on power-ups!',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: const [
                _ShopItem(
                  icon: '❄️',
                  title: 'Streak Freeze',
                  description: 'Keep your streak safe for one full day of inactivity.',
                  price: 200,
                ),
                SizedBox(height: 16),
                _ShopItem(
                  icon: '💰',
                  title: 'Double Coin Wager',
                  description: 'Double your 50 coin wager if you maintain a 7 day streak.',
                  price: 50,
                ),
                SizedBox(height: 16),
                _ShopItem(
                  icon: '🛡️',
                  title: 'Quiz Shield',
                  description: 'Forgive one wrong answer in your next quiz.',
                  price: 100,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopItem extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final int price;

  const _ShopItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Bought $title!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _kGreen,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: _kGreen, width: 2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💰', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '$price',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  final String title;
  final String emoji;
  final String description;

  const _ComingSoonTab({
    required this.title,
    required this.emoji,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('COMING SOON', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 2)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
