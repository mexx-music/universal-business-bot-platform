import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/label_helpers.dart';
import '../../models/company.dart';
import '../../models/product_or_service.dart';

class CompanyScreen extends StatelessWidget {
  const CompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Text(
                l.companyTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              FilledButton.tonal(
                onPressed: () => _showEditDialog(context, state, l),
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(l.btnEdit),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _CompanyInfoCard(company: state.company),
          const SizedBox(height: 24),
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

  void _showEditDialog(
    BuildContext context,
    AppState state,
    AppLocalizations l,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => _EditCompanyDialog(state: state),
    );
  }
}

class _CompanyInfoCard extends StatelessWidget {
  final Company company;

  const _CompanyInfoCard({required this.company});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
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
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            Text(company.description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
            _InfoRow(icon: Icons.language, label: company.website),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.email_outlined, label: company.email),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.phone_outlined, label: company.phone),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.location_on_outlined, label: company.address),
          ],
        ),
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
    return Row(
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

class _EditCompanyDialog extends StatefulWidget {
  final AppState state;

  const _EditCompanyDialog({required this.state});

  @override
  State<_EditCompanyDialog> createState() => _EditCompanyDialogState();
}

class _EditCompanyDialogState extends State<_EditCompanyDialog> {
  late final TextEditingController _name;
  late final TextEditingController _industry;
  late final TextEditingController _description;
  late final TextEditingController _website;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();
    final c = widget.state.company;
    _name = TextEditingController(text: c.name);
    _industry = TextEditingController(text: c.industry);
    _description = TextEditingController(text: c.description);
    _website = TextEditingController(text: c.website);
    _email = TextEditingController(text: c.email);
    _phone = TextEditingController(text: c.phone);
    _address = TextEditingController(text: c.address);
  }

  @override
  void dispose() {
    _name.dispose();
    _industry.dispose();
    _description.dispose();
    _website.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.companyEditDialogTitle),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(l.fieldCompanyName, _name),
              _field(l.fieldIndustry, _industry),
              _field(l.fieldDescription, _description, maxLines: 3),
              _field(l.fieldWebsite, _website),
              _field(l.fieldEmail, _email),
              _field(l.fieldPhone, _phone),
              _field(l.fieldAddress, _address),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.btnCancel),
        ),
        FilledButton(
          onPressed: () {
            widget.state.updateCompany(
              widget.state.company.copyWith(
                name: _name.text,
                industry: _industry.text,
                description: _description.text,
                website: _website.text,
                email: _email.text,
                phone: _phone.text,
                address: _address.text,
              ),
            );
            Navigator.of(context).pop();
          },
          child: Text(l.btnSave),
        ),
      ],
    );
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
}
