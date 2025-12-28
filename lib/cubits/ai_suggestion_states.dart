import '../models/heart_healthy_meal.dart';

/// Abstract base class for AI Suggestion states
abstract class AISuggestionState {
  const AISuggestionState();
}

/// Initial state - no action has been taken yet
class AISuggestionInitial extends AISuggestionState {
  const AISuggestionInitial();
}

/// Loading state - fetching suggestions
class AISuggestionLoading extends AISuggestionState {
  const AISuggestionLoading();
}

/// Success state - suggestion has been loaded successfully
class AISuggestionSuccess extends AISuggestionState {
  final HeartHealthyMeal suggestion;

  const AISuggestionSuccess(this.suggestion);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AISuggestionSuccess &&
          runtimeType == other.runtimeType &&
          suggestion.id == other.suggestion.id;

  @override
  int get hashCode => suggestion.id.hashCode;
}

/// Saving state - saving suggestion to Firestore
class AISuggestionSaving extends AISuggestionState {
  final HeartHealthyMeal suggestion;

  const AISuggestionSaving(this.suggestion);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AISuggestionSaving &&
          runtimeType == other.runtimeType &&
          suggestion.id == other.suggestion.id;

  @override
  int get hashCode => suggestion.id.hashCode;
}

/// Saved state - suggestion has been saved successfully
class AISuggestionSaved extends AISuggestionState {
  final HeartHealthyMeal suggestion;

  const AISuggestionSaved(this.suggestion);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AISuggestionSaved &&
          runtimeType == other.runtimeType &&
          suggestion.id == other.suggestion.id;

  @override
  int get hashCode => suggestion.id.hashCode;
}

/// Error state - an error occurred
class AISuggestionError extends AISuggestionState {
  final String message;
  final HeartHealthyMeal? previousSuggestion;

  const AISuggestionError(this.message, {this.previousSuggestion});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AISuggestionError &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          previousSuggestion?.id == other.previousSuggestion?.id;

  @override
  int get hashCode => message.hashCode ^ (previousSuggestion?.id.hashCode ?? 0);
}

