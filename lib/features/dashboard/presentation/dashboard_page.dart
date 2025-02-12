import 'package:bloodinsight/core/styles/colors.dart';
import 'package:bloodinsight/core/styles/sizes.dart';
import 'package:bloodinsight/core/styles/style.dart';
import 'package:bloodinsight/features/bloodwork/data/bloodwork_model.dart';
import 'package:bloodinsight/features/reminders/data/remainder_model.dart';
import 'package:bloodinsight/features/user_profile/data/user_profile_model.dart';
import 'package:bloodinsight/shared/services/auth_service.dart';
import 'package:bloodinsight/shared/services/bloodwork_service.dart';
import 'package:bloodinsight/shared/services/reminder_service.dart';
import 'package:bloodinsight/shared/services/user_profile_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _prefetchProfileImage();
  }

  Future<void> _prefetchProfileImage() async {
    final profileService = context.read<ProfileService>();
    final userId = context.read<AuthService>().currentUser!.uid;
    final profile = await profileService.getProfile(userId);

    if (profile?.photoUrl != null && mounted) {
      await precacheImage(
        NetworkImage(profile!.photoUrl!),
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final profileService = context.read<ProfileService>();
    final reminderService = context.read<ReminderService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
      ),
      body: StreamBuilder<UserProfile?>(
        stream: profileService.streamProfile(authService.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final profile = snapshot.data;
          final userName = profile?.name;

          return SingleChildScrollView(
            padding: Sizes.kPadd20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                Text(
                  (userName != null) ? 'Hello, $userName!' : 'Hello!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Sizes.kGap5,
                Text(
                  "Here's your health overview",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.7),
                      ),
                ),
                Sizes.kGap25,
                StreamBuilder<BloodworkReminder?>(
                  stream: reminderService.streamNextReminder(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildCardPlaceholder();
                    }

                    final reminder = snapshot.data;

                    if (reminder == null) {
                      return _buildCard(
                        context,
                        title: 'Next Scheduled Bloodwork',
                        icon: Icons.calendar_today,
                        color: AppColors.steelBlue,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'No upcoming bloodwork scheduled',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Sizes.kGap15,
                            OutlinedButton.icon(
                              onPressed: () => context.push('/reminder/add'),
                              icon: const Icon(Icons.add_outlined),
                              label: const Text('Schedule Now'),
                            ),
                          ],
                        ),
                      );
                    }

                    return _buildCard(
                      context,
                      title: 'Next Scheduled Bloodwork',
                      icon: Icons.calendar_today,
                      color: AppColors.steelBlue,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reminder.labName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Sizes.kGap10,
                          Text(
                            DateFormat('EEEE, MMMM d, y')
                                .format(reminder.scheduledDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Sizes.kGap5,
                          Text(
                            'at ${DateFormat('h:mm a').format(reminder.scheduledDate)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          if (reminder.isFasting) ...[
                            Sizes.kGap10,
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withValues(alpha: 0.1),
                                borderRadius: Sizes.kRadius8,
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.no_food,
                                    size: 16,
                                    color: AppColors.bittersweet,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Fasting Required',
                                    style: TextStyle(
                                      color: AppColors.bittersweet,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          Sizes.kGap15,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  context.push(
                                    '/reminder/reschedule/${reminder.id}',
                                  );
                                },
                                icon: const Icon(Icons.edit_calendar),
                                label: const Text('Reschedule'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  try {
                                    await reminderService
                                        .deleteReminder(reminder.id);
                                  } catch (e) {
                                    if (context.mounted) {
                                      context.showSnackBar(
                                        'Error canceling reminder: $e',
                                        isError: true,
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('Cancel'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Sizes.kGap20,

                StreamBuilder<List<Bloodwork>>(
                  stream:
                      context.read<BloodworkService>().streamUserBloodwork(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildCardPlaceholder();
                    }

                    if (snapshot.hasError) {
                      return _buildCard(
                        context,
                        title: 'Latest Results Summary',
                        icon: Icons.analytics,
                        color: AppColors.moonstone,
                        child: const Text('Error loading bloodwork data'),
                      );
                    }

                    final bloodworks = snapshot.data;
                    if (bloodworks == null || bloodworks.isEmpty) {
                      return _buildCard(
                        context,
                        title: 'Latest Results Summary',
                        icon: Icons.analytics,
                        color: AppColors.moonstone,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'No bloodwork results yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Sizes.kGap15,
                            OutlinedButton.icon(
                              onPressed: () => context.push('/bloodwork/add'),
                              icon: const Icon(Icons.add_outlined),
                              label: const Text('Add Results'),
                            ),
                          ],
                        ),
                      );
                    }

                    // Get the most recent bloodwork
                    final latestBloodwork = bloodworks.first;
                    final totalMarkers = latestBloodwork.markers.length;
                    final outOfRangeMarkers =
                        latestBloodwork.abnormalMarkers.length;
                    final daysAgo = DateTime.now()
                        .difference(latestBloodwork.dateCollected)
                        .inDays;

                    return _buildCard(
                      context,
                      title: 'Latest Results Summary',
                      icon: Icons.analytics,
                      color: AppColors.moonstone,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMetricRow(
                            context,
                            label: 'Total Markers',
                            value: totalMarkers.toString(),
                            trend: 'Tested',
                            trendColor: AppColors.moonstone,
                          ),
                          Sizes.kGap15,
                          _buildMetricRow(
                            context,
                            label: 'Out of Range',
                            value: outOfRangeMarkers.toString(),
                            trend: outOfRangeMarkers > 0 ? 'Review' : 'Normal',
                            trendColor: outOfRangeMarkers > 0
                                ? AppColors.bittersweet
                                : Colors.green,
                          ),
                          Sizes.kGap15,
                          _buildMetricRow(
                            context,
                            label: 'Last Test',
                            value: daysAgo == 0
                                ? 'Today'
                                : daysAgo == 1
                                    ? 'Yesterday'
                                    : '$daysAgo days ago',
                          ),
                          Sizes.kGap15,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => context.push('/bloodwork/add'),
                                icon: const Icon(Icons.add_outlined),
                                label: const Text('Add New'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => context.push('/bloodwork'),
                                icon: const Icon(Icons.history),
                                label: const Text('View History'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                Sizes.kGap20,

                // Health tips card
                _buildCard(
                  context,
                  title: 'Health Tips',
                  icon: Icons.tips_and_updates,
                  color: AppColors.bittersweet,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTip(
                        context,
                        icon: Icons.water_drop,
                        tip: 'Stay hydrated before your next blood test',
                      ),
                      Sizes.kGap15,
                      _buildTip(
                        context,
                        icon: Icons.restaurant,
                        tip: 'Fast for 8-12 hours before the test',
                      ),
                      Sizes.kGap15,
                      _buildTip(
                        context,
                        icon: Icons.medication,
                        tip: 'Bring a list of your current medications',
                      ),
                    ],
                  ),
                ),
                Sizes.kGap100,
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: Sizes.kPadd20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Sizes.kRadius16,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              Sizes.kGap10,
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Sizes.kGap20,
          child,
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context, {
    required String label,
    required String value,
    String? trend,
    Color? trendColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (trend != null) ...[
              Sizes.kGap8,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: trendColor?.withValues(alpha: 0.1),
                  borderRadius: Sizes.kRadius8,
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: trendColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTip(
    BuildContext context, {
    required IconData icon,
    required String tip,
  }) {
    return Row(
      children: [
        Container(
          padding: Sizes.kPadd8,
          decoration: BoxDecoration(
            color: AppColors.bittersweet.withValues(alpha: 0.1),
            borderRadius: Sizes.kRadius8,
          ),
          child: Icon(
            icon,
            color: AppColors.bittersweet,
            size: 20,
          ),
        ),
        Sizes.kGap15,
        Expanded(
          child: Text(
            tip,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildCardPlaceholder() {
  return Container(
    width: double.infinity,
    padding: Sizes.kPadd20,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: Sizes.kRadius16,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: const Center(
      child: CircularProgressIndicator(),
    ),
  );
}
