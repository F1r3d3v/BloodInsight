import 'package:bloodinsight/core/styles/colors.dart';
import 'package:bloodinsight/core/styles/sizes.dart';
import 'package:bloodinsight/features/bloodwork/data/bloodwork_model.dart';
import 'package:bloodinsight/shared/services/bloodwork_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BloodworkHistoryPage extends StatelessWidget {
  const BloodworkHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bloodwork History',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/bloodwork/add'),
          ),
        ],
      ),
      body: StreamBuilder<List<Bloodwork>>(
        stream: context.read<BloodworkService>().streamUserBloodwork(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final bloodworks = snapshot.data;

          if (bloodworks == null || bloodworks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.science_outlined,
                    size: 64,
                    color: Theme.of(context).primaryColor
                      ..withValues(alpha: 0.5),
                  ),
                  Sizes.kGap20,
                  Text(
                    'No bloodwork records yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Sizes.kGap10,
                  Text(
                    'Add your first bloodwork result',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.7),
                        ),
                  ),
                  Sizes.kGap30,
                  FilledButton.icon(
                    onPressed: () => context.push('/bloodwork/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Bloodwork'),
                  ),
                ],
              ),
            );
          }

          return GroupedListView<Bloodwork, DateTime>(
            padding: Sizes.kPadd20,
            elements: bloodworks,
            groupBy: (bloodwork) => DateTime(
              bloodwork.dateCollected.year,
              bloodwork.dateCollected.month,
            ),
            groupSeparatorBuilder: (date) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                DateFormat('MMMM yyyy').format(date),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            itemBuilder: (context, bloodwork) {
              final abnormalCount = bloodwork.abnormalMarkers.length;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                child: Material(
                  color: Colors.transparent,
                  borderRadius: Sizes.kRadius16,
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    highlightColor:
                        Theme.of(context).highlightColor.withValues(alpha: 0.1),
                    onTap: () => context.push('/bloodwork/${bloodwork.id}'),
                    child: Padding(
                      padding: Sizes.kPadd20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                bloodwork.labName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                DateFormat('MMM d, y')
                                    .format(bloodwork.dateCollected),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                          Sizes.kGap20,
                          Row(
                            children: [
                              _buildMetricChip(
                                context,
                                label: 'Total Markers',
                                value: bloodwork.markers.length.toString(),
                                color: AppColors.moonstone,
                              ),
                              Sizes.kGap12,
                              if (abnormalCount > 0)
                                _buildMetricChip(
                                  context,
                                  label: 'Out of Range',
                                  value: abnormalCount.toString(),
                                  color: AppColors.bittersweet,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            order: GroupedListOrder.DESC,
          );
        },
      ),
    );
  }

  Widget _buildMetricChip(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: Sizes.kRadius8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
