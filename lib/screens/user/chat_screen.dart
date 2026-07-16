import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/chat_provider.dart';
import '../../providers/event_provider.dart';
import '../../services/chat_api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import 'checklist_screen.dart';
import 'event_flow_home_screen.dart';

const bool _skipChatBackend = bool.fromEnvironment(
  'SKIP_CHAT_BACKEND',
  defaultValue: false,
);
const bool _skipCreateEventBackend = bool.fromEnvironment(
  'SKIP_CREATE_EVENT_BACKEND',
  defaultValue: false,
);

enum _ChatRole { assistant, user }

class _ChatMessage {
  const _ChatMessage({
    required this.role,
    required this.text,
    required this.timestamp,
  });

  final _ChatRole role;
  final String text;
  final DateTime timestamp;
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      role: _ChatRole.assistant,
      text:
          "Hello! I'm your Evergreen Assistant. Need help finding the perfect venue, managing your budget, or choosing a catering package? Ask me anything!",
      timestamp: DateTime(2024, 1, 1, 10, 2),
    ),
  ];
  var _isSending = false;

  bool get _useLocalChatData => _skipChatBackend || _skipCreateEventBackend;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? prompt]) async {
    final message = (prompt ?? _messageController.text).trim();
    if (message.isEmpty || _isSending) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          role: _ChatRole.user,
          text: message,
          timestamp: DateTime.now(),
        ),
      );
      _isSending = true;
      _messageController.clear();
    });
    _scrollToBottom();

    try {
      final reply = _useLocalChatData
          ? ChatReply(message: _localReplyFor(message))
          : await ref.read(chatApiServiceProvider).sendMessage(message);
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            role: _ChatRole.assistant,
            text: reply.message,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  String _localReplyFor(String message) {
    if (message.toLowerCase().contains('bethlehem')) {
      return 'I can shortlist elegant venues in Bethlehem based on your guest count, budget, and preferred style.';
    }
    return 'I can help with that. Share your budget, guest count, and event style so I can make a practical recommendation.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.eventPageBackground,
      body: SafeArea(
        child: Column(
          children: [
            const _ChatHeader(),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                    children: [
                      const Center(child: _TodayPill()),
                      const SizedBox(height: 18),
                      for (final message in _messages) ...[
                        _MessageBubble(message: message),
                        const SizedBox(height: 14),
                      ],
                      if (_isSending) ...[
                        const _TypingBubble(),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            _QuickActions(onSend: _sendMessage),
            _MessageInputBar(
              controller: _messageController,
              isSending: _isSending,
              onSend: () => _sendMessage(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _ChatBottomNav(),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.eventBackground,
      child: Column(
        children: [
          SizedBox(
            height: 64,
            child: Row(
              children: [
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: AppColors.eventBlack,
                ),
                const _AssistantAvatar(size: 38),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evergreen Assistant',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            AppTextStyles.labelMd(
                              color: AppColors.eventBlack,
                            ).copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.eventAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ONLINE',
                            style:
                                AppTextStyles.labelSm(
                                  color: AppColors.eventMutedForeground,
                                ).copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert_rounded),
                  color: AppColors.eventBlack,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.eventBorder),
        ],
      ),
    );
  }
}

class _AssistantAvatar extends StatelessWidget {
  const _AssistantAvatar({this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.eventPrimary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.park_rounded,
        color: AppColors.onPrimary,
        size: size * 0.58,
      ),
    );
  }
}

class _TodayPill extends StatelessWidget {
  const _TodayPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.eventBackground,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.eventBorder),
      ),
      child: Text(
        'TODAY',
        style: AppTextStyles.labelSm(
          color: AppColors.eventMutedForeground,
        ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.1),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == _ChatRole.user;
    final bubbleColor = isUser
        ? AppColors.eventPrimary
        : AppColors.eventMutedBackground;
    final textColor = isUser ? AppColors.onPrimary : AppColors.eventBlack;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 330),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              const _AssistantAvatar(size: 30),
              const SizedBox(width: 9),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isUser ? 18 : 6),
                        bottomRight: Radius.circular(isUser ? 6 : 18),
                      ),
                    ),
                    child: isUser
                        ? Text(
                            message.text,
                            style: AppTextStyles.bodyMd(
                              color: textColor,
                            ).copyWith(fontSize: 15, letterSpacing: 0),
                          )
                        : _AssistantMessageText(text: message.text),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatTime(message.timestamp),
                    style: AppTextStyles.labelSm(
                      color: AppColors.eventMutedForeground,
                    ).copyWith(fontSize: 11, letterSpacing: 0),
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

