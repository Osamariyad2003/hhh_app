import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/recipe_remote_datasource.dart';
import '../models/heart_healthy_meal.dart';
import 'ai_suggestion_states.dart';

class AISuggestionCubit extends Cubit<AISuggestionState> {
  final _recipeDatasource = RecipeRemoteDatasource.instance;

  AISuggestionCubit() : super(const AISuggestionInitial());

  Future<void> getSuggestions(String userInput) async {
    if (userInput.trim().isEmpty) {
      emit(AISuggestionError(
        'Please enter ingredients or describe what you\'d like to prepare',
        previousSuggestion: _getCurrentSuggestion(),
      ));
      return;
    }

    emit(const AISuggestionLoading());

    try {
      final suggestion = await _recipeDatasource.getRecipeSuggestions(userInput);
      emit(AISuggestionSuccess(suggestion));
    } catch (e) {
      emit(AISuggestionError(
        e.toString().replaceAll('Exception: ', ''),
        previousSuggestion: _getCurrentSuggestion(),
      ));
    }
  }

  Future<void> saveSuggestionToFirestore(String userInput) async {
    final currentSuggestion = _getCurrentSuggestion();
    
    if (userInput.trim().isEmpty) {
      emit(AISuggestionError(
        'Cannot save: No input provided',
        previousSuggestion: currentSuggestion,
      ));
      return;
    }

    if (currentSuggestion == null) {
      emit(AISuggestionError(
        'No suggestion to save. Please get suggestions first.',
        previousSuggestion: null,
      ));
      return;
    }

    emit(AISuggestionSaving(currentSuggestion));

    try {
      await _recipeDatasource.saveSuggestedMealToFirestore(userInput);
      emit(AISuggestionSaved(currentSuggestion));
    } catch (e) {
      emit(AISuggestionError(
        e.toString().replaceAll('Exception: ', ''),
        previousSuggestion: currentSuggestion,
      ));
    }
  }

  void clearSuggestion() {
    emit(const AISuggestionInitial());
  }

  void clearError() {
    final currentState = state;
    if (currentState is AISuggestionError) {
      final previousSuggestion = currentState.previousSuggestion;
      if (previousSuggestion != null) {
        emit(AISuggestionSuccess(previousSuggestion));
      } else {
        emit(const AISuggestionInitial());
      }
    }
  }

  void reset() {
    emit(const AISuggestionInitial());
  }

  HeartHealthyMeal? _getCurrentSuggestion() {
    final currentState = state;
    if (currentState is AISuggestionSuccess) {
      return currentState.suggestion;
    } else if (currentState is AISuggestionSaving) {
      return currentState.suggestion;
    } else if (currentState is AISuggestionSaved) {
      return currentState.suggestion;
    } else if (currentState is AISuggestionError) {
      return currentState.previousSuggestion;
    }
    return null;
  }
}
