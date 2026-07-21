import 'package:flutter/material.dart';
import '../models/business.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/field_label.dart';

/// Screen — "Business Details". Edits the profile-quality fields that don't
/// have a home elsewhere yet: opening hours, guest capacity, and a simple FAQ
/// list. Mutates [business] in place, same pattern as ManageFeaturesScreen.
class BusinessDetailsScreen extends StatefulWidget {
  const BusinessDetailsScreen({super.key, required this.business});

  final Business business;

  @override
  State<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
  late final _hoursCtrl = TextEditingController(text: widget.business.businessHours);
  late final _capacityCtrl = TextEditingController(text: widget.business.capacity?.toString() ?? '');

  @override
  void dispose() {
    _hoursCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.business
      ..businessHours = _hoursCtrl.text.trim()
      ..capacity = int.tryParse(_capacityCtrl.text.trim());
    Navigator.of(context).pop();
  }

  Future<void> _addFaq() async {
    final questionCtrl = TextEditingController();
    final answerCtrl = TextEditingController();
    final faq = await showDialog<Faq>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add FAQ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: questionCtrl, decoration: const InputDecoration(hintText: 'Question')),
            const SizedBox(height: 12),
            TextField(controller: answerCtrl, decoration: const InputDecoration(hintText: 'Answer'), minLines: 2, maxLines: 4),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (questionCtrl.text.trim().isEmpty || answerCtrl.text.trim().isEmpty) return;
              Navigator.of(dialogContext).pop(Faq(question: questionCtrl.text.trim(), answer: answerCtrl.text.trim()));
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (faq != null) setState(() => widget.business.faqs.add(faq));
  }

  void _removeFaq(Faq faq) => setState(() => widget.business.faqs.remove(faq));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business Details')),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              children: [
                const FieldLabel('Business Hours'),
                TextField(
                  controller: _hoursCtrl,
                  decoration: const InputDecoration(hintText: 'Example: Mon–Sat, 9am–9pm'),
                ),
                const SizedBox(height: 20),
                const FieldLabel('Capacity (Guests)'),
                TextField(
                  controller: _capacityCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Example: 400'),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: FieldLabel('FAQs')),
                    TextButton.icon(
                      onPressed: _addFaq,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add FAQ'),
                    ),
                  ],
                ),
                if (widget.business.faqs.isEmpty)
                  Text('No FAQs added yet.', style: AppTextStyles.bodyMd())
                else
                  for (final faq in widget.business.faqs)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(faq.question, style: AppTextStyles.labelMd()),
                                const SizedBox(height: 4),
                                Text(faq.answer, style: AppTextStyles.bodyMd()),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeFaq(faq),
                            icon: const Icon(Icons.close, size: 18, color: AppColors.outline),
                          ),
                        ],
                      ),
                    ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
