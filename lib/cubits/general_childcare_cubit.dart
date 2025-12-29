import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../services/general_childcare_service.dart';
import '../models/general_childcare_model.dart';
import 'general_childcare_states.dart';
import 'dart:async';

/// Cubit for managing General Childcare state
class GeneralChildcareCubit extends Cubit<GeneralChildcareState> {
  final _service = GeneralChildcareService.instance;
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  String? _currentLanguage;
  String? _currentCategory;

  GeneralChildcareCubit() : super(const GeneralChildcareInitial());

  /// Load childcare items with filters
  void loadChildcareItems({String? language, String? category}) {
    _currentLanguage = language;
    _currentCategory = category;

    emit(const GeneralChildcareLoading());

    // Cancel previous subscription
    _subscription?.cancel();

    // Subscribe to stream with timeout
    _subscription = _service
        .streamChildcareItems(
          language: language,
          category: category,
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: (sink) {
            sink.add(<Map<String, dynamic>>[]);
            sink.close();
          },
        )
        .listen(
      (data) {
        try {
          final items = data
              .map((json) => GeneralChildcareModel.fromJson(json))
              .toList();
          emit(GeneralChildcareSuccess(items));
        } catch (e) {
          debugPrint('Error parsing childcare items: $e');
          emit(GeneralChildcareError('Failed to parse childcare items: $e'));
        }
      },
      onError: (error) {
        debugPrint('Error loading childcare items: $error');
        emit(GeneralChildcareError('Failed to load childcare items: $error'));
      },
      onDone: () {
        // If stream completes without data, emit empty success
        if (state is GeneralChildcareLoading) {
          emit(const GeneralChildcareSuccess([]));
        }
      },
    );
  }

  /// Reload childcare items with current filters
  void reload() {
    if (_currentLanguage != null || _currentCategory != null) {
      loadChildcareItems(
        language: _currentLanguage,
        category: _currentCategory,
      );
    } else {
      loadChildcareItems();
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

