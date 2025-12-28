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

      // Section Screen Messages
      'loadingHospitals': 'Loading hospitals...',
      'unableToLoadHospitals': 'Unable to load hospitals',
      'noHospitalsAvailable': 'No hospitals available',
      'hospitalInfoWillAppear': 'Hospital information will appear here once available.',
      'hospital': 'Hospital',
      'checkConnection': 'Please check your connection and try again.',
      'loadingSupportGroups': 'Loading support groups...',
      'unableToLoadSupportGroups': 'Unable to load support groups',
      'noSupportGroupsAvailable': 'No support groups available',
      'supportGroupInfoWillAppear': 'Support group information will appear here once available.',
      'supportGroup': 'Support Group',
      'patientStories': 'Patient Stories',
      'loadingStories': 'Loading stories...',
      'unableToLoadStories': 'Unable to load stories',
      'noStoriesAvailable': 'No stories available',
      'storiesWillAppear': 'Patient stories will appear here once they are published.',
      'story': 'Story',
      'by': 'By',
      'unableToLoadContent': 'Unable to load content',
      'loadingContent': 'Loading content...',
      'noContentAvailable': 'No content available',
      'contentNotAvailableYet': 'Content for this section is not available yet.',
      'sectionNoContent': 'This section has no content yet.',
      'error': 'Error',

      // Track Dashboard
      'clothesOptional': 'Clothes (optional)',
      'notSet': 'Not set',
      'withDiaper': 'With diaper',
      'noClothes': 'No clothes',
      'bottle': 'Bottle',
      'breast': 'Breast',
      'tube': 'Tube',
      'map': 'Map',
      'childLocation': 'Child Location',
      'mapInformation': 'Map Information',
      'mapInfoDescription': 'This map shows the location for tracking your child\'s health data. You can use this to mark important locations like hospitals, clinics, or home.',
      'unableToLoadChildren': 'Unable to load children',
      'noActiveChildren': 'No active children',
      'addChildToStart': 'Add a child to start tracking their health data, or unarchive one in Manage.',

      // Login/Signup
      'login': 'Login',
      'signUp': 'Sign Up',
      'continueAsGuest': 'Continue as Guest',
      'alreadyHaveAccount': 'Already have an account? ',
      'email': 'Email',
      'password': 'Password',
      'username': 'Username',
      'confirmPassword': 'Confirm Password',

      // Profile
      'profile': 'Profile',
      'profileUpdated': 'Profile updated successfully',
      'failedToUpdateProfile': 'Failed to update profile',
      'saveChanges': 'Save Changes',
      'changePassword': 'Change Password',
      'currentPassword': 'Current Password',
      'newPassword': 'New Password',

      // Tutorial
      'tutorialDetails': 'Tutorial Details',
      'openVideoLink': 'Open Video Link',
      'watchOnYouTube': 'Watch on YouTube',
      'openVideo': 'Open Video',
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

      // Section Screen Messages
      'loadingHospitals': 'جارٍ تحميل المستشفيات...',
      'unableToLoadHospitals': 'تعذر تحميل المستشفيات',
      'noHospitalsAvailable': 'لا توجد مستشفيات متاحة',
      'hospitalInfoWillAppear': 'ستظهر معلومات المستشفى هنا بمجرد توفرها.',
      'hospital': 'مستشفى',
      'checkConnection': 'يرجى التحقق من اتصالك والمحاولة مرة أخرى.',
      'loadingSupportGroups': 'جارٍ تحميل مجموعات الدعم...',
      'unableToLoadSupportGroups': 'تعذر تحميل مجموعات الدعم',
      'noSupportGroupsAvailable': 'لا توجد مجموعات دعم متاحة',
      'supportGroupInfoWillAppear': 'ستظهر معلومات مجموعة الدعم هنا بمجرد توفرها.',
      'supportGroup': 'مجموعة الدعم',
      'patientStories': 'قصص المرضى',
      'loadingStories': 'جارٍ تحميل القصص...',
      'unableToLoadStories': 'تعذر تحميل القصص',
      'noStoriesAvailable': 'لا توجد قصص متاحة',
      'storiesWillAppear': 'ستظهر قصص المرضى هنا بمجرد نشرها.',
      'story': 'قصة',
      'by': 'بواسطة',
      'unableToLoadContent': 'تعذر تحميل المحتوى',
      'loadingContent': 'جارٍ تحميل المحتوى...',
      'noContentAvailable': 'لا يوجد محتوى متاح',
      'contentNotAvailableYet': 'المحتوى لهذا القسم غير متاح بعد.',
      'sectionNoContent': 'هذا القسم لا يحتوي على محتوى بعد.',
      'error': 'خطأ',

      // Track Dashboard
      'clothesOptional': 'الملابس (اختياري)',
      'notSet': 'غير محدد',
      'withDiaper': 'مع حفاض',
      'noClothes': 'بدون ملابس',
      'bottle': 'زجاجة',
      'breast': 'رضاعة طبيعية',
      'tube': 'أنبوب',
      'map': 'الخريطة',
      'childLocation': 'موقع الطفل',
      'mapInformation': 'معلومات الخريطة',
      'mapInfoDescription': 'تعرض هذه الخريطة الموقع لمتابعة بيانات صحة طفلك. يمكنك استخدامها لتحديد مواقع مهمة مثل المستشفيات والعيادات أو المنزل.',
      'unableToLoadChildren': 'تعذر تحميل الأطفال',
      'noActiveChildren': 'لا يوجد أطفال نشطين',
      'addChildToStart': 'أضف طفلاً لبدء متابعة بيانات صحته، أو قم بإلغاء أرشفة واحد في الإدارة.',

      // Login/Signup
      'login': 'تسجيل الدخول',
      'signUp': 'إنشاء حساب',
      'continueAsGuest': 'المتابعة كضيف',
      'alreadyHaveAccount': 'هل لديك حساب بالفعل؟ ',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'username': 'اسم المستخدم',
      'confirmPassword': 'تأكيد كلمة المرور',

      // Profile
      'profile': 'الملف الشخصي',
      'profileUpdated': 'تم تحديث الملف الشخصي بنجاح',
      'failedToUpdateProfile': 'فشل تحديث الملف الشخصي',
      'saveChanges': 'حفظ التغييرات',
      'changePassword': 'تغيير كلمة المرور',
      'currentPassword': 'كلمة المرور الحالية',
      'newPassword': 'كلمة المرور الجديدة',

      // Tutorial
      'tutorialDetails': 'تفاصيل الدرس',
      'openVideoLink': 'فتح رابط الفيديو',
      'watchOnYouTube': 'شاهد على YouTube',
      'openVideo': 'فتح الفيديو',
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
