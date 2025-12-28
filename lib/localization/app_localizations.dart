import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocDelegate();

  static AppLocalizations of(BuildContext context) {
    final loc = Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (loc == null) {
      return AppLocalizations(const Locale('en'));
    }
    return loc;
  }

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  bool get isArabic => locale.languageCode == 'ar';

  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'appTitle': 'Health Hearts at Home',
      'start': 'Start',
      'starting': 'Starting...',
      'caregiverSupportSubtitle': 'Caregiver support for children with CHD.',
      'home': 'Home',

      'generalChildcare': 'General Childcare',
      'tutorials': 'Tutorials',
      'spiritualNeeds': 'Spiritual Needs',
      'hospitalInfo': 'Hospital Info',
      'caregiverSupport': 'Caregiver Support',
      'trackYourChild': 'Track Your Child',
      'heartPrediction': 'Heart Disease Prediction',
      'aiSuggestions': 'AI Health Suggestions',
      'aboutChd': 'About CHD',
      'contacts': 'Contacts',

      'settings': 'Settings',
      'language': 'Language',
      'english': 'English',
      'arabic': 'Arabic',

      'track': 'Track',
      'manageChildren': 'Manage children',
      'selectChild': 'Select child',
      'noChildrenYet': 'No children yet. Tap + to add.',
      'addChild': 'Add Child',
      'childName': 'Child name',
      'pickDob': 'Pick date of birth',
      'choose': 'Choose',
      'create': 'Create',
      'saving': 'Saving...',
      'failedCreateChild': 'Failed to create child',

      'weight': 'Weight',
      'feeding': 'Feeding',
      'oxygen': 'Oxygen',

      'addWeight': 'Add weight (kg)',
      'editWeight': 'Edit weight (kg)',
      'kg': 'kg',
      'noteOptional': 'note (optional)',

      'addFeeding': 'Add feeding',
      'editFeeding': 'Edit feeding',
      'amountMl': 'amount (ml)',
      'type': 'type',

      'addOxygen': 'Add oxygen (SpO2 %)',
      'editOxygen': 'Edit oxygen (SpO2 %)',
      'spo2': 'SpO2',

      'save': 'Save',
      'cancel': 'Cancel',

      'delete': 'Delete',
      'deleteLogTitle': 'Delete log?',
      'deleteLogBody': 'This cannot be undone.',
      'deleteChildTitle': 'Delete child?',
      'deleteChildBody': 'This will delete the child and all logs (weight, feeding, oxygen).',
      'failedDeleteChild': 'Failed to delete child',

      'dob': 'DOB',
      'age': 'Age',
      'openDetails': 'Open details',

      'tutorialsEmpty': 'No tutorials yet. Add data in Firestore.',
      'tutorialsError': 'Error loading tutorials',

      'appLock': 'App Lock',
      'requireUnlock': 'Require unlock on open',
      'setPin': 'Set/Change PIN',
      'unlockNow': 'Lock now',
      'pin': 'PIN',
      'enterPin': 'Enter PIN',
      'confirmPin': 'Confirm PIN',
      'pinMismatch': 'PINs do not match',
      'pinSet': 'PIN saved',
      'unlock': 'Unlock',
      'unlockFailed': 'Unlock failed',
      'biometricUnavailable': 'Biometric not available, use PIN',
      'biometric': 'Biometric',
      'useBiometric': 'Use Biometric',
      'logout': 'Logout',
      'logoutConfirm': 'Are you sure you want to logout?',
      'loggingOut': 'Logging out...',
    },
    'ar': {
      'appTitle': 'قلوب صحية في المنزل',
      'start': 'ابدأ',
      'starting': 'جارٍ البدء...',
      'caregiverSupportSubtitle': 'دعم مقدمي الرعاية للأطفال المصابين بعيوب القلب الخلقية.',
      'home': 'الرئيسية',

      'generalChildcare': 'رعاية الطفل العامة',
      'tutorials': 'الدروس',
      'spiritualNeeds': 'الاحتياجات الروحية',
      'hospitalInfo': 'معلومات المستشفى',
      'caregiverSupport': 'دعم مقدمي الرعاية',
      'trackYourChild': 'متابعة طفلك',
      'heartPrediction': 'توقع أمراض القلب',
      'aiSuggestions': 'اقتراحات صحية بالذكاء الاصطناعي',
      'aboutChd': 'عن عيوب القلب الخلقية',
      'contacts': 'جهات الاتصال',

      'settings': 'الإعدادات',
      'language': 'اللغة',
      'english': 'الإنجليزية',
      'arabic': 'العربية',

      'track': 'المتابعة',
      'manageChildren': 'إدارة الأطفال',
      'selectChild': 'اختر الطفل',
      'noChildrenYet': 'لا يوجد أطفال بعد. اضغط + للإضافة.',
      'addChild': 'إضافة طفل',
      'childName': 'اسم الطفل',
      'pickDob': 'اختر تاريخ الميلاد',
      'choose': 'اختيار',
      'create': 'إنشاء',
      'saving': 'جارٍ الحفظ...',
      'failedCreateChild': 'فشل إنشاء الطفل',

      'weight': 'الوزن',
      'feeding': 'الرضعات',
      'oxygen': 'الأكسجين',

      'addWeight': 'إضافة وزن (كغ)',
      'editWeight': 'تعديل الوزن (كغ)',
      'kg': 'كغ',
      'noteOptional': 'ملاحظة (اختياري)',

      'addFeeding': 'إضافة رضعة',
      'editFeeding': 'تعديل الرضعة',
      'amountMl': 'الكمية (مل)',
      'type': 'النوع',

      'addOxygen': 'إضافة أكسجين (SpO2 %)',
      'editOxygen': 'تعديل الأكسجين (SpO2 %)',
      'spo2': 'SpO2',

      'save': 'حفظ',
      'cancel': 'إلغاء',

      'delete': 'حذف',
      'deleteLogTitle': 'حذف السجل؟',
      'deleteLogBody': 'لا يمكن التراجع عن ذلك.',
      'deleteChildTitle': 'حذف الطفل؟',
      'deleteChildBody': 'سيتم حذف الطفل وجميع السجلات (الوزن، الرضعات، الأكسجين).',
      'failedDeleteChild': 'فشل حذف الطفل',

      'dob': 'تاريخ الميلاد',
      'age': 'العمر',
      'openDetails': 'فتح التفاصيل',

      'tutorialsEmpty': 'لا توجد دروس بعد. أضف بيانات في Firestore.',
      'tutorialsError': 'خطأ في تحميل الدروس',

      'appLock': 'قفل التطبيق',
      'requireUnlock': 'يتطلب فتح عند التشغيل',
      'setPin': 'تعيين/تغيير PIN',
      'unlockNow': 'اقفل الآن',
      'pin': 'PIN',
      'enterPin': 'أدخل PIN',
      'confirmPin': 'تأكيد PIN',
      'pinMismatch': 'PIN غير متطابق',
      'pinSet': 'تم حفظ PIN',
      'unlock': 'فتح',
      'unlockFailed': 'فشل الفتح',
      'biometricUnavailable': 'البصمة غير متاحة، استخدم PIN',
      'biometric': 'البصمة',
      'useBiometric': 'استخدم البصمة',
      'logout': 'تسجيل الخروج',
      'logoutConfirm': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      'loggingOut': 'جارٍ تسجيل الخروج...',
    },
  };

  String t(String key) {
    final lang = _strings[locale.languageCode] ?? _strings['en']!;
    return lang[key] ?? (_strings['en']![key] ?? key);
  }
}

class _AppLocDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en' || locale.languageCode == 'ar';

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
