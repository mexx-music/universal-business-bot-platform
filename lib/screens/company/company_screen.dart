import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/label_helpers.dart';
import '../../models/business_rules.dart';
import '../../models/company.dart';
import '../../models/intake_invitation.dart';
import '../../models/product_or_service.dart';

class CompanyScreen extends StatelessWidget {
  const CompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final company = state.company;
    final rules = state.businessRules;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l.companyTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.companyCoreSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _SectionCard(
            title: l.companyProfileSection,
            icon: Icons.business_outlined,
            onEdit: () => _showProfileDialog(context, state),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(company: company),
                const SizedBox(height: 18),
                Text(company.shortDescription),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InfoChip(
                      icon: Icons.category_outlined,
                      label: company.category,
                    ),
                    _InfoChip(
                      icon: Icons.public,
                      label: company.country.isEmpty ? '-' : company.country,
                    ),
                    _InfoChip(
                      icon: Icons.translate,
                      label: company.primaryLanguage.toUpperCase(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _SectionCard(
            title: l.companyContactWebSection,
            icon: Icons.contact_mail_outlined,
            onEdit: () => _showContactDialog(context, state),
            child: Column(
              children: [
                _InfoRow(icon: Icons.language, label: company.website),
                _InfoRow(
                  icon: Icons.email_outlined,
                  label: company.supportEmail,
                ),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: company.supportPhone.isEmpty
                      ? '-'
                      : company.supportPhone,
                ),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: company.address,
                ),
              ],
            ),
          ),
          _SectionCard(
            title: l.companySocialSection,
            icon: Icons.share_outlined,
            onEdit: () => _showSocialDialog(context, state),
            child: company.socialLinks.isEmpty
                ? _EmptyText(text: l.companyNoSocialLinks)
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: company.socialLinks.entries
                        .where((entry) => entry.value.trim().isNotEmpty)
                        .map(
                          (entry) =>
                              _SocialChip(label: entry.key, url: entry.value),
                        )
                        .toList(),
                  ),
          ),
          _SectionCard(
            title: l.companyBusinessRulesSection,
            icon: Icons.rule_outlined,
            onEdit: () => _showBusinessRulesDialog(context, state),
            child: _BusinessRulesView(rules: rules),
          ),
          _SectionCard(
            title: l.companyInternalNotesSection,
            icon: Icons.sticky_note_2_outlined,
            onEdit: () => _showInternalNotesDialog(context, state),
            child: company.internalNotes.trim().isEmpty
                ? _EmptyText(text: l.companyNoInternalNotes)
                : Text(company.internalNotes),
          ),
          _SectionCard(
            title: l.companyIntakeInvitationSection,
            icon: Icons.mark_email_read_outlined,
            onEdit: () {},
            hideEditButton: true,
            child: _IntakeInvitationView(state: state),
          ),
          const SizedBox(height: 8),
          Text(
            l.companyProducts,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...state.products.map((p) => _ProductCard(product: p)),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context, AppState state) {
    showDialog<void>(
      context: context,
      builder: (_) => _EditProfileDialog(state: state),
    );
  }

  void _showContactDialog(BuildContext context, AppState state) {
    showDialog<void>(
      context: context,
      builder: (_) => _EditContactDialog(state: state),
    );
  }

  void _showSocialDialog(BuildContext context, AppState state) {
    showDialog<void>(
      context: context,
      builder: (_) => _EditSocialDialog(state: state),
    );
  }

  void _showBusinessRulesDialog(BuildContext context, AppState state) {
    showDialog<void>(
      context: context,
      builder: (_) => _EditBusinessRulesDialog(state: state),
    );
  }

