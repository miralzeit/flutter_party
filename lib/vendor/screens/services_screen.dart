import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business.dart';
import '../providers/business_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'add_edit_service_screen.dart';
import 'create_package_screen.dart';
import 'package_preview_screen.dart';
import 'service_preview_screen.dart';

const String _allFilter = 'All';
const String _packagesFilter = 'Packages';

/// Screen — "Services & Packages" tab. Services and packages are both just
/// listings the vendor sells, so they share one list and one filter bar
/// instead of being two separate screens. Also reused mid onboarding: pass
/// [business] directly (not yet in [businessesProvider]) with [onFinish] for
/// the wizard's "Finish" step; as a tab, [business] is left null and the
/// active business is read from Riverpod instead.
class ServicesPackagesScreen extends ConsumerStatefulWidget {
  const ServicesPackagesScreen({super.key, this.business, this.onFinish});

  final Business? business;
  final VoidCallback? onFinish;

  @override
  ConsumerState<ServicesPackagesScreen> createState() => _ServicesPackagesScreenState();
}

class _ServicesPackagesScreenState extends ConsumerState<ServicesPackagesScreen> {
  String _filter = _allFilter;

  bool get _isOnboarding => widget.business != null;

  void _refresh() {
    setState(() {});
    if (!_isOnboarding) ref.read(businessesProvider.notifier).touch();
  }

