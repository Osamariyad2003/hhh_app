import '../models/general_childcare_model.dart';

/// Static childcare data
/// This replaces Firestore data with hardcoded content
class StaticChildcareData {
  static List<GeneralChildcareModel> get allItems => [
        // English Content
        ..._englishItems,
        ..._arabicItems,
      ];

  static final List<GeneralChildcareModel> _englishItems = [
    GeneralChildcareModel(
      id: 'growth_1_en',
      title: 'Monitoring Your Child\'s Growth',
      description: 'Understanding growth patterns and milestones for children with CHD',
      category: 'growth',
      ageRange: '0-12 months',
      contentType: 'text',
      body: '''
# Monitoring Your Child's Growth

## Why Growth Monitoring is Important

Children with Congenital Heart Disease (CHD) may experience different growth patterns compared to healthy children. Regular monitoring helps ensure your child is developing appropriately.

## Key Indicators

- **Weight gain**: Should be steady and consistent
- **Height**: Track monthly measurements
- **Head circumference**: Important for infants
- **Development milestones**: Motor skills, social interaction

## When to Be Concerned

Contact your healthcare provider if you notice:
- Sudden weight loss
- Failure to gain weight over 2-3 weeks
- Significant delays in developmental milestones

## Tips for Healthy Growth

1. Ensure adequate nutrition
2. Follow feeding schedules recommended by your doctor
3. Monitor for signs of fatigue during feeding
4. Keep regular appointments with your pediatric cardiologist
''',
      language: 'en',
      order: 1,
      isActive: true,
    ),
    GeneralChildcareModel(
      id: 'nutrition_1_en',
      title: 'Nutrition Guidelines for CHD Children',
      description: 'Essential feeding and nutrition information for your child',
      category: 'nutrition',
      ageRange: 'All ages',
      contentType: 'text',
      body: '''
# Nutrition Guidelines for CHD Children

## Special Nutritional Needs

Children with CHD often require more calories than healthy children because their hearts work harder. However, they may tire easily during feeding.

## Feeding Strategies

### For Infants
- Feed smaller amounts more frequently
- Allow rest periods during feeding
- Consider fortified formula if recommended by your doctor
- Monitor for signs of fatigue (sweating, rapid breathing)

### For Older Children
- High-calorie, nutrient-dense foods
- Frequent small meals
- Avoid excessive salt (unless otherwise directed)
- Stay hydrated, but monitor fluid intake if on diuretics

## Important Considerations

- **Calorie needs**: May be 20-40% higher than typical
- **Feeding time**: May take longer than usual
- **Supplements**: Only use as recommended by your healthcare team
- **Tube feeding**: May be necessary for some children

## When to Contact Your Doctor

- Difficulty feeding or swallowing
- Persistent vomiting
- Signs of dehydration
- Significant weight loss
''',
      language: 'en',
      order: 2,
      isActive: true,
    ),
    GeneralChildcareModel(
      id: 'sleep_1_en',
      title: 'Sleep Patterns and Rest',
      description: 'Understanding sleep needs and creating a safe sleep environment',
      category: 'sleep',
      ageRange: 'All ages',
      contentType: 'text',
      body: '''
# Sleep Patterns and Rest

## Sleep Needs for CHD Children

Children with CHD may need more rest than typical children. Their hearts work harder, which can cause fatigue.

## Creating a Safe Sleep Environment

- **Position**: Follow your doctor's recommendations (some children need elevated positions)
- **Monitoring**: Consider using a baby monitor or pulse oximeter if recommended
- **Temperature**: Keep room comfortable, not too hot or cold
- **Safety**: Follow safe sleep guidelines (no loose bedding, proper crib setup)

## Common Sleep Challenges

- **Frequent waking**: May be due to discomfort or breathing difficulties
- **Restlessness**: Can indicate oxygen issues
- **Excessive sleepiness**: May need medical evaluation

## Tips for Better Sleep

1. Establish a consistent bedtime routine
2. Create a calm, quiet environment
3. Monitor for signs of breathing difficulties
4. Keep emergency contacts nearby
5. Follow medication schedules as prescribed

## When to Seek Help

Contact your healthcare provider if you notice:
- Severe breathing difficulties during sleep
- Blue or pale skin color
- Excessive sweating
- Unusual restlessness or agitation
''',
      language: 'en',
      order: 3,
      isActive: true,
    ),
    GeneralChildcareModel(
      id: 'hygiene_1_en',
      title: 'Hygiene and Infection Prevention',
      description: 'Maintaining cleanliness to prevent infections in children with CHD',
      category: 'hygiene',
      ageRange: 'All ages',
      contentType: 'text',
      body: '''
# Hygiene and Infection Prevention

## Why Hygiene is Critical

Children with CHD are at higher risk for infections, which can be more serious for them. Good hygiene practices are essential.

## Daily Hygiene Practices

### Hand Washing
- Wash hands frequently with soap and water
- Use hand sanitizer when soap isn't available
- Teach children proper handwashing techniques
- Wash hands before feeding, after diaper changes, and after being in public

### Bathing
- Regular baths help prevent skin infections
- Use mild, fragrance-free soaps
- Keep surgical sites clean and dry (if applicable)
- Pat dry gently, especially around medical devices

### Oral Care
- Brush teeth twice daily
- Regular dental checkups are important
- Some children may need antibiotic prophylaxis before dental procedures

## Infection Prevention

- **Vaccinations**: Keep all vaccinations up to date
- **Avoid sick contacts**: Limit exposure to people with colds or flu
- **Clean surfaces**: Regularly disinfect toys and surfaces
- **Medical equipment**: Keep all medical devices clean

## Special Considerations

- **Surgical sites**: Keep clean and monitor for signs of infection
- **Feeding tubes**: Follow strict hygiene protocols
- **Oxygen equipment**: Keep clean and replace as recommended

## When to Contact Your Doctor

- Signs of infection (fever, redness, swelling)
- Unusual discharge from wounds
- Persistent cough or breathing changes
- Decreased activity or appetite
''',
      language: 'en',
      order: 4,
      isActive: true,
    ),
    GeneralChildcareModel(
      id: 'safety_1_en',
      title: 'Home Safety for CHD Children',
      description: 'Creating a safe environment for your child at home',
      category: 'safety',
      ageRange: 'All ages',
      contentType: 'text',
      body: '''
# Home Safety for CHD Children

## Creating a Safe Environment

Children with CHD may have special safety needs. It's important to create a home environment that supports their health and well-being.

## General Safety Measures

### Medical Equipment
- Keep all medical devices in good working order
- Have backup supplies available
- Know how to use emergency equipment
- Keep emergency contact numbers easily accessible

### Home Environment
- Maintain appropriate temperature (not too hot or cold)
- Ensure good air quality
- Remove potential hazards (loose cords, small objects)
- Install safety gates and locks as needed

### Activity Safety
- Follow activity restrictions as recommended by your doctor
- Supervise play activities
- Avoid overexertion
- Monitor for signs of fatigue or distress

## Emergency Preparedness

- **Emergency plan**: Have a clear plan for medical emergencies
- **Medications**: Keep medications organized and accessible
- **Medical records**: Keep copies of important medical documents
- **Transportation**: Know how to get to the hospital quickly

## Special Considerations

- **Oxygen use**: Follow safety guidelines for oxygen equipment
- **Feeding safety**: Monitor for choking risks
- **Medication safety**: Store medications safely, follow dosing instructions

## When to Call for Help

Call emergency services immediately if:
- Severe breathing difficulties
- Blue or pale skin color
- Loss of consciousness
- Severe chest pain or distress
''',
      language: 'en',
      order: 5,
      isActive: true,
    ),
    GeneralChildcareModel(
      id: 'daily_care_1_en',
      title: 'Daily Care Routine',
      description: 'Establishing a daily care routine for your child',
      category: 'daily_care',
      ageRange: 'All ages',
      contentType: 'text',
      body: '''
# Daily Care Routine

## Importance of Routine

A consistent daily routine helps children with CHD feel secure and makes it easier to manage their care needs.

## Morning Routine

1. **Medications**: Administer morning medications as prescribed
2. **Vital signs**: Check temperature, breathing, and color
3. **Feeding**: Follow feeding schedule
4. **Activity**: Gentle activities as tolerated

## Throughout the Day

- **Medication schedule**: Follow all medication times
- **Feeding times**: Maintain consistent feeding schedule
- **Rest periods**: Allow adequate rest between activities
- **Monitoring**: Watch for any changes in condition

## Evening Routine

1. **Medications**: Administer evening medications
2. **Bathing**: Gentle bath if appropriate
3. **Feeding**: Last feeding of the day
4. **Bedtime**: Establish calming bedtime routine

## Tracking and Documentation

- Keep a daily log of:
  - Medications given
  - Feeding amounts and times
  - Any symptoms or concerns
  - Activity levels
  - Sleep patterns

## Tips for Success

- Be consistent with timing
- Involve your child when age-appropriate
- Make routines positive and calm
- Adjust as needed based on your child's condition
''',
      language: 'en',
      order: 6,
      isActive: true,
    ),
    GeneralChildcareModel(
      id: 'development_1_en',
      title: 'Developmental Milestones',
      description: 'Understanding developmental progress for children with CHD',
      category: 'development',
      ageRange: '0-5 years',
      contentType: 'text',
      body: '''
# Developmental Milestones

## Understanding Development

Children with CHD may reach milestones at different times than typical children. This is normal and expected.

## What to Expect

### Physical Development
- May be slower due to energy limitations
- Focus on progress, not comparison
- Celebrate small achievements
- Work with physical therapists if recommended

### Cognitive Development
- Usually progresses normally
- Provide age-appropriate stimulation
- Read, play, and interact regularly
- Support learning through play

### Social Development
- Encourage interaction with family and peers
- Support emotional development
- Address any concerns with your healthcare team

## Supporting Development

1. **Play**: Age-appropriate play activities
2. **Stimulation**: Provide varied experiences
3. **Rest**: Balance activity with rest
4. **Therapy**: Participate in recommended therapies

## When to Discuss Concerns

Talk to your healthcare team if you have concerns about:
- Significant delays in multiple areas
- Regression in skills
- Lack of progress over several months
- Behavioral concerns
''',
      language: 'en',
      order: 7,
      isActive: true,
    ),
  ];

