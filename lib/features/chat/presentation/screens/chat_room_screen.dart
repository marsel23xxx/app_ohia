import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// ── Chat Room Screen ──
/// Chat 1-on-1 antara Pencari dan Pembagi.
/// Support: text messages, share location.
class ChatRoomScreen extends StatefulWidget {
  final int conversationId;
  final Map<String, dynamic> otherUser;

  const ChatRoomScreen({
    super.key,
    required this.conversationId,
    required this.otherUser,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isSending = false;

  // Dummy messages
  List<Map<String, dynamic>> _messages = [];
  final int _myUserId = 1; // TODO: Get from auth

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    // TODO: Call API GET /api/chat/{id}/messages
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isLoading = false;
      _messages = [
        {
          'id': 1,
          'sender_id': _myUserId,
          'body': 'Pak, masih ada basonya?',
          'type': 'text',
          'created_at': '2026-03-14T10:25:00Z',
        },
        {
          'id': 2,
          'sender_id': widget.otherUser['id'],
          'body': 'Ada kak, lagi di daerah Cimanggu Permai',
          'type': 'text',
          'created_at': '2026-03-14T10:26:00Z',
        },
        {
          'id': 3,
          'sender_id': widget.otherUser['id'],
          'body': '📍 Shared location',
          'type': 'location',
          'latitude': -6.6010,
          'longitude': 106.8020,
          'created_at': '2026-03-14T10:26:30Z',
        },
        {
          'id': 4,
          'sender_id': _myUserId,
          'body': 'Oke pak, saya ke sana ya!',
          'type': 'text',
          'created_at': '2026-03-14T10:27:00Z',
        },
      ];
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'sender_id': _myUserId,
        'body': text,
        'type': 'text',
        'created_at': DateTime.now().toIso8601String(),
      });
    });

    _scrollToBottom();

    // TODO: Call API POST /api/chat/send
  }

  Future<void> _shareLocation() async {
    // TODO: Get current location from LocationService
    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'sender_id': _myUserId,
        'body': '📍 Shared location',
        'type': 'location',
        'latitude': -6.5971,
        'longitude': 106.8060,
        'created_at': DateTime.now().toIso8601String(),
      });
    });

    _scrollToBottom();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lokasi berhasil dibagikan'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.secondary,
              child: Text(
                (widget.otherUser['nama_lengkap'] as String?)?.substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUser['nama_lengkap'] ?? '-',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Online',
                    style: TextStyle(fontSize: 11, color: AppColors.success),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined),
            onPressed: () {
              // TODO: VoIP call
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur telepon akan hadir di update berikutnya')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Messages ──
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),

          // ── Input Bar ──
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isMine = msg['sender_id'] == _myUserId;
    final isLocation = msg['type'] == 'location';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) const SizedBox(width: 40), // space for avatar

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMine ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMine ? 16 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Message body
                  if (isLocation)
                    GestureDetector(
                      onTap: () {
                        // TODO: Buka map atau navigate ke lokasi
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Lokasi: ${msg['latitude']}, ${msg['longitude']}',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: isMine
                              ? Colors.white.withOpacity(0.15)
                              : AppColors.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on,
                                color: isMine ? Colors.white : AppColors.error,
                                size: 20),
                            const SizedBox(width: 6),
                            Text(
                              'Lihat Lokasi',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isMine ? Colors.white : AppColors.info,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Text(
                      msg['body'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: isMine ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  const SizedBox(height: 4),

                  // Timestamp
                  Text(
                    _formatMsgTime(msg['created_at']),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMine ? Colors.white60 : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isMine) const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.sm,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Share location button
          IconButton(
            icon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
            onPressed: _shareLocation,
            tooltip: 'Share Location',
          ),

          // Text input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Tulis pesan...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.xs),

          // Send button
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMsgTime(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
