import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Custom widgets optimized for web interactions
class WebOptimizedWidgets {
  /// Hover-enabled card with smooth animations
  static Widget hoverCard({
    required Widget child,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    List<BoxShadow>? boxShadow,
    VoidCallback? onTap,
  }) {
    return _HoverCard(
      onTap: onTap,
      padding: padding ?? const EdgeInsets.all(16),
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      backgroundColor: backgroundColor ?? Colors.white,
      boxShadow: boxShadow,
      child: child,
    );
  }

  /// Hover-enabled button with scale animation
  static Widget hoverButton({
    required Widget child,
    required VoidCallback onPressed,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return _HoverButton(
      onPressed: onPressed,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      backgroundColor: backgroundColor ?? AppColors.primaryMedium,
      foregroundColor: foregroundColor ?? Colors.white,
      child: child,
    );
  }

  /// Custom scrollbar for web
  static Widget customScrollbar({
    required Widget child,
    ScrollController? controller,
  }) {
    return Scrollbar(
      controller: controller,
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 8,
      radius: const Radius.circular(4),
      child: child,
    );
  }
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const _HoverCard({
    required this.child,
    required this.padding,
    required this.borderRadius,
    required this.backgroundColor,
    this.boxShadow,
    this.onTap,
  });

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _elevationAnimation = Tween<double>(begin: 4, end: 8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _animationController.forward(),
      onExit: (_) => _animationController.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: widget.borderRadius,
                  boxShadow:
                      widget.boxShadow ??
                      [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: _elevationAnimation.value * 3,
                          offset: Offset(0, _elevationAnimation.value),
                        ),
                      ],
                ),
                child: widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Color foregroundColor;

  const _HoverButton({
    required this.child,
    required this.onPressed,
    required this.padding,
    required this.borderRadius,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _colorAnimation =
        ColorTween(
          begin: widget.backgroundColor,
          end: widget.backgroundColor.withValues(alpha: 0.8),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _animationController.forward(),
      onExit: (_) => _animationController.reverse(),
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: _colorAnimation.value,
                  borderRadius: widget.borderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DefaultTextStyle(
                  style: TextStyle(color: widget.foregroundColor),
                  child: widget.child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