  void _openAddSheet(Business business) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.room_service_outlined, color: AppColors.primary),
              title: const Text('Add Service'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _addService(business);
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard_outlined, color: AppColors.primary),
              title: const Text('Create Package'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _addPackage(business);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addService(Business business) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditServiceScreen(
          onSubmit: (service) {
            business.services.add(service);
            _refresh();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _editService(Business business, Service service) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditServiceScreen(
          initial: service,
          onSubmit: (_) {
            _refresh();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _deleteService(Business business, Service service) async {
    final confirmed = await _confirmDelete('Delete Service', 'Are you sure you want to delete "${service.name}"?');
    if (confirmed) {
      business.services.remove(service);
      for (final package in business.packages) {
        package.includedServices.remove(service);
      }
      _refresh();
    }
  }

  void _previewService(Service service) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServicePreviewScreen(service: service)));
  }

  void _addPackage(Business business) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreatePackageScreen(business: business))).then((_) => _refresh());
  }

  void _editPackage(Business business, Package package) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => CreatePackageScreen(business: business, initial: package)))
        .then((_) => _refresh());
  }

  Future<void> _deletePackage(Business business, Package package) async {
    final confirmed = await _confirmDelete('Delete Package', 'Are you sure you want to delete "${package.name}"?');
    if (confirmed) {
      business.packages.remove(package);
      _refresh();
    }
  }

  void _previewPackage(Package package) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PackagePreviewScreen(package: package)));
  }

  Future<bool> _confirmDelete(String title, String message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  @override
  Widget build(BuildContext context) {
    final business = widget.business ?? activeBusinessOf(ref.watch(businessesProvider), ref.watch(activeBusinessIdProvider));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Services & Packages'),
        actions: [
          if (business != null)
            IconButton(
              onPressed: () => _openAddSheet(business),
              icon: const Icon(Icons.add),
              tooltip: 'Add',
            ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: business == null ? _noBusiness() : _content(business),
          ),
        ),
      ),
    );
  }

  Widget _noBusiness() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Add a business first to manage its services.', textAlign: TextAlign.center, style: AppTextStyles.bodyMd()),
        ),
      );

  Widget _content(Business business) {
    final categories = {for (final s in business.services) if (s.category.isNotEmpty) s.category}.toList()..sort();
    final chips = [_allFilter, ...categories, if (business.packages.isNotEmpty) _packagesFilter];

    final showServices = _filter == _allFilter || categories.contains(_filter);
    final showPackages = _filter == _allFilter || _filter == _packagesFilter;
    final filteredServices = showServices
        ? business.services.where((s) => _filter == _allFilter || s.category == _filter).toList()
        : const <Service>[];
    final filteredPackages = showPackages ? business.packages : const <Package>[];

    final isEmptyOverall = business.services.isEmpty && business.packages.isEmpty;

    return Column(
      children: [
        if (chips.length > 1)
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              itemCount: chips.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final chip = chips[index];
                final selected = chip == _filter;
                return ChoiceChip(
                  label: Text(chip),
                  selected: selected,
                  onSelected: (_) => setState(() => _filter = chip),
                  selectedColor: AppColors.primaryContainer.withValues(alpha: 0.2),
                  labelStyle: AppTextStyles.labelSm(color: selected ? AppColors.primary : AppColors.onSurfaceVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    side: BorderSide(color: selected ? AppColors.primary : AppColors.outlineVariant),
                  ),
                );
              },
            ),
          ),
        Expanded(
          child: isEmptyOverall
              ? _emptyState(business)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  children: [
                    for (final service in filteredServices) ...[
                      _ServiceCard(
                        service: service,
                        onEdit: () => _editService(business, service),
                        onPreview: () => _previewService(service),
                        onDelete: () => _deleteService(business, service),
                      ),
                      const SizedBox(height: 12),
                    ],
                    for (final package in filteredPackages) ...[
                      _PackageCard(
                        package: package,
                        onEdit: () => _editPackage(business, package),
                        onPreview: () => _previewPackage(package),
                        onDelete: () => _deletePackage(business, package),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (filteredServices.isEmpty && filteredPackages.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Text('No items in this category.', style: AppTextStyles.bodyMd(), textAlign: TextAlign.center),
                      ),
                  ],
                ),
        ),
        if (widget.onFinish != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: ElevatedButton(
              onPressed: widget.onFinish,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
              child: const Text('Finish'),
            ),
          ),
      ],
    );
  }

  Widget _emptyState(Business business) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No services yet — add your first one to start attracting customers.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLg(),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _addService(business),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
              icon: const Icon(Icons.add),
              label: const Text('Add Service'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _mutedItalic(String text) => Text(
      text,
      style: AppTextStyles.labelSm(color: AppColors.outline).copyWith(fontStyle: FontStyle.italic),
    );

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.onEdit, required this.onPreview, required this.onDelete});

  final Service service;
  final VoidCallback onEdit;
  final VoidCallback onPreview;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.dflt),
              ),
              child: const Icon(Icons.room_service_outlined, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(service.name, style: AppTextStyles.labelMd())),
                      service.price != null
                          ? Text('${service.price!.toStringAsFixed(0)} ILS', style: AppTextStyles.labelMd(color: AppColors.onSurface))
                          : _mutedItalic('Tap to set a base price'),
                    ],
                  ),
                  if (service.category.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(service.category, style: AppTextStyles.labelSm()),
                  ],
                  const SizedBox(height: 2),
                  service.description.isNotEmpty
                      ? Text(service.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.labelSm())
                      : _mutedItalic('Tap to add a description'),
                ],
              ),
            ),
            PopupMenuButton<_CardAction>(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.more_vert, size: 20, color: AppColors.outline),
              onSelected: (action) {
                switch (action) {
                  case _CardAction.edit:
                    onEdit();
                  case _CardAction.preview:
                    onPreview();
                  case _CardAction.delete:
                    onDelete();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: _CardAction.edit, child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit'))),
                PopupMenuItem(value: _CardAction.preview, child: ListTile(leading: Icon(Icons.visibility_outlined), title: Text('Preview'))),
                PopupMenuItem(
                  value: _CardAction.delete,
                  child: ListTile(leading: Icon(Icons.delete_outline, color: AppColors.error), title: Text('Delete', style: TextStyle(color: AppColors.error))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.package, required this.onEdit, required this.onPreview, required this.onDelete});

  final Package package;
  final VoidCallback onEdit;
  final VoidCallback onPreview;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    const maxShown = 3;
    final shown = package.includedServices.take(maxShown).toList();
    final remaining = package.includedServices.length - shown.length;
    final savings = package.savings;

    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(package.name, style: AppTextStyles.labelMd())),
                package.price != null
                    ? Text('${package.price!.toStringAsFixed(0)} ILS', style: AppTextStyles.labelMd(color: AppColors.onSurface))
                    : _mutedItalic('Tap to set a price'),
                PopupMenuButton<_CardAction>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert, size: 20, color: AppColors.outline),
                  onSelected: (action) {
                    switch (action) {
                      case _CardAction.edit:
                        onEdit();
                      case _CardAction.preview:
                        onPreview();
                      case _CardAction.delete:
                        onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: _CardAction.edit, child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit'))),
                    PopupMenuItem(value: _CardAction.preview, child: ListTile(leading: Icon(Icons.visibility_outlined), title: Text('Preview'))),
                    PopupMenuItem(
                      value: _CardAction.delete,
                      child: ListTile(leading: Icon(Icons.delete_outline, color: AppColors.error), title: Text('Delete', style: TextStyle(color: AppColors.error))),
                    ),
                  ],
                ),
              ],
            ),
            if (savings != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryContainer.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text('Save ${savings.toStringAsFixed(0)} ILS', style: AppTextStyles.labelSm(color: AppColors.tertiary)),
                  ),
                ),
              ),
            if (shown.isEmpty)
              _mutedItalic('No services attached yet.')
            else
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Includes', style: AppTextStyles.labelSm()),
                    const SizedBox(height: 2),
                    for (final service in shown)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.tertiary, size: 16),
                            const SizedBox(width: 6),
                            Text(service.name, style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                          ],
                        ),
                      ),
                    if (remaining > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text('+$remaining more', style: AppTextStyles.labelSm()),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum _CardAction { edit, preview, delete }
