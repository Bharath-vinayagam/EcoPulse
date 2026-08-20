import 'dart:io';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_expense_co2/main.dart';
import 'package:smart_expense_co2/services/api_service.dart';
import 'package:smart_expense_co2/utils/app_theme.dart';
import 'package:smart_expense_co2/screens/tips_screen.dart';
import 'package:smart_expense_co2/screens/leaderboard_screen.dart';
import 'package:smart_expense_co2/screens/login_screen.dart';
import 'package:smart_expense_co2/screens/ai_chat_screen.dart';
import 'package:smart_expense_co2/screens/transport_compare_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    _loadSavedAvatar();
    _loadProfile();
  }

  Future<void> _loadSavedAvatar() async {
    final uid = apiService.userId;
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('user_avatar_file_path_$uid');
    if (savedPath != null && savedPath.isNotEmpty) {
      final file = File(savedPath);
      if (file.existsSync()) {
        setState(() => _avatarFile = file);
        return;
      }
    }
    setState(() => _avatarFile = null);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final uid = apiService.userId;
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_avatar_file_path_$uid', file.path);
        if (mounted) {
          setState(() {
            _avatarFile = file;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('🎉 Profile photo updated!'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      print('Pick image error: $e');
    }
  }

  Future<void> _removePhoto() async {
    final uid = apiService.userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_avatar_file_path_$uid');
    setState(() {
      _avatarFile = null;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🗑️ Profile photo removed!'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('📸 Update Profile Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: AppTheme.primaryGreen),
                  ),
                  title: const Text('Take Live Photo (Camera)', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyan.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: AppTheme.accentCyan),
                  ),
                  title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_avatarFile != null) ...[
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    ),
                    title: const Text('Remove Photo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                    onTap: () {
                      Navigator.pop(context);
                      _removePhoto();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await apiService.getProfile().timeout(const Duration(seconds: 4), onTimeout: () => null);
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showEcoForestBottomSheet(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ecoData = await apiService.getEcoOffset();

    final totalCo2 = (ecoData?['total_co2_kg'] as num?)?.toDouble() ?? 0.0;
    final treesNeeded = (ecoData?['trees_needed_annual'] as num?)?.toDouble() ?? (totalCo2 / 21.7);
    int virtualPlanted = (ecoData?['virtual_trees_planted'] as num?)?.toInt() ?? 0;
    int points = (ecoData?['user_points'] as num?)?.toInt() ?? (_profile?['total_points'] ?? 0);
    String grade = ecoData?['eco_grade'] ?? 'A';
    String status = ecoData?['eco_status'] ?? 'Low Carbon Champion 🌱';

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '🌲 Digital Eco Forest & Offset',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.heroGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppTheme.emeraldGlow,
                    ),
                    child: Column(
                      children: [
                        const Text('🌱 ECO GRADE RATING', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const SizedBox(height: 6),
                        Text(
                          grade,
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        Text(
                          status,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              const Text('🌳 Trees Needed', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                '${treesNeeded.toStringAsFixed(1)} Trees',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                              ),
                              const Text('to offset annual CO₂', style: TextStyle(fontSize: 9, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              const Text('🪴 Virtual Planted', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                '$virtualPlanted Trees',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00E5FF)),
                              ),
                              Text('$points pts available', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.park_rounded, color: Colors.white),
                      label: const Text(
                        'Pledge 100 Pts to Plant a Tree 🌳',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      onPressed: points < 100
                          ? null
                          : () async {
                              final res = await apiService.plantTree();
                              if (res != null) {
                                setModalState(() {
                                  points = res['remaining_points'] ?? (points - 100);
                                  virtualPlanted = res['virtual_trees_planted'] ?? (virtualPlanted + 1);
                                });
                                _loadProfile();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('🎉 Virtual Tree Planted in your Eco Forest!'),
                                      backgroundColor: AppTheme.success,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                }
                              }
                            },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsCards(isDark),
                        const SizedBox(height: 24),
                        _buildMenuSection(isDark),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeaderAppBar(bool isDark) {
    final name = _profile?['name'] ?? 'User';
    final email = _profile?['email'] ?? 'user@example.com';
    final level = (_profile?['level'] as int?) ?? 1;
    final points = (_profile?['total_points'] ?? _profile?['points']) ?? 0;
    final streak = (_profile?['streak_days'] ?? _profile?['streak']) ?? 0;

    return SliverAppBar(
      expandedHeight: 260,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF0F4C81), Color(0xFF0284C7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                FadeInDown(
                  child: GestureDetector(
                    onTap: () => _showImageSourceDialog(context),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryGreen.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 44,
                            backgroundImage: _avatarFile != null ? FileImage(_avatarFile!) as ImageProvider : null,
                            backgroundColor: AppTheme.primaryGreen,
                            child: _avatarFile == null
                                ? Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.neonGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeIn(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 14),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeaderPill('Lvl $level', Icons.military_tech_rounded, const Color(0xFFFFD700)),
                      const SizedBox(width: 8),
                      _buildHeaderPill('$points pts', Icons.stars_rounded, AppTheme.accentCyan),
                      const SizedBox(width: 8),
                      _buildHeaderPill('$streak Days', Icons.local_fire_department_rounded, const Color(0xFFFF5722)),
                    ],
                  ),
                ),
              ],
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
          onPressed: _loadProfile,
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildHeaderPill(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(bool isDark) {
    final co2Goal = (_profile?['monthly_co2_goal'] as num?)?.toDouble() ?? 100.0;
    final spendGoal = (_profile?['monthly_spending_goal'] as num?)?.toDouble() ?? 50000.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Preferences & Goals', style: AppTheme.heading2),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildGoalCard(
                'CO₂ Target',
                '${co2Goal.toStringAsFixed(0)} kg',
                Icons.co2_rounded,
                AppTheme.heroGradient,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGoalCard(
                'Spending Limit',
                '₹${spendGoal.toStringAsFixed(0)}',
                Icons.account_balance_wallet_rounded,
                AppTheme.blueGradient,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoalCard(String label, String value, IconData icon, Gradient gradient) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentCyan.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: isDark ? AppTheme.accentCyan : const Color(0xFFF59E0B),
                size: 24,
              ),
            ),
            title: Text(
              'Dark Mode',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            subtitle: Text(
              isDark ? 'Obsidian Dark theme active' : 'Clean Light theme active',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            trailing: Switch.adaptive(
              value: isDark,
              activeColor: AppTheme.neonGreen,
              onChanged: (val) async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('dark_mode', val);
                themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
              },
            ),
          ),
          const Divider(height: 1, indent: 64),
          _buildMenuItem(
            icon: Icons.auto_awesome_rounded,
            color: AppTheme.accentCyan,
            title: 'EcoPulse AI Assistant',
            subtitle: 'Chat with AI for custom carbon advice',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AiChatScreen())),
          ),
          const Divider(height: 1, indent: 64),
          _buildMenuItem(
            icon: Icons.directions_car_rounded,
            color: AppTheme.accentCyan,
            title: 'Transport Carbon Comparator',
            subtitle: 'Compare Metro vs Solo Cab vs EV emissions',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TransportCompareScreen())),
          ),
          const Divider(height: 1, indent: 64),
          _buildMenuItem(
            icon: Icons.lightbulb_rounded,
            color: const Color(0xFFFFD700),
            title: 'Eco Recommendations',
            subtitle: 'Tips to lower your carbon footprint',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TipsScreen())),
          ),
          const Divider(height: 1, indent: 64),
          _buildMenuItem(
            icon: Icons.file_download_rounded,
            color: AppTheme.accentCyan,
            title: 'Export Carbon & Expense Audit',
            subtitle: 'Download CSV audit report or view summary',
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                builder: (ctx) => SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📄 Export Carbon Audit & Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.15), shape: BoxShape.circle),
                            child: const Icon(Icons.table_chart_rounded, color: AppTheme.primaryGreen),
                          ),
                          title: const Text('Export Full CSV Audit', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Download all raw expense & CO₂ logs as CSV'),
                          onTap: () async {
                            Navigator.pop(ctx);
                            final csvData = await apiService.exportExpensesCSV();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    csvData != null
                                        ? '✅ CSV Audit Report generated! (${csvData.split('\n').length - 1} rows exported)'
                                        : 'Failed to generate CSV report. Check network.',
                                  ),
                                  backgroundColor: AppTheme.success,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          },
                        ),
                        const Divider(height: 1, indent: 56),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: AppTheme.accentCyan.withOpacity(0.15), shape: BoxShape.circle),
                            child: const Icon(Icons.analytics_rounded, color: AppTheme.accentCyan),
                          ),
                          title: const Text('View Monthly Executive Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Monthly CO₂ grade, spend breakdown & tree offset'),
                          onTap: () {
                            Navigator.pop(ctx);
                            _showEcoForestBottomSheet(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 64),
          _buildMenuItem(
            icon: Icons.emoji_events_rounded,
            color: const Color(0xFFFF9800),
            title: 'Community Leaderboard',
            subtitle: 'Compare rankings with active users',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaderboardScreen())),
          ),
          const Divider(height: 1, indent: 64),
          _buildMenuItem(
            icon: Icons.logout_rounded,
            color: AppTheme.error,
            title: 'Sign Out',
            subtitle: 'Log out of your account session',
            onTap: () async {
              await apiService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
    );
  }
}
