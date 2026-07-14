import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/admin_vendor.dart';
import '../../models/vendor_application.dart';
import '../../providers/admin_providers.dart';
import '../../theme/admin_colors.dart';
import '../../theme/admin_text_styles.dart';
import '../../theme/admin_theme.dart';
import '../../utils/admin_date_format.dart';
import '../../widgets/admin_empty_state.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/vendor_status_chip.dart';
import 'vendor_application_detail_screen.dart';
import 'vendor_detail_screen.dart';

const _allFilter = 'All';

/// Screen — "Vendor Management". Two views per the design: **All Vendors**
/// (the master directory table with status filters) and **Pending** (the
/// application-review queue). Modeled as tabs of one screen since they're
/// reached from a single "Vendors" sidebar destination, backed by two
/// different lists — [vendorsProvider] (already-live vendors) and
/// [applicationsProvider] (still in the approval pipeline) — matching the
/// data model's real separation between a Vendor and a VendorApplication.
class VendorsScreen extends ConsumerStatefulWidget {
  const VendorsScreen({super.key});

  @override
  ConsumerState<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends ConsumerState<VendorsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _allVendorsFilter = _allFilter;

  @override
  void initState() {
    super.initState();
    final initialStatus = ref.read(vendorsInitialFilterProvider);
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialStatus == VendorStatus.pending ? 1 : 0);
    if (initialStatus != null && initialStatus != VendorStatus.pending) _allVendorsFilter = initialStatus.label;
    if (initialStatus != null) {
      Future.microtask(() => ref.read(vendorsInitialFilterProvider.notifier).state = null);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// This screen is kept alive inside the shell's [IndexedStack] (so its
  /// tab state persists across sidebar navigation), which means `initState`
  /// only ever runs once — it does NOT re-run each time this section is
  /// selected again. Deep links from Overview's stat cards must therefore
  /// be applied reactively via [ref.listen] in `build`, not just read once.
  void _applyDeepLink(VendorStatus? status) {
    if (status == null) return;
    if (status == VendorStatus.pending) {
      _tabController.index = 1;
    } else {
      _tabController.index = 0;
      setState(() => _allVendorsFilter = status.label);
    }
    Future.microtask(() => ref.read(vendorsInitialFilterProvider.notifier).state = null);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<VendorStatus?>(vendorsInitialFilterProvider, (previous, next) => _applyDeepLink(next));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'All Vendors'), Tab(text: 'Pending')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AllVendorsTab(filter: _allVendorsFilter, onFilterChanged: (f) => setState(() => _allVendorsFilter = f)),
          const _PendingVendorsTab(),
        ],
      ),
    );
  }
}

class _AllVendorsTab extends ConsumerStatefulWidget {
  const _AllVendorsTab({required this.filter, required this.onFilterChanged});

  final String filter;
  final ValueChanged<String> onFilterChanged;

  @override
  ConsumerState<_AllVendorsTab> createState() => _AllVendorsTabState();
}

class _AllVendorsTabState extends ConsumerState<_AllVendorsTab> {
  String _query = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;

  Future<void> _suspend(AdminVendor vendor) async {
    final reason = await showAdminReasonDialog(
      context,
      title: 'Suspend Vendor',
      message: '${vendor.businessName} will be hidden from the public directory until reinstated.',
      confirmLabel: 'Suspend',
    );
    if (reason == null) return;
    ref.read(vendorsProvider.notifier).setStatus(vendor.id, VendorStatus.suspended, reason: reason.isEmpty ? null : reason);
  }

  Future<void> _reinstate(AdminVendor vendor) async {
    final confirmed = await showAdminConfirmDialog(
      context,
      title: 'Reinstate Vendor',
      message: '${vendor.businessName} will become visible in the public directory again.',
      confirmLabel: 'Reinstate',
      destructive: false,
    );
    if (confirmed) ref.read(vendorsProvider.notifier).setStatus(vendor.id, VendorStatus.active);
  }

  Future<void> _block(AdminVendor vendor) async {
    final reason = await showAdminReasonDialog(
      context,
      title: 'Block Vendor',
      message: '${vendor.businessName} will be permanently removed from the platform. This cannot be undone from this screen.',
      confirmLabel: 'Block Permanently',
      reasonRequired: true,
    );
    if (reason == null) return;
    ref.read(vendorsProvider.notifier).setStatus(vendor.id, VendorStatus.blocked, reason: reason);
  }

