import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('ar'),
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'RecycleOrigin Driver'**
  String get appTitle;

  /// No description provided for @homeTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTabLabel;

  /// No description provided for @requestTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requestTabLabel;

  /// No description provided for @shopTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopTabLabel;

  /// No description provided for @profileTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTabLabel;

  /// No description provided for @exitDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit application'**
  String get exitDialogTitle;

  /// No description provided for @exitDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to exit the application?'**
  String get exitDialogMessage;

  /// No description provided for @noLabel.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noLabel;

  /// No description provided for @yesLabel.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesLabel;

  /// No description provided for @appBarTitle.
  ///
  /// In en, this message translates to:
  /// **'RecycleOrigin'**
  String get appBarTitle;

  /// No description provided for @statisticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsLabel;

  /// No description provided for @guideLabel.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get guideLabel;

  /// No description provided for @contactUsLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUsLabel;

  /// No description provided for @aboutUsLabel.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get aboutUsLabel;

  /// No description provided for @supportTicketsLabel.
  ///
  /// In en, this message translates to:
  /// **'Support tickets'**
  String get supportTicketsLabel;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get logoutConfirmMessage;

  /// No description provided for @navigationErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Navigation error: '**
  String get navigationErrorPrefix;

  /// No description provided for @signOutErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error signing out: '**
  String get signOutErrorPrefix;

  /// No description provided for @logoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutLabel;

  /// No description provided for @loginLabel.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginLabel;

  /// No description provided for @userProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get userProfileLabel;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeTitle;

  /// No description provided for @loginSuccessSnack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginSuccessSnack;

  /// No description provided for @logoutSuccessSnack.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been signed out'**
  String get logoutSuccessSnack;

  /// No description provided for @confirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmLabel;

  /// No description provided for @goToProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Please complete your profile information first.'**
  String get goToProfileDescription;

  /// No description provided for @dearUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Dear user'**
  String get dearUserTitle;

  /// No description provided for @logoutSuccessDescription.
  ///
  /// In en, this message translates to:
  /// **'You have successfully logged out.'**
  String get logoutSuccessDescription;

  /// No description provided for @warehouseDeliveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Warehouse delivery'**
  String get warehouseDeliveryLabel;

  /// No description provided for @collectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collectionLabel;

  /// No description provided for @walletLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletLabel;

  /// No description provided for @notLoggedInLabel.
  ///
  /// In en, this message translates to:
  /// **'You are not logged in.'**
  String get notLoggedInLabel;

  /// No description provided for @loginToAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Login to your account'**
  String get loginToAccountLabel;

  /// No description provided for @userProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'User profile'**
  String get userProfileTitle;

  /// No description provided for @personalInfoLabel.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInfoLabel;

  /// No description provided for @wasteManagementSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'Waste management system'**
  String get wasteManagementSystemTitle;

  /// No description provided for @loginErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Login error'**
  String get loginErrorTitle;

  /// No description provided for @connectionFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Connection failed.'**
  String get connectionFailedMessage;

  /// No description provided for @connectionRetryMessage.
  ///
  /// In en, this message translates to:
  /// **'Connection failed, please try again.'**
  String get connectionRetryMessage;

  /// No description provided for @okLabel.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okLabel;

  /// No description provided for @enterReceivedCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter the received code.'**
  String get enterReceivedCodeMessage;

  /// No description provided for @enterPhoneToLoginMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number to log in.'**
  String get enterPhoneToLoginMessage;

  /// No description provided for @enterPhoneValidationMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone number.'**
  String get enterPhoneValidationMessage;

  /// No description provided for @getVerificationCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Get verification code'**
  String get getVerificationCodeLabel;

  /// No description provided for @correctPhoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit phone number'**
  String get correctPhoneNumberLabel;

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'RecycleOrigin\nDriver app.'**
  String get splashTitle;

  /// No description provided for @splashVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Trial version 1.0'**
  String get splashVersionLabel;

  /// No description provided for @aboutStoreLabel.
  ///
  /// In en, this message translates to:
  /// **'About store'**
  String get aboutStoreLabel;

  /// No description provided for @returnPolicyLabel.
  ///
  /// In en, this message translates to:
  /// **'Return policy'**
  String get returnPolicyLabel;

  /// No description provided for @privacyPolicyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicyLabel;

  /// No description provided for @howToOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'How to order'**
  String get howToOrderLabel;

  /// No description provided for @faqLabel.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get faqLabel;

  /// No description provided for @paymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get paymentMethodLabel;

  /// No description provided for @loginPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Login page'**
  String get loginPageLabel;

  /// No description provided for @profilePageLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile page'**
  String get profilePageLabel;

  /// No description provided for @loginRequiredDescription.
  ///
  /// In en, this message translates to:
  /// **'You must log in to continue.'**
  String get loginRequiredDescription;

  /// No description provided for @completeProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Please complete your profile information to continue.'**
  String get completeProfileDescription;

  /// No description provided for @requestSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your request has been submitted successfully.'**
  String get requestSubmittedSuccess;

  /// No description provided for @requestDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Request details'**
  String get requestDetailTitle;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @weightKgLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKgLabel;

  /// No description provided for @priceTomanLabel.
  ///
  /// In en, this message translates to:
  /// **'Price (Toman)'**
  String get priceTomanLabel;

  /// No description provided for @noWasteToDeliver.
  ///
  /// In en, this message translates to:
  /// **'No waste to deliver.'**
  String get noWasteToDeliver;

  /// No description provided for @alreadyCollected.
  ///
  /// In en, this message translates to:
  /// **'Already collected!'**
  String get alreadyCollected;

  /// No description provided for @gotItLabel.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotItLabel;

  /// No description provided for @deliverLabel.
  ///
  /// In en, this message translates to:
  /// **'Deliver'**
  String get deliverLabel;

  /// No description provided for @deliverToWarehouseLabel.
  ///
  /// In en, this message translates to:
  /// **'Deliver to warehouse'**
  String get deliverToWarehouseLabel;

  /// No description provided for @countLabel.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get countLabel;

  /// No description provided for @countWithColon.
  ///
  /// In en, this message translates to:
  /// **'Count:'**
  String get countWithColon;

  /// No description provided for @ofLabel.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofLabel;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @noProductAvailable.
  ///
  /// In en, this message translates to:
  /// **'No product available.'**
  String get noProductAvailable;

  /// No description provided for @noRequestAvailable.
  ///
  /// In en, this message translates to:
  /// **'No request available.'**
  String get noRequestAvailable;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @customerWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer weight'**
  String get customerWeightLabel;

  /// No description provided for @deliveryWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery weight'**
  String get deliveryWeightLabel;

  /// No description provided for @noWasteAdded.
  ///
  /// In en, this message translates to:
  /// **'No waste added.'**
  String get noWasteAdded;

  /// No description provided for @noAccessLabel.
  ///
  /// In en, this message translates to:
  /// **'No access'**
  String get noAccessLabel;

  /// No description provided for @noneLabel.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneLabel;

  /// No description provided for @settlementRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Settlement request'**
  String get settlementRequestTitle;

  /// No description provided for @pointsLabel.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get pointsLabel;

  /// No description provided for @tomanLabel.
  ///
  /// In en, this message translates to:
  /// **'Toman'**
  String get tomanLabel;

  /// No description provided for @shebaNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Sheba number'**
  String get shebaNumberLabel;

  /// No description provided for @requestedAmountToman.
  ///
  /// In en, this message translates to:
  /// **'Requested amount (Toman)'**
  String get requestedAmountToman;

  /// No description provided for @requestListTitle.
  ///
  /// In en, this message translates to:
  /// **'Request list'**
  String get requestListTitle;

  /// No description provided for @enterShebaNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your Sheba number.'**
  String get enterShebaNumber;

  /// No description provided for @submitRequestLabel.
  ///
  /// In en, this message translates to:
  /// **'Submit request'**
  String get submitRequestLabel;

  /// No description provided for @transactionListTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction list'**
  String get transactionListTitle;

  /// No description provided for @forLabel.
  ///
  /// In en, this message translates to:
  /// **'For'**
  String get forLabel;

  /// No description provided for @amountTomanLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (Toman)'**
  String get amountTomanLabel;

  /// No description provided for @settlementRequestLabel.
  ///
  /// In en, this message translates to:
  /// **'Settlement request'**
  String get settlementRequestLabel;

  /// No description provided for @noTransactionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No transaction available.'**
  String get noTransactionAvailable;

  /// No description provided for @newAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'New address'**
  String get newAddressLabel;

  /// No description provided for @addressNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Address name'**
  String get addressNameLabel;

  /// No description provided for @areasLabel.
  ///
  /// In en, this message translates to:
  /// **'Areas:'**
  String get areasLabel;

  /// No description provided for @selectAreaMessage.
  ///
  /// In en, this message translates to:
  /// **'Please select the desired area.'**
  String get selectAreaMessage;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @noAreaSelected.
  ///
  /// In en, this message translates to:
  /// **'No area selected!'**
  String get noAreaSelected;

  /// No description provided for @personInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Person information'**
  String get personInfoTitle;

  /// No description provided for @specificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get specificationsLabel;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// No description provided for @userTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'User type'**
  String get userTypeLabel;

  /// No description provided for @userTypeColon.
  ///
  /// In en, this message translates to:
  /// **'User type:'**
  String get userTypeColon;

  /// No description provided for @provinceLabel.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get provinceLabel;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// No description provided for @postalCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get postalCodeLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @invalidCredentialsMessage.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Please try again.'**
  String get invalidCredentialsMessage;

  /// No description provided for @enterEmailValidationMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email.'**
  String get enterEmailValidationMessage;

  /// No description provided for @enterPasswordValidationMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get enterPasswordValidationMessage;

  /// No description provided for @authWelcomeBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBackTitle;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get authEmailInvalid;

  /// No description provided for @authOpenMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get authOpenMenuTooltip;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @vehicleTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle type'**
  String get vehicleTypeLabel;

  /// No description provided for @vehicleColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle color'**
  String get vehicleColorLabel;

  /// No description provided for @plateNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Plate number'**
  String get plateNumberLabel;

  /// No description provided for @infoEditedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Information has been updated.'**
  String get infoEditedSuccess;

  /// No description provided for @editProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileLabel;

  /// No description provided for @profileSaveFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not save profile. Please try again.'**
  String get profileSaveFailedMessage;

  /// No description provided for @profileNameRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first and last name.'**
  String get profileNameRequiredMessage;

  /// No description provided for @profileTypesListEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'The type list could not be loaded. You can still save; your current account type is used.'**
  String get profileTypesListEmptyHint;

  /// No description provided for @selectWarehouseLabel.
  ///
  /// In en, this message translates to:
  /// **'Select warehouse'**
  String get selectWarehouseLabel;

  /// No description provided for @selectWarehouseMessage.
  ///
  /// In en, this message translates to:
  /// **'Please select the desired warehouse.'**
  String get selectWarehouseMessage;

  /// No description provided for @kilogramLabel.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kilogramLabel;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortMostExpensive.
  ///
  /// In en, this message translates to:
  /// **'Most expensive'**
  String get sortMostExpensive;

  /// No description provided for @sortCheapest.
  ///
  /// In en, this message translates to:
  /// **'Cheapest'**
  String get sortCheapest;

  /// No description provided for @collectRequestStatusPendingAssignment.
  ///
  /// In en, this message translates to:
  /// **'Pending driver assignment'**
  String get collectRequestStatusPendingAssignment;

  /// No description provided for @collectRequestStatusPendingDriverAcceptance.
  ///
  /// In en, this message translates to:
  /// **'Pending driver acceptance'**
  String get collectRequestStatusPendingDriverAcceptance;

  /// No description provided for @collectRequestStatusDriverAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted by driver'**
  String get collectRequestStatusDriverAccepted;

  /// No description provided for @collectRequestStatusCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get collectRequestStatusCollected;

  /// No description provided for @collectRequestStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get collectRequestStatusCancelled;

  /// No description provided for @collectRequestStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get collectRequestStatusInProgress;

  /// No description provided for @collectAcceptLabel.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get collectAcceptLabel;

  /// No description provided for @collectRejectLabel.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get collectRejectLabel;

  /// No description provided for @collectAcceptedSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Request accepted. You can continue with this pickup.'**
  String get collectAcceptedSuccessMessage;

  /// No description provided for @collectAcceptedStateHint.
  ///
  /// In en, this message translates to:
  /// **'You have accepted this request. Update weights below when you collect.'**
  String get collectAcceptedStateHint;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @applicationLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Application language'**
  String get applicationLanguageLabel;

  /// No description provided for @englishLabel.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLabel;

  /// No description provided for @turkishLabel.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkishLabel;

  /// No description provided for @arabicLabel.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabicLabel;

  /// No description provided for @settingsScreenIntro.
  ///
  /// In en, this message translates to:
  /// **'Language updates apply immediately and are saved on this device.'**
  String get settingsScreenIntro;

  /// No description provided for @appInformationSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'App information'**
  String get appInformationSectionTitle;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @retryLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryLabel;

  /// No description provided for @collectTotalWeightColon.
  ///
  /// In en, this message translates to:
  /// **'Total weight:'**
  String get collectTotalWeightColon;

  /// No description provided for @collectPerKgColon.
  ///
  /// In en, this message translates to:
  /// **'Per kg:'**
  String get collectPerKgColon;

  /// No description provided for @collectTotalPriceColon.
  ///
  /// In en, this message translates to:
  /// **'Total price:'**
  String get collectTotalPriceColon;

  /// No description provided for @fieldRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a value.'**
  String get fieldRequiredValidation;

  /// No description provided for @transactionOperationWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get transactionOperationWithdrawal;

  /// No description provided for @transactionOperationDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get transactionOperationDeposit;

  /// No description provided for @collectRequestStatusPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Picked up'**
  String get collectRequestStatusPickedUp;

  /// No description provided for @confirmPickupLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Pickup'**
  String get confirmPickupLabel;

  /// No description provided for @confirmPickupTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Pickup'**
  String get confirmPickupTitle;

  /// No description provided for @confirmPickupMessage.
  ///
  /// In en, this message translates to:
  /// **'You are about to confirm that you have picked up all the waste items. Please verify the exact weights before confirming.'**
  String get confirmPickupMessage;

  /// No description provided for @confirmPickupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Pickup confirmed successfully.'**
  String get confirmPickupSuccess;

  /// No description provided for @cancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelLabel;

  /// No description provided for @wasteItemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Waste Items'**
  String get wasteItemsLabel;

  /// No description provided for @customerEstimateLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer estimate'**
  String get customerEstimateLabel;

  /// No description provided for @exactWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Exact weight (kg)'**
  String get exactWeightLabel;

  /// No description provided for @pickupSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup Summary'**
  String get pickupSummaryLabel;

  /// No description provided for @totalItemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total items'**
  String get totalItemsLabel;

  /// No description provided for @totalEstimatedWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated weight'**
  String get totalEstimatedWeightLabel;

  /// No description provided for @totalExactWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Exact weight'**
  String get totalExactWeightLabel;

  /// No description provided for @requestInfoLabel.
  ///
  /// In en, this message translates to:
  /// **'Request Info'**
  String get requestInfoLabel;

  /// No description provided for @scheduledTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Scheduled time'**
  String get scheduledTimeLabel;

  /// No description provided for @driverActionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get driverActionsLabel;

  /// No description provided for @requestPickedUpHint.
  ///
  /// In en, this message translates to:
  /// **'This request has been picked up. Waiting for admin approval.'**
  String get requestPickedUpHint;

  /// No description provided for @myRequestsLabel.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get myRequestsLabel;

  /// No description provided for @collectListSortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get collectListSortTooltip;

  /// No description provided for @collectListFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get collectListFilterTooltip;

  /// No description provided for @collectListSortSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort requests'**
  String get collectListSortSheetTitle;

  /// No description provided for @collectListFilterSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter by status'**
  String get collectListFilterSheetTitle;

  /// No description provided for @collectListSortNewestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get collectListSortNewestFirst;

  /// No description provided for @collectListSortOldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get collectListSortOldestFirst;

  /// No description provided for @collectListSortIdDesc.
  ///
  /// In en, this message translates to:
  /// **'Request ID (high to low)'**
  String get collectListSortIdDesc;

  /// No description provided for @collectListSortIdAsc.
  ///
  /// In en, this message translates to:
  /// **'Request ID (low to high)'**
  String get collectListSortIdAsc;

  /// No description provided for @collectListFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get collectListFilterAll;

  /// No description provided for @collectListFilterNeedsAction.
  ///
  /// In en, this message translates to:
  /// **'Needs your action'**
  String get collectListFilterNeedsAction;

  /// No description provided for @pickupLocationMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Pickup location'**
  String get pickupLocationMapTitle;

  /// No description provided for @openInMapsAppLabel.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get openInMapsAppLabel;

  /// No description provided for @openMapsAppFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open a maps app.'**
  String get openMapsAppFailed;

  /// No description provided for @pickupMapPreviewSemantics.
  ///
  /// In en, this message translates to:
  /// **'Pickup location map. Tap to open in your maps app.'**
  String get pickupMapPreviewSemantics;

  /// No description provided for @gpsCoordinatesLabel.
  ///
  /// In en, this message translates to:
  /// **'GPS'**
  String get gpsCoordinatesLabel;

  /// No description provided for @pickupLocationMarkerTitle.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickupLocationMarkerTitle;

  /// No description provided for @mapScreenMyLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get mapScreenMyLocation;

  /// No description provided for @openStreetMapAttributionShort.
  ///
  /// In en, this message translates to:
  /// **'OpenStreetMap'**
  String get openStreetMapAttributionShort;

  /// No description provided for @driverSessionDateCaption.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get driverSessionDateCaption;

  /// No description provided for @driverSessionTimeCaption.
  ///
  /// In en, this message translates to:
  /// **'Device time'**
  String get driverSessionTimeCaption;

  /// No description provided for @driverSessionHeaderSemantic.
  ///
  /// In en, this message translates to:
  /// **'Date {date}, device time {time}'**
  String driverSessionHeaderSemantic(String date, String time);

  /// No description provided for @customerAverageRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer average rating'**
  String get customerAverageRatingLabel;

  /// No description provided for @rateCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate this customer'**
  String get rateCustomerTitle;

  /// No description provided for @rateCustomerHint.
  ///
  /// In en, this message translates to:
  /// **'How was this pickup experience with the customer?'**
  String get rateCustomerHint;

  /// No description provided for @ratingCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get ratingCommentLabel;

  /// No description provided for @submitRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Submit rating'**
  String get submitRatingLabel;

  /// No description provided for @yourRatingSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback'**
  String get yourRatingSubmitted;

  /// No description provided for @ratingsSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get ratingsSectionLabel;

  /// No description provided for @authForgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPasswordLink;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authOrDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOrDivider;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the email address linked to your account and we\'ll send you instructions to reset your password.'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authForgotPasswordSendButton.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get authForgotPasswordSendButton;

  /// No description provided for @authForgotPasswordSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get authForgotPasswordSentTitle;

  /// No description provided for @authForgotPasswordSentBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent password-reset instructions to {email}. Follow the link in the email to choose a new password.'**
  String authForgotPasswordSentBody(String email);

  /// No description provided for @authBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBackToLogin;

  /// No description provided for @authVerifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get authVerifyEmailTitle;

  /// No description provided for @authVerifyEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification link to {email}. Please open the link to activate your account.'**
  String authVerifyEmailSubtitle(String email);

  /// No description provided for @authVerifyEmailIveVerified.
  ///
  /// In en, this message translates to:
  /// **'I\'ve verified'**
  String get authVerifyEmailIveVerified;

  /// No description provided for @authVerifyEmailResend.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get authVerifyEmailResend;

  /// No description provided for @authVerifyEmailResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String authVerifyEmailResendIn(int seconds);

  /// No description provided for @authVerifyEmailNotYet.
  ///
  /// In en, this message translates to:
  /// **'Your email is still not verified. Please check your inbox.'**
  String get authVerifyEmailNotYet;

  /// No description provided for @authVerifyEmailResentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification email resent.'**
  String get authVerifyEmailResentSuccess;

  /// No description provided for @authVerifyEmailLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authVerifyEmailLogout;

  /// No description provided for @authGoogleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get authGoogleSignInFailed;

  /// No description provided for @authNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get authNetworkError;

  /// No description provided for @authGenericError.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the request. Please try again.'**
  String get authGenericError;

  /// No description provided for @authEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get authEmailRequired;

  /// No description provided for @authEmailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get authEmailAlreadyRegistered;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get authPasswordTooShort;

  /// No description provided for @authRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authRegisterButton;

  /// No description provided for @authFirstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get authFirstNameRequired;

  /// No description provided for @authLastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name'**
  String get authLastNameRequired;

  /// No description provided for @authNotRegisteredPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get authNotRegisteredPrompt;

  /// No description provided for @authSwitchToLoginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get authSwitchToLoginPrompt;

  /// No description provided for @authCreateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authCreateAccountTitle;

  /// No description provided for @authSubtitleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your driver account.'**
  String get authSubtitleSignIn;

  /// No description provided for @authSubtitleSignUp.
  ///
  /// In en, this message translates to:
  /// **'Create an account to start delivering.'**
  String get authSubtitleSignUp;
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
      <String>['ar', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
