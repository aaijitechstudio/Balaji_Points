// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'बालाजी पॉइंट्स';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get error => 'त्रुटि';

  @override
  String get success => 'सफल';

  @override
  String get ok => 'ठीक है';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get save => 'सहेजें';

  @override
  String get delete => 'मिटाएं';

  @override
  String get edit => 'संपादित करें';

  @override
  String get submit => 'जमा करें';

  @override
  String get back => 'वापस';

  @override
  String get next => 'अगला';

  @override
  String get done => 'हो गया';

  @override
  String get retry => 'पुनः प्रयास';

  @override
  String get refresh => 'ताज़ा करें';

  @override
  String get loginWithPhone => 'फोन नंबर से लॉगिन करें';

  @override
  String get enterPhoneNumber => 'अपना पंजीकृत फोन नंबर दर्ज करें';

  @override
  String get phoneNumber => 'फोन नंबर';

  @override
  String get enterPhoneHint => '10 अंकों का फोन नंबर दर्ज करें';

  @override
  String get sendOTP => 'OTP भेजें';

  @override
  String get verifyOTP => 'OTP सत्यापित करें';

  @override
  String get enterOTPCode => '6 अंकों का कोड दर्ज करें';

  @override
  String get didntReceiveOTP => 'OTP नहीं मिला? ';

  @override
  String get resend => 'पुनः भेजें';

  @override
  String resendIn(int seconds) {
    return '$seconds सेकंड में पुनः भेजें';
  }

  @override
  String get invalidPhone => 'कृपया अपना फोन नंबर दर्ज करें';

  @override
  String get invalidPhoneLength => 'फोन नंबर 10 अंकों का होना चाहिए';

  @override
  String get invalidPhoneFormat => 'फोन नंबर में केवल अंक होने चाहिए';

  @override
  String get invalidOTP => 'कृपया 6 अंकों का वैध OTP दर्ज करें';

  @override
  String get selectRole => 'अपनी भूमिका चुनें';

  @override
  String get carpenter => 'बढ़ई';

  @override
  String get admin => 'व्यवस्थापक';

  @override
  String get welcomeBack => 'वापस स्वागत है';

  @override
  String get createAccount => 'खाता बनाएं';

  @override
  String get continueWithPhone => 'फोन से जारी रखें';

  @override
  String get continueWithPin => 'PIN के साथ जारी रखें';

  @override
  String get loginInfo =>
      'अपने पंजीकृत फोन नंबर का उपयोग करके लॉगिन करें। सत्यापन के लिए आपको एक OTP प्राप्त होगा।';

  @override
  String get poweredBy => 'द्वारा संचालित';

  @override
  String get companyName => 'श्री बालाजी प्लाईवुड एंड हार्डवेयर';

  @override
  String get enterPinPageTitle => 'अपना 4 अंकों का PIN दर्ज करें';

  @override
  String get enter4DigitPin => 'अपना 4 अंकों का PIN दर्ज करें';

  @override
  String get pinLabel => 'पिन';

  @override
  String get fourDigitPin => '4 अंकों का PIN';

  @override
  String get login => 'लॉगिन';

  @override
  String get forgotPin => 'PIN भूल गए?';

  @override
  String get newUserSetPin => 'नए उपयोगकर्ता? PIN सेट करें';

  @override
  String get invalidPin => 'अमान्य PIN';

  @override
  String get createPinTitle => 'अपना 4 अंकों का PIN बनाएं';

  @override
  String get createPinSubtitle => 'यह PIN लॉगिन के लिए उपयोग किया जाएगा';

  @override
  String get mobileNumber => 'मोबाइल नंबर';

  @override
  String get firstName => 'पहला नाम';

  @override
  String get firstNameRequired => 'पहला नाम *';

  @override
  String get lastName => 'अंतिम नाम';

  @override
  String get confirmPin => 'PIN की पुष्टि करें';

  @override
  String get savePin => 'PIN सहेजें';

  @override
  String get pinCreatedSuccess => 'PIN सफलतापूर्वक बनाया गया';

  @override
  String get failedToSavePin => 'PIN सहेजने में विफल';

  @override
  String get pinsDoNotMatch => 'PIN और पुष्टि PIN मेल नहीं खाते';

  @override
  String get resetPinTitle => 'PIN रीसेट करें';

  @override
  String get resetPinSubtitle =>
      'अपना PIN रीसेट करने के लिए अपना पंजीकृत मोबाइल नंबर दर्ज करें।';

  @override
  String get mustBeLoggedInToResetPin =>
      'आपको अपना PIN रीसेट करने के लिए लॉग इन होना चाहिए। कृपया पहले लॉगिन करें।';

  @override
  String get canOnlyResetOwnPin =>
      'आप केवल अपना PIN रीसेट कर सकते हैं। फोन नंबर आपके लॉग इन खाते से मेल खाना चाहिए।';

  @override
  String get enterCurrentPin =>
      'कृपया स्वामित्व सत्यापित करने के लिए अपना वर्तमान PIN दर्ज करें।';

  @override
  String get currentPinLabel => 'वर्तमान PIN';

  @override
  String get newPinMustBeDifferent =>
      'नया PIN आपके वर्तमान PIN से अलग होना चाहिए।';

  @override
  String get contactAdminForPinReset =>
      'आपको अपना PIN रीसेट करने के लिए लॉग इन होना चाहिए। यदि आप अपना PIN भूल गए हैं, तो कृपया सहायता के लिए व्यवस्थापक से संपर्क करें।';

  @override
  String get forgotCurrentPin => 'अपना वर्तमान PIN भूल गए?';

  @override
  String get forgotPinHelp =>
      'यदि आपको अपना वर्तमान PIN याद नहीं है, तो कृपया सहायता के लिए हमारी सहायता टीम से संपर्क करें।';

  @override
  String get adminSupportInfo => 'व्यवस्थापक सहायता';

  @override
  String get callSupport => 'सहायता को कॉल करें';

  @override
  String get adminResetPin => 'PIN रीसेट करें';

  @override
  String adminResetPinTitle(String carpenterName) {
    return '$carpenterName के लिए PIN रीसेट करें';
  }

  @override
  String get adminResetPinSubtitle =>
      'इस बढ़ई के लिए एक नया 4 अंकों का PIN दर्ज करें।';

  @override
  String adminResetPinConfirm(String carpenterName) {
    return 'क्या आप $carpenterName के लिए PIN रीसेट करना चाहते हैं?';
  }

  @override
  String adminResetPinSuccess(String carpenterName) {
    return '$carpenterName के लिए PIN सफलतापूर्वक रीसेट किया गया';
  }

  @override
  String get adminResetPinFailed =>
      'PIN रीसेट करने में विफल। कृपया पुनः प्रयास करें।';

  @override
  String get adminNotAuthorized =>
      'आप इस क्रिया को करने के लिए अधिकृत नहीं हैं।';

  @override
  String get enterNewPinForCarpenter => 'नया 4 अंकों का PIN दर्ज करें';

  @override
  String get confirmNewPinForCarpenter => 'नया 4 अंकों का PIN की पुष्टि करें';

  @override
  String get newPinLabel => 'नया 4 अंकों का PIN';

  @override
  String get checkNumber => 'नंबर जांचें';

  @override
  String get verified => 'सत्यापित';

  @override
  String get pleaseVerifyMobile => 'कृपया पहले मोबाइल नंबर सत्यापित करें';

  @override
  String get noAccountFound => 'इस नंबर के लिए कोई खाता नहीं मिला';

  @override
  String get pinResetSuccess =>
      'PIN सफलतापूर्वक रीसेट किया गया। कृपया फिर से लॉगिन करें।';

  @override
  String get failedToResetPin => 'PIN रीसेट करने में विफल। पुनः प्रयास करें।';

  @override
  String get enterValidTenDigit => 'मान्य 10 अंकों का नंबर दर्ज करें';

  @override
  String get enter4Digits => '4 अंक दर्ज करें';

  @override
  String get pinMismatch => 'PIN मेल नहीं खाते';

  @override
  String get enterValidFirstName => 'मान्य पहला नाम दर्ज करें';

  @override
  String get imageError => 'छवि त्रुटि';

  @override
  String get resetPin => 'PIN रीसेट करें';

  @override
  String get changePin => 'PIN बदलें';

  @override
  String get rememberMe => 'मुझे याद रखें';

  @override
  String get accountExistsUseReset =>
      'खाता पहले से मौजूद है। कृपया अपना PIN बदलने के लिए Reset PIN का उपयोग करें।';

  @override
  String get home => 'होम';

  @override
  String get addPoints => 'पॉइंट जोड़ें';

  @override
  String get latestOffers => 'नवीनतम ऑफर्स';

  @override
  String get topCarpenters => 'शीर्ष 3 बढ़ई';

  @override
  String get todaysWinner => 'आज के विजेता';

  @override
  String get yourPosition => 'आपकी स्थिति';

  @override
  String rank(int rank) {
    return 'रैंक #$rank';
  }

  @override
  String points(int points) {
    return '$points पॉइंट्स';
  }

  @override
  String get noOffersAvailable => 'इस समय कोई ऑफर उपलब्ध नहीं है';

  @override
  String get dailySpinWinner => '🎉 दैनिक स्पिन विजेता';

  @override
  String get congratulations => 'बधाई हो!';

  @override
  String won(int points) {
    return '$points पॉइंट्स जीते!';
  }

  @override
  String get profile => 'प्रोफाइल';

  @override
  String get editProfile => 'प्रोफाइल संपादित करें';

  @override
  String get completeProfile => 'अपना प्रोफाइल पूरा करें';

  @override
  String get profileIncomplete => 'प्रोफाइल अधूरा';

  @override
  String get completeProfileMessage =>
      'बिल जोड़ना और पॉइंट्स अर्जित करना शुरू करने के लिए कृपया अपना प्रोफाइल पूरा करें';

  @override
  String get completeProfileDetails =>
      'जारी रखने के लिए अपना पहला नाम, अंतिम नाम और प्रोफाइल फोटो जोड़ें';

  @override
  String get completeNow => 'अभी पूरा करें';

  @override
  String get helpSupport => 'सहायता और समर्थन';

  @override
  String get contactUs => 'संपर्क करें';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get logoutConfirmation => 'क्या आप वाकई लॉगआउट करना चाहते हैं?';

  @override
  String get name => 'नाम';

  @override
  String get email => 'ईमेल';

  @override
  String get phone => 'फोन';

  @override
  String get role => 'भूमिका';

  @override
  String get memberSince => 'सदस्य बने';

  @override
  String get totalPoints => 'कुल पॉइंट्स';

  @override
  String get notVerified => 'असत्यापित';

  @override
  String get needHelp => 'मदद चाहिए?';

  @override
  String get contactSupport =>
      'किसी भी प्रश्न या समस्या के लिए हमारी सहायता टीम से संपर्क करें।';

  @override
  String get supportPhone1 => '96006 - 09121';

  @override
  String get supportPhone2 => '0424 - 3557187';

  @override
  String get callNow => 'अभी कॉल करें';

  @override
  String get getInTouch => 'हमसे संपर्क करें';

  @override
  String get mobile => 'मोबाइल';

  @override
  String get landline => 'लैंडलाइन';

  @override
  String get addBill => 'बिल जोड़ें';

  @override
  String get billDetails => 'बिल विवरण';

  @override
  String get billNumber => 'बिल नंबर';

  @override
  String get billAmount => 'बिल राशि';

  @override
  String get billDate => 'बिल तारीख';

  @override
  String get uploadBillImage => 'बिल फोटो अपलोड करें';

  @override
  String get selectImage => 'फोटो चुनें';

  @override
  String get changeImage => 'फोटो बदलें';

  @override
  String get pointsConversion => '1000 ₹ = 1 पॉइंट';

  @override
  String get estimatedPoints => 'अनुमानित पॉइंट्स';

  @override
  String youWillEarn(int points) {
    return 'आप लगभग $points पॉइंट्स अर्जित करेंगे';
  }

  @override
  String get enterBillNumber => 'कृपया बिल नंबर दर्ज करें';

  @override
  String get enterBillAmount => 'कृपया बिल राशि दर्ज करें';

  @override
  String get enterValidAmount => 'कृपया वैध राशि दर्ज करें';

  @override
  String get selectBillDate => 'कृपया बिल तारीख चुनें';

  @override
  String get uploadBillPhoto => 'कृपया बिल फोटो अपलोड करें';

  @override
  String get billSubmitted => 'बिल सफलतापूर्वक जमा किया गया';

  @override
  String get billSubmitError => 'बिल जमा करने में विफल';

  @override
  String get wallet => 'वॉलेट';

  @override
  String get availablePoints => 'उपलब्ध पॉइंट्स';

  @override
  String get redeemPoints => 'पॉइंट्स भुनाएं';

  @override
  String get transactionHistory => 'लेनदेन इतिहास';

  @override
  String get noTransactions => 'अभी तक कोई लेनदेन नहीं';

  @override
  String get earned => 'अर्जित';

  @override
  String get spent => 'खर्च किया';

  @override
  String get pending => 'लंबित';

  @override
  String get offers => 'ऑफर्स';

  @override
  String get viewDetails => 'विवरण देखें';

  @override
  String get redeemNow => 'अभी भुनाएं';

  @override
  String pointsRequired(int points) {
    return '$points पॉइंट्स आवश्यक';
  }

  @override
  String get offerRedeemed => 'ऑफर सफलतापूर्वक भुनाया गया';

  @override
  String get insufficientPoints => 'अपर्याप्त पॉइंट्स';

  @override
  String get offerExpired => 'यह ऑफर समाप्त हो गया है';

  @override
  String validUntil(String date) {
    return '$date तक वैध';
  }

  @override
  String get dailySpin => 'दैनिक स्पिन';

  @override
  String get spinNow => 'अभी घुमाएं';

  @override
  String get spinning => 'घूम रहा है...';

  @override
  String get spinWheel => 'पहिया घुमाएं';

  @override
  String get dailySpinCompleted => 'आप आज पहले ही घुमा चुके हैं';

  @override
  String get comeBackTomorrow => 'जीतने का एक और मौका पाने के लिए कल वापस आएं!';

  @override
  String nextSpinIn(int hours, int minutes) {
    return 'अगला स्पिन: $hoursघंटे $minutesमिनट में';
  }

  @override
  String winner(String name) {
    return 'विजेता: $name';
  }

  @override
  String prizePoints(int points) {
    return '🎁 $points पॉइंट्स';
  }

  @override
  String get adminPanel => 'व्यवस्थापक पैनल';

  @override
  String get adminSubtitle =>
      'बिल, ऑफर्स, उपयोगकर्ता और दैनिक स्पिन प्रबंधित करें';

  @override
  String get dashboard => 'डैशबोर्ड';

  @override
  String get users => 'उपयोगकर्ता';

  @override
  String get manageUsers => 'उपयोगकर्ता प्रबंधित करें';

  @override
  String get manageBills => 'बिल प्रबंधित करें';

  @override
  String get manageOffers => 'ऑफर्स प्रबंधित करें';

  @override
  String get manageDailySpin => 'दैनिक स्पिन प्रबंधित करें';

  @override
  String get pendingBills => 'लंबित बिल';

  @override
  String get approvedBills => 'स्वीकृत बिल';

  @override
  String get rejectedBills => 'अस्वीकृत बिल';

  @override
  String get pendingUsers => 'लंबित उपयोगकर्ता';

  @override
  String get verifiedUsers => 'सत्यापित उपयोगकर्ता';

  @override
  String get approve => 'स्वीकृत करें';

  @override
  String get reject => 'अस्वीकार करें';

  @override
  String get userApproved => 'उपयोगकर्ता सफलतापूर्वक स्वीकृत';

  @override
  String get userRejected => 'उपयोगकर्ता अस्वीकृत';

  @override
  String get billApproved => 'बिल सफलतापूर्वक स्वीकृत';

  @override
  String get billRejected => 'बिल अस्वीकृत';

  @override
  String get createOffer => 'ऑफर बनाएं';

  @override
  String get offerTitle => 'ऑफर शीर्षक';

  @override
  String get offerDescription => 'ऑफर विवरण';

  @override
  String get offerCreated => 'ऑफर सफलतापूर्वक बनाया गया';

  @override
  String get logoutFailed => 'लॉगआउट विफल';

  @override
  String get errorOccurred => 'एक त्रुटि हुई';

  @override
  String get networkError =>
      'नेटवर्क त्रुटि। कृपया अपना इंटरनेट कनेक्शन जांचें।';

  @override
  String get permissionDenied => 'अनुमति अस्वीकृत';

  @override
  String get sessionExpired => 'सत्र समाप्त। कृपया फिर से लॉगिन करें।';

  @override
  String get invalidCredentials => 'अमान्य प्रमाण पत्र';

  @override
  String get userNotFound => 'उपयोगकर्ता नहीं मिला';

  @override
  String get phoneAuthFailed => 'फोन प्रमाणीकरण विफल';

  @override
  String get configError => 'कॉन्फ़िगरेशन त्रुटि';

  @override
  String get missingClientId =>
      'Firebase में SHA-1 फ़िंगरप्रिंट गुम है। कृपया चलाएं: scripts/get_sha1.sh';

  @override
  String get tooManyRequests =>
      'बहुत सारे अनुरोध। कृपया कुछ मिनट प्रतीक्षा करें।';

  @override
  String get invalidVerificationCode =>
      'अमान्य OTP कोड। कृपया जांचें और पुनः प्रयास करें।';

  @override
  String get verificationExpired =>
      'सत्यापन समाप्त। कृपया नया OTP अनुरोध करें।';

  @override
  String get userDisabled =>
      'यह खाता अक्षम कर दिया गया है। कृपया समर्थन से संपर्क करें।';

  @override
  String get fieldRequired => 'यह फ़ील्ड आवश्यक है';

  @override
  String get invalidEmail => 'कृपया वैध ईमेल दर्ज करें';

  @override
  String get invalidName => 'कृपया वैध नाम दर्ज करें';

  @override
  String get nameTooShort => 'नाम कम से कम 2 अक्षर का होना चाहिए';

  @override
  String get invalidAmount => 'कृपया वैध राशि दर्ज करें';

  @override
  String get amountTooLow => 'राशि 0 से अधिक होनी चाहिए';

  @override
  String get searchHint => 'खोजें...';

  @override
  String get noResultsFound => 'कोई परिणाम नहीं मिला';

  @override
  String get noDataAvailable => 'कोई डेटा उपलब्ध नहीं';

  @override
  String get pullToRefresh => 'ताज़ा करने के लिए खींचें';

  @override
  String get releaseToRefresh => 'ताज़ा करने के लिए छोड़ें';

  @override
  String get refreshing => 'ताज़ा हो रहा है...';

  @override
  String get loadMore => 'और लोड करें';

  @override
  String get seeAll => 'सभी देखें';

  @override
  String get close => 'बंद करें';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get areYouSure => 'क्या आप सुनिश्चित हैं?';

  @override
  String get cannotUndo => 'इस क्रिया को पूर्ववत नहीं किया जा सकता।';

  @override
  String get yes => 'हां';

  @override
  String get no => 'नहीं';

  @override
  String get today => 'आज';

  @override
  String get yesterday => 'कल';

  @override
  String get tomorrow => 'आने वाला कल';

  @override
  String get january => 'जनवरी';

  @override
  String get february => 'फरवरी';

  @override
  String get march => 'मार्च';

  @override
  String get april => 'अप्रैल';

  @override
  String get may => 'मई';

  @override
  String get june => 'जून';

  @override
  String get july => 'जुलाई';

  @override
  String get august => 'अगस्त';

  @override
  String get september => 'सितंबर';

  @override
  String get october => 'अक्टूबर';

  @override
  String get november => 'नवंबर';

  @override
  String get december => 'दिसंबर';

  @override
  String get jan => 'जन';

  @override
  String get feb => 'फर';

  @override
  String get mar => 'मार';

  @override
  String get apr => 'अप्र';

  @override
  String get jun => 'जून';

  @override
  String get jul => 'जुला';

  @override
  String get aug => 'अग';

  @override
  String get sep => 'सित';

  @override
  String get oct => 'अक्ट';

  @override
  String get nov => 'नव';

  @override
  String get dec => 'दिस';

  @override
  String get approveBill => 'बिल स्वीकृत करें';

  @override
  String approveBillConfirmation(String amount, String phone) {
    return '$phone के लिए ₹$amount का बिल स्वीकृत करें?';
  }

  @override
  String get approvingBill => 'बिल स्वीकृत किया जा रहा है...';

  @override
  String get billApprovedSuccess => 'बिल स्वीकृत हो गया!';

  @override
  String get failedToApproveBill =>
      'बिल स्वीकृत करने में विफल। पुनः प्रयास करें।';

  @override
  String get rejectBill => 'बिल अस्वीकार करें';

  @override
  String get rejectBillConfirmation =>
      'क्या आप वाकई इस बिल को अस्वीकार करना चाहते हैं?';

  @override
  String get billRejectedSuccess => 'बिल अस्वीकृत';

  @override
  String get failedToRejectBill => 'अस्वीकार करने में विफल';

  @override
  String get failedToLoadImage => 'छवि लोड करने में विफल';

  @override
  String get noImageAvailable => 'कोई छवि उपलब्ध नहीं';

  @override
  String get errorLoadingBills => 'बिल लोड करने में त्रुटि';

  @override
  String get noPendingBills => 'कोई लंबित बिल नहीं';

  @override
  String get pendingStatus => 'लंबित';

  @override
  String get noDate => 'कोई तारीख नहीं';

  @override
  String get deleteOffer => 'ऑफर मिटाएं';

  @override
  String get deleteOfferConfirmation =>
      'क्या आप वाकई इस ऑफर को मिटाना चाहते हैं? इस क्रिया को पूर्ववत नहीं किया जा सकता।';

  @override
  String get offerDeletedSuccess => 'ऑफर सफलतापूर्वक मिटाया गया';

  @override
  String get failedToDeleteOffer => 'ऑफर मिटाने में विफल';

  @override
  String get errorLoadingOffers => 'ऑफर लोड करने में त्रुटि';

  @override
  String get noOffersCreated => 'कोई ऑफर नहीं बनाए गए';

  @override
  String get createFirstOffer => 'पॉइंट्स और बैनर के साथ अपना पहला ऑफर बनाएं';

  @override
  String get active => 'सक्रिय';

  @override
  String get inactive => 'निष्क्रिय';

  @override
  String get createdLabel => 'बनाया गया';

  @override
  String get editOffer => 'ऑफर संपादित करें';

  @override
  String get createNewOffer => 'नया ऑफर बनाएं';

  @override
  String get tapToUploadBanner => 'बैनर अपलोड करने के लिए टैप करें';

  @override
  String get offerTitleLabel => 'ऑफर शीर्षक *';

  @override
  String get offerTitleHint => 'उदा., दिवाली विशेष ऑफर';

  @override
  String get enterOfferTitle => 'कृपया ऑफर शीर्षक दर्ज करें';

  @override
  String get descriptionLabel => 'विवरण';

  @override
  String get descriptionHint => 'ऑफर का संक्षिप्त विवरण';

  @override
  String get pointsRequiredLabel => 'आवश्यक पॉइंट्स *';

  @override
  String get pointsHint => 'उदा., 100';

  @override
  String get enterPointsError => 'कृपया पॉइंट्स दर्ज करें';

  @override
  String get enterValidNumber => 'कृपया एक वैध संख्या दर्ज करें';

  @override
  String get setValidUntilDate => 'वैधता तिथि निर्धारित करें (वैकल्पिक)';

  @override
  String validUntilDisplay(String date) {
    return '$date तक वैध';
  }

  @override
  String get offerStatus => 'ऑफर स्थिति';

  @override
  String get uploadingBanner => 'बैनर अपलोड हो रहा है...';

  @override
  String get updateOffer => 'ऑफर अपडेट करें';

  @override
  String get offerUpdatedSuccess => 'ऑफर सफलतापूर्वक अपडेट किया गया';

  @override
  String get offerCreatedSuccess => 'ऑफर सफलतापूर्वक बनाया गया';

  @override
  String get failedToSaveOffer => 'ऑफर सहेजने में विफल';

  @override
  String get failedToPickImage => 'छवि चुनने में विफल';

  @override
  String get searchByNameOrPhone => 'नाम या फोन से खोजें...';

  @override
  String get add => 'जोड़ें';

  @override
  String get all => 'सभी';

  @override
  String get platinum => 'प्लेटिनम';

  @override
  String get gold => 'गोल्ड';

  @override
  String get silver => 'सिल्वर';

  @override
  String get bronze => 'ब्रॉन्ज';

  @override
  String get errorLoadingUsers => 'उपयोगकर्ता लोड करने में त्रुटि';

  @override
  String get noUsersFound => 'कोई उपयोगकर्ता नहीं मिला';

  @override
  String get tryDifferentSearch => 'अलग खोज शब्द का प्रयास करें';

  @override
  String get noCarpentersYet => 'अभी तक कोई बढ़ई पंजीकृत नहीं';

  @override
  String joinedLabel(String date) {
    return '$date को शामिल हुए';
  }

  @override
  String get addCarpenter => 'बढ़ई जोड़ें';

  @override
  String get deleteCarpenter => 'बढ़ई हटाएं';

  @override
  String get deleteCarpenterConfirmation =>
      'क्या आप वाकई इस बढ़ई को हटाना चाहते हैं? यह स्थायी रूप से हटा देगा:\n\n• उपयोगकर्ता खाता\n• सभी पॉइंट्स और लेनदेन इतिहास\n• सभी जमा किए गए बिल\n• सभी ऑफर रिडेम्प्शन\n\nइस क्रिया को पूर्ववत नहीं किया जा सकता।';

  @override
  String get deleteCarpenterWarning =>
      'बढ़ई को हटाना सिस्टम से उनके सभी डेटा को स्थायी रूप से हटा देगा। इस क्रिया को पूर्ववत नहीं किया जा सकता।';

  @override
  String get carpenterDeletedSuccess => 'बढ़ई सफलतापूर्वक हटाया गया';

  @override
  String get failedToDeleteCarpenter => 'बढ़ई हटाने में विफल';

  @override
  String get dangerZone => 'खतरनाक क्षेत्र';

  @override
  String get phoneNumberLabel => 'फोन नंबर';

  @override
  String get phoneNumberHint => 'उदा. 9876543210 (बिना +91)';

  @override
  String get enterOTP => 'OTP दर्ज करें';

  @override
  String get verifyAndCreate => 'सत्यापित करें और बनाएं';

  @override
  String get adminSignOutNote =>
      'नोट: OTP सत्यापन के दौरान ऐप अस्थायी रूप से सत्यापित बढ़ई के रूप में साइन इन करेगा और फिर साइन आउट करेगा। व्यवस्थापक को फिर से साइन इन करना होगा।';

  @override
  String get carpenterCreated => 'बढ़ई बनाया गया';

  @override
  String get carpenterCreatedMessage =>
      'बढ़ई खाता सफलतापूर्वक बनाया गया। सत्यापन के दौरान ऐप उस बढ़ई के रूप में साइन इन हो गया है और अब साइन आउट हो गया है। आपको व्यवस्थापक के रूप में फिर से साइन इन करना होगा।';

  @override
  String get enterValidPhone => 'एक वैध फोन नंबर दर्ज करें';

  @override
  String get phoneAlreadyExists => 'फोन नंबर पहले से मौजूद है';

  @override
  String get verificationFailed => 'सत्यापन विफल';

  @override
  String get otpSent => 'OTP भेजा गया';

  @override
  String get failedToSignIn => 'OTP से साइन इन करने में विफल';

  @override
  String get authError => 'प्रमाणीकरण त्रुटि';

  @override
  String get totalPointsLabel => 'कुल पॉइंट्स';

  @override
  String tierLabel(String tier) {
    return '$tier स्तर';
  }

  @override
  String get recentActivity => 'हालिया गतिविधि';

  @override
  String get noActivityYet => 'अभी तक कोई गतिविधि नहीं';

  @override
  String get noWinnerYetToday => 'आज अभी तक कोई विजेता नहीं';

  @override
  String get youWonPrize => '🎉 आपने जीत लिया!';

  @override
  String get todaysWinnerLabel => '🏆 आज के विजेता';

  @override
  String get myPoints => 'मेरे पॉइंट्स';

  @override
  String get redeemRewards => 'पुरस्कार भुनाएं';

  @override
  String get leaderboard => 'लीडरबोर्ड';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get rankShort => 'रैंक';

  @override
  String get earn => 'कमाएं';

  @override
  String get approved => 'स्वीकृत';

  @override
  String get addNewBill => 'नया बिल जोड़ें';

  @override
  String get recentBills => 'हाल के बिल';

  @override
  String get noBillsYet => 'अभी तक कोई बिल नहीं';

  @override
  String get submitFirstBill =>
      'पॉइंट्स अर्जित करने के लिए अपना पहला बिल जमा करें';

  @override
  String get justNow => 'अभी-अभी';

  @override
  String minutesAgo(int minutes) {
    return '$minutes मिनट पहले';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours घंटे पहले';
  }

  @override
  String daysAgo(int days) {
    return '$days दिन पहले';
  }

  @override
  String get billLabel => 'बिल';

  @override
  String get statusApproved => 'स्वीकृत';

  @override
  String get statusPending => 'लंबित';

  @override
  String get statusRejected => 'अस्वीकृत';

  @override
  String get exitApp => 'ऐप से बाहर निकलें?';

  @override
  String get exitAppMessage => 'क्या आप ऐप से बाहर निकलना चाहते हैं?';

  @override
  String get exit => 'बाहर निकलें';

  @override
  String get discardChanges => 'परिवर्तन छोड़ें?';

  @override
  String get discardChangesMessage =>
      'आपके पास असहेजित परिवर्तन हैं। क्या आप उन्हें छोड़ना चाहते हैं?';

  @override
  String get discard => 'छोड़ें';

  @override
  String get pressBackAgainToExit => 'बाहर निकलने के लिए फिर से बैक दबाएं';

  @override
  String get pleaseWait => 'कृपया प्रतीक्षा करें...';

  @override
  String get pleaseWaitForSpin => 'कृपया स्पिन पूरा होने तक प्रतीक्षा करें';

  @override
  String get discardBill => 'बिल छोड़ें?';

  @override
  String get discardBillMessage =>
      'आपके पास असहेजित बिल डेटा है। क्या आप इसे छोड़ना चाहते हैं?';

  @override
  String get pleaseCompleteProfile => 'कृपया अपना प्रोफाइल पूरा करें';

  @override
  String get rewardsLoyaltyProgram => 'पुरस्कार और वफादारी कार्यक्रम';

  @override
  String get billImage => 'बिल छवि';

  @override
  String get billDateOptional => 'बिल तारीख (वैकल्पिक)';

  @override
  String get storeVendorNameOptional => 'स्टोर/विक्रेता नाम (वैकल्पिक)';

  @override
  String get billInvoiceNumberOptional => 'बिल/चालान नंबर (वैकल्पिक)';

  @override
  String get notesOptional => 'नोट्स (वैकल्पिक)';

  @override
  String get tapToAddBillImage => 'बिल छवि जोड़ने के लिए टैप करें';

  @override
  String get selectBillDateOptional => 'बिल तारीख चुनें (वैकल्पिक)';

  @override
  String get enterStoreOrVendorNameOptional =>
      'स्टोर या विक्रेता नाम दर्ज करें (वैकल्पिक)';

  @override
  String get enterBillOrInvoiceNumberOptional =>
      'बिल या चालान नंबर दर्ज करें (वैकल्पिक)';

  @override
  String get addAnyAdditionalNotes => 'कोई अतिरिक्त नोट्स जोड़ें...';

  @override
  String get submitBill => 'बिल जमा करें';

  @override
  String get saveChanges => 'परिवर्तन सहेजें';
}