  @override
  Widget build(BuildContext context) {
    final vendors = ref.watch(vendorsProvider);
    final chips = [_allFilter, VendorStatus.active.label, VendorStatus.suspended.label, VendorStatus.blocked.label];

    var filtered = vendors.where((v) => widget.filter == _allFilter || v.status.label == widget.filter).toList();
    filtered = filtered.where((v) => v.businessName.toLowerCase().contains(_query.toLowerCase())).toList();

    if (_sortColumnIndex != null) {
      filtered.sort((a, b) {
        final cmp = _sortColumnIndex == 0 ? a.businessName.compareTo(b.businessName) : a.ratingAvg.compareTo(b.ratingAvg);
        return _sortAscending ? cmp : -cmp;
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AdminSpacing.margin, AdminSpacing.margin, AdminSpacing.margin, 12),
          child: TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by business name'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AdminSpacing.margin),
          child: Wrap(
            spacing: 8,
            children: [
              for (final chip in chips)
                ChoiceChip(
                  label: Text(chip),
                  selected: widget.filter == chip,
                  onSelected: (_) => widget.onFilterChanged(chip),
                  selectedColor: AdminColors.primary.withValues(alpha: 0.15),
                  labelStyle: AdminTextStyles.labelSm(color: widget.filter == chip ? AdminColors.primary : AdminColors.onSurfaceVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AdminRadius.full),
                    side: BorderSide(color: widget.filter == chip ? AdminColors.primary : AdminColors.outlineVariant),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: filtered.isEmpty
              ? const AdminEmptyState(icon: Icons.storefront_outlined, message: 'No vendors match this filter.')
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AdminSpacing.margin),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _sortAscending,
                      columns: [
                        DataColumn(
                          label: const Text('Business / Category'),
                          onSort: (i, asc) => setState(() {
                            _sortColumnIndex = i;
                            _sortAscending = asc;
                          }),
                        ),
                        const DataColumn(label: Text('Location')),
                        DataColumn(
                          label: const Text('Rating'),
                          numeric: true,
                          onSort: (i, asc) => setState(() {
                            _sortColumnIndex = i;
                            _sortAscending = asc;
                          }),
                        ),
                        const DataColumn(label: Text('Status')),
                        const DataColumn(label: Text('Actions')),
                      ],
                      rows: [
                        for (final vendor in filtered)
                          DataRow(
                            onSelectChanged: (_) => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => VendorDetailScreen(vendorId: vendor.id)),
                            ),
                            cells: [
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(vendor.businessName, style: AdminTextStyles.labelMd()),
                                    Text(vendor.categoryLabel, style: AdminTextStyles.labelSm()),
                                  ],
                                ),
                              ),
                              DataCell(Text(vendor.location, style: AdminTextStyles.bodyMd())),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, size: 14, color: AdminColors.tertiary),
                                    const SizedBox(width: 4),
                                    Text(vendor.ratingAvg.toStringAsFixed(1), style: AdminTextStyles.bodyMd(color: AdminColors.onSurface)),
                                  ],
                                ),
                              ),
                              DataCell(VendorStatusChip(status: vendor.status)),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _ActionIconButton(
                                      tooltip: 'View',
                                      icon: Icons.visibility_outlined,
                                      onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => VendorDetailScreen(vendorId: vendor.id)),
                                      ),
                                    ),
                                    if (vendor.status == VendorStatus.suspended)
                                      _ActionIconButton(
                                        tooltip: 'Reinstate',
                                        icon: Icons.play_circle_outline,
                                        color: AdminColors.tertiary,
                                        onPressed: () => _reinstate(vendor),
                                      )
                                    else if (vendor.status == VendorStatus.active)
                                      _ActionIconButton(
                                        tooltip: 'Suspend',
                                        icon: Icons.pause_circle_outline,
                                        color: AdminColors.warning,
                                        onPressed: () => _suspend(vendor),
                                      ),
                                    if (vendor.status != VendorStatus.blocked)
                                      _ActionIconButton(
                                        tooltip: 'Block',
                                        icon: Icons.block,
                                        color: AdminColors.error,
                                        onPressed: () => _block(vendor),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _PendingVendorsTab extends ConsumerStatefulWidget {
  const _PendingVendorsTab();

  @override
  ConsumerState<_PendingVendorsTab> createState() => _PendingVendorsTabState();
}

class _PendingVendorsTabState extends ConsumerState<_PendingVendorsTab> {
  String _query = '';
  String? _categoryFilter;

  @override
  Widget build(BuildContext context) {
    final applications = ref.watch(applicationsProvider).where((a) => a.stage.isOpen).toList();
    final categories = {for (final a in applications) a.category}.toList()..sort();

    var filtered = applications.where((a) => a.businessName.toLowerCase().contains(_query.toLowerCase())).toList();
    if (_categoryFilter != null) filtered = filtered.where((a) => a.category == _categoryFilter).toList();
    filtered.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

    return Padding(
      padding: const EdgeInsets.all(AdminSpacing.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pending', style: AdminTextStyles.headlineMd()),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by business name'),
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String?>(
                initialValue: _categoryFilter,
                onSelected: (value) => setState(() => _categoryFilter = value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: null, child: Text('All Categories')),
                  for (final category in categories) PopupMenuItem(value: category, child: Text(category)),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AdminColors.outlineVariant),
                    borderRadius: BorderRadius.circular(AdminRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.filter_list, size: 18, color: AdminColors.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(_categoryFilter ?? 'Filters', style: AdminTextStyles.labelMd()),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? const AdminEmptyState(icon: Icons.hourglass_empty, message: 'No pending applications right now.')
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _PendingCard(application: filtered[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.application});

  final VendorApplication application;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AdminRadius.sm),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => VendorApplicationDetailScreen(applicationId: application.id)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AdminColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AdminRadius.sm),
          border: Border.all(color: AdminColors.outlineVariant),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(application.businessName, style: AdminTextStyles.labelMd()),
                  const SizedBox(height: 2),
                  Text(application.category, style: AdminTextStyles.bodyMd()),
                  const SizedBox(height: 2),
                  Text(application.location, style: AdminTextStyles.labelSm()),
                ],
              ),
            ),
            Text(relativeAdminTime(application.submittedAt), style: AdminTextStyles.labelSm()),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AdminColors.outline),
          ],
        ),
      ),
    );
  }
}

/// A tighter [IconButton] for the Actions [DataCell] — the default 48x48 tap
/// target makes 2-3 of them in a row wider than DataTable allocates for the
/// column, causing a small `RenderFlex overflowed` warning.
class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({required this.tooltip, required this.icon, required this.onPressed, this.color});

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, size: 18, color: color),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      visualDensity: VisualDensity.compact,
    );
  }
}
