// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'பலாஜி பாயிண்ட்ஸ்';

  @override
  String get loading => 'லோடிங்...';

  @override
  String get error => 'பிழை';

  @override
  String get success => 'வெற்றி';

  @override
  String get ok => 'சரி';

  @override
  String get cancel => 'ரத்து';

  @override
  String get save => 'சேமிக்கவும்';

  @override
  String get delete => 'அழிக்கவும்';

  @override
  String get edit => 'திருத்து';

  @override
  String get submit => 'சமர்ப்பிக்கவும்';

  @override
  String get back => 'பின் செல்ல';

  @override
  String get next => 'அடுத்தது';

  @override
  String get done => 'முடிந்தது';

  @override
  String get retry => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get refresh => 'ரிஃப்ரெஷ்';

  @override
  String get loginWithPhone => 'கைபேசி எண்கொண்டு உள்நுளையவும்';

  @override
  String get enterPhoneNumber => 'பதிவு செய்யப்பட்ட கைபேசி எண்ணை உள்ளிடவும்';

  @override
  String get phoneNumber => 'கைபேசி எண்';

  @override
  String get enterPhoneHint => '10 இலக்க கைபேசி எண்';

  @override
  String get sendOTP => 'OTP அனுப்பவும்';

  @override
  String get verifyOTP => 'OTP சரிபார்க்கவும்';

  @override
  String get enterOTPCode => 'அனுப்பப்பட்ட 6 இலக்க OTP ஐ உள்ளிடவும்';

  @override
  String get didntReceiveOTP => 'OTP வரலையா? ';

  @override
  String get resend => 'மீண்டும் அனுப்பவும்';

  @override
  String resendIn(int seconds) {
    return '$seconds விநாடிகளில் மீண்டும்';
  }

  @override
  String get invalidPhone => 'கைபேசி எண்ணை உள்ளிடவும்';

  @override
  String get invalidPhoneLength => 'கைபேசி எண் 10 இலக்கமாக இருக்க வேண்டும்';

  @override
  String get invalidPhoneFormat =>
      'கைபேசி எண் இலக்கங்கள் மட்டுமே இருக்க வேண்டும்';

  @override
  String get invalidOTP => 'செல்லுபடியாகாத OTP';

  @override
  String get selectRole => 'உங்கள் பாத்திரத்தை தேர்வுசெய்க';

  @override
  String get carpenter => 'தச்சர்';

  @override
  String get admin => 'நிர்வாகி';

  @override
  String get welcomeBack => 'மீண்டும் வரவேற்கிறோம்';

  @override
  String get createAccount => 'கணக்கு உருவாக்கு';

  @override
  String get continueWithPhone => 'கைபேசியுடன் தொடரவும்';

  @override
  String get continueWithPin => 'PIN உடன் தொடரவும்';

  @override
  String get loginInfo =>
      'உங்கள் பதிவு செய்யப்பட்ட கைபேசி எண்ணை பயன்படுத்தி உள்நுழைக. OTP அனுப்பப்படும்.';

  @override
  String get poweredBy => 'இனால் இயக்கப்படுகிறது';

  @override
  String get companyName => 'ஸ்ரீ பலாஜி பிளைவுட் & ஹார்ட்வேர்';

  @override
  String get enterPinPageTitle => '4 இலக்க PIN ஐ உள்ளிடவும்';

  @override
  String get enter4DigitPin => '4 இலக்க PIN ஐ உள்ளிடவும்';

  @override
  String get pinLabel => 'பின்';

  @override
  String get fourDigitPin => '4 இலக்க PIN';

  @override
  String get login => 'உள்நுளை';

  @override
  String get forgotPin => 'PIN மறந்துவிட்டதா?';

  @override
  String get newUserSetPin => 'புதிய பயனரா? PIN அமைக்கவும்';

  @override
  String get invalidPin => 'தவறான PIN';

  @override
  String get createPinTitle => '4 இலக்க PIN உருவாக்கவும்';

  @override
  String get createPinSubtitle => 'இந்த PIN உள்நுழைவுக்காக பயன்படுத்தப்படும்';

  @override
  String get mobileNumber => 'கைபேசி எண்';

  @override
  String get firstName => 'முதல் பெயர்';

  @override
  String get firstNameRequired => 'முதல் பெயர் *';

  @override
  String get lastName => 'கடைசி பெயர்';

  @override
  String get confirmPin => 'PIN உறுதிப்படுத்தவும்';

  @override
  String get savePin => 'PIN சேமிக்கவும்';

  @override
  String get pinCreatedSuccess => 'PIN வெற்றிகரமாக உருவாக்கப்பட்டது';

  @override
  String get failedToSavePin => 'PIN சேமிக்கத் தவறிவிட்டது';

  @override
  String get pinsDoNotMatch => 'PIN மற்றும் உறுதிப்படுத்தல் PIN பொருந்தவில்லை';

  @override
  String get resetPinTitle => 'PIN மீட்டமைக்கவும்';

  @override
  String get resetPinSubtitle =>
      'PIN மீட்டமைக்க பதிவு செய்யப்பட்ட கைபேசி எண்ணை உள்ளிடவும்.';

  @override
  String get mustBeLoggedInToResetPin =>
      'You must be logged in to reset your PIN. Please login first.';

  @override
  String get canOnlyResetOwnPin =>
      'You can only reset your own PIN. Phone number must match your logged-in account.';

  @override
  String get enterCurrentPin =>
      'Please enter your current PIN to verify ownership.';

  @override
  String get currentPinLabel => 'Current PIN';

  @override
  String get newPinMustBeDifferent =>
      'New PIN must be different from your current PIN.';

  @override
  String get contactAdminForPinReset =>
      'You must be logged in to reset your PIN. If you forgot your PIN, please contact admin for assistance.';

  @override
  String get forgotCurrentPin => 'Forgot your current PIN?';

  @override
  String get forgotPinHelp =>
      'If you don\'t remember your current PIN, please contact our support team for assistance.';

  @override
  String get adminSupportInfo => 'Admin Support';

  @override
  String get callSupport => 'Call Support';

  @override
  String get newPinLabel => 'புதிய 4 இலக்க PIN';

  @override
  String get checkNumber => 'எண் சரிபார்க்கவும்';

  @override
  String get verified => 'சரிபார்க்கப்பட்டது';

  @override
  String get pleaseVerifyMobile => 'முதலில் கைபேசி எண்ணை சரிபார்க்கவும்';

  @override
  String get noAccountFound => 'இந்த எண்ணுக்கான கணக்கு இல்லை';

  @override
  String get pinResetSuccess =>
      'PIN வெற்றிகரமாக மீட்டமைக்கப்பட்டது. மீண்டும் உள்நுழையவும்.';

  @override
  String get failedToResetPin =>
      'PIN மீட்டமைக்கத் தவறிவிட்டது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get enterValidTenDigit => 'செல்லுபடியான 10 இலக்க எண்ணை உள்ளிடவும்';

  @override
  String get enter4Digits => '4 இலக்கங்களை உள்ளிடவும்';

  @override
  String get enterValidFirstName => 'செல்லுபடியான முதல் பெயரை உள்ளிடவும்';

  @override
  String get imageError => 'படப் பிழை';

  @override
  String get resetPin => 'PIN மீட்டமைக்கவும்';

  @override
  String get changePin => 'PIN மாற்றவும்';

  @override
  String get rememberMe => 'என்னை நினைவில் வைக்கவும்';

  @override
  String get accountExistsUseReset =>
      'கணக்கு ஏற்கனவே உள்ளது. உங்கள் PIN ஐ மாற்ற Reset PIN ஐ பயன்படுத்தவும்.';

  @override
  String get home => 'முகப்பு';

  @override
  String get addPoints => 'பாயிண்ட்ஸ் சேர்க்கவும்';

  @override
  String get latestOffers => 'சமீபத்திய ஆஃபர்கள்';

  @override
  String get topCarpenters => 'சிறந்த 3 தச்சர்கள்';

  @override
  String get todaysWinner => 'இன்றைய வெற்றியாளர்';

  @override
  String get yourPosition => 'உங்கள் நிலை';

  @override
  String rank(int rank) {
    return 'தரவரிசை #$rank';
  }

  @override
  String points(int points) {
    return '$points பாயிண்ட்ஸ்';
  }

  @override
  String get noOffersAvailable => 'தற்போது எந்த ஆஃபர்களும் இல்லை';

  @override
  String get dailySpinWinner => '🎉 தினசரி ஸ்பின் வெற்றியாளர்';

  @override
  String get congratulations => 'வாழ்த்துக்கள்!';

  @override
  String won(int points) {
    return '$points பாயிண்ட்ஸ் வென்றுள்ளீர்கள்!';
  }

  @override
  String get profile => 'சுயவிவரம்';

  @override
  String get editProfile => 'சுயவிவரம் திருத்து';

  @override
  String get completeProfile => 'சுயவிவரத்தை நிறைவு செய்யவும்';

  @override
  String get profileIncomplete => 'சுயவிவரம் முழுமையில்லை';

  @override
  String get completeProfileMessage =>
      'பில்ல்களைச் சேர்த்து பாயிண்ட்ஸ் பெற உங்கள் சுயவிவரத்தை நிறைவு செய்யவும்';

  @override
  String get completeProfileDetails =>
      'முதல் பெயர், கடைசி பெயர் மற்றும் புகைப்படத்தைச் சேர்க்கவும்';

  @override
  String get completeNow => 'இப்போதே நிறைவு செய்';

  @override
  String get helpSupport => 'உதவி & ஆதரவு';

  @override
  String get contactUs => 'எங்களை தொடர்பு கொள்ள';

  @override
  String get darkMode => 'டார்க் மோட்';

  @override
  String get logout => 'வெளியேறு';

  @override
  String get logoutConfirmation => 'நீங்கள் வெளியேற விரும்புகிறீர்களா?';

  @override
  String get name => 'பெயர்';

  @override
  String get email => 'மின்னஞ்சல்';

  @override
  String get phone => 'கைபேசி';

  @override
  String get role => 'பாத்திரம்';

  @override
  String get memberSince => 'உறுப்பினர் ஆன தேதி';

  @override
  String get totalPoints => 'மொத்த பாயிண்ட்ஸ்';

  @override
  String get notVerified => 'சரிபார்க்கப்படவில்லை';

  @override
  String get needHelp => 'உதவி வேண்டுமா?';

  @override
  String get contactSupport => 'எங்கள் ஆதரவு குழுவை தொடர்பு கொள்ளவும்.';

  @override
  String get supportPhone1 => '96006 - 09121';

  @override
  String get supportPhone2 => '0424 - 3557187';

  @override
  String get callNow => 'இப்போது அழைக்கவும்';

  @override
  String get getInTouch => 'எங்களை தொடர்பு கொள்ளவும்';

  @override
  String get mobile => 'மொபைல்';

  @override
  String get landline => 'லேண்ட்லைன்';

  @override
  String get addBill => 'பில் சேர்க்கவும்';

  @override
  String get billDetails => 'பில் விவரங்கள்';

  @override
  String get billNumber => 'பில் எண்';

  @override
  String get billAmount => 'பில் தொகை';

  @override
  String get billDate => 'பில் தேதி';

  @override
  String get uploadBillImage => 'பில் படத்தை பதிவேற்றவும்';

  @override
  String get selectImage => 'படத்தைத் தேர்வு செய்';

  @override
  String get changeImage => 'படத்தை மாற்று';

  @override
  String get pointsConversion => '₹1000 = 1 பாயிண்ட்';

  @override
  String get estimatedPoints => 'மதிப்பிடப்பட்ட பாயிண்ட்ஸ்';

  @override
  String youWillEarn(int points) {
    return 'நீங்கள் கணக்கில் $points பாயிண்ட்ஸ் பெறுவீர்கள்';
  }

  @override
  String get enterBillNumber => 'பில் எண்ணை உள்ளிடவும்';

  @override
  String get enterBillAmount => 'பில் தொகையை உள்ளிடவும்';

  @override
  String get enterValidAmount => 'சரியான தொகையை உள்ளிடவும்';

  @override
  String get selectBillDate => 'பில் தேதியைத் தேர்வு செய்யவும்';

  @override
  String get uploadBillPhoto => 'பில் புகைப்படத்தை பதிவேற்றவும்';

  @override
  String get billSubmitted => 'பில் வெற்றிகரமாக சமர்ப்பிக்கப்பட்டது';

  @override
  String get billSubmitError => 'பில் சமர்ப்பிப்பு தோல்வியடைந்தது';

  @override
  String get wallet => 'வாலெட்';

  @override
  String get availablePoints => 'கிடைக்கும் பாயிண்ட்ஸ்';

  @override
  String get redeemPoints => 'பாயிண்ட்ஸ் ரீடீம்';

  @override
  String get transactionHistory => 'பரிவர்த்தனை வரலாறு';

  @override
  String get noTransactions => 'பரிவர்த்தனைகள் இல்லை';

  @override
  String get earned => 'பெற்றது';

  @override
  String get spent => 'செலவிட்டது';

  @override
  String get pending => 'நிலுவையில்';

  @override
  String get offers => 'ஆஃபர்கள்';

  @override
  String get viewDetails => 'விவரங்களைப் பார்க்க';

  @override
  String get redeemNow => 'இப்போதே ரீடீம் செய்யவும்';

  @override
  String pointsRequired(int points) {
    return '$points பாயிண்ட்ஸ் தேவை';
  }

  @override
  String get offerRedeemed => 'ஆஃபர் வெற்றிகரமாக ரீடீம் செய்யப்பட்டது';

  @override
  String get insufficientPoints => 'பாயிண்ட்ஸ் போதவில்லை';

  @override
  String get offerExpired => 'இந்த ஆஃபர் காலாவதியானது';

  @override
  String validUntil(String date) {
    return 'செல்லுபடியாகும் தேதி: $date';
  }

  @override
  String get dailySpin => 'டெய்லி ஸ்பின்';

  @override
  String get spinNow => 'இப்போதே ஸ்பின் செய்';

  @override
  String get spinning => 'ஸ்பின் நடக்கிறது...';

  @override
  String get spinWheel => 'சக்கரத்தை ஸ்பின் செய்';

  @override
  String get dailySpinCompleted =>
      'நீங்கள் இன்று ஏற்கனவே ஸ்பின் செய்துவிட்டீர்கள்';

  @override
  String get comeBackTomorrow => 'நாளை மீண்டும் முயற்சிக்கவும்!';

  @override
  String nextSpinIn(int hours, int minutes) {
    return 'அடுத்த ஸ்பின்: $hoursமணி $minutesநிமி';
  }

  @override
  String winner(String name) {
    return 'வெற்றியாளர்: $name';
  }

  @override
  String prizePoints(int points) {
    return '🎁 $points பாயிண்ட்ஸ்';
  }

  @override
  String get adminPanel => 'அட்மின் பேனல்';

  @override
  String get adminSubtitle =>
      'பில்கள், ஆஃபர்கள், பயனர்கள் & டெய்லி ஸ்பின் மேலாண்மை';

  @override
  String get dashboard => 'டாஷ்போர்ட்';

  @override
  String get users => 'பயனர்கள்';

  @override
  String get manageUsers => 'பயனர்களை மேலாண்மை செய்';

  @override
  String get manageBills => 'பில்களை மேலாண்மை செய்';

  @override
  String get manageOffers => 'ஆஃபர்களை மேலாண்மை செய்';

  @override
  String get manageDailySpin => 'டெய்லி ஸ்பின் மேலாண்மை';

  @override
  String get pendingBills => 'நிலுவை பில்கள்';

  @override
  String get approvedBills => 'ஒப்புதல் அளிக்கப்பட்ட பில்கள்';

  @override
  String get rejectedBills => 'நிராகரிக்கப்பட்ட பில்கள்';

  @override
  String get pendingUsers => 'நிலுவை பயனர்கள்';

  @override
  String get verifiedUsers => 'சரிபார்க்கப்பட்ட பயனர்கள்';

  @override
  String get approve => 'ஒப்புதல்';

  @override
  String get reject => 'நிராகரி';

  @override
  String get userApproved => 'பயனர் வெற்றிகரமாக ஒப்புதல் பெற்றார்';

  @override
  String get userRejected => 'பயனர் நிராகரிக்கப்பட்டார்';

  @override
  String get billApproved => 'பில் வெற்றிகரமாக ஒப்புதல் பெற்றது';

  @override
  String get billRejected => 'பில் நிராகரிக்கப்பட்டது';

  @override
  String get createOffer => 'ஆஃபர் உருவாக்கு';

  @override
  String get offerTitle => 'ஆஃபர் தலைப்பு';

  @override
  String get offerDescription => 'ஆஃபர் விளக்கம்';

  @override
  String get offerCreated => 'ஆஃபர் வெற்றிகரமாக உருவாக்கப்பட்டது';

  @override
  String get logoutFailed => 'வெளியேற முடியவில்லை';

  @override
  String get errorOccurred => 'பிழை ஏற்பட்டது';

  @override
  String get networkError => 'இணைய பிழை. உங்கள் இணைப்பை சரிபார்க்கவும்.';

  @override
  String get permissionDenied => 'அனுமதி மறுக்கப்பட்டது';

  @override
  String get sessionExpired => 'செஷன் காலாவதியானது. மீண்டும் உள்நுழைக.';

  @override
  String get invalidCredentials => 'செல்லுபடியாகாத தகவல்கள்';

  @override
  String get userNotFound => 'பயனர் கிடைக்கவில்லை';

  @override
  String get phoneAuthFailed => 'கைபேசி சரிபார்ப்பு தோல்வியடைந்தது';

  @override
  String get configError => 'கட்டமைப்பு பிழை';

  @override
  String get missingClientId =>
      'Firebase-ல் SHA-1 இல்லை. scripts/get_sha1.sh ஐ இயக்கவும்.';

  @override
  String get tooManyRequests =>
      'அதிகமான கோரிக்கைகள். சில நிமிடங்கள் காத்திருங்கள்.';

  @override
  String get invalidVerificationCode => 'செல்லுபடியாகாத OTP';

  @override
  String get verificationExpired => 'OTP காலாவதியானது';

  @override
  String get userDisabled => 'இந்த கணக்கு முடக்கப்பட்டுள்ளது';

  @override
  String get fieldRequired => 'இந்த புலம் அவசியம்';

  @override
  String get invalidEmail => 'செல்லுபடியாகாத மின்னஞ்சல்';

  @override
  String get invalidName => 'செல்லுபடியாகாத பெயர்';

  @override
  String get nameTooShort => 'பெயர் குறைந்தது 2 எழுத்துகள் இருக்க வேண்டும்';

  @override
  String get invalidAmount => 'செல்லுபடியாகாத தொகை';

  @override
  String get amountTooLow => 'தொகை 0-ஐ விட அதிகமாக இருக்க வேண்டும்';

  @override
  String get searchHint => 'தேடுக...';

  @override
  String get noResultsFound => 'முடிவுகள் இல்லை';

  @override
  String get noDataAvailable => 'தரவுகள் இல்லை';

  @override
  String get pullToRefresh => 'ரீஃபிரெஷ் செய்ய இழுக்கவும்';

  @override
  String get releaseToRefresh => 'ரீஃபிரெஷ் செய்ய விடவும்';

  @override
  String get refreshing => 'ரீஃபிரெஷ் செய்கிறது...';

  @override
  String get loadMore => 'மேலும் ஏற்றவும்';

  @override
  String get seeAll => 'அனைத்தையும் காண்க';

  @override
  String get close => 'மூடு';

  @override
  String get confirm => 'உறுதி செய்';

  @override
  String get areYouSure => 'உறுதியாக உள்ளீர்களா?';

  @override
  String get cannotUndo => 'இந்த செயலை ரத்து செய்ய முடியாது.';

  @override
  String get yes => 'ஆம்';

  @override
  String get no => 'இல்லை';

  @override
  String get today => 'இன்று';

  @override
  String get yesterday => 'நேற்று';

  @override
  String get tomorrow => 'நாளை';

  @override
  String get january => 'ஜனவரி';

  @override
  String get february => 'பிப்ரவரி';

  @override
  String get march => 'மார்ச்';

  @override
  String get april => 'ஏப்ரல்';

  @override
  String get may => 'மே';

  @override
  String get june => 'ஜூன்';

  @override
  String get july => 'ஜூலை';

  @override
  String get august => 'ஆகஸ்ட்';

  @override
  String get september => 'செப்டம்பர்';

  @override
  String get october => 'அக்டோபர்';

  @override
  String get november => 'நவம்பர்';

  @override
  String get december => 'டிசம்பர்';

  @override
  String get jan => 'ஜன்';

  @override
  String get feb => 'பிப்';

  @override
  String get mar => 'மார்';

  @override
  String get apr => 'ஏப்';

  @override
  String get jun => 'ஜூன்';

  @override
  String get jul => 'ஜூலை';

  @override
  String get aug => 'ஆக';

  @override
  String get sep => 'செப்';

  @override
  String get oct => 'அக்';

  @override
  String get nov => 'நவ';

  @override
  String get dec => 'டிச';

  @override
  String get approveBill => 'பிலை ஒப்புதல் அளி';

  @override
  String approveBillConfirmation(String amount, String phone) {
    return '$phone க்கான ₹$amount பிலை ஒப்புதல் அளிக்கவா?';
  }

  @override
  String get approvingBill => 'பிலை ஒப்புதல் அளிக்கிறது...';

  @override
  String get billApprovedSuccess => 'பில் ஒப்புதல் பெற்றது!';

  @override
  String get failedToApproveBill =>
      'பிலை ஒப்புதல் செய்ய முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get rejectBill => 'பிலை நிராகரி';

  @override
  String get rejectBillConfirmation =>
      'இந்த பிலை நிராகரிக்க விரும்புகிறீர்களா?';

  @override
  String get billRejectedSuccess => 'பில் நிராகரிக்கப்பட்டது';

  @override
  String get failedToRejectBill => 'பிலை நிராகரிக்க முடியவில்லை';

  @override
  String get failedToLoadImage => 'படத்தை ஏற்ற முடியவில்லை';

  @override
  String get noImageAvailable => 'படம் இல்லை';

  @override
  String get errorLoadingBills => 'பில்களை ஏற்றும்போது பிழை';

  @override
  String get noPendingBills => 'நிலுவை பில்கள் இல்லை';

  @override
  String get pendingStatus => 'நிலுவை';

  @override
  String get noDate => 'தேதி இல்லை';

  @override
  String get deleteOffer => 'ஆஃபரை நீக்கு';

  @override
  String get deleteOfferConfirmation =>
      'இந்த ஆஃபரை நீக்க விரும்புகிறீர்களா? மீட்டெடுக்க முடியாது.';

  @override
  String get offerDeletedSuccess => 'ஆஃபர் வெற்றிகரமாக நீக்கப்பட்டது';

  @override
  String get failedToDeleteOffer => 'ஆஃபரை நீக்க முடியவில்லை';

  @override
  String get errorLoadingOffers => 'ஆஃபர்களை ஏற்றும்போது பிழை';

  @override
  String get noOffersCreated => 'ஆஃபர்கள் உருவாக்கப்படவில்லை';

  @override
  String get createFirstOffer =>
      'உங்கள் முதல் ஆஃபரை பாயிண்ட்ஸ் மற்றும் பேனர் உடன் உருவாக்கவும்';

  @override
  String get active => 'செயலில்';

  @override
  String get inactive => 'செயலற்றது';

  @override
  String get createdLabel => 'உருவாக்கப்பட்டது';

  @override
  String get editOffer => 'ஆஃபரை திருத்து';

  @override
  String get createNewOffer => 'புதிய ஆஃபர் உருவாக்கு';

  @override
  String get tapToUploadBanner => 'பேனரை பதிவேற்ற தட்டவும்';

  @override
  String get offerTitleLabel => 'ஆஃபர் தலைப்பு *';

  @override
  String get offerTitleHint => 'எ.கா., தீபாவளி சிறப்பு ஆஃபர்';

  @override
  String get enterOfferTitle => 'ஆஃபர் தலைப்பை உள்ளிடவும்';

  @override
  String get descriptionLabel => 'விளக்கம்';

  @override
  String get descriptionHint => 'ஆஃபரின் சுருக்கமான விவரம்';

  @override
  String get pointsRequiredLabel => 'தேவையான பாயிண்ட்ஸ் *';

  @override
  String get pointsHint => 'எ.கா., 100';

  @override
  String get enterPointsError => 'பாயிண்ட்ஸை உள்ளிடவும்';

  @override
  String get enterValidNumber => 'செல்லுபடியாகாத எண்';

  @override
  String get setValidUntilDate => 'Valid until தேதியை அமைக்கவும் (விருப்பம்)';

  @override
  String validUntilDisplay(String date) {
    return 'செல்லுபடியாகும் தேதி: $date';
  }

  @override
  String get offerStatus => 'ஆஃபர் நிலை';

  @override
  String get uploadingBanner => 'பேனர் பதிவேற்றுகிறது...';

  @override
  String get updateOffer => 'ஆஃபரை புதுப்பிக்கவும்';

  @override
  String get offerUpdatedSuccess => 'ஆஃபர் வெற்றிகரமாக புதுப்பிக்கப்பட்டது';

  @override
  String get offerCreatedSuccess => 'ஆஃபர் வெற்றிகரமாக உருவாக்கப்பட்டது';

  @override
  String get failedToSaveOffer => 'ஆஃபரை சேமிக்க முடியவில்லை';

  @override
  String get failedToPickImage => 'படத்தைத் தேர்வு செய்ய இயலவில்லை';

  @override
  String get searchByNameOrPhone => 'பெயர் அல்லது கைபேசி எண்ணால் தேடவும்...';

  @override
  String get add => 'சேர்க்கவும்';

  @override
  String get all => 'அனைத்தும்';

  @override
  String get platinum => 'பிளாட்டினம்';

  @override
  String get gold => 'கோல்டு';

  @override
  String get silver => 'சில்வர்';

  @override
  String get bronze => 'ப்ரான்ஸ்';

  @override
  String get errorLoadingUsers => 'பயனர்களை ஏற்றும்போது பிழை';

  @override
  String get noUsersFound => 'பயனர்கள் கிடைக்கவில்லை';

  @override
  String get tryDifferentSearch => 'வேறு தேடல் சொற்களை முயற்சிக்கவும்';

  @override
  String get noCarpentersYet => 'தச்சர்கள் இன்னும் பதிவு செய்யவில்லை';

  @override
  String joinedLabel(String date) {
    return '$date அன்று சேர்ந்தார்';
  }

  @override
  String get addCarpenter => 'தச்சரை சேர்க்கவும்';

  @override
  String get deleteCarpenter => 'Delete Carpenter';

  @override
  String get deleteCarpenterConfirmation =>
      'Are you sure you want to delete this carpenter? This will permanently delete:\n\n• User account\n• All points and transaction history\n• All submitted bills\n• All offer redemptions\n\nThis action cannot be undone.';

  @override
  String get deleteCarpenterWarning =>
      'Deleting a carpenter will permanently remove all their data from the system. This action cannot be undone.';

  @override
  String get carpenterDeletedSuccess => 'Carpenter deleted successfully';

  @override
  String get failedToDeleteCarpenter => 'Failed to delete carpenter';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get phoneNumberLabel => 'கைபேசி எண்';

  @override
  String get phoneNumberHint => 'எ.கா. 9876543210 (+91 இல்லாமல்)';

  @override
  String get enterOTP => 'OTP உள்ளிடவும்';

  @override
  String get verifyAndCreate => 'சரிபார்த்து உருவாக்கவும்';

  @override
  String get adminSignOutNote =>
      'குறிப்பு: OTP சரிபார்ப்பின் போது தற்காலிகமாக தச்சர் கணக்காக உள்நுழையும். பின்னர் மீண்டும் வெளியேறும். நிர்வாகி மீண்டும் உள்நுழைய வேண்டும்.';

  @override
  String get carpenterCreated => 'தச்சர் உருவாக்கப்பட்டார்';

  @override
  String get carpenterCreatedMessage =>
      'தச்சர் கணக்கு வெற்றிகரமாக உருவாக்கப்பட்டது. தற்காலிகமாக உள்நுழைந்து பின்னர் வெளியேறப்பட்டது. நிர்வாகி மீண்டும் உள்நுழைய வேண்டும்.';

  @override
  String get enterValidPhone => 'செல்லுபடியாகும் கைபேசி எண்ணை உள்ளிடவும்';

  @override
  String get phoneAlreadyExists => 'கைபேசி எண் ஏற்கனவே உள்ளது';

  @override
  String get verificationFailed => 'சரிபார்ப்பு தோல்வியடைந்தது';

  @override
  String get otpSent => 'OTP அனுப்பப்பட்டது';

  @override
  String get failedToSignIn => 'OTP உள்நுழைவு தோல்வியடைந்தது';

  @override
  String get authError => 'அங்கீகார பிழை';

  @override
  String get totalPointsLabel => 'மொத்த பாயிண்ட்ஸ்';

  @override
  String tierLabel(String tier) {
    return '$tier நிலை';
  }

  @override
  String get recentActivity => 'சமீபத்திய செயல்கள்';

  @override
  String get noActivityYet => 'ஏதும் செயல்கள் இல்லை';

  @override
  String get noWinnerYetToday => 'இன்று இன்னும் வெற்றியாளர் இல்லை';

  @override
  String get youWonPrize => '🎉 நீங்கள் வென்றுள்ளீர்கள்!';

  @override
  String get todaysWinnerLabel => '🏆 இன்றைய வெற்றியாளர்';

  @override
  String get myPoints => 'என் பாயிண்ட்ஸ்';

  @override
  String get redeemRewards => 'வெகுமதிகளை ரீடீம் செய்யவும்';

  @override
  String get leaderboard => 'தரவரிசை பட்டியல்';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get rankShort => 'ரேங்க்';

  @override
  String get earn => 'சம்பாதி';

  @override
  String get approved => 'ஒப்புதல்';

  @override
  String get addNewBill => 'புதிய பில் சேர்க்கவும்';

  @override
  String get recentBills => 'சமீபத்திய பில்கள்';

  @override
  String get noBillsYet => 'இன்னும் பில்கள் இல்லை';

  @override
  String get submitFirstBill =>
      'பாயிண்ட்ஸ் பெற உங்கள் முதல் பிலை சமர்ப்பிக்கவும்';

  @override
  String get justNow => 'இப்பொழுது';

  @override
  String minutesAgo(int minutes) {
    return '$minutes நிமி முன்பு';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours மணி முன்பு';
  }

  @override
  String daysAgo(int days) {
    return '$days நாள் முன்பு';
  }

  @override
  String get billLabel => 'பில்';

  @override
  String get statusApproved => 'ஒப்புதல்';

  @override
  String get statusPending => 'நிலுவை';

  @override
  String get statusRejected => 'நிராகரி';

  @override
  String get exitApp => 'Exit App?';

  @override
  String get exitAppMessage => 'Do you want to exit the app?';

  @override
  String get exit => 'Exit';

  @override
  String get discardChanges => 'Discard Changes?';

  @override
  String get discardChangesMessage =>
      'You have unsaved changes. Do you want to discard them?';

  @override
  String get discard => 'Discard';

  @override
  String get pressBackAgainToExit => 'Press back again to exit';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get pleaseWaitForSpin => 'Please wait for spin to complete';

  @override
  String get discardBill => 'Discard Bill?';

  @override
  String get discardBillMessage =>
      'You have unsaved bill data. Do you want to discard it?';

  @override
  String get pleaseCompleteProfile => 'Please complete your profile';

  @override
  String get rewardsLoyaltyProgram => 'Rewards & Loyalty Program';

  @override
  String get billImage => 'Bill Image';

  @override
  String get billDateOptional => 'Bill Date (Optional)';

  @override
  String get storeVendorNameOptional => 'Store/Vendor Name (Optional)';

  @override
  String get billInvoiceNumberOptional => 'Bill/Invoice Number (Optional)';

  @override
  String get notesOptional => 'Notes (Optional)';

  @override
  String get tapToAddBillImage => 'Tap to add bill image';

  @override
  String get selectBillDateOptional => 'Select bill date (optional)';

  @override
  String get enterStoreOrVendorNameOptional =>
      'Enter store or vendor name (optional)';

  @override
  String get enterBillOrInvoiceNumberOptional =>
      'Enter bill or invoice number (optional)';

  @override
  String get addAnyAdditionalNotes => 'Add any additional notes...';

  @override
  String get submitBill => 'Submit Bill';

  @override
  String get saveChanges => 'Save Changes';
}
