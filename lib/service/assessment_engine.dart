import 'package:flutter/material.dart';
import 'package:promotional_app/model/assesment_model.dart';


class AssessmentEngine {
  // --- UNIVERSAL VITALS (Asked to Everyone) ---
  static final List<ScreeningQuestion> _coreQuestions = [
    ScreeningQuestion(id: 'height', text: "Height?", type: QuestionType.slider, category: LifestyleCategory.biometrics, min: 120, max: 220, unit: "cm"),
    ScreeningQuestion(id: 'weight', text: "Weight?", type: QuestionType.slider, category: LifestyleCategory.biometrics, min: 30, max: 180, unit: "kg"),
    ScreeningQuestion(id: 'waist_hip', text: "Is your waist larger than your hips?", type: QuestionType.yesNo, category: LifestyleCategory.biometrics, isRedFlag: true),
    ScreeningQuestion(id: 'bp_dizzy', text: "Do you get dizzy when standing up quickly?", type: QuestionType.yesNo, category: LifestyleCategory.heart, isRedFlag: true),
    ScreeningQuestion(id: 'water', text: "Daily water intake?", type: QuestionType.singleChoice, category: LifestyleCategory.toxicity, options: ["< 1.5 L", "1.5 - 2.5 L", "3 L+"]),
    ScreeningQuestion(id: 'cooking_oil', text: "Primary cooking oil?", type: QuestionType.singleChoice, category: LifestyleCategory.toxicity, options: ["Ghee/Coconut/Olive", "Refined (Sunflower/Soy)", "Mustard"]),
    ScreeningQuestion(id: 'sleep_hrs', text: "Avg Sleep?", type: QuestionType.slider, category: LifestyleCategory.sleep, min: 3, max: 12, unit: "hrs"),
  ];

