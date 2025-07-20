import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../utils/theme.dart';
import '../widgets/chat_widgets.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final UserModel otherUser;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.otherUser,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late Stream<QuerySnapshot> _messagesStream;

  @override
  void initState() {
    super.initState();
    _messagesStream = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
    
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markMessagesAsRead() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Mark all messages as read
    final unreadMessages = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUser.uid)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    if (unreadMessages.docs.isNotEmpty) {
      await batch.commit();
    }

    // Update chat unread count
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .update({'unreadCount_${currentUser.uid}': 0});
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _messageController.clear();

    try {
      final messageId = FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc()
          .id;

      final message = MessageModel(
        id: messageId,
        senderId: currentUser.uid,
        receiverId: widget.otherUser.uid,
        text: text,
        timestamp: DateTime.now(),
        isRead: false,
      );

      // Add message to subcollection
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());

      // Update chat document
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({
        'lastMessage': text,
        'lastMessageTimestamp': DateTime.now().millisecondsSinceEpoch,
        'unreadCount_${widget.otherUser.uid}': FieldValue.increment(1),
      });

      // Scroll to bottom
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildDateSeparator(),
          Expanded(child: _buildMessagesList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: widget.otherUser.imageUrl.isNotEmpty
                ? NetworkImage(widget.otherUser.imageUrl)
                : null,
            child: widget.otherUser.imageUrl.isEmpty
                ? Text(
                    widget.otherUser.name.isNotEmpty
                        ? widget.otherUser.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
            backgroundColor: AppTheme.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUser.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  widget.otherUser.isOnline ? 'Online' : 'Offline',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: widget.otherUser.isOnline ? Colors.green : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_outlined, color: AppTheme.textPrimary),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.call_outlined, color: AppTheme.textPrimary),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildDateSeparator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppTheme.dividerColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              "Today, ${DateTime.now().day} ${_getMonthName(DateTime.now().month)}",
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppTheme.dividerColor)),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _messagesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data?.docs ?? [];

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Send a message to start the conversation',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final messageData = messages[index].data() as Map<String, dynamic>;
            final message = MessageModel.fromMap(messageData);
            final currentUser = FirebaseAuth.instance.currentUser;
            final isMe = message.senderId == currentUser?.uid;

            return ChatBubble(
              message: message,
              isMe: isMe,
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        border: Border(
          top: BorderSide(color: AppTheme.dividerColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.emoji_emotions_outlined,
                color: AppTheme.textSecondary,
              ),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  hintStyle: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.attach_file,
                color: AppTheme.textSecondary,
              ),
              onPressed: () {},
            ),
            const SizedBox(width: 4),
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}