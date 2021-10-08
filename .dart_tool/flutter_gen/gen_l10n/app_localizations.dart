
import 'dart:async';

// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations returned
/// by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// localizationDelegates list, and the locales they support in the app's
/// supportedLocales list. For example:
///
/// ```
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  // ignore: unused_field
  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'LogOut'**
  String get logout;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Search Drop Off'**
  String get searchdropoff;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentlocation;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Choose Type'**
  String get choosetype;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get bike;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Tuktuk'**
  String get tuktuk;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Requsting a Ride '**
  String get requstin;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleasewait;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Finding a Driver'**
  String get findingadriver;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Cancel Ride'**
  String get cancelride;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Call Driver'**
  String get calldriver;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Confirm DropOFF Location'**
  String get cdropoffloc;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmpassword;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Do not have an Account ?'**
  String get notaccount;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Register Here'**
  String get registerhere;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phonenumbere;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Rate this Driver'**
  String get ratedriver;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createaccount;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **' Allready have an Account ?'**
  String get haveanaccount;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Search for Place'**
  String get searchforplace;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'PickUp Location'**
  String get pickuplocation;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Where to ?'**
  String get whereto;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Set Drop Off on Map'**
  String get setdropoffonmap;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Trip Fare'**
  String get tripfare;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'This is the total amount, it has been charged to the rider'**
  String get thetotalamount;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Pay Cash'**
  String get paycash;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'No driver found'**
  String get nodriverfound;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'No available driver found in the nearby, we suggest you try again shortly'**
  String get noavailabledriverfound;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Verify Your Number'**
  String get verifyyournumber;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'please enter your mobile number to receive OTP code'**
  String get pleaseenteryourmobile;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Resend the Code'**
  String get resend;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Pleas verify your numbere type the verification code'**
  String get typeverification;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Verification code '**
  String get verificationcode;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **' Confirm'**
  String get confirm;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(_lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations _lookupAppLocalizations(Locale locale) {
  


// Lookup logic when only language code is specified.
switch (locale.languageCode) {
  case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
}


  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
