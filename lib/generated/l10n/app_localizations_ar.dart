// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'بوابة الإنجازات';

  @override
  String get healthCluster => 'تجمع جدة الصحي الثاني';

  @override
  String get welcome => 'مرحباً';

  @override
  String get portalAdministration => 'لوحة التحكم الإدارية';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get adminDashboard => 'لوحة تحكم المدير';

  @override
  String get mainDashboard => 'الواجهة الرئيسية';

  @override
  String get quickReview => 'مراجعة سريعة';

  @override
  String get achievementsManagement => 'إدارة الإنجازات';

  @override
  String get usersManagement => 'إدارة المستخدمين';

  @override
  String get reportsAndAnalytics => 'التقارير والتحليل';

  @override
  String get adminSettings => 'إعدادات المدير';

  @override
  String get systemSettings => 'إعدادات النظام';

  @override
  String get generalSettings => 'الإعدادات العامة';

  @override
  String get appearanceAndInterface => 'المظهر والواجهة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get securityAndProtection => 'الأمان والحماية';

  @override
  String get usersAndRoles => 'المستخدمين والأدوار';

  @override
  String get systemAndMaintenance => 'النظام والصيانة';

  @override
  String get integrationAndAPI => 'التكامل وواجهة برمجة التطبيقات';

  @override
  String get welcomeToDashboard => 'مرحباً بك في لوحة التحكم';

  @override
  String get trackAchievementsEasily => 'تتبع الإنجازات وإدارة النظام بسهولة';

  @override
  String get refreshData => 'تحديث البيانات';

  @override
  String get pendingAchievements => 'الإنجازات المعلقة';

  @override
  String get approvedAchievements => 'الإنجازات المعتمدة';

  @override
  String get rejectedAchievements => 'الإنجازات المرفوضة';

  @override
  String get totalAchievements => 'إجمالي الإنجازات';

  @override
  String get approved => 'معتمد';

  @override
  String get activeUsers => 'المستخدمين النشطين';

  @override
  String get mostActiveDepartments => 'أنشط الأقسام';

  @override
  String get pending => 'معلق';

  @override
  String get rejected => 'مرفوض';

  @override
  String get today => 'اليوم';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get departments => 'Departments';

  @override
  String get total => 'المجموع';

  @override
  String get quickFilter => 'Quick Filter';

  @override
  String get all => 'الكل';

  @override
  String get urgentOnly => 'Urgent Only';

  @override
  String get sortBy => 'Sort By';

  @override
  String get date => 'التاريخ';

  @override
  String get department => 'الإدارة';

  @override
  String get priority => 'Priority';

  @override
  String get urgent => 'Urgent';

  @override
  String get medium => 'Medium';

  @override
  String get newItem => 'New';

  @override
  String get mediumPriority => 'Medium Priority';

  @override
  String daysPassed(String count, String days) {
    return '$count $days passed';
  }

  @override
  String get day => 'day';

  @override
  String get days => 'days';

  @override
  String get searchInTopicGoalDepartment =>
      'Search in topic, goal, department...';

  @override
  String get advancedFilters => 'Advanced Filters';

  @override
  String get status => 'الحالة';

  @override
  String get allStatuses => 'All Statuses';

  @override
  String get allDepartments => 'All Departments';

  @override
  String get humanResources => 'Human Resources';

  @override
  String get informationTechnology => 'Information Technology';

  @override
  String get finance => 'Finance';

  @override
  String get medical => 'Medical';

  @override
  String get administrative => 'Administrative';

  @override
  String get nursing => 'Nursing';

  @override
  String get selectDateRange => 'Select Date Range';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get achievementDetails => 'Achievement Details';

  @override
  String get topic => 'Topic';

  @override
  String get goal => 'الهدف';

  @override
  String get participationType => 'Participation Type';

  @override
  String get executiveDepartment => 'الإدارة التنفيذية';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get edit => 'تعديل';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusUndefined => 'Undefined';

  @override
  String get exportToExcel => 'Export to Excel';

  @override
  String get exportToCSV => 'Export to CSV';

  @override
  String get printReport => 'Print Report';

  @override
  String get weeklyReport => 'Weekly Report';

  @override
  String get monthlyReport => 'Monthly Report';

  @override
  String get yearlyReport => 'Yearly Report';

  @override
  String get exportReport => 'Export Report';

  @override
  String get achievementsTrend => 'Achievements Trend';

  @override
  String get achievementsStatusDistribution =>
      'Achievements Status Distribution';

  @override
  String get achievementsByDepartment => 'Achievements by Department';

  @override
  String get choosePeriodToShowAnalytics =>
      'Choose report period to show analytics';

  @override
  String get detailedStatistics => 'Detailed Statistics';

  @override
  String get approvalRate => 'Approval Rate';

  @override
  String get annualGrowthRate => 'Annual Growth Rate';

  @override
  String get totalUsers => 'Total Users';

  @override
  String get timePeriod => 'Time Period';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get platformSettingsManagement =>
      'Platform settings management and advanced features control';

  @override
  String get language => 'اللغة';

  @override
  String get chooseSystemLanguage => 'Choose system interface language';

  @override
  String get appearance => 'Appearance';

  @override
  String get chooseAppearanceStyle =>
      'Choose appearance style (applies immediately)';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get automatic => 'Automatic';

  @override
  String get sessionTimeout => 'Session Timeout';

  @override
  String get sessionTimeoutDescription =>
      'Duration to stay in system without activity (in minutes)';

  @override
  String get defaultUserRole => 'Default role for new users';

  @override
  String get defaultUserRoleDescription =>
      'Role automatically assigned to new users';

  @override
  String get regularUser => 'Regular User';

  @override
  String get moderator => 'Moderator';

  @override
  String get admin => 'المدير';

  @override
  String get appearanceStyle => 'Appearance Style';

  @override
  String get appearanceStyleDescription =>
      'Choose preferred display style (applies immediately)';

  @override
  String get darkMode => 'داكن';

  @override
  String get darkModeDescription =>
      'Enable/disable dark appearance (quick toggle)';

  @override
  String get languageSettingsTitle => 'Language Settings';

  @override
  String get currentTheme => 'Current Theme';

  @override
  String get currentThemeDescription => 'Currently applied style';

  @override
  String get systemColors => 'System Colors';

  @override
  String get systemColorsDescription => 'Preview of colors used in the system';

  @override
  String get primaryColors => 'Primary Colors';

  @override
  String get primary => 'Primary';

  @override
  String get surfaceColors => 'Surface Colors';

  @override
  String get background => 'Background';

  @override
  String get cards => 'Cards';

  @override
  String get fontSize => 'Font Size';

  @override
  String get fontSizeDescription => 'Customize font size in the system';

  @override
  String get small => 'Small';

  @override
  String get large => 'Large';

  @override
  String get quickThemeChange => 'Quick Theme Change';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get emailNotifications => 'Email Notifications';

  @override
  String get emailNotificationsDescription =>
      'Receive important notifications via email';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotificationsDescription =>
      'Receive instant notifications when important events occur';

  @override
  String get notificationTypes => 'Notification Types';

  @override
  String get newAchievement => 'New Achievement';

  @override
  String get achievementStatusUpdate => 'Achievement Status Update';

  @override
  String get newUser => 'New User';

  @override
  String get monthlyReport2 => 'Monthly Report';

  @override
  String get twoFactorAuthentication => 'Two Factor Authentication';

  @override
  String get twoFactorAuthDescription =>
      'Enable two factor authentication for extra protection';

  @override
  String get auditLog => 'Audit Log';

  @override
  String get auditLogDescription =>
      'Log all important operations in the system';

  @override
  String get passwordPolicy => 'Password Policy';

  @override
  String get securityActions => 'Security Actions';

  @override
  String get autoAchievementApproval => 'Auto Achievement Approval';

  @override
  String get autoAchievementApprovalDescription =>
      'Approve achievements automatically without review';

  @override
  String get modulePermissions => 'Module Permissions';

  @override
  String get userManagementActions => 'User Management Actions';

  @override
  String get maintenanceMode => 'Maintenance Mode';

  @override
  String get maintenanceModeDescription =>
      'Enable maintenance mode to prevent user access';

  @override
  String get automaticBackup => 'Automatic Backup';

  @override
  String get automaticBackupDescription => 'Enable automatic data backup';

  @override
  String get backupFrequency => 'Backup Frequency';

  @override
  String get backupFrequencyDescription => 'Set backup creation frequency';

  @override
  String get hourly => 'Hourly';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get maxFileSize => 'Maximum File Size';

  @override
  String get maxFileSizeDescription =>
      'Maximum size for uploaded files (in megabytes)';

  @override
  String get systemActions => 'System Actions';

  @override
  String get apiToken => 'API Token';

  @override
  String get apiTokenDescription =>
      'API key for integration with external systems';

  @override
  String get externalIntegrations => 'External Integrations';

  @override
  String get webhookSettings => 'Webhook Settings';

  @override
  String get manageWebhooks => 'Manage Webhooks';

  @override
  String get settingsCategories => 'Settings Categories';

  @override
  String get chooseSettingsCategory => 'Choose Settings Category';

  @override
  String currentThemeDisplay(String theme) {
    return 'Theme: $theme';
  }

  @override
  String switchedToTheme(String theme) {
    return 'Switched to $theme theme';
  }

  @override
  String get settingsSavedSuccessfully => 'Settings saved successfully';

  @override
  String get exportReportFeatureSoon =>
      'Export report feature will be added soon';

  @override
  String themeChangedTo(String theme) {
    return 'Theme changed to $theme';
  }

  @override
  String themeChangeError(String error) {
    return 'Error changing theme: $error';
  }

  @override
  String get systemInformation => 'System Information';

  @override
  String get version => 'الإصدار';

  @override
  String get lastUpdate => 'Last Update: 2025-08-07';

  @override
  String get database => 'Database: Firebase';

  @override
  String get server => 'Server: Google Cloud';

  @override
  String get close => 'إغلاق';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get delete => 'حذف';

  @override
  String get view => 'عرض';

  @override
  String get responseRate => 'Response Rate';

  @override
  String get userSatisfaction => 'User Satisfaction';

  @override
  String get efficiency => 'Efficiency';

  @override
  String get averageReviewTime => 'Average Review Time';

  @override
  String get monthlyCompletionRate => 'Monthly Completion Rate';

  @override
  String get overdueAchievements => 'Overdue Achievements';

  @override
  String get qualityLevel => 'Quality Level';

  @override
  String get clearCacheSuccessfully => 'Cache cleared successfully';

  @override
  String get creatingBackup => 'Creating backup...';

  @override
  String get exportingUserList => 'Exporting user list...';

  @override
  String get navigateToUserManagement => 'Navigate to User Management';

  @override
  String get exportUserReport => 'Export User Report';

  @override
  String get regenerateApiToken => 'Regenerate API Token';

  @override
  String get regenerateApiTokenConfirm =>
      'This will invalidate the current key. Do you want to continue?';

  @override
  String get general => 'General';

  @override
  String get security => 'Security';

  @override
  String get users => 'المستخدمون';

  @override
  String get system => 'System';

  @override
  String get integration => 'Integration';
}