  static final List<HealthPath> paths = [
    // --- PATH 1: METABOLIC SYNDROME ---
    HealthPath(
      id: 'metabolic',
      title: 'Weight & Blood Sugar',
      description: 'Insulin resistance, cravings & fat loss barriers.',
      icon: Icons.monitor_weight_outlined,
      specificQuestions: [
        ScreeningQuestion(id: 'polyuria', text: "Do you wake up to urinate >1 time/night?", type: QuestionType.yesNo, category: LifestyleCategory.diabetes, isRedFlag: true),
        ScreeningQuestion(id: 'crash', text: "Do you feel sleepy/foggy 30 mins after lunch?", type: QuestionType.yesNo, category: LifestyleCategory.diabetes),
        ScreeningQuestion(id: 'hangry', text: "Do you get irritable/shaky if you miss a meal?", type: QuestionType.yesNo, category: LifestyleCategory.diabetes),
        ScreeningQuestion(id: 'acanthosis', text: "Dark patches on neck/armpits?", type: QuestionType.yesNo, category: LifestyleCategory.diabetes, isRedFlag: true),
        ScreeningQuestion(id: 'xanthelasma', text: "Yellowish bumps on eyelids?", type: QuestionType.yesNo, category: LifestyleCategory.heart, isRedFlag: true),
        ScreeningQuestion(id: 'fat_nausea', text: "Do you feel nauseous after fatty/fried meals?", type: QuestionType.yesNo, category: LifestyleCategory.gut),
        ScreeningQuestion(id: 'eating_speed', text: "Do you eat fast (<15 mins)?", type: QuestionType.yesNo, category: LifestyleCategory.gut),
        ScreeningQuestion(id: 'sugar_crave', text: "Do you 'need' sweets after meals?", type: QuestionType.yesNo, category: LifestyleCategory.diabetes),
      ],
    ),

    // --- PATH 2: HORMONAL BALANCE ---
    HealthPath(
      id: 'hormonal',
      title: 'PCOS & Thyroid',
      description: 'Periods, hair fall, acne & fatigue.',
      icon: Icons.spa_outlined,
      specificQuestions: [
        ScreeningQuestion(id: 'cycle_regularity', text: "Are periods irregular?", type: QuestionType.yesNo, category: LifestyleCategory.hormonal),
        ScreeningQuestion(id: 'jawline_acne', text: "Cystic acne on jawline/chin?", type: QuestionType.yesNo, category: LifestyleCategory.hormonal, isRedFlag: true),
        ScreeningQuestion(id: 'hirsutism', text: "Coarse hair on chin/chest?", type: QuestionType.yesNo, category: LifestyleCategory.hormonal, isRedFlag: true),
        ScreeningQuestion(id: 'cold_intolerance', text: "Are hands/feet constantly cold?", type: QuestionType.yesNo, category: LifestyleCategory.hormonal),
        ScreeningQuestion(id: 'eyebrows', text: "Thinning of outer eyebrows?", type: QuestionType.yesNo, category: LifestyleCategory.hormonal),
        ScreeningQuestion(id: 'constipation', text: "Chronic constipation?", type: QuestionType.yesNo, category: LifestyleCategory.gut),
        ScreeningQuestion(id: 'tired_wired', text: "Tired all day but awake at night?", type: QuestionType.yesNo, category: LifestyleCategory.sleep, isRedFlag: true),
      ],
    ),

    // --- PATH 3: CARDIO & HYPERTENSION ---
    HealthPath(
      id: 'cardio',
      title: 'Heart & Hypertension',
      description: 'BP, palpitations & cholesterol check.',
      icon: Icons.favorite_border,
      specificQuestions: [
        ScreeningQuestion(id: 'morning_headache', text: "Wake up with heavy head/neck pain?", type: QuestionType.yesNo, category: LifestyleCategory.heart, isRedFlag: true),
        ScreeningQuestion(id: 'tinnitus', text: "Ringing in ears (Tinnitus)?", type: QuestionType.yesNo, category: LifestyleCategory.heart),
        ScreeningQuestion(id: 'breath_stairs', text: "Short of breath after 1 flight of stairs?", type: QuestionType.yesNo, category: LifestyleCategory.heart, isRedFlag: true),
        ScreeningQuestion(id: 'salt_swell', text: "Do fingers swell after salty food?", type: QuestionType.yesNo, category: LifestyleCategory.heart),
        ScreeningQuestion(id: 'family_heart', text: "Family history of heart attack <55 yrs?", type: QuestionType.yesNo, category: LifestyleCategory.heart),
      ],
    ),

    // --- PATH 4: GUT & IMMUNITY ---
    HealthPath(
      id: 'gut_immune',
      title: 'Gut & Immunity',
      description: 'Bloating, acidity & recovery speed.',
      icon: Icons.shield_outlined,
      specificQuestions: [
        ScreeningQuestion(id: 'bloating_time', text: "Get more bloated as day goes on?", type: QuestionType.yesNo, category: LifestyleCategory.gut),
        ScreeningQuestion(id: 'acid_reflux', text: "Rely on antacids (Eno/Pantop)?", type: QuestionType.yesNo, category: LifestyleCategory.gut, isRedFlag: true),
        ScreeningQuestion(id: 'tongue_coat', text: "White coating on tongue?", type: QuestionType.yesNo, category: LifestyleCategory.gut),
        ScreeningQuestion(id: 'stool_float', text: "Do stools float/look greasy?", type: QuestionType.yesNo, category: LifestyleCategory.gut),
        ScreeningQuestion(id: 'antibiotics', text: "Antibiotics >2 times last year?", type: QuestionType.yesNo, category: LifestyleCategory.immunity),
        ScreeningQuestion(id: 'recovery_slow', text: "Does flu take >7 days to clear?", type: QuestionType.yesNo, category: LifestyleCategory.immunity, isRedFlag: true),
      ],
    ),
  ];

  static List<ScreeningQuestion> getFullQuestionSet(HealthPath path) {
    return [...path.specificQuestions, ..._coreQuestions];
  }

  static List<HealthPath> getAvailablePaths(double age, String gender) {
    return paths.where((path) {
      if (gender == 'Male' && path.id == 'hormonal') return false;
      return true;
    }).toList();
  }
}

