import 'package:bloodinsight/core/styles/assets.dart';
import 'package:bloodinsight/core/styles/colors.dart';
import 'package:bloodinsight/core/styles/sizes.dart';
import 'package:bloodinsight/features/auth/data/auth_state.dart';
import 'package:bloodinsight/features/auth/logic/auth_cubit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is SignedInState) {
          context.go('/dashboard');
        }
      },
      builder: (context, state) {
        final authCubit = context.read<AuthCubit>();
        return Material(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.icterine700,
                  AppColors.icterine600,
                  AppColors.icterine500,
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: Sizes.kPadd24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Sizes.kGap30,
                      Image.asset(
                        AppImages.logoBanner,
                        height: 100,
                      ),
                      Sizes.kGap30,
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Sizes.kGap10,
                      Text(
                        'Sign in to continue your health journey',
                        style: TextStyle(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.8),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Sizes.kGap40,
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'Enter your email',
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: Theme.of(context).primaryColor,
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.9),
                                border: OutlineInputBorder(
                                  borderRadius: Sizes.kRadius12,
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: Sizes.kRadius12,
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: Sizes.kRadius12,
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            Sizes.kGap20,
                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: Theme.of(context).primaryColor,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.9),
                                border: OutlineInputBorder(
                                  borderRadius: Sizes.kRadius12,
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: Sizes.kRadius12,
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: Sizes.kRadius12,
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            if (state case SignedOutState(:final error?)) ...[
                              Sizes.kGap20,
                              Text(
                                error,
                                style: const TextStyle(
                                  color: AppColors.bittersweet,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                            Sizes.kGap30,
                            // Sign In Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: Sizes.kRadius16,
                                  ),
                                ),
                                onPressed: state is SigningInState
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          authCubit.signInWithCredentials(
                                            _emailController.text,
                                            _passwordController.text,
                                          );
                                        }
                                      },
                                child: state is SigningInState &&
                                        state.method == SignInMethod.email
                                    ? const SizedBox.square(
                                        dimension: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            Sizes.kGap20,
                            // Sign Up Link
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey[400],
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: Sizes.kPaddH12,
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey[400],
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            Sizes.kGap20,
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey[300]!),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: Sizes.kRadius16,
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: state is SigningInState
                                    ? null
                                    : () => context
                                        .read<AuthCubit>()
                                        .signInWithGoogle(),
                                icon: state is SigningInState &&
                                        state.method == SignInMethod.google
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.grey,
                                          ),
                                        ),
                                      )
                                    : Image.asset(
                                        'assets/images/google_logo.png',
                                        height: 24,
                                      ),
                                label: Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ),
                            Sizes.kGap20,
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyLarge,
                                children: <TextSpan>[
                                  const TextSpan(
                                    text: "Don't have an account?",
                                  ),
                                  const TextSpan(text: ' '),
                                  TextSpan(
                                    text: 'Sign Up',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        context.go('/sign-up');
                                      },
                                  ),
                                ],
                              ),
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
        );
      },
    );
  }
}
