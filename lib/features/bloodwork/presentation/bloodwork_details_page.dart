import 'package:bloodinsight/core/styles/colors.dart';
import 'package:bloodinsight/core/styles/sizes.dart';
import 'package:bloodinsight/core/styles/style.dart';
import 'package:bloodinsight/features/bloodwork/data/bloodmarker_model.dart';
import 'package:bloodinsight/features/bloodwork/data/bloodwork_model.dart';
import 'package:bloodinsight/shared/services/bloodwork_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BloodworkDetailsPage extends StatelessWidget {
  const BloodworkDetailsPage({
    super.key,
    required this.bloodworkId,
  });

  final String bloodworkId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Bloodwork>(
      stream: context.read<BloodworkService>().streamBloodwork(bloodworkId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final bloodwork = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Bloodwork Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/bloodwork/$bloodworkId/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmation(context),
              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: Sizes.kPadd16,
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _buildSummaryCard(context, bloodwork),
                      Sizes.kGap20,
                      ...BloodMarkerCategory.values.map((category) {
                        final markersCategory =
                            bloodwork.getMarkersByCategory(category);
                        if (markersCategory.isEmpty) {
                          return Sizes.kEmptyWidget;
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.displayName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Sizes.kGap10,
                            _buildMarkersCard(context, markersCategory),
                            Sizes.kGap20,
                          ],
                        );
                      }),
                      Sizes.kGap40,
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bloodwork'),
        content: const Text(
          'Are you sure you want to delete this bloodwork record? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      if (context.mounted) {
        await context.read<BloodworkService>().deleteBloodwork(bloodworkId);
      }
      if (context.mounted) {
        context
          ..showSnackBar('Bloodwork record deleted')
          ..go('/bloodwork');
      }
    }
  }

  Widget _buildSummaryCard(BuildContext context, Bloodwork bloodwork) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, MMMM d, y').format(bloodwork.dateCollected),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Sizes.kGap5,
              Text(
                bloodwork.labName,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryMetric(
                context,
                value: bloodwork.markers.length.toString(),
                label: 'Total\nMarkers',
                color: AppColors.moonstone,
              ),
              _buildSummaryMetric(
                context,
                value: bloodwork.abnormalMarkers.length.toString(),
                label: 'Out of\nRange',
                color: AppColors.bittersweet,
              ),
              _buildSummaryMetric(
                context,
                value: (bloodwork.markers.length -
                        bloodwork.abnormalMarkers.length)
                    .toString(),
                label: 'Within\nRange',
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(
    BuildContext context, {
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        Sizes.kGap8,
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildMarkersCard(BuildContext context, List<BloodMarker> markers) {
    return Container(
      width: double.infinity,
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
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: Sizes.kPadd20,
        itemCount: markers.length,
        separatorBuilder: (_, __) => const Divider(height: 32),
        itemBuilder: (context, index) {
          final marker = markers[index];
          final isNormal = marker.isNormal;

          return Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      marker.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Sizes.kGap5,
                    Text(
                      '${marker.minRange} - ${marker.maxRange} ${marker.unit}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (!isNormal ? AppColors.bittersweet : Colors.green)
                      .withValues(alpha: 0.1),
                  borderRadius: Sizes.kRadius8,
                ),
                child: Text(
                  '${marker.value} ${marker.unit}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: !isNormal ? AppColors.bittersweet : Colors.green,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