class AppTranslations {
  // --- UI LABELS ---
  static const Map<String, Map<String, String>> uiLabels = {
    'en': {
      'back': 'Back',
      'analyzing': 'Analyzing Metabolic Patterns...',
      'book_consult': 'Book Consultation',
      'restart': 'Start New Audit',
      'audit_title': 'Health Assessment',
      'select_path': 'Select Your Concern',
      'welcome': 'Welcome',
      'start_diag': 'Start Diagnostic',
      'submit': 'Submit Audit',
      'name': 'Full Name',
      'contact': 'Mobile Number',
      'age': 'Age',
      'gender': 'Gender',
    },
    'hi': {
      'back': 'पीछे',
      'analyzing': 'मेटाबोलिक विश्लेषण चल रहा है...',
      'book_consult': 'परामर्श बुक करें',
      'restart': 'पुनः आरंभ करें',
      'audit_title': 'स्वास्थ्य मूल्यांकन',
      'select_path': 'अपनी समस्या चुनें',
      'welcome': 'नमस्ते',
      'start_diag': 'जांच शुरू करें',
      'submit': 'जमा करें',
      'name': 'पूरा नाम',
      'contact': 'मोबाइल नंबर',
      'age': 'आयु',
      'gender': 'लिंग',
    },
    'or': {
      'back': 'ଫେରନ୍ତୁ',
      'analyzing': 'ବିଶ୍ଳେଷଣ ଚାଲିଛି...',
      'book_consult': 'ପରାମର୍ଶ ବୁକ୍ କରନ୍ତୁ',
      'restart': 'ନୂତନ ଯାଞ୍ଚ',
      'audit_title': 'ସ୍ୱାସ୍ଥ୍ୟ ମୂଲ୍ୟାଙ୍କନ',
      'select_path': 'ଆପଣଙ୍କ ସମସ୍ୟା ବାଛନ୍ତୁ',
      'welcome': 'ନମସ୍କାର',
      'start_diag': 'ଆରମ୍ଭ କରନ୍ତୁ',
      'submit': 'ଦାଖଲ କରନ୍ତୁ',
      'name': 'ପୁରା ନାମ',
      'contact': 'ମୋବାଇଲ୍ ନମ୍ବର',
      'age': 'ବୟସ',
      'gender': 'ଲିଙ୍ଗ',
    }
  };

