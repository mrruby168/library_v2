import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── Sidebar icon button ───────────────────────────────────────────────────────
class SidebarButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;
  final Color? activeColor;

  const SidebarButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isActive = false,
    this.activeColor,
  });

  @override
  State<SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<SidebarButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive
        ? (widget.activeColor ?? AppColors.gold)
        : _hovered
            ? AppColors.textPrimary
            : AppColors.textMuted;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: widget.isActive
                  ? (widget.activeColor ?? AppColors.gold).withOpacity(0.12)
                  : _hovered
                      ? AppColors.cardHover
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }

  IconData get icon => widget.icon;
}

// ── Hover list tile ───────────────────────────────────────────────────────────
class HoverTile extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isSelected;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const HoverTile({
    super.key,
    required this.child,
    this.onTap,
    this.isSelected = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  State<HoverTile> createState() => _HoverTileState();
}

class _HoverTileState extends State<HoverTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (widget.isSelected) {
      bg = AppColors.gold.withOpacity(0.12);
    } else if (_hovered) {
      bg = AppColors.cardHover;
    } else {
      bg = Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: widget.borderRadius,
            border: widget.isSelected
                ? Border(
                    left: BorderSide(color: AppColors.gold, width: 3),
                  )
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ── Small icon button ─────────────────────────────────────────────────────────
class SmallIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Color? color;
  final double size;

  const SmallIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.color,
    this.size = 16,
  });

  @override
  State<SmallIconButton> createState() => _SmallIconButtonState();
}

class _SmallIconButtonState extends State<SmallIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _hovered ? AppColors.cardHover : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              widget.icon,
              size: widget.size,
              color: widget.color ??
                  (_hovered ? AppColors.textPrimary : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Divider ───────────────────────────────────────────────────────────────────
class AppDivider extends StatelessWidget {
  final double indent;
  const AppDivider({super.key, this.indent = 0});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: AppColors.border,
      thickness: 1,
      height: 1,
      indent: indent,
    );
  }
}
