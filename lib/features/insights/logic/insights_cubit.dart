import 'package:bloodinsight/shared/services/insights_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'insights_cubit.freezed.dart';

@freezed
class InsightsState with _$InsightsState {
  const factory InsightsState.initial() = _Initial;
  const factory InsightsState.loading() = _Loading;
  const factory InsightsState.loaded(Map<String, dynamic> insights) = _Loaded;
  const factory InsightsState.error(String message) = _Error;
}

class InsightsCubit extends Cubit<InsightsState> {
  InsightsCubit({
    required InsightsService insightsService,
  })  : _insightsService = insightsService,
        super(const InsightsState.initial());

  final InsightsService _insightsService;

  Future<void> generateInsights() async {
    try {
      emit(const InsightsState.loading());
      final insights = await _insightsService.generateHealthInsights();
      emit(InsightsState.loaded(insights));
    } catch (err) {
      emit(InsightsState.error(err.toString()));
    }
  }

  void clearInsights() {
    emit(const InsightsState.initial());
  }
}
