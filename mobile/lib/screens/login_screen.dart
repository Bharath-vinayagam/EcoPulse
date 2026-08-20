import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_expense_co2/services/api_service.dart';
import 'package:smart_expense_co2/screens/main_navigation.dart';
import 'package:smart_expense_co2/utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final userText = _usernameController.text.trim();
    final emailText = _emailController.text.trim();
    final passText = _passwordController.text.trim();

    if (_isLogin) {
      if (userText.isEmpty || passText.isEmpty) {
        _showError('Please enter your username or email, and password.');
        return;
      }
    } else {
      if (userText.isEmpty || emailText.isEmpty || passText.isEmpty) {
        _showError('Please enter username, email, and password.');
        return;
      }
      if (userText.length < 3) {
        _showError('Username must be at least 3 characters.');
        return;
      }
      if (passText.length < 6) {
        _showError('Strong password required (minimum 6 characters).');
        return;
      }
    }

    setState(() => _isLoading = true);

    Map<String, dynamic> result;
    final prefs = await SharedPreferences.getInstance();
    if (_isLogin) {
      result = await apiService.login(
        usernameOrEmail: userText,
        password: passText,
      );
      await prefs.setBool('is_new_user', false);
    } else {
      result = await apiService.register(
        username: userText,
        email: emailText,
        password: passText,
      );
      await prefs.setBool('is_new_user', true);
    }

    if (mounted) setState(() => _isLoading = false);

    if (result['success'] == true && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    } else if (mounted) {
      _showError(result['message'] ?? 'Authentication failed');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF064E3B), Color(0xFF047857)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.12),
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/ecopulse_logo.jpg',
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeIn(
                    delay: const Duration(milliseconds: 200),
                    child: const Text(
                      'EcoPulse',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FadeIn(
                    delay: const Duration(milliseconds: 300),
                    child: Text(
                      'Track spending. Measure carbon. Save Earth.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isLogin ? 'Welcome Back 👋' : 'Join Eco Tracker 🌿',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isLogin
                                ? 'Sign in to access your carbon dashboard'
                                : 'Create your account to start tracking emissions',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (!_isLogin) ...[
                            TextField(
                              controller: _usernameController,
                              style: const TextStyle(color: Color(0xFF0F172A)),
                              decoration: InputDecoration(
                                labelText: 'Unique Username',
                                hintText: 'e.g. eco_warrior',
                                labelStyle: TextStyle(color: Colors.grey.shade600),
                                prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.primaryGreen),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _emailController,
                              style: const TextStyle(color: Color(0xFF0F172A)),
                              decoration: InputDecoration(
                                labelText: 'Gmail / Email Address',
                                hintText: 'e.g. user@gmail.com',
                                labelStyle: TextStyle(color: Colors.grey.shade600),
                                prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryGreen),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ] else ...[
                            TextField(
                              controller: _usernameController,
                              style: const TextStyle(color: Color(0xFF0F172A)),
                              decoration: InputDecoration(
                                labelText: 'Username or Gmail',
                                hintText: 'e.g. eco_warrior or user@gmail.com',
                                labelStyle: TextStyle(color: Colors.grey.shade600),
                                prefixIcon: const Icon(Icons.account_circle_outlined, color: AppTheme.primaryGreen),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            style: const TextStyle(color: Color(0xFF0F172A)),
                            decoration: InputDecoration(
                              labelText: 'Strong Password',
                              helperText: _isLogin ? null : 'Minimum 6 characters',
                              labelStyle: TextStyle(color: Colors.grey.shade600),
                              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryGreen),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: Colors.grey.shade500,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            obscureText: _obscurePassword,
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                shadowColor: AppTheme.primaryGreen.withOpacity(0.4),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      _isLogin ? 'Sign In' : 'Create Account',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _isLogin = !_isLogin);
                              },
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 14),
                                  children: [
                                    TextSpan(
                                      text: _isLogin
                                          ? "Don't have an account? "
                                          : "Already registered? ",
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                    TextSpan(
                                      text: _isLogin ? "Register" : "Sign In",
                                      style: const TextStyle(
                                        color: AppTheme.primaryGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
