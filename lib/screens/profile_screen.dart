import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _phone = '';
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('phone') ?? 'Learner';
    final userId = prefs.getString('user_id');
    int completedCount = 0;
    if (userId != null) {
      final progress = await ApiService.fetchProgress(userId);
      completedCount = progress.length;
    }
    
    if (mounted) {
      setState(() {
        _phone = phone;
        _completedCount = completedCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = _phone;
    final streak = 0;
    final coins = 0;
    final gems = 0;
    final completedCount = _completedCount;
    final completedLessons = []; // Placeholder to fix compilation error

    return SafeArea(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'My Profile',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 32),
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF58CC02), width: 3),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 56,
                color: Color(0xFF58CC02),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '⭐  Learner',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF856404),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Stats row
            Row(
              children: [
                _StatCard(
                  icon: '🔥',
                  label: 'Day Streak',
                  value: '$streak',
                  color: const Color(0xFFFFF3E0),
                  borderColor: const Color(0xFFFF9800),
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: '💰',
                  label: 'Coins',
                  value: '$coins',
                  color: const Color(0xFFFFF9C4),
                  borderColor: const Color(0xFFFFD600),
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: '💎',
                  label: 'Gems',
                  value: '$gems',
                  color: const Color(0xFFE3F2FD),
                  borderColor: const Color(0xFF1CB0F6),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _StatCard(
              icon: '✅',
              label: 'Lessons Completed',
              value: '$completedCount completed',
              color: const Color(0xFFE8F5E9),
              borderColor: const Color(0xFF58CC02),
              wide: true,
            ),
            const SizedBox(height: 32),
            // Completed lessons list
            if (completedLessons.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Completed Lessons',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...completedLessons.map(
                (lesson) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF58CC02),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesson.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Module ${lesson.moduleNumber} · ${lesson.sectionName}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF888888),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '+${lesson.coinsReward} 💰',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4A017),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  final Color borderColor;
  final bool wide;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.borderColor,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: wide
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              children: [
                Text(icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
    );

    if (wide) return SizedBox(width: double.infinity, child: card);
    return Expanded(child: card);
  }
}
