import '../models/heart_healthy_meal.dart';

abstract class AISuggestionState {
  const AISuggestionState();
}

class AISuggestionInitial extends AISuggestionState {
  const AISuggestionInitial();
}

class AISuggestionLoading extends AISuggestionState {
  const AISuggestionLoading();
}

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

