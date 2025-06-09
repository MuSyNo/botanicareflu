import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ms.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
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
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ms'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'BotaniCare'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @irrigation.
  ///
  /// In en, this message translates to:
  /// **'Irrigation'**
  String get irrigation;

  /// No description provided for @soilHealth.
  ///
  /// In en, this message translates to:
  /// **'Soil Health'**
  String get soilHealth;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get systemSettings;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @idle.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get idle;

  /// No description provided for @irrigateNow.
  ///
  /// In en, this message translates to:
  /// **'Irrigate Now'**
  String get irrigateNow;

  /// No description provided for @startIrrigation.
  ///
  /// In en, this message translates to:
  /// **'Start Irrigation'**
  String get startIrrigation;

  /// No description provided for @stopIrrigation.
  ///
  /// In en, this message translates to:
  /// **'Stop Irrigation'**
  String get stopIrrigation;

  /// No description provided for @irrigationDuration.
  ///
  /// In en, this message translates to:
  /// **'Irrigation Duration'**
  String get irrigationDuration;

  /// No description provided for @setThreshold.
  ///
  /// In en, this message translates to:
  /// **'Set Moisture Threshold'**
  String get setThreshold;

  /// No description provided for @autoMode.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get autoMode;

  /// No description provided for @manualMode.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manualMode;

  /// No description provided for @irrigationMode.
  ///
  /// In en, this message translates to:
  /// **'Irrigation Mode'**
  String get irrigationMode;

  /// No description provided for @latestSoilCondition.
  ///
  /// In en, this message translates to:
  /// **'Latest Soil Condition'**
  String get latestSoilCondition;

  /// No description provided for @recommendation.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get recommendation;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @askQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about plant care...'**
  String get askQuestion;

  /// No description provided for @chatbotAssistant.
  ///
  /// In en, this message translates to:
  /// **'Plant Care Assistant'**
  String get chatbotAssistant;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotifications;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No history found.'**
  String get noHistory;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailLabel;

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get notSignedIn;

  /// No description provided for @updateAccount.
  ///
  /// In en, this message translates to:
  /// **'Account updated successfully.'**
  String get updateAccount;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @muteNotifications.
  ///
  /// In en, this message translates to:
  /// **'Mute Notifications'**
  String get muteNotifications;

  /// No description provided for @muteNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Disable all alerts and updates'**
  String get muteNotificationsDescription;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Enable Sound'**
  String get sound;

  /// No description provided for @soundDescription.
  ///
  /// In en, this message translates to:
  /// **'Play notification sounds'**
  String get soundDescription;

  /// No description provided for @soilEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'New Soil Entry'**
  String get soilEntryTitle;

  /// No description provided for @ph.
  ///
  /// In en, this message translates to:
  /// **'pH'**
  String get ph;

  /// No description provided for @nitrogen.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen (N)'**
  String get nitrogen;

  /// No description provided for @phosphorus.
  ///
  /// In en, this message translates to:
  /// **'Phosphorus (P)'**
  String get phosphorus;

  /// No description provided for @potassium.
  ///
  /// In en, this message translates to:
  /// **'Potassium (K)'**
  String get potassium;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @crop.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get crop;

  /// No description provided for @acidic.
  ///
  /// In en, this message translates to:
  /// **'Acidic'**
  String get acidic;

  /// No description provided for @alkaline.
  ///
  /// In en, this message translates to:
  /// **'Alkaline'**
  String get alkaline;

  /// No description provided for @neutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get neutral;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @addCrop.
  ///
  /// In en, this message translates to:
  /// **'Add Crop'**
  String get addCrop;

  /// No description provided for @cropName.
  ///
  /// In en, this message translates to:
  /// **'Crop Name'**
  String get cropName;

  /// No description provided for @zone.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get zone;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @soilHealthOverview.
  ///
  /// In en, this message translates to:
  /// **'Soil Health Overview'**
  String get soilHealthOverview;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastUpdated;

  /// No description provided for @soilPH.
  ///
  /// In en, this message translates to:
  /// **'Soil pH'**
  String get soilPH;

  /// No description provided for @idealPHRange.
  ///
  /// In en, this message translates to:
  /// **'Ideal range: 6.0 - 7.5'**
  String get idealPHRange;

  /// No description provided for @overallStatus.
  ///
  /// In en, this message translates to:
  /// **'Overall Status'**
  String get overallStatus;

  /// No description provided for @statusBasedOn.
  ///
  /// In en, this message translates to:
  /// **'Based on pH and NPK balance'**
  String get statusBasedOn;

  /// No description provided for @careRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Care Recommendation'**
  String get careRecommendation;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Recommendation copied'**
  String get copiedToClipboard;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found for that email.'**
  String get userNotFound;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get wrongPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is invalid.'**
  String get invalidEmail;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed.'**
  String get loginFailed;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'failed'**
  String get failed;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changePasswordNotice.
  ///
  /// In en, this message translates to:
  /// **'🔒 Change password not implemented.'**
  String get changePasswordNotice;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'✅ Profile updated successfully.'**
  String get profileSaved;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get saveFailed;

  /// No description provided for @restartAppToApply.
  ///
  /// In en, this message translates to:
  /// **'Restart the app to apply dark mode'**
  String get restartAppToApply;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started with smart irrigation'**
  String get registerSubtitle;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordHint;

  /// No description provided for @agreeTermsLabel.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms and Conditions'**
  String get agreeTermsLabel;

  /// No description provided for @agreeTermsNotice.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the Terms and Conditions'**
  String get agreeTermsNotice;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @isRequired.
  ///
  /// In en, this message translates to:
  /// **'is required'**
  String get isRequired;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a password reset link.'**
  String get resetPasswordSubtitle;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'✅ Reset link has been sent to your email.'**
  String get resetLinkSent;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email.'**
  String get emailRequired;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'updated'**
  String get updated;

  /// No description provided for @selectCrop.
  ///
  /// In en, this message translates to:
  /// **'Please select a crop'**
  String get selectCrop;

  /// No description provided for @viewLatestCondition.
  ///
  /// In en, this message translates to:
  /// **'View the latest pH and NPK data with recommendations'**
  String get viewLatestCondition;

  /// No description provided for @soilHealthHistory.
  ///
  /// In en, this message translates to:
  /// **'Soil Health History'**
  String get soilHealthHistory;

  /// No description provided for @viewPastEntries.
  ///
  /// In en, this message translates to:
  /// **'View all past entries recorded'**
  String get viewPastEntries;

  /// No description provided for @firmwareVersion.
  ///
  /// In en, this message translates to:
  /// **'Firmware Version 1.0.0'**
  String get firmwareVersion;

  /// No description provided for @syncTimeWithDevice.
  ///
  /// In en, this message translates to:
  /// **'Sync Time with Device'**
  String get syncTimeWithDevice;

  /// No description provided for @syncComingSoon.
  ///
  /// In en, this message translates to:
  /// **'⏳ Time sync feature coming soon.'**
  String get syncComingSoon;

  /// No description provided for @waterUsage.
  ///
  /// In en, this message translates to:
  /// **'Water Usage'**
  String get waterUsage;

  /// No description provided for @noUsageData.
  ///
  /// In en, this message translates to:
  /// **'No usage data available'**
  String get noUsageData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ms'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ms':
      return AppLocalizationsMs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
