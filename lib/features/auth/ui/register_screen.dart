import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/auth_cubit.dart';
import '../logic/auth_state.dart';
import '../../../core/repositories/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // Loading state managed by BLoC
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final name =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
    AuthCubit.get(context).register(
      name: name,
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(AuthRepository()),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthRegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green.shade400,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            Navigator.pushReplacementNamed(context, '/location-permission');
          } else if (state is AuthRegisterError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthRegisterLoading;
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Image.asset('assets/images/splash_screen.png', width: 160, height: 80, fit: BoxFit.contain),
                      const SizedBox(height: 16),
                      const Text('Sign up', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0D3B66))),
                      const SizedBox(height: 28),
                      _buildLabel('Name'),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: TextFormField(controller: _firstNameController, decoration: _buildInputDecoration(hint: 'First name', icon: Icons.person_outline), validator: (value) { if (value == null || value.isEmpty) return 'Required'; return null; })),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(controller: _lastNameController, decoration: _buildInputDecoration(hint: 'Last name', icon: Icons.person_outline), validator: (value) { if (value == null || value.isEmpty) return 'Required'; return null; })),
                      ]),
                      const SizedBox(height: 20),
                      _buildLabel('Email'),
                      const SizedBox(height: 8),
                      TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: _buildInputDecoration(hint: 'Enter your Email', icon: Icons.email_outlined), validator: (value) { if (value == null || value.isEmpty) return 'Please enter your email'; if (!value.contains('@')) return 'Please enter a valid email'; return null; }),
                      const SizedBox(height: 20),
                      _buildLabel('Password'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _buildInputDecoration(hint: 'Enter your password', icon: Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey), onPressed: () { setState(() => _obscurePassword = !_obscurePassword); }),
                        ),
                        validator: (value) { if (value == null || value.isEmpty) return 'Please enter a password'; if (value.length < 8) return 'Password must be at least 8 characters'; return null; },
                      ),
                      const SizedBox(height: 4),
                      Align(alignment: Alignment.centerLeft, child: Text('Password must be 8+ characters, include 1 uppercase letter, 1 number', style: TextStyle(fontSize: 11, color: Colors.grey.shade500))),
                      const SizedBox(height: 16),
                      _buildLabel('Confirm password'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: _buildInputDecoration(hint: 'Confirm your password', icon: Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey), onPressed: () { setState(() => _obscureConfirmPassword = !_obscureConfirmPassword); }),
                        ),
                        validator: (value) { if (value != _passwordController.text) return 'Passwords do not match'; return null; },
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => _register(context),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D3B66), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                          child: isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : const Text('Sign up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text('Already have an account? ', style: TextStyle(color: Color(0xFF4F4F4F), fontSize: 14)),
                        GestureDetector(onTap: () => Navigator.pushReplacementNamed(context, '/login'), child: const Text('Sign in', style: TextStyle(color: Color(0xFF0D3B66), fontWeight: FontWeight.bold, fontSize: 14, decoration: TextDecoration.underline))),
                      ]),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(alignment: Alignment.centerLeft, child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333))));
  }

  InputDecoration _buildInputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint, hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
      filled: true, fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D3B66), width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
    );
  }
}
