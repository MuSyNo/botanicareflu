// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `BotaniCare`
  String get appTitle {
    return Intl.message('BotaniCare', name: 'appTitle', desc: '', args: []);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Remember Me`
  String get rememberMe {
    return Intl.message('Remember Me', name: 'rememberMe', desc: '', args: []);
  }

  /// `Forgot Password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot Password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account?`
  String get noAccount {
    return Intl.message(
      'Don\'t have an account?',
      name: 'noAccount',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
  }

  /// `Confirm Password`
  String get confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get createAccount {
    return Intl.message(
      'Create Account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message('Dashboard', name: 'dashboard', desc: '', args: []);
  }

  /// `Irrigation`
  String get irrigation {
    return Intl.message('Irrigation', name: 'irrigation', desc: '', args: []);
  }

  /// `Soil Health`
  String get soilHealth {
    return Intl.message('Soil Health', name: 'soilHealth', desc: '', args: []);
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Account`
  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  /// `Account Settings`
  String get accountSettings {
    return Intl.message(
      'Account Settings',
      name: 'accountSettings',
      desc: '',
      args: [],
    );
  }

  /// `System Settings`
  String get systemSettings {
    return Intl.message(
      'System Settings',
      name: 'systemSettings',
      desc: '',
      args: [],
    );
  }

  /// `Notification Settings`
  String get notificationSettings {
    return Intl.message(
      'Notification Settings',
      name: 'notificationSettings',
      desc: '',
      args: [],
    );
  }

  /// `Help & Support`
  String get helpSupport {
    return Intl.message(
      'Help & Support',
      name: 'helpSupport',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Update`
  String get update {
    return Intl.message('Update', name: 'update', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Submit`
  String get submit {
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `Status`
  String get status {
    return Intl.message('Status', name: 'status', desc: '', args: []);
  }

  /// `Active`
  String get active {
    return Intl.message('Active', name: 'active', desc: '', args: []);
  }

  /// `Idle`
  String get idle {
    return Intl.message('Idle', name: 'idle', desc: '', args: []);
  }

  /// `Irrigate Now`
  String get irrigateNow {
    return Intl.message(
      'Irrigate Now',
      name: 'irrigateNow',
      desc: '',
      args: [],
    );
  }

  /// `Start Irrigation`
  String get startIrrigation {
    return Intl.message(
      'Start Irrigation',
      name: 'startIrrigation',
      desc: '',
      args: [],
    );
  }

  /// `Stop Irrigation`
  String get stopIrrigation {
    return Intl.message(
      'Stop Irrigation',
      name: 'stopIrrigation',
      desc: '',
      args: [],
    );
  }

  /// `Irrigation Duration`
  String get irrigationDuration {
    return Intl.message(
      'Irrigation Duration',
      name: 'irrigationDuration',
      desc: '',
      args: [],
    );
  }

  /// `Set Moisture Threshold`
  String get setThreshold {
    return Intl.message(
      'Set Moisture Threshold',
      name: 'setThreshold',
      desc: '',
      args: [],
    );
  }

  /// `Auto`
  String get autoMode {
    return Intl.message('Auto', name: 'autoMode', desc: '', args: []);
  }

  /// `Manual`
  String get manualMode {
    return Intl.message('Manual', name: 'manualMode', desc: '', args: []);
  }

  /// `Irrigation Mode`
  String get irrigationMode {
    return Intl.message(
      'Irrigation Mode',
      name: 'irrigationMode',
      desc: '',
      args: [],
    );
  }

  /// `Latest Soil Condition`
  String get latestSoilCondition {
    return Intl.message(
      'Latest Soil Condition',
      name: 'latestSoilCondition',
      desc: '',
      args: [],
    );
  }

  /// `Recommendation`
  String get recommendation {
    return Intl.message(
      'Recommendation',
      name: 'recommendation',
      desc: '',
      args: [],
    );
  }

  /// `Copied`
  String get copied {
    return Intl.message('Copied', name: 'copied', desc: '', args: []);
  }

  /// `Copy`
  String get copy {
    return Intl.message('Copy', name: 'copy', desc: '', args: []);
  }

  /// `Ask me anything about plant care...`
  String get askQuestion {
    return Intl.message(
      'Ask me anything about plant care...',
      name: 'askQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Plant Care Assistant`
  String get chatbotAssistant {
    return Intl.message(
      'Plant Care Assistant',
      name: 'chatbotAssistant',
      desc: '',
      args: [],
    );
  }

  /// `Mark all as read`
  String get markAllRead {
    return Intl.message(
      'Mark all as read',
      name: 'markAllRead',
      desc: '',
      args: [],
    );
  }

  /// `No notifications yet.`
  String get noNotifications {
    return Intl.message(
      'No notifications yet.',
      name: 'noNotifications',
      desc: '',
      args: [],
    );
  }

  /// `No history found.`
  String get noHistory {
    return Intl.message(
      'No history found.',
      name: 'noHistory',
      desc: '',
      args: [],
    );
  }

  /// `Email Address`
  String get emailLabel {
    return Intl.message(
      'Email Address',
      name: 'emailLabel',
      desc: '',
      args: [],
    );
  }

  /// `Not signed in`
  String get notSignedIn {
    return Intl.message(
      'Not signed in',
      name: 'notSignedIn',
      desc: '',
      args: [],
    );
  }

  /// `Account updated successfully.`
  String get updateAccount {
    return Intl.message(
      'Account updated successfully.',
      name: 'updateAccount',
      desc: '',
      args: [],
    );
  }

  /// `Reset Password`
  String get resetPassword {
    return Intl.message(
      'Reset Password',
      name: 'resetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Mute Notifications`
  String get muteNotifications {
    return Intl.message(
      'Mute Notifications',
      name: 'muteNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Disable all alerts and updates`
  String get muteNotificationsDescription {
    return Intl.message(
      'Disable all alerts and updates',
      name: 'muteNotificationsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Enable Sound`
  String get sound {
    return Intl.message('Enable Sound', name: 'sound', desc: '', args: []);
  }

  /// `Play notification sounds`
  String get soundDescription {
    return Intl.message(
      'Play notification sounds',
      name: 'soundDescription',
      desc: '',
      args: [],
    );
  }

  /// `New Soil Entry`
  String get soilEntryTitle {
    return Intl.message(
      'New Soil Entry',
      name: 'soilEntryTitle',
      desc: '',
      args: [],
    );
  }

  /// `pH`
  String get ph {
    return Intl.message('pH', name: 'ph', desc: '', args: []);
  }

  /// `Nitrogen (N)`
  String get nitrogen {
    return Intl.message('Nitrogen (N)', name: 'nitrogen', desc: '', args: []);
  }

  /// `Phosphorus (P)`
  String get phosphorus {
    return Intl.message(
      'Phosphorus (P)',
      name: 'phosphorus',
      desc: '',
      args: [],
    );
  }

  /// `Potassium (K)`
  String get potassium {
    return Intl.message('Potassium (K)', name: 'potassium', desc: '', args: []);
  }

  /// `History`
  String get history {
    return Intl.message('History', name: 'history', desc: '', args: []);
  }

  /// `Crop`
  String get crop {
    return Intl.message('Crop', name: 'crop', desc: '', args: []);
  }

  /// `Acidic`
  String get acidic {
    return Intl.message('Acidic', name: 'acidic', desc: '', args: []);
  }

  /// `Alkaline`
  String get alkaline {
    return Intl.message('Alkaline', name: 'alkaline', desc: '', args: []);
  }

  /// `Neutral`
  String get neutral {
    return Intl.message('Neutral', name: 'neutral', desc: '', args: []);
  }

  /// `Phone Number`
  String get phone {
    return Intl.message('Phone Number', name: 'phone', desc: '', args: []);
  }

  /// `Address`
  String get address {
    return Intl.message('Address', name: 'address', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ms'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