  void _showInternalNotesDialog(BuildContext context, AppState state) {
    showDialog<void>(
      context: context,
      builder: (_) => _EditInternalNotesDialog(state: state),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final VoidCallback onEdit;
  final bool hideEditButton;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    required this.onEdit,
    this.hideEditButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!hideEditButton)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(l.btnEdit),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _IntakeInvitationView extends StatelessWidget {
  const _IntakeInvitationView({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final invitation = state.selectedIntakeInvitation;
    final link = state.selectedIntakeInvitationLink();
    final canWrite = state.canWriteWorkspace;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.companyIntakeInvitationDescription),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              avatar: Icon(_invitationStatusIcon(invitation?.status), size: 16),
              label: Text(_invitationStatusLabel(l, invitation?.status)),
            ),
            if (invitation != null)
              Chip(
                avatar: const Icon(Icons.lock_outline, size: 16),
                label: Text(l.companyIntakeInvitationTokenHint),
              ),
          ],
        ),
        if (link != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(link, style: theme.textTheme.bodySmall),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: !canWrite || invitation != null
                  ? null
                  : () async {
                      await state.createIntakeInvitation();
                    },
              icon: const Icon(Icons.add_link),
              label: Text(l.companyIntakeInvitationCreate),
            ),
            OutlinedButton.icon(
              onPressed: !canWrite || link == null
                  ? null
                  : () async {
                      await Clipboard.setData(ClipboardData(text: link));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l.companyIntakeInvitationCopied),
                          ),
                        );
                      }
                    },
              icon: const Icon(Icons.copy_outlined),
              label: Text(l.companyIntakeInvitationCopy),
            ),
            OutlinedButton.icon(
              onPressed: !canWrite || invitation == null
                  ? null
                  : () async {
                      await state.regenerateIntakeInvitation();
                    },
              icon: const Icon(Icons.refresh),
              label: Text(l.companyIntakeInvitationRegenerate),
            ),
            OutlinedButton.icon(
              onPressed: !canWrite || invitation?.isActive != true
                  ? null
                  : () async {
                      await state.deactivateIntakeInvitation();
                    },
              icon: const Icon(Icons.link_off_outlined),
              label: Text(l.companyIntakeInvitationDisable),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                await state.reloadWorkspaces();
              },
              icon: const Icon(Icons.sync_outlined),
              label: Text(l.companyIntakeInvitationRefresh),
            ),
          ],
        ),
      ],
    );
  }
}

String _invitationStatusLabel(
  AppLocalizations l,
  IntakeInvitationStatus? status,
) {
  return switch (status) {
    IntakeInvitationStatus.invited => l.companyIntakeInvitationStatusInvited,
    IntakeInvitationStatus.started => l.companyIntakeInvitationStatusStarted,
    IntakeInvitationStatus.partial => l.companyIntakeInvitationStatusPartial,
    IntakeInvitationStatus.completed =>
      l.companyIntakeInvitationStatusCompleted,
    IntakeInvitationStatus.disabled => l.companyIntakeInvitationStatusDisabled,
    null => l.companyIntakeInvitationStatusMissing,
  };
}

IconData _invitationStatusIcon(IntakeInvitationStatus? status) {
  return switch (status) {
    IntakeInvitationStatus.invited => Icons.mark_email_unread_outlined,
    IntakeInvitationStatus.started => Icons.play_circle_outline,
    IntakeInvitationStatus.partial => Icons.pending_actions_outlined,
    IntakeInvitationStatus.completed => Icons.check_circle_outline,
    IntakeInvitationStatus.disabled => Icons.link_off_outlined,
    null => Icons.link_outlined,
  };
}

class _Header extends StatelessWidget {
  final Company company;

  const _Header({required this.company});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.business,
            size: 28,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                company.companyName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                company.industry,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _SocialChip extends StatelessWidget {
  final String label;
  final String url;

  const _SocialChip({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxLabelWidth = screenWidth < 480 ? screenWidth - 112 : 360.0;
    return Chip(
      avatar: const Icon(Icons.link, size: 16),
      label: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxLabelWidth),
        child: Text(
          '$label · $url',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      labelStyle: theme.textTheme.labelSmall,
    );
  }
}

class _BusinessRulesView extends StatelessWidget {
  final BusinessRules rules;

  const _BusinessRulesView({required this.rules});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RuleBlock(title: l.companyBrandVoice, text: rules.brandVoice),
        _RuleList(title: l.companyDoNotSay, items: rules.doNotSay),
        _RuleList(
          title: l.companyAllowedSupportTopics,
          items: rules.allowedSupportTopics,
        ),
        _RuleBlock(
          title: l.companyEscalationNotes,
          text: rules.escalationNotes,
        ),
        if (rules.disclaimerText != null && rules.disclaimerText!.isNotEmpty)
          _RuleBlock(
            title: l.companyDisclaimerText,
            text: rules.disclaimerText!,
          ),
      ],
    );
  }
}

class _RuleBlock extends StatelessWidget {
  final String title;
  final String text;

