import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'landing_section_header.dart';

enum _PreviewDevice { desktop, tablet, smartphone }

class LandingPreviewSection extends StatefulWidget {
  const LandingPreviewSection({super.key});

  @override
  State<LandingPreviewSection> createState() => _LandingPreviewSectionState();
}

class _LandingPreviewSectionState extends State<LandingPreviewSection> {
  _PreviewDevice _device = _PreviewDevice.desktop;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 54),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LandingSectionHeader(
            title: l.landingPreviewTitle,
            subtitle: l.landingPreviewSubtitle,
          ),
          const SizedBox(height: 22),
          SegmentedButton<_PreviewDevice>(
            segments: [
              ButtonSegment(
                value: _PreviewDevice.desktop,
                icon: const Icon(Icons.desktop_windows_rounded),
                label: Text(l.landingPreviewDesktop),
              ),
              ButtonSegment(
                value: _PreviewDevice.tablet,
                icon: const Icon(Icons.tablet_mac_rounded),
                label: Text(l.landingPreviewTablet),
              ),
              ButtonSegment(
                value: _PreviewDevice.smartphone,
                icon: const Icon(Icons.phone_iphone_rounded),
                label: Text(l.landingPreviewPhone),
              ),
            ],
            selected: {_device},
            onSelectionChanged: (selection) {
              setState(() => _device = selection.first);
            },
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeOutCubic,
            child: _DeviceMockup(key: ValueKey(_device), device: _device),
          ),
        ],
      ),
    );
  }
}

class _DeviceMockup extends StatelessWidget {
  final _PreviewDevice device;

  const _DeviceMockup({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPhone = device == _PreviewDevice.smartphone;
    final isTablet = device == _PreviewDevice.tablet;
    final width = isPhone
        ? 320.0
        : isTablet
        ? 640.0
        : double.infinity;
    final height = isPhone
        ? 600.0
        : isTablet
        ? 520.0
        : 460.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: Container(
          height: height,
          padding: EdgeInsets.all(isPhone ? 14 : 18),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(isPhone ? 34 : 28),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: isPhone ? 8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withAlpha(24),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: isPhone ? const _PhoneLayout() : _WideLayout(tablet: isTablet),
        ),
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  final bool tablet;

  const _WideLayout({required this.tablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: tablet ? 136 : 190,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(16),
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MockLine(width: tablet ? 78 : 110, strong: true),
              const SizedBox(height: 22),
              for (final icon in [
                Icons.dashboard_rounded,
                Icons.business_rounded,
                Icons.library_books_rounded,
                Icons.smart_toy_rounded,
                Icons.query_stats_rounded,
              ]) ...[
                Row(
                  children: [
                    Icon(icon, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 9),
                    Expanded(child: _MockLine(width: double.infinity)),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricTile(color: theme.colorScheme.tertiary),
                  ),
                  if (!tablet) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricTile(color: theme.colorScheme.secondary),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _Panel(
                        child: Column(
                          children: [
                            for (var i = 0; i < 5; i++) ...[
                              _ListRow(active: i == 1),
                              if (i < 4) const SizedBox(height: 12),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: _Panel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            _MockLine(width: 130, strong: true),
                            SizedBox(height: 18),
                            _ProgressBar(value: .78),
                            SizedBox(height: 18),
                            _ProgressBar(value: .54),
                            SizedBox(height: 18),
                            _ProgressBar(value: .36),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhoneLayout extends StatelessWidget {
  const _PhoneLayout();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 58,
          height: 5,
          decoration: BoxDecoration(
            color: theme.colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                Icons.hub_rounded,
                color: theme.colorScheme.onPrimary,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: _MockLine(width: double.infinity, strong: true),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _MetricTile(color: theme.colorScheme.primary),
        const SizedBox(height: 12),
        _MetricTile(color: theme.colorScheme.tertiary),
        const SizedBox(height: 16),
        const Expanded(
          child: _Panel(
            child: Column(
              children: [
                _ListRow(active: true),
                SizedBox(height: 12),
                _ListRow(active: false),
                SizedBox(height: 12),
                _ListRow(active: false),
                SizedBox(height: 18),
                _ProgressBar(value: .68),
                SizedBox(height: 16),
                _ProgressBar(value: .42),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final Color color;

  const _MetricTile({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withAlpha(42),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          _MockLine(width: 100, strong: true, color: color),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(150),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

class _ListRow extends StatelessWidget {
  final bool active;

  const _ListRow({required this.active});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: active
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MockLine(width: double.infinity, strong: true),
              SizedBox(height: 7),
              _MockLine(width: 120),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;

  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 10,
        color: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.outlineVariant.withAlpha(120),
      ),
    );
  }
}

class _MockLine extends StatelessWidget {
  final double width;
  final bool strong;
  final Color? color;

  const _MockLine({required this.width, this.strong = false, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: strong ? 10 : 8,
      decoration: BoxDecoration(
        color:
            color?.withAlpha(120) ??
            (strong
                ? theme.colorScheme.onSurface.withAlpha(42)
                : theme.colorScheme.outlineVariant.withAlpha(150)),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
