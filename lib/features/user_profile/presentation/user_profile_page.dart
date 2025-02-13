import 'package:bloodinsight/core/connectivity_status.dart';
import 'package:bloodinsight/core/styles/sizes.dart';
import 'package:bloodinsight/core/styles/style.dart';
import 'package:bloodinsight/features/auth/logic/auth_cubit.dart';
import 'package:bloodinsight/features/user_profile/data/user_profile_model.dart';
import 'package:bloodinsight/shared/services/auth_service.dart';
import 'package:bloodinsight/shared/services/user_profile_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final profileService = context.read<ProfileService>();
    final userId = context.read<AuthService>().currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await context.push(
                '/profile/edit',
                extra: await profileService.getProfile(userId),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<UserProfile?>(
        stream: profileService.streamProfile(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            context
              ..showSnackBar(
                'Error: ${snapshot.error}',
                isError: true,
                duration: const Duration(seconds: 5),
              )
              ..pop();
            return Sizes.kEmptyWidget;
          }

          final profile = snapshot.data;
          if (profile == null) {
            context
              ..showSnackBar('Profile not found', isError: true)
              ..pop();
            return Sizes.kEmptyWidget;
          }

          return SingleChildScrollView(
            padding: Sizes.kPadd16,
            child: Column(
              children: [
                _buildProfileHeader(context, profile),
                Sizes.kGap30,
                _buildHealthMetrics(context, profile, profileService),
                Sizes.kGap30,
                _buildPersonalInfo(context, profile),
                Sizes.kGap20,
                _buildSignOutButton(context, authCubit),
                Sizes.kGap20,
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile profile) {
    final isConnected = GetIt.I<ConnectionStatus>().hasConnection;
    final showOfflineBanner =
        !isConnected || (isConnected && profile.photoUrl == null);
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).primaryColor,
          backgroundImage:
              showOfflineBanner ? null : NetworkImage(profile.photoUrl!),
          child: showOfflineBanner
              ? Text(
                  profile.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        Sizes.kGap15,
        Text(
          profile.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          profile.email,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildHealthMetrics(
    BuildContext context,
    UserProfile profile,
    ProfileService profileService,
  ) {
    final bmi = profileService.calculateBMI(profile);

    return Container(
      padding: Sizes.kPadd20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Sizes.kRadius16,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMetricRow(
            context,
            icon: Icons.monitor_weight_outlined,
            label: 'Weight',
            value: '${profile.weight} kg',
          ),
          const Divider(),
          _buildMetricRow(
            context,
            icon: Icons.height,
            label: 'Height',
            value: '${profile.height} cm',
          ),
          const Divider(),
          _buildMetricRow(
            context,
            icon: Icons.health_and_safety_outlined,
            label: 'BMI',
            value: bmi.toStringAsFixed(1),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo(BuildContext context, UserProfile profile) {
    return Container(
      padding: Sizes.kPadd20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Sizes.kRadius16,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            context,
            icon: Icons.calendar_today,
            label: 'Date of Birth',
            value: DateFormat('MMM d, y').format(profile.dateOfBirth),
          ),
          const Divider(),
          _buildInfoRow(
            context,
            icon: (profile.gender == 'Male')
                ? Icons.male_outlined
                : Icons.female_outlined,
            label: 'Gender',
            value: profile.gender,
          ),
          const Divider(),
          _buildInfoRow(
            context,
            icon: Icons.bloodtype_outlined,
            label: 'Blood Type',
            value: profile.bloodType ?? 'Not specified',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: Sizes.kPadd12,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          Sizes.kGap15,
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: Sizes.kPadd12,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          Sizes.kGap15,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, AuthCubit authCubit) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: Sizes.kPaddH20,
        child: OutlinedButton.icon(
          onPressed: () async {
            await authCubit.signOut();
            if (context.mounted) {
              context.go('/login');
            }
          },
          icon: const Icon(Icons.logout),
          label: const Text('Sign Out'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: Theme.of(context).primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: Sizes.kRadius12,
            ),
          ),
        ),
      ),
    );
  }
}
