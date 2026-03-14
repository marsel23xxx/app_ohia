import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// ── Conversations List Screen ──
/// Daftar semua chat/conversation milik user.
class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    // TODO: Call ChatRepository.getConversations()
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      // Dummy data untuk demo
      _conversations = [
        {
          'conversation_id': 1,
          'other_user': {'id': 2, 'nama_lengkap': 'Baso Pak Warso', 'foto_profil': null},
          'last_message': {'body': 'Masih ada basonya pak?', 'is_mine': true, 'created_at': '2026-03-14T10:30:00Z'},
          'unread_count': 0,
        },
        {
          'conversation_id': 2,
          'other_user': {'id': 3, 'nama_lengkap': 'Es Doger Bu Siti', 'foto_profil': null},
          'last_message': {'body': 'Ada kak, silakan merapat 😊', 'is_mine': false, 'created_at': '2026-03-14T09:15:00Z'},
          'unread_count': 1,
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Search conversations
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    itemCount: _conversations.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
                    itemBuilder: (context, index) {
                      return _buildConversationTile(_conversations[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conv) {
    final other = conv['other_user'] as Map<String, dynamic>;
    final lastMsg = conv['last_message'] as Map<String, dynamic>?;
    final unread = conv['unread_count'] as int? ?? 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.secondary,
        child: Text(
          (other['nama_lengkap'] as String).substring(0, 1).toUpperCase(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              other['nama_lengkap'] ?? '-',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (lastMsg != null)
            Text(
              _formatTime(lastMsg['created_at']),
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                color: unread > 0 ? AppColors.primary : AppColors.textHint,
              ),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          if (lastMsg != null && lastMsg['is_mine'] == true)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.done_all, size: 14, color: AppColors.info),
            ),
          Expanded(
            child: Text(
              lastMsg?['body'] ?? 'Belum ada pesan',
              style: AppTextStyles.caption.copyWith(
                fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
                color: unread > 0 ? AppColors.textPrimary : AppColors.textHint,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (unread > 0)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$unread',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.pushNamed(context, '/chat/room', arguments: {
          'conversation_id': conv['conversation_id'],
          'other_user': other,
        });
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textHint),
          const SizedBox(height: AppSpacing.md),
          Text('Belum ada percakapan', style: AppTextStyles.body.copyWith(color: AppColors.textHint)),
          const SizedBox(height: AppSpacing.sm),
          Text('Mulai chat dari halaman detail Pembagi', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  String _formatTime(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      return '${dt.day}/${dt.month}';
    } catch (_) {
      return '';
    }
  }
}
