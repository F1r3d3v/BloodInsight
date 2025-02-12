import 'package:bloodinsight/core/styles/assets.dart';
import 'package:bloodinsight/core/styles/colors.dart';
import 'package:bloodinsight/core/styles/sizes.dart';
import 'package:bloodinsight/features/auth/data/auth_state.dart';
import 'package:bloodinsight/features/auth/logic/auth_cubit.dart';
import 'package:bloodinsight/features/user_profile/data/user_profile_model.dart';
import 'package:bloodinsight/shared/services/user_profile_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

enum SignUpStep {
  credentials,
  personalInfo,
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _credentialsFormKey = GlobalKey<FormState>();
  final _personalInfoFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _gender;
  String? _bloodType;
  bool _isPasswordVisible = false;
  SignUpStep _currentStep = SignUpStep.credentials;

  final List<String> _genders = ['Male', 'Female'];
  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Widget _buildCredentialsForm() {
    return Form(
      key: _credentialsFormKey,
      child: Column(
        children: [
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
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
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
        ],
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
    return Form(
      key: _personalInfoFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              hintText: 'Enter your name',
              prefixIcon: Icon(
                Icons.person_outline,
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
                return 'Please enter your name';
              }
              return null;
            },
          ),
          Sizes.kGap20,
          InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                prefixIcon: Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).primaryColor,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.9),
                border: OutlineInputBorder(
                  borderRadius: Sizes.kRadius12,
                  borderSide: BorderSide.none,
                ),
              ),
              child: Text(
                _dateOfBirth == null
                    ? 'Select your date of birth'
                    : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
              ),
            ),
          ),
          Sizes.kGap20,
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: InputDecoration(
              labelText: 'Gender',
              prefixIcon: Icon(
                Icons.person_outline,
                color: Theme.of(context).primaryColor,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.9),
              border: OutlineInputBorder(
                borderRadius: Sizes.kRadius12,
                borderSide: BorderSide.none,
              ),
            ),
            items: _genders.map((gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _gender = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your gender';
              }
              return null;
            },
          ),
          Sizes.kGap20,
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Height (cm)',
                    prefixIcon: Icon(
                      Icons.height,
                      color: Theme.of(context).primaryColor,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.9),
                    border: OutlineInputBorder(
                      borderRadius: Sizes.kRadius12,
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid';
                    }
                    return null;
                  },
                ),
              ),
              Sizes.kGap20,
              Expanded(
                child: TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Weight (kg)',
                    prefixIcon: Icon(
                      Icons.monitor_weight_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.9),
                    border: OutlineInputBorder(
                      borderRadius: Sizes.kRadius12,
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          Sizes.kGap20,
          DropdownButtonFormField<String>(
            value: _bloodType,
            decoration: InputDecoration(
              labelText: 'Blood Type (Optional)',
              prefixIcon: Icon(
                Icons.bloodtype_outlined,
                color: Theme.of(context).primaryColor,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.9),
              border: OutlineInputBorder(
                borderRadius: Sizes.kRadius12,
                borderSide: BorderSide.none,
              ),
            ),
            items: _bloodTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _bloodType = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _finishSignUp() async {
    final authCubit = context.read<AuthCubit>();
    final profileService = context.read<ProfileService>();

    await authCubit.signInWithCredentials(
      _emailController.text,
      _passwordController.text,
    );

    if (authCubit.state is SignedInState) {
      final userId = authCubit.userId!;
      final userProfile = UserProfile(
        id: userId,
        name: _nameController.text,
        email: _emailController.text,
        dateOfBirth: _dateOfBirth!,
        gender: _gender!,
        bloodType: _bloodType,
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
      );

      await profileService.upsertProfile(userId, userProfile);

      if (mounted) {
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) async {
        if (state is SignedUpState) {
          await _finishSignUp();
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Container(
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
                      if (_currentStep == SignUpStep.credentials) ...[
                        Image.asset(
                          AppImages.logoBanner,
                          height: 100,
                        ),
                        Sizes.kGap30,
                      ],
                      Text(
                        _currentStep == SignUpStep.credentials
                            ? 'Create Account'
                            : 'Tell Us More',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Sizes.kGap10,
                      Text(
                        _currentStep == SignUpStep.credentials
                            ? 'Sign up to start your health journey'
                            : 'Help us personalize your experience',
                        style: TextStyle(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.8),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Sizes.kGap40,
                      if (_currentStep == SignUpStep.credentials)
                        _buildCredentialsForm()
                      else
                        _buildPersonalInfoForm(),
                      if (state case SignedOutState(:final error?)) ...[
                        Sizes.kGap20,
                        Align(
                          child: Text(
                            error,
                            style: const TextStyle(
                              color: AppColors.bittersweet,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                      Sizes.kGap30,
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: Sizes.kRadius16,
                            ),
                          ),
                          onPressed: state is SigningUpState
                              ? null
                              : () async {
                                  if (_currentStep == SignUpStep.credentials) {
                                    if (_credentialsFormKey.currentState!
                                        .validate()) {
                                      setState(() {
                                        _currentStep = SignUpStep.personalInfo;
                                      });
                                    }
                                  } else {
                                    if (_personalInfoFormKey.currentState!
                                        .validate()) {
                                      await context
                                          .read<AuthCubit>()
                                          .signUpWithCredentials(
                                            _emailController.text,
                                            _passwordController.text,
                                          );
                                    }
                                  }
                                },
                          child: state is SigningUpState
                              ? const SizedBox.square(
                                  dimension: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _currentStep == SignUpStep.credentials
                                      ? 'Continue'
                                      : 'Create Account',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      Sizes.kGap20,
                      if (_currentStep == SignUpStep.credentials) ...[
                        Align(
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyLarge,
                              children: <TextSpan>[
                                const TextSpan(
                                  text: 'Already have an account?',
                                ),
                                const TextSpan(text: ' '),
                                TextSpan(
                                  text: 'Sign In',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      context.go('/login');
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _currentStep = SignUpStep.credentials;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_back,
                                size: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Back to Credentials',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
