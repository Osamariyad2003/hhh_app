import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/heart_disease_prediction.dart';
import '../services/ml_prediction_service.dart';

class PredictionState {
  final bool isLoading;
  final HeartDiseasePredictionResponse? prediction;
  final String? error;
  final List<String> availableModels;

  const PredictionState({
    this.isLoading = false,
    this.prediction,
    this.error,
    this.availableModels = const [],
  });

  PredictionState copyWith({
    bool? isLoading,
    HeartDiseasePredictionResponse? prediction,
    String? error,
    List<String>? availableModels,
  }) {
    return PredictionState(
      isLoading: isLoading ?? this.isLoading,
      prediction: prediction ?? this.prediction,
      error: error,
      availableModels: availableModels ?? this.availableModels,
    );
  }
}

class PredictionCubit extends Cubit<PredictionState> {
  PredictionCubit() : super(const PredictionState());

  Future<void> loadAvailableModels() async {
    try {
      final models = await MLPredictionService.instance.getAvailableModels();
      emit(state.copyWith(availableModels: models));
    } catch (e) {
      // Silently fail, models list is optional
    }
  }

  Future<void> predictHeartDisease(HeartDiseasePredictionRequest request) async {
    emit(state.copyWith(isLoading: true, error: null, prediction: null));

    try {
      // Validate request
      if (!MLPredictionService.instance.validateRequest(request)) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Invalid input data. Please check all fields.',
        ));
        return;
      }

      // Make prediction
      final prediction = await MLPredictionService.instance.predictHeartDisease(request);

      emit(state.copyWith(
        isLoading: false,
        prediction: prediction,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
        prediction: null,
      ));
    }
  }

  void clearPrediction() {
    emit(state.copyWith(prediction: null, error: null));
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}

