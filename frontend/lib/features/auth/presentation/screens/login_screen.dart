import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leksika/core/services/google_auth_service.dart';
import 'package:leksika/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:leksika/features/auth/presentation/bloc/auth_event.dart';
import 'package:leksika/features/auth/presentation/bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isRemember = false;
  bool _obs = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    context.read<AuthBloc>().add(
          LoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  Future<void> _googleSignIn() async {
    final idToken = await GoogleAuthService.getIdToken();
    if (idToken == null) return;
    if (!mounted) return;
    context.read<AuthBloc>().add(GoogleLoginRequested(idToken));
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
          Navigator.pushNamed(context, '/otp');
        }
        if (state is Authenticated) {
          if (state.user.isEmailVerified) {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            Navigator.pushNamed(context, '/otp');
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
                          top: 80, bottom: 50, left: 30, right: 30),
                      decoration: const BoxDecoration(
                        color: Color(0xFF76B0A6),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WELCOME BACK,\nLeksikans!',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3F39),
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Ready to ace your study session today?',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        children: [
                          _field(
                            label: 'Email',
                            icon: Icons.email_outlined,
                            hint: 'example@leksikans.com',
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          _field(
                            label: 'Password',
                            icon: Icons.lock_outline,
                            hint: '••••••••',
                            isPass: true,
                            controller: _passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password wajib diisi';
                              }
                              return null;
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _isRemember,
                                    onChanged: isLoading
                                        ? null
                                        : (v) => setState(() => _isRemember = v!),
                                    activeColor: const Color(0xFF006947),
                                  ),
                                  const Text('Remember me',
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                              TextButton(
                                onPressed: isLoading ? null : () {},
                                child: const Text(
                                  'Lupa password?',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _btn(
                            isLoading: isLoading,
                            onPressed: isLoading ? null : _submit,
                          ),
                          const SizedBox(height: 20),
                          const Text('Or continue with',
                              style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 15),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            icon: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.g_mobiledata, size: 30, color: Colors.blue),
                            label: Text(
                              isLoading ? 'Memuat...' : 'Google',
                              style: const TextStyle(color: Colors.black),
                            ),
                            onPressed: isLoading ? null : _googleSignIn,
                          ),
                          const SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Belum punya akun? '),
                              GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : () => Navigator.pushNamed(context, '/register'),
                                child: const Text(
                                  'Daftar sekarang',
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

  Widget _field({
    required String label,
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool isPass = false,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        obscureText: isPass ? _obs : false,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF006947)),
          suffixIcon: isPass
              ? IconButton(
                  icon: Icon(_obs ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obs = !_obs),
                )
              : null,
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ]);
  }

  Widget _btn({required bool isLoading, required VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF006947),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: onPressed,
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
                'LOGIN →',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}