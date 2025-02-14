import 'package:bloodinsight/core/styles/colors.dart';
import 'package:bloodinsight/core/styles/sizes.dart';
import 'package:bloodinsight/core/styles/style.dart';
import 'package:bloodinsight/features/insights/logic/insights_cubit.dart';
import 'package:bloodinsight/shared/widgets/scaffold_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InsightsCubit(
        insightsService: context.read(),
      ),
      child: const InsightsView(),
    );
  }
}

class InsightsView extends StatelessWidget {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<InsightsCubit, InsightsState>(
        listener: (context, state) {
          state.maybeWhen(
            initial: () => context.showBottomNav(),
            error: (message) {
              context
                ..showBottomNav()
                ..showSnackBar(message, isError: true);
            },
            orElse: () => context.hideBottomNav(),
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => _buildInitialState(context),
            loading: _buildLoadingState,
            loaded: (insights) => _buildLoadedState(insights, context),
            error: (_) => _buildInitialState(context),
          );
        },
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Padding(
        padding: Sizes.kPadd16,
        child: Container(
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
              Sizes.kGap20,
              Text(
                'Get Your Health Insights',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Sizes.kGap10,
              Text(
                'Generate a comprehensive health report based on your latest bloodwork results',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
              ),
              Sizes.kGap25,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<InsightsCubit>().generateInsights();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: const Icon(Icons.analytics),
                  label: const Text('Generate Report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/loading.json',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 16),
          const Text(
            'Analyzing your health data...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(
    Map<String, dynamic> insights,
    BuildContext context,
  ) {
    final cards = [
      _buildCard(
        title: 'Health Summary',
        icon: Icons.summarize,
        color: AppColors.steelBlue,
        content: Text(
          insights['summary'] as String,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
      _buildCard(
        title: 'Age-Related Insights',
        icon: Icons.calendar_today,
        color: AppColors.moonstone,
        content: Text(
          insights['age_related_insights'] as String,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
      _buildBMICard(insights['bmi_analysis'] as Map<String, dynamic>),
      _buildBloodworkCard(
        insights['bloodwork_analysis'] as Map<String, dynamic>,
      ),
      _buildTrendsCard(insights['trends'] as List<dynamic>),
      _buildRecommendationsCard(
        insights['lifestyle_recommendations'] as List<dynamic>,
      ),
      _buildFollowUpCard(insights['follow_up'] as Map<String, dynamic>),
      _buildContinueButton(context),
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 16),
      itemCount: cards.length,
      separatorBuilder: (context, index) => Sizes.kGap20,
      itemBuilder: (context, index) => cards[index],
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
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
              Icon(icon, color: color, size: 24),
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
          content,
        ],
      ),
    );
  }

  Widget _buildBMICard(Map<String, dynamic> bmiAnalysis) {
    final bmiColor = _getBMIStatusColor(bmiAnalysis['status'] as String);
    return _buildCard(
      title: 'BMI Analysis',
      icon: Icons.monitor_weight,
      color: AppColors.bittersweet,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bmiColor.withValues(alpha: 0.1),
              borderRadius: Sizes.kRadius8,
            ),
            child: Text(
              'Status: ${bmiAnalysis['status']}',
              style: TextStyle(
                color: bmiColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Sizes.kGap15,
          Text(
            bmiAnalysis['recommendation'] as String,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodworkCard(Map<String, dynamic> bloodworkAnalysis) {
    return _buildCard(
      title: 'Bloodwork Analysis',
      icon: Icons.bloodtype,
      color: AppColors.moonstone,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Normal Markers: ${(bloodworkAnalysis['normal_markers'] as List).join(", ")}',
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          Sizes.kGap15,
          const Text(
            'Concerns:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Sizes.kGap12,
          ...(bloodworkAnalysis['concerns'] as List).map(
            (concern) {
              final concernMap = concern as Map<String, dynamic>;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        Text(
                          concernMap['marker'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          concern['value'] as String,
                        ),
                      ],
                    ),
                  ),
                  Sizes.kGap8,
                  Text(
                    concern['recommendation'] as String,
                    style: const TextStyle(color: AppColors.bittersweet),
                  ),
                  Sizes.kGap8,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsCard(List<dynamic> trends) {
    return _buildCard(
      title: 'Health Trends',
      icon: Icons.trending_up,
      color: AppColors.steelBlue,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trends.isEmpty) ...[
            const Text(
              'No trends to report',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Sizes.kGap8,
          ] else
            ...trends.map((dynamic trendData) {
              final trend = trendData as Map<String, dynamic>;
              final isImproving = trend['trend'] == 'improving';
              final isStable = trend['trend'] == 'stable';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isImproving
                              ? Icons.trending_up
                              : isStable
                                  ? Icons.trending_flat
                                  : Icons.trending_down,
                          color: isImproving
                              ? Colors.green
                              : isStable
                                  ? AppColors.moonstone
                                  : AppColors.bittersweet,
                          size: 20,
                        ),
                        Sizes.kGap8,
                        Text(
                          trend['marker'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Sizes.kGap8,
                    Text(
                      trend['description'] as String,
                      style: const TextStyle(height: 1.5),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(List<dynamic> recommendations) {
    return _buildCard(
      title: 'Lifestyle Recommendations',
      icon: Icons.recommend,
      color: AppColors.steelBlue,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: recommendations.map((rec) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 16),
                Sizes.kGap10,
                Expanded(child: Text(rec as String)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFollowUpCard(Map<String, dynamic> followUp) {
    return _buildCard(
      title: 'Follow-up Plan',
      icon: Icons.calendar_month,
      color: AppColors.moonstone,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next check-up: ${followUp['timeframe']}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Sizes.kGap15,
          const Text('Focus areas:'),
          ...(followUp['focus_areas'] as List).map(
            (area) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.arrow_right, size: 16),
                  Expanded(
                    child: Text(
                      area as String,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Padding(
      padding: Sizes.kPaddH20,
      child: FilledButton(
        onPressed: () {
          context
            ..read<InsightsCubit>().clearInsights()
            ..go('/dashboard');
        },
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: Sizes.kRadius16,
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Color _getBMIStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'overweight':
        return AppColors.bittersweet;
      case 'underweight':
        return AppColors.moonstone;
      default:
        return AppColors.steelBlue;
    }
  }
}
