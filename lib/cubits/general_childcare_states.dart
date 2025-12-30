import '../models/general_childcare_model.dart';

abstract class GeneralChildcareState {
  const GeneralChildcareState();
}

class GeneralChildcareInitial extends GeneralChildcareState {
  const GeneralChildcareInitial();
}

class GeneralChildcareLoading extends GeneralChildcareState {
  const GeneralChildcareLoading();
}

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