  // --- QUESTION DICTIONARY ---
  static const Map<String, Map<String, dynamic>> questions = {
    // --- CORE VITALS ---
    'height': {
      'hi': {'q': 'आपकी लंबाई (Height)?'},
      'or': {'q': 'ଆପଣଙ୍କ ଉଚ୍ଚତା (Height)?'},
    },
    'weight': {
      'hi': {'q': 'आपका वजन (Weight)?'},
      'or': {'q': 'ଆପଣଙ୍କ ଓଜନ (Weight)?'},
    },
    'waist_hip': {
      'hi': {'q': 'क्या आपकी कमर (Waist) आपके कूल्हों (Hips) से चौड़ी है?'},
      'or': {'q': 'ଆପଣଙ୍କ ଅଣ୍ଟା (Waist) କ’ଣ ଆପଣଙ୍କ ହିପ୍ସ (Hips) ଠାରୁ ଅଧିକ ଚଉଡା କି?'},
    },
    'bp_dizzy': {
      'hi': {'q': 'क्या अचानक खड़े होने पर चक्कर आते हैं?'},
      'or': {'q': 'ହଠାତ୍ ଛିଡା ହେଲେ ମୁଣ୍ଡ ବୁଲାଏ କି?'},
    },
    'water': {
      'hi': {'q': 'रोजाना कितना पानी पीते हैं?'},
      'or': {'q': 'ଦିନକୁ କେତେ ପାଣି ପିଅନ୍ତି?'},
    },
    'cooking_oil': {
      'hi': {'q': 'खाना पकाने का मुख्य तेल?'},
      'or': {'q': 'ରୋଷେଇ ପାଇଁ କେଉଁ ତେଲ ବ୍ୟବହାର କରନ୍ତି?'},
    },
    'sleep_hrs': {
      'hi': {'q': 'औसत नींद (घंटे)?'},
      'or': {'q': 'ହାରାହାରି ନିଦ (ଘଣ୍ଟା)?'},
    },

    // --- METABOLIC (DIABETES) ---
    'polyuria': {
      'hi': {'q': 'क्या आप रात में पेशाब करने के लिए उठते हैं (>1 बार)?'},
      'or': {'q': 'ରାତିରେ ପରିସ୍ରା କରିବାକୁ ଉଠନ୍ତି କି (>1 ଥର)?'},
    },
    'crash': {
      'hi': {'q': 'क्या लंच के 30 मिनट बाद बहुत नींद आती है?'},
      'or': {'q': 'ଖାଇବା ପରେ ନିଦ ଲାଗେ କି?'},
    },
    'hangry': {
      'hi': {'q': 'खाना न मिलने पर क्या चिड़चिड़ापन या कंपन होता है?'},
      'or': {'q': 'ଖାଇବା ଡେରି ହେଲେ ଚିଡିଚିଡା ଲାଗେ କି?'},
    },
    'acanthosis': {
      'hi': {'q': 'गर्दन या बगलों पर काले निशान हैं?'},
      'or': {'q': 'ବେକ କିମ୍ବା କାଖରେ କଳା ଦାଗ ଅଛି କି?'},
    },
    'xanthelasma': {
      'hi': {'q': 'पलकों पर पीले दाने हैं?'},
      'or': {'q': 'ଆଖି ପତା ଉପରେ ହଳଦିଆ ଦାନା ଅଛି କି?'},
    },
    'fat_nausea': {
      'hi': {'q': 'तली हुई चीजें खाने के बाद उल्टी जैसा लगता है?'},
      'or': {'q': 'ତେଲିଆ ଖାଦ୍ୟ ଖାଇଲେ ବାନ୍ତି ଲାଗେ କି?'},
    },
    'eating_speed': {
      'hi': {'q': 'क्या आप बहुत जल्दी खाना खाते हैं (<15 मिनट)?'},
      'or': {'q': 'ଆପଣ କ’ଣ ବହୁତ ଜଲଦି ଖାଆନ୍ତି (<15 ମିନିଟ୍)?'},
    },
    'sugar_crave': {
      'hi': {'q': 'खाने के बाद मीठा खाने की तलब होती है?'},
      'or': {'q': 'ଖାଇବା ପରେ ମିଠା ଖାଇବାକୁ ଇଚ୍ଛା ହୁଏ କି?'},
    },

    // --- HORMONAL (PCOS/THYROID) ---
    'cycle_regularity': {
      'hi': {'q': 'क्या पीरियड्स अनियमित हैं?'},
      'or': {'q': 'ମାସିକ ଧର୍ମ (Periods) ଅନିୟମିତ କି?'},
    },
    'jawline_acne': {
      'hi': {'q': 'क्या ठुड्डी (Chin) पर मुहांसे होते हैं?'},
      'or': {'q': 'ଥୋଡି (Chin) ରେ ବ୍ରଣ ହୁଏ କି?'},
    },
    'hirsutism': {
      'hi': {'q': 'चेहरे या छाती पर अनचाहे बाल हैं?'},
      'or': {'q': 'ମୁହଁ କିମ୍ବା ଛାତିରେ ଅଦରକାରୀ କେଶ ଅଛି କି?'},
    },
    'cold_intolerance': {
      'hi': {'q': 'क्या हाथ-पैर हमेशा ठंडे रहते हैं?'},
      'or': {'q': 'ହାତ ଗୋଡ ସବୁବେଳେ ଥଣ୍ଡା ରହେ କି?'},
    },
    'eyebrows': {
      'hi': {'q': 'क्या भौहें (Eyebrows) किनारों से पतली हो रही हैं?'},
      'or': {'q': 'ଆଖିର ଭ୍ରୁଲତା (Eyebrows) ପତଳା ହେଉଛି କି?'},
    },
    'constipation': {
      'hi': {'q': 'क्या अक्सर कब्ज रहती है?'},
      'or': {'q': 'କୋଷ୍ଠକାଠିନ୍ୟ (Constipation) ରହେ କି?'},
    },
    'tired_wired': {
      'hi': {'q': 'दिन भर थकान, लेकिन रात में नींद नहीं आती?'},
      'or': {'q': 'ଦିନସାରା ଥକା, କିନ୍ତୁ ରାତିରେ ନିଦ ହୁଏନି?'},
    },

    // --- CARDIO (HEART) ---
    'morning_headache': {
      'hi': {'q': 'क्या सुबह सिर या गर्दन में भारीपन रहता है?'},
      'or': {'q': 'ସକାଳୁ ମୁଣ୍ଡ ବିନ୍ଧା କିମ୍ବା ବେକ ବିନ୍ଧା ହୁଏ କି?'},
    },
    'tinnitus': {
      'hi': {'q': 'क्या कानों में घंटी बजने जैसी आवाज आती है?'},
      'or': {'q': 'କାନରେ ଶବ୍ଦ (Tinnitus) ହୁଏ କି?'},
    },
    'breath_stairs': {
      'hi': {'q': 'सीढ़ियां चढ़ने पर सांस फूलती है?'},
      'or': {'q': 'ପାହାଚ ଚଢିଲେ ନିଶ୍ୱାସ ଫୁଲେ କି?'},
    },
    'salt_swell': {
      'hi': {'q': 'नमक खाने के बाद उंगलियों में सूजन आती है?'},
      'or': {'q': 'ଲୁଣ ଖାଇଲେ ହାତ ଗୋଡ ଫୁଲେ କି?'},
    },
    'family_heart': {
      'hi': {'q': 'परिवार में किसी को हार्ट अटैक आया है (<55 वर्ष)?'},
      'or': {'q': 'ପରିବାରରେ କାହାର ହୃଦଘାତ (Heart Attack) ହୋଇଛି କି?'},
    },

    // --- GUT & IMMUNITY ---
    'bloating_time': {
      'hi': {'q': 'क्या दिन ढलते ही पेट फूलने लगता है?'},
      'or': {'q': 'ସନ୍ଧ୍ୟା ହେଲେ ପେଟ ଫୁଲେ କି (Bloating)?'},
    },
    'acid_reflux': {
      'hi': {'q': 'क्या अक्सर एंटासिड (Eno/Pantop) की जरूरत पड़ती है?'},
      'or': {'q': 'ଗ୍ୟାସ୍ ଔଷଧ (Eno/Pantop) ଖାଇବାକୁ ପଡେ କି?'},
    },
    'tongue_coat': {
      'hi': {'q': 'क्या जीभ पर सफेद परत जमी रहती है?'},
      'or': {'q': 'ଜିଭରେ ଧଳା ସ୍ତର ଜମେ କି?'},
    },
    'stool_float': {
      'hi': {'q': 'क्या मल (Stool) पानी में तैरता है या चिपचिपा है?'},
      'or': {'q': 'ଝାଡା (Stool) ପାଣିରେ ଭାସେ କିମ୍ବା ଚିକିଟା ହୁଏ କି?'},
    },
    'antibiotics': {
      'hi': {'q': 'पिछले साल >2 बार एंटीबायोटिक ली है?'},
      'or': {'q': 'ଗତ ବର୍ଷ >2 ଥର ଆଣ୍ଟିବାୟୋଟିକ୍ ଖାଇଛନ୍ତି କି?'},
    },
    'recovery_slow': {
      'hi': {'q': 'क्या सर्दी-जुकाम ठीक होने में >7 दिन लगते हैं?'},
      'or': {'q': 'ଥଣ୍ଡା ଠିକ୍ ହେବାକୁ 7 ଦିନରୁ ଅଧିକ ସମୟ ଲାଗେ କି?'},
    },
  };
}