  static final List<GeneralChildcareModel> _arabicItems = [
    GeneralChildcareModel(
      id: 'growth_1_ar',
      title: 'مراقبة نمو طفلك',
      description: 'فهم أنماط النمو والمعالم التنموية للأطفال المصابين بأمراض القلب الخلقية',
      category: 'growth',
      ageRange: '0-12 شهر',
      contentType: 'text',
      body: '''
# مراقبة نمو طفلك

## لماذا مراقبة النمو مهمة

قد يعاني الأطفال المصابون بأمراض القلب الخلقية (CHD) من أنماط نمو مختلفة مقارنة بالأطفال الأصحاء. تساعد المراقبة المنتظمة على ضمان نمو طفلك بشكل مناسب.

## المؤشرات الرئيسية

- **زيادة الوزن**: يجب أن تكون ثابتة ومستمرة
- **الطول**: تتبع القياسات الشهرية
- **محيط الرأس**: مهم للرضع
- **معالم التطور**: المهارات الحركية والتفاعل الاجتماعي

## متى تقلق

اتصل بمقدم الرعاية الصحية إذا لاحظت:
- فقدان الوزن المفاجئ
- عدم زيادة الوزن لمدة 2-3 أسابيع
- تأخيرات كبيرة في المعالم التنموية

## نصائح للنمو الصحي

1. تأكد من التغذية الكافية
2. اتبع جداول التغذية الموصى بها من قبل طبيبك
3. راقب علامات التعب أثناء الرضاعة
4. حافظ على المواعيد المنتظمة مع طبيب القلب للأطفال
''',
      language: 'ar',
      order: 1,
      isActive: true,
    ),
    GeneralChildcareModel(
      id: 'nutrition_1_ar',
      title: 'إرشادات التغذية لأطفال أمراض القلب الخلقية',
      description: 'معلومات أساسية عن التغذية والرضاعة لطفلك',
      category: 'nutrition',
      ageRange: 'جميع الأعمار',
      contentType: 'text',
      body: '''
# إرشادات التغذية لأطفال أمراض القلب الخلقية

## الاحتياجات الغذائية الخاصة

غالبًا ما يحتاج الأطفال المصابون بأمراض القلب الخلقية إلى سعرات حرارية أكثر من الأطفال الأصحاء لأن قلوبهم تعمل بجهد أكبر. ومع ذلك، قد يتعبون بسهولة أثناء الرضاعة.

## استراتيجيات التغذية

### للرضع
- أطعم كميات أصغر بشكل متكرر
- اسمح بفترات راحة أثناء الرضاعة
- فكر في الحليب المدعم إذا أوصى به طبيبك
- راقب علامات التعب (التعرق، التنفس السريع)

### للأطفال الأكبر سنًا
- أطعمة عالية السعرات وغنية بالعناصر الغذائية
- وجبات صغيرة متكررة
- تجنب الملح الزائد (ما لم يُوجه بخلاف ذلك)
- حافظ على الترطيب، لكن راقب تناول السوائل إذا كان على مدرات البول

## اعتبارات مهمة

- **احتياجات السعرات الحرارية**: قد تكون أعلى بنسبة 20-40% من المعتاد
- **وقت الرضاعة**: قد يستغرق وقتًا أطول من المعتاد
- **المكملات**: استخدم فقط حسب توصية فريق الرعاية الصحية
- **التغذية بالأنبوب**: قد تكون ضرورية لبعض الأطفال

## متى تتصل بطبيبك

- صعوبة في الرضاعة أو البلع
- القيء المستمر
- علامات الجفاف
- فقدان الوزن الكبير
''',
      language: 'ar',
      order: 2,
      isActive: true,
    ),
    GeneralChildcareModel(
      id: 'sleep_1_ar',
      title: 'أنماط النوم والراحة',
      description: 'فهم احتياجات النوم وخلق بيئة نوم آمنة',
      category: 'sleep',
      ageRange: 'جميع الأعمار',
      contentType: 'text',
      body: '''
# أنماط النوم والراحة

## احتياجات النوم لأطفال أمراض القلب الخلقية

قد يحتاج الأطفال المصابون بأمراض القلب الخلقية إلى راحة أكثر من الأطفال العاديين. تعمل قلوبهم بجهد أكبر، مما قد يسبب التعب.

## خلق بيئة نوم آمنة

- **الوضع**: اتبع توصيات طبيبك (بعض الأطفال يحتاجون أوضاعًا مرتفعة)
- **المراقبة**: فكر في استخدام جهاز مراقبة الطفل أو مقياس التأكسج النبضي إذا أوصى به
- **درجة الحرارة**: حافظ على الغرفة مريحة، ليست ساخنة جدًا أو باردة جدًا
- **السلامة**: اتبع إرشادات النوم الآمن (لا أغطية فضفاضة، إعداد سرير مناسب)

## تحديات النوم الشائعة

- **الاستيقاظ المتكرر**: قد يكون بسبب عدم الراحة أو صعوبات التنفس
- **الأرق**: يمكن أن يشير إلى مشاكل الأكسجين
- **النعاس المفرط**: قد يحتاج إلى تقييم طبي

## نصائح لنوم أفضل

1. أنشئ روتين نوم ثابت
2. خلق بيئة هادئة وهادئة
3. راقب علامات صعوبات التنفس
4. احتفظ بجهات الاتصال الطارئة في متناول اليد
5. اتبع جداول الأدوية كما هو موصوف

## متى تطلب المساعدة

اتصل بمقدم الرعاية الصحية إذا لاحظت:
- صعوبات تنفس شديدة أثناء النوم
- لون الجلد الأزرق أو الشاحب
- التعرق المفرط
- الأرق أو الانفعال غير المعتاد
''',
      language: 'ar',
      order: 3,
      isActive: true,
    ),
    GeneralChildcareModel(
      id: 'hygiene_1_ar',
      title: 'النظافة والوقاية من العدوى',
      description: 'الحفاظ على النظافة لمنع العدوى لدى الأطفال المصابين بأمراض القلب الخلقية',
      category: 'hygiene',
      ageRange: 'جميع الأعمار',
      contentType: 'text',
      body: '''
# النظافة والوقاية من العدوى

## لماذا النظافة حرجة

الأطفال المصابون بأمراض القلب الخلقية معرضون لخطر أعلى للإصابة بالعدوى، والتي يمكن أن تكون أكثر خطورة بالنسبة لهم. ممارسات النظافة الجيدة ضرورية.

## ممارسات النظافة اليومية

### غسل اليدين
- اغسل اليدين بشكل متكرر بالصابون والماء
- استخدم معقم اليدين عندما لا يتوفر الصابون
- علم الأطفال تقنيات غسل اليدين المناسبة
- اغسل اليدين قبل الرضاعة وبعد تغيير الحفاضات وبعد التواجد في الأماكن العامة

### الاستحمام
- الاستحمام المنتظم يساعد على منع التهابات الجلد
- استخدم صابونًا خفيفًا خاليًا من العطور
- حافظ على مواقع الجراحة نظيفة وجافة (إن أمكن)
- جفف برفق، خاصة حول الأجهزة الطبية

### العناية بالفم
- نظف الأسنان مرتين يوميًا
- فحوصات الأسنان المنتظمة مهمة
- قد يحتاج بعض الأطفال إلى المضادات الحيوية الوقائية قبل إجراءات الأسنان

## الوقاية من العدوى

- **التطعيمات**: حافظ على تحديث جميع التطعيمات
- **تجنب الاتصال بالمرضى**: قلل التعرض للأشخاص المصابين بنزلات البرد أو الإنفلونزا
- **تنظيف الأسطح**: عقم الألعاب والأسطح بانتظام
- **المعدات الطبية**: حافظ على نظافة جميع الأجهزة الطبية

## اعتبارات خاصة

- **مواقع الجراحة**: حافظ على النظافة وراقب علامات العدوى
- **أنابيب التغذية**: اتبع بروتوكولات النظافة الصارمة
- **معدات الأكسجين**: حافظ على النظافة واستبدل حسب التوصية

## متى تتصل بطبيبك

- علامات العدوى (الحمى، الاحمرار، التورم)
- إفرازات غير عادية من الجروح
- السعال المستمر أو تغيرات التنفس
- انخفاض النشاط أو الشهية
''',
      language: 'ar',
      order: 4,
      isActive: true,
    ),
    GeneralChildcareModel(
      id: 'safety_1_ar',
      title: 'سلامة المنزل لأطفال أمراض القلب الخلقية',
      description: 'خلق بيئة آمنة لطفلك في المنزل',
      category: 'safety',
      ageRange: 'جميع الأعمار',
      contentType: 'text',
      body: '''
# سلامة المنزل لأطفال أمراض القلب الخلقية

## خلق بيئة آمنة

قد يكون للأطفال المصابين بأمراض القلب الخلقية احتياجات سلامة خاصة. من المهم خلق بيئة منزلية تدعم صحتهم ورفاهيتهم.

## إجراءات السلامة العامة

### المعدات الطبية
- حافظ على جميع الأجهزة الطبية في حالة عمل جيدة
- احتفظ بالإمدادات الاحتياطية المتاحة
- اعرف كيفية استخدام معدات الطوارئ
- احتفظ بأرقام الاتصال الطارئة في متناول اليد بسهولة

### بيئة المنزل
- حافظ على درجة حرارة مناسبة (ليست ساخنة جدًا أو باردة جدًا)
- تأكد من جودة الهواء الجيدة
- أزل المخاطر المحتملة (الحبال الفضفاضة، الأشياء الصغيرة)
- قم بتركيب بوابات السلامة والأقفال حسب الحاجة

### سلامة النشاط
- اتبع قيود النشاط كما أوصى طبيبك
- راقب أنشطة اللعب
- تجنب الإرهاق
- راقب علامات التعب أو الضيق

## الاستعداد للطوارئ

- **خطة الطوارئ**: احصل على خطة واضحة للطوارئ الطبية
- **الأدوية**: حافظ على تنظيم الأدوية وإمكانية الوصول إليها
- **السجلات الطبية**: احتفظ بنسخ من المستندات الطبية المهمة
- **النقل**: اعرف كيفية الوصول إلى المستشفى بسرعة

## اعتبارات خاصة

- **استخدام الأكسجين**: اتبع إرشادات السلامة لمعدات الأكسجين
- **سلامة التغذية**: راقب مخاطر الاختناق
- **سلامة الأدوية**: قم بتخزين الأدوية بأمان، اتبع تعليمات الجرعة

## متى تستدعي المساعدة

اتصل بخدمات الطوارئ فورًا إذا:
- صعوبات تنفس شديدة
- لون الجلد الأزرق أو الشاحب
- فقدان الوعي
- ألم صدر شديد أو ضيق
''',
      language: 'ar',
      order: 5,
      isActive: true,
    ),
    GeneralChildcareModel(
      id: 'daily_care_1_ar',
      title: 'روتين الرعاية اليومية',
      description: 'إنشاء روتين رعاية يومي لطفلك',
      category: 'daily_care',
      ageRange: 'جميع الأعمار',
      contentType: 'text',
      body: '''
# روتين الرعاية اليومية

## أهمية الروتين

يساعد الروتين اليومي الثابت الأطفال المصابين بأمراض القلب الخلقية على الشعور بالأمان ويجعل إدارة احتياجات رعايتهم أسهل.

## روتين الصباح

1. **الأدوية**: أعط أدوية الصباح كما هو موصوف
2. **العلامات الحيوية**: تحقق من درجة الحرارة والتنفس واللون
3. **التغذية**: اتبع جدول التغذية
4. **النشاط**: أنشطة لطيفة حسب التحمل

## طوال اليوم

- **جدول الأدوية**: اتبع جميع أوقات الأدوية
- **أوقات التغذية**: حافظ على جدول تغذية ثابت
- **فترات الراحة**: اسمح براحة كافية بين الأنشطة
- **المراقبة**: راقب أي تغييرات في الحالة

## روتين المساء

1. **الأدوية**: أعط أدوية المساء
2. **الاستحمام**: حمام لطيف إذا كان مناسبًا
3. **التغذية**: آخر رضاعة في اليوم
4. **وقت النوم**: أنشئ روتين نوم مهدئ

## التتبع والتوثيق

- احتفظ بسجل يومي لـ:
  - الأدوية المعطاة
  - كميات وأوقات التغذية
  - أي أعراض أو مخاوف
  - مستويات النشاط
  - أنماط النوم

## نصائح للنجاح

- كن ثابتًا في التوقيت
- شارك طفلك عندما يكون مناسبًا للعمر
- اجعل الروتين إيجابيًا وهادئًا
- اضبط حسب الحاجة بناءً على حالة طفلك
''',
      language: 'ar',
      order: 6,
      isActive: true,
    ),
    GeneralChildcareModel(
      id: 'development_1_ar',
      title: 'المعالم التنموية',
      description: 'فهم التقدم التنموي للأطفال المصابين بأمراض القلب الخلقية',
      category: 'development',
      ageRange: '0-5 سنوات',
      contentType: 'text',
      body: '''
# المعالم التنموية

## فهم التطور

قد يصل الأطفال المصابون بأمراض القلب الخلقية إلى المعالم في أوقات مختلفة عن الأطفال العاديين. هذا طبيعي ومتوقع.

## ما يمكن توقعه

### التطور البدني
- قد يكون أبطأ بسبب قيود الطاقة
- ركز على التقدم، وليس المقارنة
- احتفل بالإنجازات الصغيرة
- اعمل مع أخصائيي العلاج الطبيعي إذا أوصى به

### التطور المعرفي
- عادة ما يتقدم بشكل طبيعي
- قدم تحفيزًا مناسبًا للعمر
- اقرأ واعب واتفاعل بانتظام
- ادعم التعلم من خلال اللعب

### التطور الاجتماعي
- شجع التفاعل مع العائلة والأقران
- ادعم التطور العاطفي
- ناقش أي مخاوف مع فريق الرعاية الصحية

## دعم التطور

1. **اللعب**: أنشطة لعب مناسبة للعمر
2. **التحفيز**: قدم تجارب متنوعة
3. **الراحة**: وازن النشاط مع الراحة
4. **العلاج**: شارك في العلاجات الموصى بها

## متى تناقش المخاوف

تحدث إلى فريق الرعاية الصحية إذا كانت لديك مخاوف بشأن:
- تأخيرات كبيرة في مناطق متعددة
- تراجع في المهارات
- عدم التقدم على مدى عدة أشهر
- مخاوف سلوكية
''',
      language: 'ar',
      order: 7,
      isActive: true,
    ),
  ];

  /// Get items filtered by language and category
  static List<GeneralChildcareModel> getItems({
    String? language,
    String? category,
  }) {
    var items = allItems.where((item) => item.isActive).toList();

    // Filter by language
    if (language != null && language.isNotEmpty) {
      items = items.where((item) => item.language == language).toList();
    }

    // Filter by category
    if (category != null && category.isNotEmpty && category != 'all') {
      items = items.where((item) => item.category == category).toList();
    }

    // Sort by order
    items.sort((a, b) => a.order.compareTo(b.order));

    return items;
  }

  /// Get item by ID
  static GeneralChildcareModel? getItemById(String id) {
    try {
      return allItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
}