  const _RuleBlock({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelLarge),
          const SizedBox(height: 3),
          Text(text.isEmpty ? '-' : text),
        ],
      ),
    );
  }
}

class _RuleList extends StatelessWidget {
  final String title;
  final List<String> items;

  const _RuleList({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          if (items.isEmpty)
            const Text('-')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) => Chip(label: Text(item))).toList(),
            ),
        ],
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  final String text;

  const _EmptyText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductOrService product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: product.type.color.withAlpha(30),
          child: Icon(product.type.icon, color: product.type.color, size: 20),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          product.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: product.type.color.withAlpha(20),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                productTypeLabel(context, product.type),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: product.type.color,
                ),
              ),
            ),
            if (product.price != null) ...[
              const SizedBox(height: 4),
              Text(
                '${product.price!.toStringAsFixed(0)} €',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final AppState state;

  const _EditProfileDialog({required this.state});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _name;
  late final TextEditingController _industry;
  late final TextEditingController _description;
  late final TextEditingController _country;
  late final TextEditingController _primaryLanguage;

  @override
  void initState() {
    super.initState();
    final c = widget.state.company;
    _name = TextEditingController(text: c.name);
    _industry = TextEditingController(text: c.industry);
    _description = TextEditingController(text: c.description);
    _country = TextEditingController(text: c.country);
    _primaryLanguage = TextEditingController(text: c.primaryLanguage);
  }

  @override
  void dispose() {
    _name.dispose();
    _industry.dispose();
    _description.dispose();
    _country.dispose();
    _primaryLanguage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return _EditDialogScaffold(
      title: l.companyProfileSection,
      children: [
        _field(l.fieldCompanyName, _name),
        _field(l.fieldIndustry, _industry),
        _field(l.fieldDescription, _description, maxLines: 4),
        _field(l.fieldCountry, _country),
        _field(l.fieldPrimaryLanguage, _primaryLanguage),
      ],
      onSave: () {
        widget.state.updateCompany(
          widget.state.company.copyWith(
            name: _name.text.trim(),
            industry: _industry.text.trim(),
            description: _description.text.trim(),
            country: _country.text.trim(),
            primaryLanguage: _primaryLanguage.text.trim(),
          ),
        );
      },
    );
  }
}

class _EditContactDialog extends StatefulWidget {
  final AppState state;

  const _EditContactDialog({required this.state});

  @override
  State<_EditContactDialog> createState() => _EditContactDialogState();
}

class _EditContactDialogState extends State<_EditContactDialog> {
  late final TextEditingController _website;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();
    final c = widget.state.company;
    _website = TextEditingController(text: c.website);
    _email = TextEditingController(text: c.email);
    _phone = TextEditingController(text: c.supportPhone);
    _address = TextEditingController(text: c.address);
  }

  @override
  void dispose() {
    _website.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return _EditDialogScaffold(
      title: l.companyContactWebSection,
      children: [
        _field(l.fieldWebsite, _website),
        _field(l.fieldSupportEmail, _email),
        _field(l.fieldSupportPhone, _phone),
        _field(l.fieldAddress, _address),
      ],
      onSave: () {
        widget.state.updateCompany(
          widget.state.company.copyWith(
            website: _website.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            address: _address.text.trim(),
          ),
        );
      },
    );
  }
}

class _EditSocialDialog extends StatefulWidget {
  final AppState state;

  const _EditSocialDialog({required this.state});

  @override
  State<_EditSocialDialog> createState() => _EditSocialDialogState();
}

class _EditSocialDialogState extends State<_EditSocialDialog> {
  late final TextEditingController _website;
  late final TextEditingController _facebook;
  late final TextEditingController _instagram;
  late final TextEditingController _youtube;
  late final TextEditingController _telegram;

  @override
  void initState() {
    super.initState();
    final links = widget.state.company.socialLinks;
    _website = TextEditingController(text: links['website'] ?? '');
    _facebook = TextEditingController(text: links['facebook'] ?? '');
    _instagram = TextEditingController(text: links['instagram'] ?? '');
    _youtube = TextEditingController(text: links['youtube'] ?? '');
    _telegram = TextEditingController(text: links['telegram'] ?? '');
  }

