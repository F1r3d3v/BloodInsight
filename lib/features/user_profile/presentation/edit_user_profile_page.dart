import 'package:bloodinsight/core/styles/sizes.dart';
import 'package:bloodinsight/core/styles/style.dart';
import 'package:bloodinsight/features/user_profile/data/user_profile_model.dart';
import 'package:bloodinsight/shared/services/user_profile_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
    required this.profile,
  });

  final UserProfile profile;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late DateTime _dateOfBirth;
  late String _gender;
  String? _bloodType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _heightController =
        TextEditingController(text: widget.profile.height.toString());
    _weightController =
        TextEditingController(text: widget.profile.weight.toString());
    _dateOfBirth = widget.profile.dateOfBirth;
    _gender = widget.profile.gender;
    _bloodType = widget.profile.bloodType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedProfile = widget.profile.copyWith(
        name: _nameController.text,
        dateOfBirth: _dateOfBirth,
        gender: _gender,
        bloodType: _bloodType,
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
      );

      await context.read<ProfileService>().updateProfileFields(
            widget.profile.id,
            updatedProfile.toJson(),
          );

      if (context.mounted) {
        context
          ..showSnackBar('Profile updated succesfully')
          ..pop();
      }
    } catch (err) {
      if (context.mounted) {
        context.showSnackBar(
          'Error updating profile: $err',
          isError: true,
          duration: const Duration(seconds: 5),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: Sizes.kPaddH12,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => _save(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: Sizes.kPadd20,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldContainer(
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    icon: Icon(Icons.person_outline),
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
              ),
              Sizes.kGap20,
              _buildFieldContainer(
                Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    Sizes.kGap15,
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _dateOfBirth,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => _dateOfBirth = date);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth',
                            border: InputBorder.none,
                          ),
                          child: Text(
                            DateFormat('MMM d, y').format(_dateOfBirth),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Sizes.kGap20,
              _buildFieldContainer(
                Row(
                  children: [
                    if (_gender == 'Male')
                      const Icon(Icons.male_outlined)
                    else
                      const Icon(Icons.female_outlined),
                    Sizes.kGap15,
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          border: InputBorder.none,
                        ),
                        items: ['Male', 'Female']
                            .map(
                              (gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _gender = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Sizes.kGap20,
              _buildFieldContainer(
                Row(
                  children: [
                    const Icon(Icons.bloodtype_outlined),
                    Sizes.kGap15,
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _bloodType,
                        decoration: const InputDecoration(
                          labelText: 'Blood Type',
                          border: InputBorder.none,
                        ),
                        items:
                            ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() => _bloodType = value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Sizes.kGap20,
              Row(
                children: [
                  Expanded(
                    child: _buildFieldContainer(
                      TextFormField(
                        controller: _heightController,
                        decoration: const InputDecoration(
                          labelText: 'Height (cm)',
                          icon: Icon(Icons.height),
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final height = double.tryParse(value);
                          if (height == null || height <= 0) {
                            return 'Invalid height';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  Sizes.kGap20,
                  Expanded(
                    child: _buildFieldContainer(
                      TextFormField(
                        controller: _weightController,
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                          icon: Icon(Icons.monitor_weight_outlined),
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final weight = double.tryParse(value);
                          if (weight == null || weight <= 0) {
                            return 'Invalid weight';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldContainer(Widget child) {
    return Container(
      padding: Sizes.kPadd16,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Sizes.kRadius12,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}
