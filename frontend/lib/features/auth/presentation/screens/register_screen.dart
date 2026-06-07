import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leksika/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:leksika/features/auth/presentation/bloc/auth_event.dart';
import 'package:leksika/features/auth/presentation/bloc/auth_state.dart';
import 'package:leksika/features/auth/presentation/screens/syarat_ketentuan_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isAgree = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    context.read<AuthBloc>().add(
          RegisterRequested(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            passwordConfirmation: _passwordConfirmationController.text,
          ),
        );
  }

  // ✅ Buka halaman Syarat & Ketentuan, lalu set _isAgree jika user setuju
  Future<void> _openSyaratKetentuan() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const SyaratKetentuanScreen(),
      ),
    );
    if (result == true) {
      setState(() => _isAgree = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is AuthEmailNotVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.pushReplacementNamed(
            context,
            '/otp',
            arguments: {'email': _emailController.text.trim()},
          );
        }
        if (state is Authenticated) {
          if (state.user.isEmailVerified) {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            Navigator.pushReplacementNamed(
              context,
              '/otp',
              arguments: {'email': state.user.email},
            );
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: Colors.white,
          body: AbsorbPointer(
            absorbing: isLoading,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                          top: 80, bottom: 40, left: 30, right: 30),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1E7E0),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CREATE YOUR\nACCOUNT',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF006947),
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Become a Leksikans today and unlock your AI superpower',
                            style: TextStyle(
                                color: Color(0xFF4A8F83), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        children: [
                          _buildInputField(
                            label: 'Nama',
                            icon: Icons.person_outline,
                            hint: 'Nama lengkap',
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nama wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildInputField(
                            label: 'Email',
                            icon: Icons.email_outlined,
                            hint: 'member@leksika.com',
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildInputField(
                            label: 'Password',
                            icon: Icons.lock_outline,
                            hint: '••••••••',
                            isPassword: true,
                            isObscured: _obscurePassword,
                            controller: _passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password wajib diisi';
                              }
                              return null;
                            },
                            onToggle: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildInputField(
                            label: 'Konfirmasi Password',
                            icon: Icons.lock_clock_outlined,
                            hint: '••••••••',
                            isPassword: true,
                            isObscured: _obscureConfirmPassword,
                            controller: _passwordConfirmationController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Konfirmasi password wajib diisi';
                              }
                              if (value != _passwordController.text) {
                                return 'Password tidak sama';
                              }
                              return null;
                            },
                            onToggle: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          const SizedBox(height: 15),

                          // ✅ FIX: Checkbox + teks "Terms of Service" yang bisa diklik
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: _isAgree,
                                onChanged: isLoading
                                    ? null
                                    : (v) => setState(() => _isAgree = v!),
                                activeColor: const Color(0xFF006947),
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black87,
                                    ),
                                    children: [
                                      const TextSpan(
                                          text: 'I agree to the '),
                                      TextSpan(
                                        text: 'Terms of Service and Privacy Policy',
                                        style: const TextStyle(
                                          color: Color(0xFF006947),
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = isLoading
                                              ? null
                                              : _openSyaratKetentuan,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF006947),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: _isAgree && !isLoading ? _submit : null,
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'BUAT AKUN →',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Sudah punya akun? '),
                              GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : () {
                                        if (Navigator.canPop(context)) {
                                          Navigator.pop(context);
                                        } else {
                                          Navigator.pushReplacementNamed(
                                            context,
                                            '/login',
                                          );
                                        }
                                      },
                                child: const Text(
                                  'Log in',
                                  style: TextStyle(
                                    color: Color(0xFF006947),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onToggle,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? isObscured : false,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF006947)),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                        isObscured ? Icons.visibility_off : Icons.visibility),
                    onPressed: onToggle,
                    color: Colors.grey,
                  )
                : null,
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
