import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:smart_expense_co2/services/api_service.dart';
import 'package:smart_expense_co2/utils/app_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = apiService.userId;
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      final data = await apiService.getLeaderboard().timeout(const Duration(seconds: 4), onTimeout: () => []);
      if (mounted) {
        setState(() {
          _leaderboard = data;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : CustomScrollView(
              slivers: [
                _buildHeaderAppBar(isDark),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      if (_leaderboard.isNotEmpty) _buildPodiumSection(isDark),
                      const SizedBox(height: 20),
                      _buildRankingsList(isDark),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeaderAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFFD97706), Color(0xFFF59E0B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FadeInDown(
                    child: const Text(
                      'COMMUNITY RANKINGS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Leaderboard',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 26),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
          ),
          onPressed: _loadLeaderboard,
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildPodiumSection(bool isDark) {
    final first = _leaderboard.isNotEmpty ? _leaderboard[0] : null;
    final second = _leaderboard.length > 1 ? _leaderboard[1] : null;
    final third = _leaderboard.length > 2 ? _leaderboard[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (second != null) _buildPodiumItem(second, 2, 85, isDark),
            if (first != null) _buildPodiumItem(first, 1, 110, isDark),
            if (third != null) _buildPodiumItem(third, 3, 75, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> user, int rank, double height, bool isDark) {
    final name = (user['name'] as String?) ?? 'User';
    final points = (user['total_points'] ?? user['points']) ?? 0;
    final isMe = user['user_id'] == _currentUserId || user['id'] == _currentUserId;

    Color badgeColor;
    String badgeEmoji;
    switch (rank) {
      case 1:
        badgeColor = const Color(0xFFFFD700);
        badgeEmoji = '🥇';
        break;
      case 2:
        badgeColor = const Color(0xFFC0C0C0);
        badgeEmoji = '🥈';
        break;
      default:
        badgeColor = const Color(0xFFCD7F32);
        badgeEmoji = '🥉';
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(badgeEmoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: badgeColor, width: 2),
          ),
          child: CircleAvatar(
            radius: rank == 1 ? 24 : 20,
            backgroundColor: badgeColor.withOpacity(0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isMe ? AppTheme.primaryGreen : (isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ),
        Text(
          '$points pts',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFD97706)),
        ),
        const SizedBox(height: 8),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            gradient: rank == 1
                ? AppTheme.goldGradient
                : LinearGradient(
                    colors: [badgeColor.withOpacity(0.7), badgeColor],
                  ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankingsList(bool isDark) {
    final remaining = _leaderboard.length > 3 ? _leaderboard.sublist(3) : _leaderboard;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('All Rankings', style: AppTheme.heading2),
          const SizedBox(height: 12),
          if (_leaderboard.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(child: Text('No leaderboard data found')),
            )
          else
            ...remaining.asMap().entries.map((entry) {
              final idx = entry.key;
              final user = entry.value;
              final rank = user['rank'] ?? (idx + 1);
              final name = (user['name'] as String?) ?? 'User';
              final points = (user['total_points'] ?? user['points']) ?? 0;
              final isMe = user['user_id'] == _currentUserId || user['id'] == _currentUserId;

              return FadeInUp(
                delay: Duration(milliseconds: 50 * idx),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppTheme.primaryGreen.withOpacity(0.12)
                        : (isDark ? AppTheme.cardDark : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isMe ? AppTheme.primaryGreen : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
                      width: isMe ? 2 : 1,
                    ),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isMe ? AppTheme.primaryGreen : Colors.grey.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '#$rank',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isMe ? Colors.white : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryGreen,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('YOU', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$points pts',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
