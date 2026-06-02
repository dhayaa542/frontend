class UserProfile {
  final String username;
  final int streak;
  final int coins;
  final int gems;
  final int completedLessons;

  const UserProfile({
    required this.username,
    required this.streak,
    required this.coins,
    required this.gems,
    required this.completedLessons,
  });
}
