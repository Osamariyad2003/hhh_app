import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/heart_disease_prediction.dart';
import '../services/ml_prediction_service.dart';
import '../services/firebase/firestore_prediction_service.dart';
import '../services/firebase_auth_service.dart';

class PredictionState {
  final bool isLoading;
  final HeartDiseasePredictionResponse? prediction;
  final String? error;
  final List<String> availableModels;
  final bool isSaving;

  const PredictionState({
    this.isLoading = false,
    this.prediction,
    this.error,
    this.availableModels = const [],
    this.isSaving = false,
  });

  PredictionState copyWith({
    bool? isLoading,
    HeartDiseasePredictionResponse? prediction,
    String? error,
    List<String>? availableModels,
    bool? isSaving,
  }) {
    return PredictionState(
      isLoading: isLoading ?? this.isLoading,
      prediction: prediction ?? this.prediction,
      error: error,
      availableModels: availableModels ?? this.availableModels,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class PredictionCubit extends Cubit<PredictionState> {
  final _predictionService = FirestorePredictionService();
  final _authService = FirebaseAuthService.instance;

  PredictionCubit() : super(const PredictionState());

  Future<void> loadAvailableModels() async {
    try {
      final models = await MLPredictionService.instance.getAvailableModels();
      emit(state.copyWith(availableModels: models));
    } catch (e) {
      // Silently fail, models list is optional
    }
  }

  Future<void> predictHeartDisease(
    HeartDiseasePredictionRequest request, {
    String? patientId,
  }) async {
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

      // Save prediction to Firebase
      await _savePredictionToFirebase(request, prediction, patientId);
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
        prediction: null,
      ));
    }
  }

  /// Save prediction to Firebase
  Future<void> _savePredictionToFirebase(
    HeartDiseasePredictionRequest request,
    HeartDiseasePredictionResponse response,
    String? patientId,
  ) async {
    try {
      emit(state.copyWith(isSaving: true));

      final userId = _authService.currentUserId;
      await _predictionService.savePrediction(
        request: request,
        response: response,
        userId: userId,
        patientId: patientId,
      );

      emit(state.copyWith(isSaving: false));
    } catch (e) {
      // Don't fail the prediction if saving fails, just log the error
      emit(state.copyWith(isSaving: false));
      // Optionally emit a warning state
    }
  }

  void clearPrediction() {
    emit(state.copyWith(prediction: null, error: null));
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}

