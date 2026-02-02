import 'package:flutter/material.dart';

class KnowledgeItem {
  final String id;
  final String category;
  final IconData icon;

  final Map<String, String> title;
  final Map<String, String> symptoms;
  final Map<String, String> reality;
  final Map<String, String> solution; // NOW HIGH-LEVEL SCIENCE

  const KnowledgeItem({
    required this.id,
    required this.category,
    required this.icon,
    required this.title,
    required this.symptoms,
    required this.reality,
    required this.solution,
  });
}

const List<KnowledgeItem> masterKnowledge = [

  // 1. DIABETES
  KnowledgeItem(
    id: 'diabetes',
    category: 'disease',
    icon: Icons.water_drop_outlined,
    title: {
      'en': 'Diabetes: The Insulin Lie',
      'hi': 'मधुमेह: इंसुलिन का सच',
      'or': 'ମଧୁମେହ: ଇନସୁଲିନ୍ ର ସତ୍ୟ',
    },
    symptoms: {
      'en': '• Constant hunger/cravings\n• Dark neck (Acanthosis Nigricans)\n• Weight gain around belly',
      'hi': '• बार-बार भूख लगना\n• गर्दन का काला पड़ना\n• पेट की चर्बी बढ़ना',
      'or': '• ଅତ୍ୟଧିକ ଭୋକ ଲାଗିବା\n• ବେକ କଳା ପଡିଯିବା\n• ପେଟ ଚର୍ବି ବଢିବା',
    },
    reality: {
      'en': 'Insulin pushes sugar INTO your fat cells. You don\'t lose the sugar; you store it as visceral fat. This causes Fatty Liver and kidney damage over time.',
      'hi': 'इंसुलिन चीनी को खत्म नहीं करता, उसे चर्बी में बदल देता है। इसीलिए शुगर के मरीजों का वजन बढ़ता है और लिवर खराब होता है।',
      'or': 'ଇନସୁଲିନ୍ ଶର୍କରାକୁ ଚର୍ବିରେ ପରିଣତ କରେ। ଏହା ଦ୍ୱାରା ମୋଟାପା ଏବଂ ଫ୍ୟାଟି ଲିଭର ହୁଏ।',
    },
    solution: {
      'en': 'We focus on "Insulin Sensitization" using Galactomannan fibers and Chromium-rich complexes. We regulate the "Dawn Phenomenon" using clinical Chronobiology (timing of nutrients) to rest the pancreas.',
      'hi': 'हम "इन्सुलिन सेंसिटिविटी" पर काम करते हैं। हम विशेष फाइबर और क्रोमियम का उपयोग करके कोशिकाओं को प्राकृतिक रूप से ठीक करते हैं।',
      'or': 'ଆମେ ବିଶେଷ ଫାଇବର ଏବଂ କ୍ରୋମିୟମ ବ୍ୟବହାର କରି କୋଷଗୁଡ଼ିକୁ ପ୍ରାକୃତିକ ଭାବେ ସୁସ୍ଥ କରୁ।',
    },
  ),

  // 2. BLOOD PRESSURE
  KnowledgeItem(
    id: 'bp',
    category: 'disease',
    icon: Icons.favorite_border,
    title: {
      'en': 'The BP Medicine Trap',
      'hi': 'हाई बीपी की दवा का जाल',
      'or': 'ଉଚ୍ଚ ରକ୍ତଚାପ ଔଷଧର ସତ୍ୟ',
    },
    symptoms: {
      'en': '• Heavy head in mornings\n• Breathlessness on stairs\n• Ringing in ears',
      'hi': '• सुबह सिर भारी लगना\n• सांस फूलना\n• कानों में बजना',
      'or': '• ସକାଳେ ମୁଣ୍ଡ ଭାରି ଲାଗିବା\n• ନିଶ୍ୱାସ ନେବାରେ କଷ୍ଟ\n• କାନରେ ଶବ୍ଦ ହେବା',
    },
    reality: {
      'en': 'Medicine forcefully relaxes blood vessels but ignores the root cause (Arterial Stiffness). Long term use damages the kidney filters (Nephrons).',
      'hi': 'दवा जबरदस्ती नसों को फैलाती है लेकिन बीमारी ठीक नहीं करती। लंबे समय तक लेने से किडनी खराब होने का खतरा रहता है।',
      'or': 'ଔଷଧ ରକ୍ତନଳୀକୁ କୃତ୍ରିମ ଭାବେ ପ୍ରସାରିତ କରେ, କିନ୍ତୁ ରୋଗ ଭଲ କରେ ନାହିଁ। କିଡନୀ ନଷ୍ଟ ହେବାର ଭୟ ଥାଏ।',
    },
    solution: {
      'en': 'We utilize "Nitric Oxide" precursors and correct the "Sodium-Potassium Pump" ratio using therapeutic electrolytes. This naturally improves arterial elasticity without side effects.',
      'hi': 'हम "नाइट्रिक ऑक्साइड" और इलेक्ट्रोलाइट संतुलन के विज्ञान का उपयोग करते हैं, जिससे नसें प्राकृतिक रूप से लचीली बनती हैं।',
      'or': 'ଆମେ "ନାଇଟ୍ରିକ୍ ଅକ୍ସାଇଡ୍" ଏବଂ ଇଲେକ୍ଟ୍ରୋଲାଇଟ୍ ସନ୍ତୁଳନ ମାଧ୍ୟମରେ ରକ୍ତନଳୀକୁ ପ୍ରାକୃତିକ ଭାବେ ସୁସ୍ଥ କରୁ।',
    },
  ),

  // 3. PCOS
  KnowledgeItem(
    id: 'pcos',
    category: 'disease',
    icon: Icons.female,
    title: {
      'en': 'PCOS & Uterus Removal',
      'hi': 'पीसीओडी और ऑपरेशन',
      'or': 'PCOS ଏବଂ ଅପରେସନ୍',
    },
    symptoms: {
      'en': '• Facial hair (Hirsutism)\n• Weight gain\n• Irregular cycles',
      'hi': '• चेहरे पर बाल\n• वजन बढ़ना\n• अनियमित माहवारी',
      'or': '• ମୁହଁରେ ଲୋମ ଉଠିବା\n• ଓଜନ ବଢିବା\n• ଅନିୟମିତ ଋତୁସ୍ରାବ',
    },
    reality: {
      'en': 'Surgery causes instant Menopause and Osteoporosis. PCOS is an endocrine (hormonal) disorder, not a reproductive one. Cutting organs creates new problems.',
      'hi': 'ऑपरेशन से शरीर एकदम बूढ़ा होने लगता है और हड्डियां कमजोर हो जाती हैं। यह हार्मोन की बीमारी है, अंगों की नहीं।',
      'or': 'ଅପରେସନ୍ ଦ୍ୱାରା ଶରୀର ଶୀଘ୍ର ବୁଢା ହୋଇଯାଏ ଏବଂ ହାଡ ଦୁର୍ବଳ ହୋଇଯାଏ। ଏହା ହରମୋନ୍ ଜନିତ ସମସ୍ୟା ଅଟେ।',
    },
    solution: {
      'en': 'We regulate the HPO Axis using "Phyto-estrogens" and specific "Lignans" to balance androgen levels. We focus on lowering inflammation to dissolve cysts naturally.',
      'hi': 'हम " फाइटो-एस्ट्रोजेन" और विशेष पोषक तत्वों का उपयोग करके हार्मोन को संतुलित करते हैं और सिस्ट को प्राकृतिक रूप से गलाते हैं।',
      'or': 'ଆମେ ବିଶେଷ ପୋଷକ ତତ୍ତ୍ୱ ବ୍ୟବହାର କରି ହରମୋନ୍ ସନ୍ତୁଳିତ କରୁ ଏବଂ ସିଷ୍ଟକୁ ପ୍ରାକୃତିକ ଭାବେ ଭଲ କରୁ।',
    },
  ),

  // 4. HEART
  KnowledgeItem(
    id: 'heart',
    category: 'disease',
    icon: Icons.monitor_heart,
    title: {
      'en': 'Heart: Cholesterol Myth',
      'hi': 'हृदय और कोलेस्ट्रॉल',
      'or': 'ହୃଦୟ ଏବଂ କୋଲେଷ୍ଟ୍ରଲ',
    },
    symptoms: {
      'en': '• Breathlessness\n• High LDL/Triglycerides\n• Chest heaviness',
      'hi': '• सांस फूलना\n• हाई कोलेस्ट्रॉल\n• छाती में भारीपन',
      'or': '• ନିଶ୍ୱାସ ଫୁଲିବା\n• ଉଚ୍ଚ କୋଲେଷ୍ଟ୍ରଲ\n• ଛାତି ଭାରି ଲାଗିବା',
    },
    reality: {
      'en': 'Cholesterol repairs arteries; it is not the enemy. The real enemy is "Endothelial Inflammation" caused by oxidative stress. Stents do not stop new blockages.',
      'hi': 'कोलेस्ट्रॉल दुश्मन नहीं है। असली दुश्मन "सूजन" (Inflammation) है। स्टेंट (Stent) नए ब्लॉकेज बनने से नहीं रोकता।',
      'or': 'କୋଲେଷ୍ଟ୍ରଲ ଶତ୍ରୁ ନୁହେଁ। ଅସଲ ଶତ୍ରୁ ହେଉଛି "ଇନଫ୍ଲାମେସନ୍"। ଷ୍ଟେଣ୍ଟ ନୂଆ ବ୍ଲକେଜ୍ ରୋକିପାରେ ନାହିଁ।',
    },
    solution: {
      'en': 'We prescribe "CoQ10" boosters and "Cardiac Glycosides" found in nature to strengthen heart muscles. We optimize your Lipid Profile using Omega-3 fatty acids.',
      'hi': 'हम "CoQ10" और ओमेगा-3 फैटी एसिड का उपयोग करके हृदय की मांसपेशियों को मजबूत करते हैं और सूजन कम करते हैं।',
      'or': 'ଆମେ ଓମେଗା-୩ ଫ୍ୟାଟି ଏସିଡ୍ ବ୍ୟବହାର କରି ହୃଦୟକୁ ମଜବୁତ କରୁ।',
    },
  ),

  // 5. THYROID
  KnowledgeItem(
    id: 'thyroid',
    category: 'disease',
    icon: Icons.waves,
    title: {
      'en': 'Thyroid Dependency',
      'hi': 'थायराइड (Thyroid)',
      'or': 'ଥାଇରଏଡ୍ (Thyroid)',
    },
    symptoms: {
      'en': '• Hair fall\n• Dry skin\n• Morning fatigue',
      'hi': '• बाल झड़ना\n• रूखी त्वचा\n• सुबह थकान',
      'or': '• ଚୁଟି ଝଡିବା\n• ଶୁଷ୍କ ଚର୍ମ\n• ସକାଳେ ଥକା ଲାଗିବା',
    },
    reality: {
      'en': 'Synthetic T4 hormone makes your gland dormant (lazy). It stops working completely over time because the root cause (Auto-immunity or Nutrient Deficiency) is ignored.',
      'hi': 'कृत्रिम हार्मोन लेने से आपकी अपनी ग्रंथि काम करना बंद कर देती है। यह बीमारी की जड़ को ठीक नहीं करता।',
      'or': 'କୃତ୍ରିମ ହରମୋନ୍ ଖାଇଲେ ନିଜର ଥାଇରଏଡ୍ ଗ୍ରନ୍ଥି କାମ କରିବା ବନ୍ଦ କରିଦିଏ।',
    },
    solution: {
      'en': 'We activate the T4-to-T3 conversion process using "Selenium" and "Zinc" pathways. We eliminate anti-nutrients (Goitrogens) that block thyroid function.',
      'hi': 'हम सेलेनियम और जिंक जैसे तत्वों का उपयोग करके ग्रंथि को फिर से सक्रिय करते हैं।',
      'or': 'ଆମେ ସେଲେନିୟମ ଏବଂ ଜିଙ୍କ ବ୍ୟବହାର କରି ଗ୍ରନ୍ଥିକୁ ସକ୍ରିୟ କରୁ।',
    },
  ),

  // 6. PAINKILLERS
  KnowledgeItem(
    id: 'painkillers',
    category: 'disease',
    icon: Icons.medication_liquid,
    title: {
      'en': 'Painkillers & Kidneys',
      'hi': 'पेनकिलर के खतरे',
      'or': 'ପେନ୍ କିଲରର ବିପଦ',
    },
    symptoms: {
      'en': '• Water retention (Puffy face)\n• High Creatinine\n• Gastric ulcers',
      'hi': '• चेहरा सूजना\n• किडनी में सूजन\n• पेट में अल्सर',
      'or': '• ମୁହଁ ଫୁଲିବା\n• କିଡନୀ ସମସ୍ୟା\n• ପେଟରେ ଘା',
    },
    reality: {
      'en': 'NSAIDs (Painkillers) constrict blood flow to the kidneys, leading to silent renal failure. They mask the pain signal but accelerate cartilage degeneration.',
      'hi': 'पेनकिलर किडनी की नसों को सिकोड़ देते हैं जिससे किडनी फेल हो सकती है। ये दर्द को छुपाते हैं लेकिन बीमारी बढ़ाते हैं।',
      'or': 'ପେନ୍ କିଲର କିଡନୀକୁ ରକ୍ତ ପ୍ରବାହ କମାଇଦିଏ, ଯାହାଦ୍ୱାରା କିଡନୀ ନଷ୍ଟ ହୋଇପାରେ।',
    },
    solution: {
      'en': 'We use natural "COX-2 Inhibitors" (Curcuminoids) to manage pain inflammation. We regenerate Synovial Fluid in joints using healthy Lipids.',
      'hi': 'हम करक्यूमिन (Curcumin) और अच्छे वसा (Lipids) का उपयोग करके जोड़ों में चिकनाई लाते हैं और दर्द कम करते हैं।',
      'or': 'ଆମେ ପ୍ରାକୃତିକ ଉପାୟରେ ଗଣ୍ଠି ଯନ୍ତ୍ରଣା ଦୂର କରୁ ଏବଂ ଗଣ୍ଠିରେ ଚିକ୍କଣ ଅଂଶ ବଢାଉ।',
    },
  ),

  // 7. ANTIBIOTICS
  KnowledgeItem(
    id: 'antibiotic',
    category: 'disease',
    icon: Icons.bug_report,
    title: {
      'en': 'Antibiotics Damage',
      'hi': 'एंटीबायोटिक का सच',
      'or': 'ଆଣ୍ଟିବାୟୋଟିକ୍ ର ସତ୍ୟ',
    },
    symptoms: {
      'en': '• Weak digestion\n• Low immunity\n• Bloating',
      'hi': '• कमजोर पाचन\n• कमजोर इम्यूनिटी\n• पेट फूलना',
      'or': '• ହଜମ ଶକ୍ତି କମିବା\n• ରୋଗ ପ୍ରତିରୋଧକ ଶକ୍ତି କମିବା\n• ପେଟ ଫୁଲିବା',
    },
    reality: {
      'en': 'Antibiotics destroy the Gut Microbiome (Good Bacteria), which controls 70% of your immunity. This leads to long-term malabsorption and allergies.',
      'hi': 'एंटीबायोटिक पेट के अच्छे बैक्टीरिया को मार देता है, जिससे इम्यूनिटी हमेशा के लिए कमजोर हो जाती है।',
      'or': 'ଆଣ୍ଟିବାୟୋଟିକ୍ ପେଟର ଭଲ ବ୍ୟାକ୍ଟେରିଆକୁ ମାରିଦିଏ, ଯାହାଦ୍ୱାରା ଭବିଷ୍ୟତରେ ରୋଗ ହେବାର ସମ୍ଭାବନା ବଢିଯାଏ।',
    },
    solution: {
      'en': 'We implement a "Gut Rehabilitation Protocol" using specific Prebiotics and Probiotic strains to recolonize the intestinal flora.',
      'hi': 'हम "प्रीबायोटिक्स" और "प्रोबायोटिक्स" का उपयोग करके पेट के अच्छे बैक्टीरिया को फिर से जीवित करते हैं।',
      'or': 'ଆମେ ବିଶେଷ ପୋଷକ ତତ୍ତ୍ୱ ବ୍ୟବହାର କରି ପେଟର ହଜମ ଶକ୍ତିକୁ ପୁନର୍ବାର ଠିକ୍ କରୁ।',
    },
  ),

  // 8. FATTY LIVER
  KnowledgeItem(
    id: 'liver',
    category: 'disease',
    icon: Icons.local_drink_outlined,
    title: {
      'en': 'Fatty Liver (No Meds)',
      'hi': 'फैटी लिवर (Fatty Liver)',
      'or': 'ଫ୍ୟାଟି ଲିଭର (Fatty Liver)',
    },
    symptoms: {
      'en': '• Right side abdominal pain\n• Fatigue\n• Gas',
      'hi': '• पेट के दाईं ओर दर्द\n• थकान\n• गैस',
      'or': '• ପେଟର ଡାହାଣ ପାଖରେ ଯନ୍ତ୍ରଣା\n• ଥକା ଲାଗିବା\n• ଗ୍ୟାସ୍',
    },
    reality: {
      'en': 'Caused by Fructose (Sugar) overload leading to De Novo Lipogenesis. Medicines cannot fix this; only metabolic correction can.',
      'hi': 'यह चीनी के अधिक सेवन से होता है। इसकी कोई दवा नहीं है, केवल सही डाइट ही इसे ठीक कर सकती है।',
      'or': 'ଏହା ଅତ୍ୟଧିକ ଚିନି ଖାଇବା ଦ୍ୱାରା ହୁଏ। ଏହାର କୌଣସି ଔଷଧ ନାହିଁ, କେବଳ ଖାଦ୍ୟ ନିୟନ୍ତ୍ରଣ ଦ୍ୱାରା ଭଲ ହୁଏ।',
    },
    solution: {
      'en': 'We induce "Hepatic Detoxification" using Glucosinolates (from Cruciferous veggies) and mobilize stored triglycerides using metabolic fasting windows.',
      'hi': 'हम विशेष सब्जियों और उपवास के विज्ञान का उपयोग करके लिवर की चर्बी को पिघलाते हैं।',
      'or': 'ଆମେ ବିଶେଷ ପରିବା ଏବଂ ଉପବାସ ମାଧ୍ୟମରେ ଲିଭରରୁ ଚର୍ବି ହଟାଉ।',
    },
  ),

  // 9. ACIDITY
  KnowledgeItem(
    id: 'gut',
    category: 'disease',
    icon: Icons.sentiment_dissatisfied,
    title: {
      'en': 'Gas & Acidity Pills',
      'hi': 'गैस और एसिडिटी',
      'or': 'ଗ୍ୟାସ୍ ଏବଂ ଏସିଡିଟି',
    },
    symptoms: {
      'en': '• Burning sensation\n• Constipation\n• Headache',
      'hi': '• जलन\n• कब्ज\n• सिरदर्द',
      'or': '• ଜଳାପୋଡା\n• କୋଷ୍ଠକାଠିନ୍ୟ\n• ମୁହଁ ବିନ୍ଧା',
    },
    reality: {
      'en': 'Antacids neutralize Hydrochloric Acid (HCL). Low HCL prevents protein digestion and mineral absorption, leading to weak bones and anemia.',
      'hi': 'एंटासिड पेट के एसिड को खत्म करते हैं। इससे खाना पचता नहीं है और हड्डियां कमजोर होती हैं।',
      'or': 'ଏଣ୍ଟାସିଡ୍ ପେଟର ଏସିଡ୍ କମାଇଦିଏ, ଯାହାଦ୍ୱାରା ଖାଦ୍ୟ ହଜମ ହୁଏନି ଏବଂ ହାଡ ଦୁର୍ବଳ ହୋଇଯାଏ।',
    },
    solution: {
      'en': 'We restore the "Cephalic Phase" of digestion and stimulate enzymatic production using natural Carminatives and Probiotics.',
      'hi': 'हम प्रोबायोटिक्स और पाचक एंजाइमों को उत्तेजित करके पाचन तंत्र को प्राकृतिक रूप से ठीक करते हैं।',
      'or': 'ଆମେ ହଜମ ପ୍ରକ୍ରିୟାକୁ ପ୍ରାକୃତିକ ଭାବେ ସୁସ୍ଥ କରୁ।',
    },
  ),

  // 10. GERIATRIC
  KnowledgeItem(
    id: 'geriatric',
    category: 'disease',
    icon: Icons.elderly,
    title: {
      'en': 'Old Age Weakness',
      'hi': 'बुढ़ापे की कमजोरी',
      'or': 'ବାର୍ଦ୍ଧକ୍ୟ ଜନିତ ସମସ୍ୟା',
    },
    symptoms: {
      'en': '• Loss of balance\n• Muscle loss (Sarcopenia)\n• Memory issues',
      'hi': '• संतुलन बिगड़ना\n• मांसपेशियां सूखना\n• याददाश्त कमजोर होना',
      'or': '• ଚାଲିବାରେ ଅସୁବିଧା\n• ମାଂସପେଶୀ ଶୁଖିଯିବା\n• ମନେ ନ ରହିବା',
    },
    reality: {
      'en': 'Sarcopenia is caused by "Anabolic Resistance" — the inability to absorb protein due to weak digestion. Pills add toxic load without building strength.',
      'hi': 'पाचन कमजोर होने के कारण प्रोटीन शरीर को नहीं लगता, जिससे मांसपेशियां सूखने लगती हैं।',
      'or': 'ହଜମ ଶକ୍ତି କମିବା ଯୋଗୁଁ ପ୍ରୋଟିନ୍ ଶରୀରରେ ଲାଗେନି, ତେଣୁ ଶରୀର ଦୁର୍ବଳ ହୋଇଯାଏ।',
    },
    solution: {
      'en': 'We provide "Bio-Assimilable Proteins" and B12 specifically designed for geriatric absorption to regenerate nerve function and muscle mass.',
      'hi': 'हम ऐसे प्रोटीन और विटामिन देते हैं जो बुजुर्गों के शरीर में आसानी से पचकर ताकत देते हैं।',
      'or': 'ଆମେ ସହଜରେ ହଜମ ହେଉଥିବା ପ୍ରୋଟିନ୍ ଏବଂ ଭିଟାମିନ୍ ଯୋଗାଉ।',
    },
  ),

  // 11. GHEE
  KnowledgeItem(
    id: 'ghee',
    category: 'food',
    icon: Icons.soup_kitchen,
    title: {
      'en': 'The Science of Ghee',
      'hi': 'देसी घी का विज्ञान',
      'or': 'ଦେଶୀ ଘିଅର ବିଜ୍ଞାନ',
    },
    symptoms: {
      'en': '• Dry skin\n• Joint sounds\n• Poor memory',
      'hi': '• रूखी त्वचा\n• जोड़ों से आवाज\n• कमजोर याददाश्त',
      'or': '• ଶୁଷ୍କ ଚର୍ମ\n• ଗଣ୍ଠିରୁ ଶବ୍ଦ\n• ମନେ ନ ରହିବା',
    },
    reality: {
      'en': 'Ghee is a source of Butyric Acid, essential for gut mucosal repair. It acts as a "Lipophilic Transporter" to carry Vitamins A, D, E, K into your cells.',
      'hi': 'घी पेट की परत को ठीक करता है और विटामिन्स को कोशिकाओं तक पहुंचाता है। यह कोलेस्ट्रॉल नहीं बढ़ाता।',
      'or': 'ଘିଅ ପେଟକୁ ସୁସ୍ଥ ରଖେ ଏବଂ ଭିଟାମିନ୍ କୁ ଶରୀରର ବିଭିନ୍ନ ଅଂଶକୁ ପହଞ୍ଚାଏ।',
    },
    solution: {
      'en': 'We incorporate Ghee in "Therapeutic Doses" based on your lipid profile to heal the gut lining and lubricate synovial joints.',
      'hi': 'हम आपकी जरूरत के अनुसार घी की सही मात्रा तय करते हैं ताकि पेट और जोड़ ठीक रहें।',
      'or': 'ଆମେ ଆପଣଙ୍କ ଶରୀର ଅନୁଯାୟୀ ଘିଅର ସଠିକ୍ ମାତ୍ରା ନିର୍ଦ୍ଧାରଣ କରୁ।',
    },
  ),

  // 12. FAD DIETS
  KnowledgeItem(
    id: 'fad_diets',
    category: 'food',
    icon: Icons.no_food,
    title: {
      'en': 'Danger of Crash Diets',
      'hi': 'डाइटिंग का सच',
      'or': 'ଡାଏଟିଂ ର କୁପ୍ରଭାବ',
    },
    symptoms: {
      'en': '• Rapid weight regain\n• Hair fall\n• Metabolic crash',
      'hi': '• वजन दोबारा बढ़ना\n• बाल झड़ना\n• कमजोरी',
      'or': '• ଓଜନ ପୁଣି ବଢିଯିବା\n• ଚୁଟି ଝଡିବା\n• ଦୁର୍ବଳ ଲାଗିବା',
    },
    reality: {
      'en': 'Caloric deficit destroys muscle mass, lowering your Basal Metabolic Rate (BMR). This guarantees you will gain fat back faster.',
      'hi': 'भूखे रहने से शरीर की मशीनरी (Metabolism) धीमी हो जाती है। बाद में वजन दोगुना तेजी से बढ़ता है।',
      'or': 'ଖାଇବା ଛାଡିଲେ ଶରୀରର ହଜମ ଶକ୍ତି କମିଯାଏ, ପରେ ଓଜନ ଦୁଇଗୁଣ ବଢିଯାଏ।',
    },
    solution: {
      'en': 'We focus on "Cellular Nourishment" & "Metabolic Restoration". You eat MORE nutrient-dense food to fuel the fat-burning engine.',
      'hi': 'हम "भरपेट खाने" में विश्वास करते हैं। सही पोषण से शरीर की चर्बी जलाने की क्षमता बढ़ाते हैं।',
      'or': 'ଆମେ ପେଟପୁରା ଖାଇବାକୁ ପରାମର୍ଶ ଦେଉ। ସଠିକ୍ ପୋଷଣ ଦ୍ୱାରା ଚର୍ବି କମିଯାଏ।',
    },
  ),

  // 13. PREGNANCY
  KnowledgeItem(
    id: 'pregnancy',
    category: 'food',
    icon: Icons.pregnant_woman,
    title: {
      'en': 'Pregnancy Nutrition',
      'hi': 'गर्भावस्था पोषण',
      'or': 'ଗର୍ଭାବସ୍ଥା ଯତ୍ନ',
    },
    symptoms: {
      'en': '• Low Hemoglobin\n• Constipation from pills\n• Gestational Diabetes',
      'hi': '• खून की कमी\n• गोली से कब्ज\n• शुगर बढ़ना',
      'or': '• ରକ୍ତ କମିବା\n• ଔଷଧ ଯୋଗୁଁ କୋଷ୍ଠକାଠିନ୍ୟ\n• ସୁଗାର ବଢିବା',
    },
    reality: {
      'en': 'Synthetic Iron supplements often cause oxidative stress and constipation. "Eating for Two" is a metabolic myth leading to excess maternal weight.',
      'hi': 'कृत्रिम आयरन पचता नहीं है। "दो लोगों का खाना" खाने से केवल वजन बढ़ता है, बच्चे का विकास नहीं होता।',
      'or': 'କୃତ୍ରିମ ଆଇରନ୍ ହଜମ ହୁଏନି। "ଦୁଇ ଜଣଙ୍କ ପାଇଁ ଖାଇବା" ଦ୍ୱାରା କେବଳ ଓଜନ ବଢେ।',
    },
    solution: {
      'en': 'We use "Bio-Available Heme Iron" sources and plan micro-nutrient meals specifically for Fetal Neural Development.',
      'hi': 'हम प्राकृतिक आयरन स्रोतों का उपयोग करते हैं जो आसानी से पचते हैं और बच्चे के दिमाग का विकास करते हैं।',
      'or': 'ଆମେ ପ୍ରାକୃତିକ ଆଇରନ୍ ଯୋଗାଉ ଯାହା ଶିଶୁର ବିକାଶରେ ସାହାଯ୍ୟ କରେ।',
    },
  ),

  // 14. TURMERIC
  KnowledgeItem(
    id: 'haldi',
    category: 'food',
    icon: Icons.wb_sunny,
    title: {
      'en': 'Turmeric Bio-Availability',
      'hi': 'हल्दी का विज्ञान',
      'or': 'ହଳଦୀର ବିଜ୍ଞାନ',
    },
    symptoms: {
      'en': '• Chronic inflammation\n• Low immunity',
      'hi': '• शरीर में सूजन\n• बार-बार बीमार पड़ना',
      'or': '• ଶରୀର ଫୁଲିବା\n• ବାରମ୍ବାର ରୋଗ ହେବା',
    },
    reality: {
      'en': 'Curcumin is poorly absorbed by the human gut. Consuming it without an activator yields <1% benefit.',
      'hi': 'हल्दी का असर शरीर में आसानी से नहीं होता। इसे बिना सही तरीके के खाने से कोई फायदा नहीं है।',
      'or': 'ହଳଦୀ ଶରୀରରେ ସହଜରେ ମିଶେ ନାହିଁ। ସଠିକ୍ ଉପାୟରେ ନ ଖାଇଲେ କୌଣସି ଲାଭ ମିଳେ ନାହିଁ।',
    },
    solution: {
      'en': 'We combine Curcumin with "Piperine Alkaloids" (Black Pepper) to enhance bio-availability by 2000% for clinical anti-inflammatory effects.',
      'hi': 'हम हल्दी को काली मिर्च के साथ मिलाते हैं, जिससे इसका असर 2000% बढ़ जाता है और यह दवा जैसा काम करती है।',
      'or': 'ଆମେ ହଳଦୀ ସହିତ ଗୋଲମରିଚ ମିଶାଇ ବ୍ୟବହାର କରିବାକୁ ପରାମର୍ଶ ଦେଉ।',
    },
  ),

  // 15. RICH MAN'S NUTRITION
  KnowledgeItem(
    id: 'rich_nutrition',
    category: 'food',
    icon: Icons.star_border,
    title: {
      'en': 'Affordable Nutrition',
      'hi': 'सस्ता और सही पोषण',
      'or': 'ଶସ୍ତା ଓ ସଠିକ୍ ପୋଷଣ',
    },
    symptoms: {
      'en': '• "Healthy food is expensive"\n• Relying on imported superfoods',
      'hi': '• "हेल्दी खाना महंगा है"\n• विदेशी फलों पर निर्भरता',
      'or': '• "ସ୍ୱାସ୍ଥ୍ୟକର ଖାଦ୍ୟ ଦାମୀ"\n• ବିଦେଶୀ ଫଳ ଉପରେ ନିର୍ଭରତା',
    },
    reality: {
      'en': 'Nutrition is about Molecules, not Marketing. Local Indian superfoods often have a superior nutrient profile compared to imported ones.',
      'hi': 'पोषण का मतलब महँगा खाना नहीं है। भारतीय सुपरफूड्स विदेशी खाने से ज्यादा ताकतवर होते हैं।',
      'or': 'ପୋଷଣ ମାନେ ଦାମୀ ଖାଦ୍ୟ ନୁହେଁ। ଭାରତୀୟ ଖାଦ୍ୟ ବିଦେଶୀ ଖାଦ୍ୟ ଠାରୁ ଅଧିକ ଭଲ।',
    },
    solution: {
      'en': 'We use "Molecular Bio-Equivalence" to swap expensive items. (e.g., Avocado -> Coconut, Quinoa -> Millets).',
      'hi': 'हम महंगे खाने की जगह सस्ते और बेहतर भारतीय विकल्प बताते हैं। (जैसे: एवोकाडो -> नारियल)।',
      'or': 'ଆମେ ଦାମୀ ଖାଦ୍ୟ ବଦଳରେ ଶସ୍ତା ଏବଂ ଭଲ ଭାରତୀୟ ଖାଦ୍ୟ ବ୍ୟବହାର କରିବାକୁ ପରାମର୍ଶ ଦେଉ।',
    },
  ),
];