  @override
  void dispose() {
    _website.dispose();
    _facebook.dispose();
    _instagram.dispose();
    _youtube.dispose();
    _telegram.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return _EditDialogScaffold(
      title: l.companySocialSection,
      children: [
        _field(l.fieldWebsite, _website),
        _field(l.fieldFacebook, _facebook),
        _field(l.fieldInstagram, _instagram),
        _field(l.fieldYoutube, _youtube),
        _field(l.fieldTelegram, _telegram),
      ],
      onSave: () {
        widget.state.updateCompany(
          widget.state.company.copyWith(
            socialLinks: {
              'website': _website.text.trim(),
              'facebook': _facebook.text.trim(),
              'instagram': _instagram.text.trim(),
              'youtube': _youtube.text.trim(),
              'telegram': _telegram.text.trim(),
            },
          ),
        );
      },
    );
  }
}

class _EditBusinessRulesDialog extends StatefulWidget {
  final AppState state;

  const _EditBusinessRulesDialog({required this.state});

  @override
  State<_EditBusinessRulesDialog> createState() =>
      _EditBusinessRulesDialogState();
}

class _EditBusinessRulesDialogState extends State<_EditBusinessRulesDialog> {
  late final TextEditingController _brandVoice;
  late final TextEditingController _doNotSay;
  late final TextEditingController _allowedSupportTopics;
  late final TextEditingController _escalationNotes;
  late final TextEditingController _disclaimerText;

  @override
  void initState() {
    super.initState();
    final rules = widget.state.businessRules;
    _brandVoice = TextEditingController(text: rules.brandVoice);
    _doNotSay = TextEditingController(text: rules.doNotSay.join('\n'));
    _allowedSupportTopics = TextEditingController(
      text: rules.allowedSupportTopics.join('\n'),
    );
    _escalationNotes = TextEditingController(text: rules.escalationNotes);
    _disclaimerText = TextEditingController(text: rules.disclaimerText ?? '');
  }

  @override
  void dispose() {
    _brandVoice.dispose();
    _doNotSay.dispose();
    _allowedSupportTopics.dispose();
    _escalationNotes.dispose();
    _disclaimerText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return _EditDialogScaffold(
      title: l.companyBusinessRulesSection,
      children: [
        _field(l.companyBrandVoice, _brandVoice, maxLines: 3),
        _field(l.companyDoNotSay, _doNotSay, maxLines: 5),
        _field(
          l.companyAllowedSupportTopics,
          _allowedSupportTopics,
          maxLines: 5,
        ),
        _field(l.companyEscalationNotes, _escalationNotes, maxLines: 4),
        _field(l.companyDisclaimerText, _disclaimerText, maxLines: 3),
      ],
      onSave: () {
        widget.state.updateBusinessRules(
          BusinessRules(
            brandVoice: _brandVoice.text.trim(),
            doNotSay: _lines(_doNotSay.text),
            allowedSupportTopics: _lines(_allowedSupportTopics.text),
            escalationNotes: _escalationNotes.text.trim(),
            disclaimerText: _disclaimerText.text.trim().isEmpty
                ? null
                : _disclaimerText.text.trim(),
          ),
        );
      },
    );
  }
}

class _EditInternalNotesDialog extends StatefulWidget {
  final AppState state;

  const _EditInternalNotesDialog({required this.state});

  @override
  State<_EditInternalNotesDialog> createState() =>
      _EditInternalNotesDialogState();
}

class _EditInternalNotesDialogState extends State<_EditInternalNotesDialog> {
  late final TextEditingController _internalNotes;

  @override
  void initState() {
    super.initState();
    _internalNotes = TextEditingController(
      text: widget.state.company.internalNotes,
    );
  }

  @override
  void dispose() {
    _internalNotes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return _EditDialogScaffold(
      title: l.companyInternalNotesSection,
      children: [
        _field(l.companyInternalNotesSection, _internalNotes, maxLines: 6),
      ],
      onSave: () {
        widget.state.updateCompany(
          widget.state.company.copyWith(
            internalNotes: _internalNotes.text.trim(),
          ),
        );
      },
    );
  }
}

class _EditDialogScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onSave;

  const _EditDialogScaffold({
    required this.title,
    required this.children,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.btnCancel),
        ),
        FilledButton(
          onPressed: () {
            onSave();
            Navigator.of(context).pop();
          },
          child: Text(l.btnSave),
        ),
      ],
    );
  }
}

Widget _field(String label, TextEditingController ctrl, {int maxLines = 1}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    ),
  );
}

List<String> _lines(String value) {
  return value
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
}
