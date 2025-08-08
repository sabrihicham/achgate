import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
    Locale('en')
  ];

  /// Main application title
  ///
  /// In en, this message translates to:
  /// **'Achievements Portal'**
  String get appTitle;

  /// Health cluster name
  ///
  /// In en, this message translates to:
  /// **'Jeddah Health Cluster II'**
  String get healthCluster;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Admin Dashboard
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get portalAdministration;

  /// Login
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Logout
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Admin Dashboard
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// Main Dashboard
  ///
  /// In en, this message translates to:
  /// **'Main Dashboard'**
  String get mainDashboard;

  /// Quick Review
  ///
  /// In en, this message translates to:
  /// **'Quick Review'**
  String get quickReview;

  /// Achievements Management
  ///
  /// In en, this message translates to:
  /// **'Achievements Management'**
  String get achievementsManagement;

  /// Users Management
  ///
  /// In en, this message translates to:
  /// **'Users Management'**
  String get usersManagement;

  /// Reports and Analytics
  ///
  /// In en, this message translates to:
  /// **'Reports and Analytics'**
  String get reportsAndAnalytics;

  /// Admin Settings
  ///
  /// In en, this message translates to:
  /// **'Admin Settings'**
  String get adminSettings;

  /// System Settings
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get systemSettings;

  /// General Settings
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// Appearance and Interface
  ///
  /// In en, this message translates to:
  /// **'Appearance and Interface'**
  String get appearanceAndInterface;

  /// Notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Security and Protection
  ///
  /// In en, this message translates to:
  /// **'Security and Protection'**
  String get securityAndProtection;

  /// Users and Roles
  ///
  /// In en, this message translates to:
  /// **'Users and Roles'**
  String get usersAndRoles;

  /// System and Maintenance
  ///
  /// In en, this message translates to:
  /// **'System and Maintenance'**
  String get systemAndMaintenance;

  /// Integration and API
  ///
  /// In en, this message translates to:
  /// **'Integration and API'**
  String get integrationAndAPI;

  /// Welcome to Dashboard
  ///
  /// In en, this message translates to:
  /// **'Welcome to Dashboard'**
  String get welcomeToDashboard;

  /// Track achievements and manage system easily
  ///
  /// In en, this message translates to:
  /// **'Track achievements and manage system easily'**
  String get trackAchievementsEasily;

  /// Refresh Data
  ///
  /// In en, this message translates to:
  /// **'Refresh Data'**
  String get refreshData;

  /// Pending Achievements
  ///
  /// In en, this message translates to:
  /// **'Pending Achievements'**
  String get pendingAchievements;

  /// Approved Achievements
  ///
  /// In en, this message translates to:
  /// **'Approved Achievements'**
  String get approvedAchievements;

  /// Rejected Achievements
  ///
  /// In en, this message translates to:
  /// **'Rejected Achievements'**
  String get rejectedAchievements;

  /// Total Achievements
  ///
  /// In en, this message translates to:
  /// **'Total Achievements'**
  String get totalAchievements;

  /// Approved
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// Active Users
  ///
  /// In en, this message translates to:
  /// **'Active Users'**
  String get activeUsers;

  /// Most Active Departments
  ///
  /// In en, this message translates to:
  /// **'Most Active Departments'**
  String get mostActiveDepartments;

  /// Pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Rejected
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// Today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// This Week
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// Departments
  ///
  /// In en, this message translates to:
  /// **'Departments'**
  String get departments;

  /// Total
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Quick Filter
  ///
  /// In en, this message translates to:
  /// **'Quick Filter'**
  String get quickFilter;

  /// All
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Urgent Only
  ///
  /// In en, this message translates to:
  /// **'Urgent Only'**
  String get urgentOnly;

  /// Sort By
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// Date
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Department
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// Priority
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// Urgent
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// Medium
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// New
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newItem;

  /// Medium Priority
  ///
  /// In en, this message translates to:
  /// **'Medium Priority'**
  String get mediumPriority;

  /// Number of days passed
  ///
  /// In en, this message translates to:
  /// **'{count} {days} passed'**
  String daysPassed(String count, String days);

  /// day
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// days
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Search in topic, goal, department...
  ///
  /// In en, this message translates to:
  /// **'Search in topic, goal, department...'**
  String get searchInTopicGoalDepartment;

  /// Advanced Filters
  ///
  /// In en, this message translates to:
  /// **'Advanced Filters'**
  String get advancedFilters;

  /// Status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// All Statuses
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get allStatuses;

  /// All Departments
  ///
  /// In en, this message translates to:
  /// **'All Departments'**
  String get allDepartments;

  /// Human Resources
  ///
  /// In en, this message translates to:
  /// **'Human Resources'**
  String get humanResources;

  /// Information Technology
  ///
  /// In en, this message translates to:
  /// **'Information Technology'**
  String get informationTechnology;

  /// Finance
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// Medical
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get medical;

  /// Administrative
  ///
  /// In en, this message translates to:
  /// **'Administrative'**
  String get administrative;

  /// Nursing
  ///
  /// In en, this message translates to:
  /// **'Nursing'**
  String get nursing;

  /// Select Date Range
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// Apply Filters
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// Clear Filters
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// Achievement Details
  ///
  /// In en, this message translates to:
  /// **'Achievement Details'**
  String get achievementDetails;

  /// Topic
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get topic;

  /// Goal
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// Participation Type
  ///
  /// In en, this message translates to:
  /// **'Participation Type'**
  String get participationType;

  /// Executive Department
  ///
  /// In en, this message translates to:
  /// **'Executive Department'**
  String get executiveDepartment;

  /// Approve
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// Reject
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// Edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// Approved
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// Rejected
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// Undefined
  ///
  /// In en, this message translates to:
  /// **'Undefined'**
  String get statusUndefined;

  /// Export to Excel
  ///
  /// In en, this message translates to:
  /// **'Export to Excel'**
  String get exportToExcel;

  /// Export to CSV
  ///
  /// In en, this message translates to:
  /// **'Export to CSV'**
  String get exportToCSV;

  /// Print Report
  ///
  /// In en, this message translates to:
  /// **'Print Report'**
  String get printReport;

  /// Weekly Report
  ///
  /// In en, this message translates to:
  /// **'Weekly Report'**
  String get weeklyReport;

  /// Monthly Report
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get monthlyReport;

  /// Yearly Report
  ///
  /// In en, this message translates to:
  /// **'Yearly Report'**
  String get yearlyReport;

  /// Export Report
  ///
  /// In en, this message translates to:
  /// **'Export Report'**
  String get exportReport;

  /// Achievements Trend
  ///
  /// In en, this message translates to:
  /// **'Achievements Trend'**
  String get achievementsTrend;

  /// Achievements Status Distribution
  ///
  /// In en, this message translates to:
  /// **'Achievements Status Distribution'**
  String get achievementsStatusDistribution;

  /// Achievements by Department
  ///
  /// In en, this message translates to:
  /// **'Achievements by Department'**
  String get achievementsByDepartment;

  /// Choose report period to show analytics
  ///
  /// In en, this message translates to:
  /// **'Choose report period to show analytics'**
  String get choosePeriodToShowAnalytics;

  /// Detailed Statistics
  ///
  /// In en, this message translates to:
  /// **'Detailed Statistics'**
  String get detailedStatistics;

  /// Approval Rate
  ///
  /// In en, this message translates to:
  /// **'Approval Rate'**
  String get approvalRate;

  /// Annual Growth Rate
  ///
  /// In en, this message translates to:
  /// **'Annual Growth Rate'**
  String get annualGrowthRate;

  /// Total Users
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// Time Period
  ///
  /// In en, this message translates to:
  /// **'Time Period'**
  String get timePeriod;

  /// Save Changes
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Platform settings management and advanced features control
  ///
  /// In en, this message translates to:
  /// **'Platform settings management and advanced features control'**
  String get platformSettingsManagement;

  /// Language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Choose system interface language
  ///
  /// In en, this message translates to:
  /// **'Choose system interface language'**
  String get chooseSystemLanguage;

  /// Appearance
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Choose appearance style (applies immediately)
  ///
  /// In en, this message translates to:
  /// **'Choose appearance style (applies immediately)'**
  String get chooseAppearanceStyle;

  /// Light
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Automatic
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automatic;

  /// Session Timeout
  ///
  /// In en, this message translates to:
  /// **'Session Timeout'**
  String get sessionTimeout;

  /// Duration to stay in system without activity (in minutes)
  ///
  /// In en, this message translates to:
  /// **'Duration to stay in system without activity (in minutes)'**
  String get sessionTimeoutDescription;

  /// Default role for new users
  ///
  /// In en, this message translates to:
  /// **'Default role for new users'**
  String get defaultUserRole;

  /// Role automatically assigned to new users
  ///
  /// In en, this message translates to:
  /// **'Role automatically assigned to new users'**
  String get defaultUserRoleDescription;

  /// Regular User
  ///
  /// In en, this message translates to:
  /// **'Regular User'**
  String get regularUser;

  /// Moderator
  ///
  /// In en, this message translates to:
  /// **'Moderator'**
  String get moderator;

  /// Admin
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// Appearance Style
  ///
  /// In en, this message translates to:
  /// **'Appearance Style'**
  String get appearanceStyle;

  /// Choose preferred display style (applies immediately)
  ///
  /// In en, this message translates to:
  /// **'Choose preferred display style (applies immediately)'**
  String get appearanceStyleDescription;

  /// Dark Mode
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Enable/disable dark appearance (quick toggle)
  ///
  /// In en, this message translates to:
  /// **'Enable/disable dark appearance (quick toggle)'**
  String get darkModeDescription;

  /// Language Settings
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettingsTitle;

  /// Current Theme
  ///
  /// In en, this message translates to:
  /// **'Current Theme'**
  String get currentTheme;

  /// Currently applied style
  ///
  /// In en, this message translates to:
  /// **'Currently applied style'**
  String get currentThemeDescription;

  /// System Colors
  ///
  /// In en, this message translates to:
  /// **'System Colors'**
  String get systemColors;

  /// Preview of colors used in the system
  ///
  /// In en, this message translates to:
  /// **'Preview of colors used in the system'**
  String get systemColorsDescription;

  /// Primary Colors
  ///
  /// In en, this message translates to:
  /// **'Primary Colors'**
  String get primaryColors;

  /// Primary
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primary;

  /// Surface Colors
  ///
  /// In en, this message translates to:
  /// **'Surface Colors'**
  String get surfaceColors;

  /// Background
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// Cards
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cards;

  /// Font Size
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// Customize font size in the system
  ///
  /// In en, this message translates to:
  /// **'Customize font size in the system'**
  String get fontSizeDescription;

  /// Small
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// Large
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// Quick Theme Change
  ///
  /// In en, this message translates to:
  /// **'Quick Theme Change'**
  String get quickThemeChange;

  /// Notification Settings
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Email Notifications
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// Receive important notifications via email
  ///
  /// In en, this message translates to:
  /// **'Receive important notifications via email'**
  String get emailNotificationsDescription;

  /// Push Notifications
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// Receive instant notifications when important events occur
  ///
  /// In en, this message translates to:
  /// **'Receive instant notifications when important events occur'**
  String get pushNotificationsDescription;

  /// Notification Types
  ///
  /// In en, this message translates to:
  /// **'Notification Types'**
  String get notificationTypes;

  /// New Achievement
  ///
  /// In en, this message translates to:
  /// **'New Achievement'**
  String get newAchievement;

  /// Achievement Status Update
  ///
  /// In en, this message translates to:
  /// **'Achievement Status Update'**
  String get achievementStatusUpdate;

  /// New User
  ///
  /// In en, this message translates to:
  /// **'New User'**
  String get newUser;

  /// Monthly Report
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get monthlyReport2;

  /// Two Factor Authentication
  ///
  /// In en, this message translates to:
  /// **'Two Factor Authentication'**
  String get twoFactorAuthentication;

  /// Enable two factor authentication for extra protection
  ///
  /// In en, this message translates to:
  /// **'Enable two factor authentication for extra protection'**
  String get twoFactorAuthDescription;

  /// Audit Log
  ///
  /// In en, this message translates to:
  /// **'Audit Log'**
  String get auditLog;

  /// Log all important operations in the system
  ///
  /// In en, this message translates to:
  /// **'Log all important operations in the system'**
  String get auditLogDescription;

  /// Password Policy
  ///
  /// In en, this message translates to:
  /// **'Password Policy'**
  String get passwordPolicy;

  /// Security Actions
  ///
  /// In en, this message translates to:
  /// **'Security Actions'**
  String get securityActions;

  /// Auto Achievement Approval
  ///
  /// In en, this message translates to:
  /// **'Auto Achievement Approval'**
  String get autoAchievementApproval;

  /// Approve achievements automatically without review
  ///
  /// In en, this message translates to:
  /// **'Approve achievements automatically without review'**
  String get autoAchievementApprovalDescription;

  /// Module Permissions
  ///
  /// In en, this message translates to:
  /// **'Module Permissions'**
  String get modulePermissions;

  /// User Management Actions
  ///
  /// In en, this message translates to:
  /// **'User Management Actions'**
  String get userManagementActions;

  /// Maintenance Mode
  ///
  /// In en, this message translates to:
  /// **'Maintenance Mode'**
  String get maintenanceMode;

  /// Enable maintenance mode to prevent user access
  ///
  /// In en, this message translates to:
  /// **'Enable maintenance mode to prevent user access'**
  String get maintenanceModeDescription;

  /// Automatic Backup
  ///
  /// In en, this message translates to:
  /// **'Automatic Backup'**
  String get automaticBackup;

  /// Enable automatic data backup
  ///
  /// In en, this message translates to:
  /// **'Enable automatic data backup'**
  String get automaticBackupDescription;

  /// Backup Frequency
  ///
  /// In en, this message translates to:
  /// **'Backup Frequency'**
  String get backupFrequency;

  /// Set backup creation frequency
  ///
  /// In en, this message translates to:
  /// **'Set backup creation frequency'**
  String get backupFrequencyDescription;

  /// Hourly
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get hourly;

  /// Daily
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// Weekly
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// Monthly
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Maximum File Size
  ///
  /// In en, this message translates to:
  /// **'Maximum File Size'**
  String get maxFileSize;

  /// Maximum size for uploaded files (in megabytes)
  ///
  /// In en, this message translates to:
  /// **'Maximum size for uploaded files (in megabytes)'**
  String get maxFileSizeDescription;

  /// System Actions
  ///
  /// In en, this message translates to:
  /// **'System Actions'**
  String get systemActions;

  /// API Token
  ///
  /// In en, this message translates to:
  /// **'API Token'**
  String get apiToken;

  /// API key for integration with external systems
  ///
  /// In en, this message translates to:
  /// **'API key for integration with external systems'**
  String get apiTokenDescription;

  /// External Integrations
  ///
  /// In en, this message translates to:
  /// **'External Integrations'**
  String get externalIntegrations;

  /// Webhook Settings
  ///
  /// In en, this message translates to:
  /// **'Webhook Settings'**
  String get webhookSettings;

  /// Manage Webhooks
  ///
  /// In en, this message translates to:
  /// **'Manage Webhooks'**
  String get manageWebhooks;

  /// Settings Categories
  ///
  /// In en, this message translates to:
  /// **'Settings Categories'**
  String get settingsCategories;

  /// Choose Settings Category
  ///
  /// In en, this message translates to:
  /// **'Choose Settings Category'**
  String get chooseSettingsCategory;

  /// Current theme display
  ///
  /// In en, this message translates to:
  /// **'Theme: {theme}'**
  String currentThemeDisplay(String theme);

  /// Switched to theme
  ///
  /// In en, this message translates to:
  /// **'Switched to {theme} theme'**
  String switchedToTheme(String theme);

  /// Settings saved successfully
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully'**
  String get settingsSavedSuccessfully;

  /// Export report feature will be added soon
  ///
  /// In en, this message translates to:
  /// **'Export report feature will be added soon'**
  String get exportReportFeatureSoon;

  /// Theme changed to
  ///
  /// In en, this message translates to:
  /// **'Theme changed to {theme}'**
  String themeChangedTo(String theme);

  /// Error changing theme
  ///
  /// In en, this message translates to:
  /// **'Error changing theme: {error}'**
  String themeChangeError(String error);

  /// System Information
  ///
  /// In en, this message translates to:
  /// **'System Information'**
  String get systemInformation;

  /// Version
  ///
  /// In en, this message translates to:
  /// **'Version: 1.0.0'**
  String get version;

  /// Last Update
  ///
  /// In en, this message translates to:
  /// **'Last Update: 2025-08-07'**
  String get lastUpdate;

  /// Database
  ///
  /// In en, this message translates to:
  /// **'Database: Firebase'**
  String get database;

  /// Server
  ///
  /// In en, this message translates to:
  /// **'Server: Google Cloud'**
  String get server;

  /// Close
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// View
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// Response Rate
  ///
  /// In en, this message translates to:
  /// **'Response Rate'**
  String get responseRate;

  /// User Satisfaction
  ///
  /// In en, this message translates to:
  /// **'User Satisfaction'**
  String get userSatisfaction;

  /// Efficiency
  ///
  /// In en, this message translates to:
  /// **'Efficiency'**
  String get efficiency;

  /// Average Review Time
  ///
  /// In en, this message translates to:
  /// **'Average Review Time'**
  String get averageReviewTime;

  /// Monthly Completion Rate
  ///
  /// In en, this message translates to:
  /// **'Monthly Completion Rate'**
  String get monthlyCompletionRate;

  /// Overdue Achievements
  ///
  /// In en, this message translates to:
  /// **'Overdue Achievements'**
  String get overdueAchievements;

  /// Quality Level
  ///
  /// In en, this message translates to:
  /// **'Quality Level'**
  String get qualityLevel;

  /// Cache cleared successfully
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get clearCacheSuccessfully;

  /// Creating backup...
  ///
  /// In en, this message translates to:
  /// **'Creating backup...'**
  String get creatingBackup;

  /// Exporting user list...
  ///
  /// In en, this message translates to:
  /// **'Exporting user list...'**
  String get exportingUserList;

  /// Navigate to User Management
  ///
  /// In en, this message translates to:
  /// **'Navigate to User Management'**
  String get navigateToUserManagement;

  /// Export User Report
  ///
  /// In en, this message translates to:
  /// **'Export User Report'**
  String get exportUserReport;

  /// Regenerate API Token
  ///
  /// In en, this message translates to:
  /// **'Regenerate API Token'**
  String get regenerateApiToken;

  /// This will invalidate the current key. Do you want to continue?
  ///
  /// In en, this message translates to:
  /// **'This will invalidate the current key. Do you want to continue?'**
  String get regenerateApiTokenConfirm;

  /// General
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// Security
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Users
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// System
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Integration
  ///
  /// In en, this message translates to:
  /// **'Integration'**
  String get integration;
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
      <String>['ar', 'en'].contains(locale.languageCode);

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
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
