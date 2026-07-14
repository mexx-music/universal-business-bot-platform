import 'package:flutter/material.dart';

class LandingHoverCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const LandingHoverCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.backgroundColor,
    this.onTap,
  });

  @override
  State<LandingHoverCard> createState() => _LandingHoverCardState();
}

class _LandingHoverCardState extends State<LandingHoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = widget.backgroundColor ?? theme.colorScheme.surface;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withAlpha(_hovered ? 24 : 10),
              blurRadius: _hovered ? 24 : 12,
              offset: Offset(0, _hovered ? 12 : 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}