class _AssistantMessageText extends StatelessWidget {
  const _AssistantMessageText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    const intro = "Hello! I'm your Evergreen Assistant.";
    final baseStyle = AppTextStyles.bodyMd(
      color: AppColors.eventBlack,
    ).copyWith(fontSize: 15, letterSpacing: 0);
    if (!text.startsWith(intro)) return Text(text, style: baseStyle);

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(
            text: intro,
            style: baseStyle.copyWith(fontWeight: FontWeight.w900),
          ),
          TextSpan(text: text.substring(intro.length)),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AssistantAvatar(size: 30),
          SizedBox(width: 9),
          _TypingDots(),
        ],
      ),
    );
  }
}

class _TypingDots extends StatelessWidget {
  const _TypingDots();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.eventMutedBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        'Typing...',
        style: AppTextStyles.labelSm(color: AppColors.eventMutedForeground),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onSend});

  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    const prompts = [
      _QuickPrompt(Icons.location_on_rounded, 'Suggest a venue in Bethlehem'),
      _QuickPrompt(Icons.payments_rounded, 'Help me manage my budget'),
      _QuickPrompt(Icons.restaurant_rounded, 'Compare catering packages'),
    ];

    return Container(
      color: AppColors.eventPageBackground,
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          return OutlinedButton.icon(
            onPressed: () => onSend(prompt.text),
            icon: Icon(prompt.icon, size: 17),
            label: Text(prompt.text),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.eventBackground,
              foregroundColor: AppColors.eventDarkIcon,
              side: const BorderSide(color: AppColors.eventBorder),
              shape: const StadiumBorder(),
              textStyle: AppTextStyles.labelSm(
                color: AppColors.eventDarkIcon,
              ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
            ),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemCount: prompts.length,
      ),
    );
  }
}

class _QuickPrompt {
  const _QuickPrompt(this.icon, this.text);

  final IconData icon;
  final String text;
}

class _MessageInputBar extends StatelessWidget {
  const _MessageInputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 9, 14, 10),
      decoration: const BoxDecoration(
        color: AppColors.eventBackground,
        border: Border(top: BorderSide(color: AppColors.eventBorder)),
      ),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.add_rounded,
            foreground: AppColors.eventDarkIcon,
            background: AppColors.eventMutedBackground,
            onPressed: () {},
          ),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Chat with our AI assis...',
                suffixIcon: const Icon(
                  Icons.mic_none_rounded,
                  color: AppColors.eventMutedForeground,
                ),
                filled: true,
                fillColor: AppColors.eventMutedBackground,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          _CircleIconButton(
            icon: Icons.send_rounded,
            foreground: AppColors.onPrimary,
            background: AppColors.eventPrimary,
            onPressed: isSending ? null : onSend,
            isLoading: isSending,
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.foreground,
    required this.background,
    required this.onPressed,
    this.isLoading = false,
  });

  final IconData icon;
  final Color foreground;
  final Color background;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: IconButton.filled(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: background,
          disabledBackgroundColor: background.withValues(alpha: 0.7),
        ),
        icon: isLoading
            ? SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  color: foreground,
                  strokeWidth: 2.1,
                ),
              )
            : Icon(icon, color: foreground, size: 21),
      ),
    );
  }
}

class _ChatBottomNav extends ConsumerWidget {
  const _ChatBottomNav();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeEvent = ref.watch(activeEventProvider);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
        decoration: const BoxDecoration(
          color: AppColors.eventBackground,
          border: Border(top: BorderSide(color: AppColors.eventBorder)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _BottomNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const EventFlowHomeScreen(),
                  ),
                );
              },
            ),
            const _BottomNavItem(
              icon: Icons.chat_bubble_rounded,
              label: 'Chat',
              active: true,
            ),
            _BottomNavItem(
              icon: Icons.fact_check_rounded,
              label: 'Checklist',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => ChecklistScreen(
                      eventName: activeEvent?.eventName ?? 'Evergreen Events',
                    ),
                  ),
                );
              },
            ),
            const _BottomNavItem(icon: Icons.person_rounded, label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? AppColors.eventPrimary
        : AppColors.eventMutedForeground;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.eventSelectedBackground
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Icon(icon, color: color, size: 23),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.labelSm(color: color).copyWith(
                fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final suffix = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}
