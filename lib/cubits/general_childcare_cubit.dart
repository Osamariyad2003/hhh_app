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

  GeneralChildcareCubit() : super(const GeneralChildcareInitial()) {
    // Auto-load all items immediately
    debugPrint('DEBUG Cubit: Constructor - auto-loading data');
    loadChildcareItems();
  }

  /// Load childcare items with filters
  Future<void> loadChildcareItems({String? language, String? category}) async {
    _currentLanguage = language;
    _currentCategory = category;

    debugPrint('DEBUG Cubit: Loading childcare items - lang: $language, cat: $category');
    emit(const GeneralChildcareLoading());

    // Cancel previous subscription
    _subscription?.cancel();

    try {
      // Get data synchronously from static source
      final data = await _service.getChildcareItemsOnce(
        language: language,
        category: category,
      );
      
      debugPrint('DEBUG Cubit: Received ${data.length} items from service');
      
      final items = data
          .map((json) => GeneralChildcareModel.fromJson(json))
          .toList();
          
      debugPrint('DEBUG Cubit: Parsed ${items.length} childcare models');
      emit(GeneralChildcareSuccess(items));
    } catch (e, stackTrace) {
      debugPrint('ERROR Cubit: Failed to load childcare items: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(GeneralChildcareError('Failed to load childcare items: $e'));
    }
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

