import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/event_provider.dart';
import '../../services/event_api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

const String _googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
const bool _skipCreateEventBackend = bool.fromEnvironment(
  'SKIP_CREATE_EVENT_BACKEND',
  defaultValue: false,
);

class PlanYourEventScreen extends ConsumerStatefulWidget {
  const PlanYourEventScreen({super.key});

  @override
  ConsumerState<PlanYourEventScreen> createState() =>
      _PlanYourEventScreenState();
}

class _PlanYourEventScreenState extends ConsumerState<PlanYourEventScreen> {
  final _eventNameController = TextEditingController();
  final _locationController = TextEditingController();
  late DateTime _selectedDate;
  var _selectedEventType = 'Wedding';
  var _isSubmitting = false;
  var _locationPreview = '';

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 128));
    _locationController.addListener(_syncLocationPreview);
  }

  @override
  void dispose() {
    _locationController.removeListener(_syncLocationPreview);
    _eventNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  int get _countdownDays {
    final eventDate = DateUtils.dateOnly(_selectedDate);
    final today = DateUtils.dateOnly(DateTime.now());
    return eventDate.difference(today).inDays;
  }

  void _syncLocationPreview() {
    setState(() => _locationPreview = _locationController.text.trim());
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(today) ? today : _selectedDate,
      firstDate: today,
      lastDate: DateTime(today.year + 10, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.eventPrimary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.eventBackground,
              onSurface: AppColors.eventBlack,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) return;

    setState(() => _selectedDate = DateUtils.dateOnly(selectedDate));
  }

  Future<void> _createEvent() async {
    final eventName = _eventNameController.text.trim();
    final location = _locationController.text.trim();

    if (eventName.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an event name and location.'),
        ),
      );
      return;
    }

    final event = CreateEventRequest(
      eventType: _selectedEventType,
      eventName: eventName,
      eventDate: _selectedDate,
      location: location,
    );

    setState(() => _isSubmitting = true);

    try {
      if (!_skipCreateEventBackend) {
        await ref.read(eventApiServiceProvider).createEvent(event);
      }

      _setActiveEvent(event);

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _setActiveEvent(CreateEventRequest event) {
    ref.read(activeEventProvider.notifier).state = ActiveEvent(
      eventType: event.eventType,
      eventName: event.eventName,
      eventDate: event.eventDate,
      location: event.location,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.eventPageBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
              children: [
                const _TopIcon(),
                const SizedBox(height: 22),
                const _HeadingBlock(),
                const SizedBox(height: 34),
                _EventTypeSection(
                  selectedEventType: _selectedEventType,
                  onChanged: (eventType) {
                    setState(() => _selectedEventType = eventType);
                  },
                ),
                const SizedBox(height: 28),
                _EventNameSection(controller: _eventNameController),
                const SizedBox(height: 26),
                _EventDateSection(
                  selectedDate: _selectedDate,
                  countdownDays: _countdownDays,
                  onDateTap: _pickDate,
                ),
                const SizedBox(height: 26),
                _LocationSection(controller: _locationController),
                const SizedBox(height: 18),
                _MapPreview(location: _locationPreview),
                const SizedBox(height: 28),
                _GetStartedButton(
                  isSubmitting: _isSubmitting,
                  onPressed: _isSubmitting ? null : _createEvent,
                ),
                const SizedBox(height: 14),
                const _FooterNote(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopIcon extends StatelessWidget {
  const _TopIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          color: AppColors.eventSelectedBackground,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.calendar_month_rounded,
              color: AppColors.eventPrimary,
              size: 34,
            ),
            Positioned(
              right: 15,
              bottom: 15,
              child: Icon(
                Icons.add_circle_rounded,
                color: AppColors.eventPrimary,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeadingBlock extends StatelessWidget {
  const _HeadingBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Plan your event',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineLgMobile(
            color: AppColors.eventBlack,
          ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
        ),
        const SizedBox(height: 10),
        Text(
          'Fill in the details below to start organizing\nyour perfect celebration.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMd(
            color: AppColors.eventMutedForeground,
          ).copyWith(fontSize: 15, letterSpacing: 0),
        ),
      ],
    );
  }
}

class _EventTypeSection extends StatelessWidget {
  const _EventTypeSection({
    required this.selectedEventType,
    required this.onChanged,
  });

  final String selectedEventType;
  final ValueChanged<String> onChanged;

  static const List<_EventTypeOption> _options = [
    _EventTypeOption(
      label: 'Wedding',
      icon: Icons.favorite_rounded,
      iconBackground: AppColors.eventPrimary,
      iconColor: AppColors.onPrimary,
    ),
    _EventTypeOption(
      label: 'Engagement',
      icon: Icons.diamond_rounded,
      iconBackground: AppColors.eventLightBlue,
      iconColor: AppColors.googleBlue,
    ),
    _EventTypeOption(
      label: 'Graduation',
      icon: Icons.school_rounded,
      iconBackground: AppColors.eventSelectedBackground,
      iconColor: AppColors.eventAccent,
    ),
    _EventTypeOption(
      label: 'Birthday',
      icon: Icons.cake_rounded,
      iconBackground: AppColors.eventLightBlue,
      iconColor: AppColors.secondary,
    ),
    _EventTypeOption(
      label: 'Corporate',
      icon: Icons.business_center_rounded,
      iconBackground: AppColors.eventSelectedBackground,
      iconColor: AppColors.eventPrimary,
    ),
    _EventTypeOption(
      label: 'Baby Shower',
      icon: Icons.child_care_rounded,
      iconBackground: AppColors.eventLightBlue,
      iconColor: AppColors.googleBlue,
    ),
    _EventTypeOption(
      label: 'Anniversary',
      icon: Icons.celebration_rounded,
      iconBackground: AppColors.eventSelectedBackground,
      iconColor: AppColors.eventAccent,
    ),
    _EventTypeOption(
      label: 'Other',
      icon: Icons.auto_awesome_rounded,
      iconBackground: AppColors.eventLightBlue,
      iconColor: AppColors.secondary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _SectionBlock(
      label: 'Select Event Type',
      child: SizedBox(
        height: 62,
        child: _EventTypeScroller(
          options: _options,
          selectedEventType: selectedEventType,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _EventTypeScroller extends StatelessWidget {
  const _EventTypeScroller({
    required this.options,
    required this.selectedEventType,
    required this.onChanged,
  });

  final List<_EventTypeOption> options;
  final String selectedEventType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: options.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final option = options[index];
        return _EventTypeCard(
          option: option,
          active: selectedEventType == option.label,
          onTap: () => onChanged(option.label),
        );
      },
    );
  }
}

class _EventTypeOption {
  const _EventTypeOption({
    required this.label,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
  });

  final String label;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
}

class _EventTypeCard extends StatelessWidget {
  const _EventTypeCard({
    required this.option,
    required this.active,
    required this.onTap,
  });

  final _EventTypeOption option;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        width: active ? 150 : 168,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active
              ? AppColors.eventSelectedBackground
              : AppColors.eventBackground,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: active ? AppColors.eventAccent : AppColors.eventBorder,
            width: active ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: option.iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(option.icon, color: option.iconColor, size: 21),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    AppTextStyles.labelMd(
                      color: active
                          ? AppColors.eventAccent
                          : AppColors.eventMutedForeground,
                    ).copyWith(
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      letterSpacing: 0,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventNameSection extends StatelessWidget {
  const _EventNameSection({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionBlock(
      label: 'Event Name',
      child: _PlanningInput(
        controller: controller,
        icon: Icons.edit_rounded,
        hint: 'E.g. Smith & Co. Wedding',
        textInputAction: TextInputAction.next,
      ),
    );
  }
}

class _EventDateSection extends StatelessWidget {
  const _EventDateSection({
    required this.selectedDate,
    required this.countdownDays,
    required this.onDateTap,
  });

  final DateTime selectedDate;
  final int countdownDays;
  final VoidCallback onDateTap;

  @override
  Widget build(BuildContext context) {
    return _SectionBlock(
      label: 'When will it happen?',
      child: Row(
        children: [
          Expanded(
            child: _DateInfoCard(
              icon: Icons.calendar_today_rounded,
              label: 'DATE',
              value: _formatEventDate(selectedDate),
              onTap: onDateTap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DateInfoCard(
              icon: Icons.timer_outlined,
              label: 'COUNTDOWN',
              value: _formatCountdown(countdownDays),
              filled: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionBlock(
      label: 'City / Location',
      child: _PlanningInput(
        controller: controller,
        icon: Icons.location_on_rounded,
        hint: 'E.g. San Francisco, CA',
        textInputAction: TextInputAction.done,
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMd(
            color: AppColors.eventBlack,
          ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _PlanningInput extends StatelessWidget {
  const _PlanningInput({
    required this.controller,
    required this.icon,
    required this.hint,
    required this.textInputAction,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: textInputAction,
      style: AppTextStyles.bodyMd(
        color: AppColors.eventBlack,
      ).copyWith(fontSize: 15, letterSpacing: 0),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMd(
          color: AppColors.eventMutedForeground,
        ).copyWith(fontSize: 15, letterSpacing: 0),
        prefixIcon: Icon(icon, color: AppColors.eventMutedForeground, size: 22),
        filled: true,
        fillColor: AppColors.eventBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.eventBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.eventBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(
            color: AppColors.eventPrimary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _DateInfoCard extends StatelessWidget {
  const _DateInfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.filled = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = filled ? AppColors.onPrimary : AppColors.eventPrimary;
    final labelColor = filled
        ? AppColors.eventSoftText
        : AppColors.eventMutedForeground;
    final valueColor = filled ? AppColors.onPrimary : AppColors.eventBlack;

    final card = Container(
      height: 92,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: filled ? AppColors.eventPrimary : AppColors.eventBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: filled ? null : Border.all(color: AppColors.eventBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const Spacer(),
          Text(
            label,
            style: AppTextStyles.labelSm(
              color: labelColor,
            ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.6),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTextStyles.labelMd(color: valueColor).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: card,
    );
  }
}

String _formatEventDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String _formatCountdown(int days) {
  if (days == 1) return '1 Day';
  return '$days Days';
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final mapLocation = location.isEmpty ? 'San Francisco, CA' : location;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox(
        height: 150,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_googleMapsApiKey.isEmpty)
              const _MapFallback()
            else
              Image.network(
                _staticMapUrl(mapLocation),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const _MapFallback();
                },
              ),
            Positioned(
              left: 12,
              bottom: 12,
              child: TextButton.icon(
                onPressed: () => _openGoogleMaps(context, mapLocation),
                icon: const Icon(Icons.map_rounded, size: 18),
                label: const Text('View on Map'),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.eventBackground,
                  foregroundColor: AppColors.eventPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: const StadiumBorder(),
                  textStyle: AppTextStyles.labelSm(
                    color: AppColors.eventPrimary,
                  ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _staticMapUrl(String location) {
    return Uri.https('maps.googleapis.com', '/maps/api/staticmap', {
      'center': location,
      'zoom': '12',
      'size': '640x300',
      'scale': '2',
      'maptype': 'roadmap',
      'markers': 'color:0x1F3D3A|$location',
      'key': _googleMapsApiKey,
    }).toString();
  }

  static Future<void> _openGoogleMaps(
    BuildContext context,
    String location,
  ) async {
    final mapsUri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': location,
    });

    final launched = await launchUrl(
      mapsUri,
      mode: LaunchMode.platformDefault,
      webOnlyWindowName: '_blank',
    );

    if (launched || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open Google Maps.')),
    );
  }
}

class _MapFallback extends StatelessWidget {
  const _MapFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.eventMapGreen,
      child: Stack(
        children: [
          Positioned(
            left: -20,
            top: 28,
            right: -20,
            child: Container(
              height: 18,
              color: AppColors.eventBackground.withValues(alpha: 0.62),
            ),
          ),
          Positioned(
            left: 84,
            top: -18,
            bottom: -18,
            child: Transform.rotate(
              angle: -0.48,
              child: Container(
                width: 20,
                color: AppColors.eventBackground.withValues(alpha: 0.72),
              ),
            ),
          ),
          Positioned(
            right: 36,
            top: 14,
            bottom: -24,
            child: Transform.rotate(
              angle: 0.7,
              child: Container(
                width: 16,
                color: AppColors.eventBackground.withValues(alpha: 0.54),
              ),
            ),
          ),
          const Center(
            child: Icon(
              Icons.location_on_rounded,
              color: AppColors.eventPrimary,
              size: 42,
            ),
          ),
        ],
      ),
    );
  }
}

class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton({
    required this.isSubmitting,
    required this.onPressed,
  });

  final bool isSubmitting;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.eventPrimary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: AppTextStyles.labelMd(
            color: AppColors.onPrimary,
          ).copyWith(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.onPrimary,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Get started'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 21),
                ],
              ),
      ),
    );
  }
}

class _FooterNote extends StatelessWidget {
  const _FooterNote();

  @override
  Widget build(BuildContext context) {
    return Text(
      'You can change these details later in your planner.',
      textAlign: TextAlign.center,
      style: AppTextStyles.labelSm(
        color: AppColors.eventMutedForeground,
      ).copyWith(fontWeight: FontWeight.w500, letterSpacing: 0),
    );
  }
}
