import '../models/general_childcare_model.dart';

/// Abstract base class for General Childcare states
abstract class GeneralChildcareState {
  const GeneralChildcareState();
}

/// Initial state - no action has been taken yet
class GeneralChildcareInitial extends GeneralChildcareState {
  const GeneralChildcareInitial();
}

/// Loading state - fetching childcare items
class GeneralChildcareLoading extends GeneralChildcareState {
  const GeneralChildcareLoading();
}

/// Success state - childcare items have been loaded successfully
class GeneralChildcareSuccess extends GeneralChildcareState {
  final List<GeneralChildcareModel> items;

  const GeneralChildcareSuccess(this.items);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneralChildcareSuccess &&
          runtimeType == other.runtimeType &&
          items.length == other.items.length;

  @override
  int get hashCode => items.length.hashCode;
}

/// Error state - an error occurred
class GeneralChildcareError extends GeneralChildcareState {
  final String message;

  const GeneralChildcareError(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneralChildcareError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

