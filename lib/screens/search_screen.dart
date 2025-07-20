import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../utils/theme.dart';
import 'chat_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Search by username
      final usernameQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('username', isLessThan: '${query.toLowerCase()}z')
          .limit(20)
          .get();

      // Search by name
      final nameQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .limit(20)
          .get();

      final Set<String> userIds = {};
      final List<UserModel> results = [];

      // Process username search results
      for (final doc in usernameQuery.docs) {
        final userData = doc.data();
        if (userData['uid'] != currentUser.uid && !userIds.contains(userData['uid'])) {
          userIds.add(userData['uid']);
          results.add(UserModel.fromMap(userData));
        }
      }

      // Process name search results
      for (final doc in nameQuery.docs) {
        final userData = doc.data();
        if (userData['uid'] != currentUser.uid && !userIds.contains(userData['uid'])) {
          userIds.add(userData['uid']);
          results.add(UserModel.fromMap(userData));
        }
      }

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _startChat(UserModel user) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      // Create or find existing chat
      final chatId = _getChatId(currentUser.uid, user.uid);
      
      final chatDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .get();

      if (!chatDoc.exists) {
        // Create new chat
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .set({
          'participants': [currentUser.uid, user.uid],
          'lastMessage': '',
          'lastMessageTimestamp': DateTime.now().millisecondsSinceEpoch,
          'unreadCount_${currentUser.uid}': 0,
          'unreadCount_${user.uid}': 0,
        });
      }

      // Navigate to chat detail screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ChatDetailScreen(
            chatId: chatId,
            otherUser: user,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start chat: ${e.toString()}')),
      );
    }
  }

  String _getChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Users',
          style: GoogleFonts.pacifico(fontSize: 20),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by username or name...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchUsers('');
                  },
                )
              : null,
        ),
        onChanged: (value) {
          _searchUsers(value);
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Search for users',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a username or name to find other users',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with a different term',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: AppTheme.cardColor,
          child: ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: user.imageUrl.isNotEmpty
                  ? NetworkImage(user.imageUrl)
                  : null,
              child: user.imageUrl.isEmpty
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
              backgroundColor: AppTheme.primaryColor,
            ),
            title: Text(
              user.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
              '@${user.username}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (user.isOnline)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: AppTheme.primaryColor,
                  onPressed: () => _startChat(user),
                ),
              ],
            ),
            onTap: () => _startChat(user),
          ),
        );
      },
    );
  }
}