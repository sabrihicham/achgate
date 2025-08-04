import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_components.dart';
import '../services/achievement_service.dart';
import '../models/achievement.dart';
import 'edit_achievement_screen.dart';

class ViewAchievementsScreen extends StatefulWidget {
  const ViewAchievementsScreen({super.key});

  @override
  State<ViewAchievementsScreen> createState() => _ViewAchievementsScreenState();
}

class _ViewAchievementsScreenState extends State<ViewAchievementsScreen>
    with TickerProviderStateMixin {
  final AchievementService _achievementService = AchievementService();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _filterOptions = [
    {'value': 'all', 'label': 'جميع المنجزات', 'icon': Icons.list_alt},
    {'value': 'pending', 'label': 'معلقة', 'icon': Icons.hourglass_empty},
    {'value': 'approved', 'label': 'معتمدة', 'icon': Icons.check_circle},
    {'value': 'rejected', 'label': 'مرفوضة', 'icon': Icons.cancel},
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppComponents.appBar(
        title: 'منجزاتي',
        showBackButton: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            color: Colors.white,
            splashRadius: 20,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: _showSearchDialog,
              color: Colors.white,
              splashRadius: 20,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                children: [
                  _buildFilterChips(),
                  _buildAchievementsCount(),
                  Expanded(child: _buildAchievementsList()),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/add-achievement'),
        backgroundColor: AppColors.primaryMedium,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('إضافة منجز'),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final option = _filterOptions[index];
          final isSelected = _selectedFilter == option['value'];

          return Container(
            margin: EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = option['value'];
                });
              },
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    option['icon'],
                    size: 18,
                    color: isSelected ? Colors.white : AppColors.primaryMedium,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    option['label'],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.primaryMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.white,
              selectedColor: AppColors.primaryMedium,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected ? AppColors.primaryMedium : AppColors.outline,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAchievementsCount() {
    return FutureBuilder<Map<String, int>>(
      future: _achievementService.getUserAchievementsCount(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final counts = snapshot.data!;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryLight.withOpacity(0.1),
                AppColors.primaryMedium.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCountItem('المجموع', counts['total']!, Icons.dashboard),
              _buildCountItem(
                'معلقة',
                counts['pending']!,
                Icons.hourglass_empty,
              ),
              _buildCountItem('معتمد', counts['approved']!, Icons.check_circle),
              _buildCountItem('مرفوض', counts['rejected']!, Icons.cancel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountItem(String label, int count, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryMedium, size: 24),
        SizedBox(height: AppSpacing.xs),
        Text(
          count.toString(),
          style: AppTypography.textTheme.headlineSmall!.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.textTheme.bodySmall!.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsList() {
    return StreamBuilder<List<Achievement>>(
      stream: _getFilteredAchievements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryMedium),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error.withOpacity(0.5),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'خطأ في تحميل المنجزات',
                  style: AppTypography.textTheme.headlineSmall,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  snapshot.error.toString(),
                  style: AppTypography.textTheme.bodyMedium!.copyWith(
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        final achievements = snapshot.data ?? [];

        if (achievements.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: EdgeInsets.all(AppSpacing.md),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return _buildAchievementCard(achievement, index);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_selectedFilter) {
      case 'pending':
        message = 'لا توجد منجزات معلقة';
        icon = Icons.hourglass_empty;
        break;
      case 'approved':
        message = 'لا توجد منجزات معتمدة';
        icon = Icons.check_circle_outline;
        break;
      case 'rejected':
        message = 'لا توجد منجزات مرفوضة';
        icon = Icons.cancel_outlined;
        break;
      default:
        message = 'لم تقم بإضافة أي منجزات بعد';
        icon = Icons.inbox_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.onSurfaceVariant.withOpacity(0.5),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            message,
            style: AppTypography.textTheme.headlineSmall!.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (_selectedFilter == 'all') ...[
            SizedBox(height: AppSpacing.md),
            Text(
              'ابدأ بإضافة منجزك الأول',
              style: AppTypography.textTheme.bodyMedium!.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/add-achievement'),
              icon: const Icon(Icons.add),
              label: const Text('إضافة منجز جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMedium,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => _showAchievementDetails(achievement),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildStatusChip(achievement.status),
                          const Spacer(),
                          _buildAchievementMenu(achievement),
                        ],
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        achievement.participationType,
                        style: AppTypography.textTheme.labelLarge!.copyWith(
                          color: AppColors.primaryMedium,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        achievement.topic,
                        style: AppTypography.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Icon(
                            Icons.business,
                            size: 16,
                            color: AppColors.onSurfaceVariant,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              '${achievement.executiveDepartment} - ${achievement.mainDepartment}',
                              style: AppTypography.textTheme.bodySmall!
                                  .copyWith(color: AppColors.onSurfaceVariant),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppColors.onSurfaceVariant,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            '${achievement.date.day}/${achievement.date.month}/${achievement.date.year}',
                            style: AppTypography.textTheme.bodySmall!.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.onSurfaceVariant,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            achievement.location,
                            style: AppTypography.textTheme.bodySmall!.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case 'approved':
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        label = 'معتمد';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        backgroundColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        label = 'مرفوض';
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        label = 'معلقة';
        icon = Icons.hourglass_empty;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.textTheme.labelSmall!.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementMenu(Achievement achievement) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleMenuAction(value, achievement),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility, size: 18),
              SizedBox(width: 8),
              Text('عرض التفاصيل'),
            ],
          ),
        ),
        if (achievement.status == 'pending')
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18),
                SizedBox(width: 8),
                Text('تعديل'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: AppColors.error),
              SizedBox(width: 8),
              Text('حذف', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
      child: const Icon(Icons.more_vert),
    );
  }

  Stream<List<Achievement>> _getFilteredAchievements() {
    if (_selectedFilter == 'all') {
      return _achievementService.getUserAchievements();
    } else {
      return _achievementService.getUserAchievementsByStatus(_selectedFilter);
    }
  }

  void _handleMenuAction(String action, Achievement achievement) {
    switch (action) {
      case 'view':
        _showAchievementDetails(achievement);
        break;
      case 'edit':
        _editAchievement(achievement);
        break;
      case 'delete':
        _confirmDelete(achievement);
        break;
    }
  }

  void _showAchievementDetails(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => _AchievementDetailsDialog(achievement: achievement),
    );
  }

  void _editAchievement(Achievement achievement) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditAchievementScreen(achievement: achievement),
      ),
    );
  }

  void _confirmDelete(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text(
          'هل أنت متأكد من حذف هذا المنجز؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => _deleteAchievement(achievement),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAchievement(Achievement achievement) async {
    Navigator.of(context).pop(); // Close confirmation dialog

    try {
      await _achievementService.deleteAchievement(achievement.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف المنجز بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حذف المنجز: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('البحث في المنجزات'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'ابحث في الموضوع أو الهدف...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            Navigator.of(context).pop();
            _performSearch(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performSearch(_searchController.text);
            },
            child: const Text('بحث'),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    // TODO: Implement search functionality
    // For now, just clear the search controller
    _searchController.clear();

    // In the future, implement search by updating the stream
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('البحث عن: $query'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}

class _AchievementDetailsDialog extends StatelessWidget {
  final Achievement achievement;

  const _AchievementDetailsDialog({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'تفاصيل المنجز',
                    style: AppTypography.textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              _buildDetailRow('نوع المشاركة', achievement.participationType),
              _buildDetailRow(
                'الإدارة التنفيذية',
                achievement.executiveDepartment,
              ),
              _buildDetailRow('الإدارة الرئيسية', achievement.mainDepartment),
              _buildDetailRow('الإدارة الفرعية', achievement.subDepartment),
              _buildDetailRow(
                'التاريخ',
                '${achievement.date.day}/${achievement.date.month}/${achievement.date.year}',
              ),
              _buildDetailRow('الموقع', achievement.location),
              _buildDetailRow('المدة', achievement.duration),
              _buildDetailRow('الموضوع', achievement.topic, isMultiline: true),
              _buildDetailRow('الهدف', achievement.goal, isMultiline: true),
              _buildDetailRow('الأثر', achievement.impact, isMultiline: true),
              if (achievement.attachments.isNotEmpty)
                _buildDetailRow(
                  'المرفقات',
                  achievement.attachments.join(', '),
                  isMultiline: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isMultiline = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.textTheme.labelMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryMedium,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.textTheme.bodyMedium,
            maxLines: isMultiline ? null : 1,
            overflow: isMultiline ? null : TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
