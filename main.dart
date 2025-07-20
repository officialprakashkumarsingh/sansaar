import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

// Main entry point of the application
void main() {
  runApp(const SansaarApp());
}

// The root widget of the Sansaar application
class SansaarApp extends StatelessWidget {
  const SansaarApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Using CupertinoApp for a more native iOS feel
    return CupertinoApp(
      title: 'Sansaar',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF6A5AE0),
        scaffoldBackgroundColor: const Color(0xFFF7F7FC),
        barBackgroundColor: const Color(0xFFF7F7FC),
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: 'SFProDisplay', // Standard iOS font
            color: Colors.black87,
          ),
          navLargeTitleTextStyle: TextStyle(
            fontFamily: 'SFProDisplay',
            fontWeight: FontWeight.bold,
            fontSize: 34.0,
            color: CupertinoColors.black,
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

//============================================================
// Main Screen - Using CupertinoTabScaffold for native iOS tabs
//============================================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: Colors.white,
        activeColor: const Color(0xFF6A5AE0),
        inactiveColor: Colors.grey.shade400,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble_2_fill), label: 'Chats'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.phone), label: 'Calls'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.video_camera), label: 'Video'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings), label: 'Settings'),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        // For this demo, we'll only show the ChatListScreen for the first tab.
        // In a real app, you would have different screens for each tab.
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (context) {
              return const ChatListScreen();
            });
          default:
            return CupertinoTabView(builder: (context) {
              return Center(child: Text('Screen ${index + 1}'));
            });
        }
      },
    );
  }
}

//============================================================
// SCREEN 1: Chat List Screen
//============================================================

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          _buildCupertinoSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStories(),
                _buildChatsHeader(),
              ],
            ),
          ),
          _buildChatList(),
        ],
      ),
    );
  }

  Widget _buildCupertinoSliverAppBar() {
    return CupertinoSliverNavigationBar(
      largeTitle: Text(
        'Sansaar',
        style: GoogleFonts.pacifico(
          fontSize: 36,
          color: const Color(0xFF333333),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.search, size: 24),
            onPressed: () {},
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.bell, size: 24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStories() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        itemCount: stories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const AddStoryButton();
          }
          final user = stories[index - 1];
          return StoryCircle(user: user);
        },
      ),
    );
  }

  Widget _buildChatsHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 8.0),
      child: Text('Chats',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildChatList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final chat = chats[index];
          return ChatListItem(chat: chat);
        },
        childCount: chats.length,
      ),
    );
  }
}

//============================================================
// SCREEN 2: Chat Detail Screen
//============================================================

class ChatDetailScreen extends StatelessWidget {
  final User user;

  const ChatDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: _buildCupertinoNavBar(context),
      child: Column(
        children: [
          _buildDateSeparator(),
          Expanded(child: _buildMessagesList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  CupertinoNavigationBar _buildCupertinoNavBar(BuildContext context) {
    return CupertinoNavigationBar(
      middle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(user.imageUrl),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'Working From Home',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: const Icon(CupertinoIcons.ellipsis),
        onPressed: () {},
      ),
    );
  }

  Widget _buildDateSeparator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              "Today, 1 Sep",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final bool isMe = message.sender.name == currentUser.name;
        return ChatBubble(
          message: message,
          isMe: isMe,
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      decoration: const BoxDecoration(
          color: Colors.white,
          border:
              Border(top: BorderSide(color: Color(0xFFE5E5EA), width: 0.5))),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CupertinoTextField(
                placeholder: 'Write a reply...',
                prefix: CupertinoButton(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.emoji_emotions_outlined,
                      color: Colors.grey.shade600),
                  onPressed: () {},
                ),
                suffix: CupertinoButton(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(CupertinoIcons.camera,
                      color: Colors.grey.shade600),
                  onPressed: () {},
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFF6A5AE0),
                child: Icon(CupertinoIcons.paperplane_fill,
                    color: Colors.white, size: 20),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

//============================================================
// WIDGETS - Reusable UI components
//============================================================

class AddStoryButton extends StatelessWidget {
  const AddStoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: const Icon(Icons.add, size: 30, color: Color(0xFF6A5AE0)),
          ),
          const SizedBox(height: 8),
          const Text('Add story', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class StoryCircle extends StatelessWidget {
  final User user;

  const StoryCircle({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6A5AE0), width: 2.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(user.imageUrl),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(user.name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class ChatListItem extends StatelessWidget {
  final Chat chat;

  const ChatListItem({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) => ChatDetailScreen(user: chat.user),
        ));
      },
      child: Container(
        color: CupertinoColors.white,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(chat.user.imageUrl),
                ),
                if (chat.user.isOnline)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.user.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 4),
                if (chat.unreadCount > 0)
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: const Color(0xFF6A5AE0),
                    child: Text(
                      chat.unreadCount.toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF6A5AE0) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: !isMe
                  ? [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : [],
            ),
            child: message.isVoiceMessage
                ? _buildVoiceMessage()
                : _buildTextMessage(),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 4.0, left: 8.0, right: 8.0, bottom: 8.0),
            child: Text(
              message.time,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextMessage() {
    return Text(
      message.text,
      style: TextStyle(color: isMe ? Colors.white : Colors.black87),
    );
  }

  Widget _buildVoiceMessage() {
    // This is a static representation of a waveform.
    // A real app would use a library to generate this from audio data.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(CupertinoIcons.play_arrow_solid,
            color: isMe ? Colors.white : const Color(0xFF6A5AE0)),
        const SizedBox(width: 8),
        Image.network(
          'https://i.imgur.com/u1fK2sJ.png', // A simple waveform image
          width: 120,
          height: 25,
          color: isMe ? Colors.white70 : Colors.grey.shade400,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}


//============================================================
// MODELS & MOCK DATA (No changes needed here)
//============================================================

class User {
  final String name;
  final String imageUrl;
  final bool isOnline;

  User({required this.name, required this.imageUrl, this.isOnline = false});
}

class Chat {
  final User user;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isMuted;

  Chat({
    required this.user,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isMuted = false,
  });
}

class Message {
  final User sender;
  final String text;
  final String time;
  final bool isVoiceMessage;

  Message({
    required this.sender,
    required this.text,
    required this.time,
    this.isVoiceMessage = false,
  });
}

// User instances
final User currentUser = User(
    name: 'You',
    imageUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704d');
final User hamid =
    User(name: 'Hamid', imageUrl: 'https://i.pravatar.cc/150?u=hamid', isOnline: true);
final User linckon =
    User(name: 'Linckon', imageUrl: 'https://i.pravatar.cc/150?u=linckon');
final User athiya =
    User(name: 'Athiya', imageUrl: 'https://i.pravatar.cc/150?u=athiya', isOnline: true);
final User zaisha =
    User(name: 'Zaisha', imageUrl: 'https://i.pravatar.cc/150?u=zaisha');
final User hussain = User(
    name: 'Hussain Mazumder',
    imageUrl: 'https://i.pravatar.cc/150?u=hussain',
    isOnline: true);
final User ahatiya = User(
    name: 'Ahatiya Suzzane',
    imageUrl: 'https://i.pravatar.cc/150?u=ahatiyass',
    isOnline: true);
final User keisan = User(
    name: 'Keisan Hamza', imageUrl: 'https://i.pravatar.cc/150?u=keisan');
final User vidrohi = User(
    name: 'Vidrohi Mirza', imageUrl: 'https://i.pravatar.cc/150?u=vidrohi');
final User alexander = User(
    name: 'Alexander Hussain',
    imageUrl: 'https://i.pravatar.cc/150?u=alexander',
    isOnline: true);
final User fariha = User(
    name: 'Fariha Milaniya', imageUrl: 'https://i.pravatar.cc/150?u=fariha');
final User melisia = User(
    name: 'Melisia Suzzane',
    imageUrl: 'https://i.pravatar.cc/150?u=melisia',
    isOnline: true);

// Stories List
final List<User> stories = [hamid, linckon, athiya, zaisha, alexander, fariha];

// Chats List
final List<Chat> chats = [
  Chat(
      user: hussain,
      lastMessage: "Good Morning....",
      time: "14 min ago",
      unreadCount: 2),
  Chat(
      user: ahatiya,
      lastMessage: "What about the Dribble Shot??",
      time: "22 min ago",
      unreadCount: 1),
  Chat(
      user: keisan,
      lastMessage: "Just let me know, when you want...",
      time: "Yesterday"),
  Chat(user: vidrohi, lastMessage: "Do check your balance.", time: "Yesterday"),
  Chat(
      user: alexander,
      lastMessage: "Hey!!!! are you available??",
      time: "1 Day ago",
      unreadCount: 3),
  Chat(
      user: fariha,
      lastMessage: "Make sure you give all the updates on...",
      time: "2 Days ago"),
];

// Messages List for the detail screen
final List<Message> messages = [
  Message(
      sender: melisia,
      text: "Hello there, Would love to hear every thing in details for further use!",
      time: "8:30 PM"),
  Message(
      sender: currentUser,
      text: "Sure I'll let you know as soon as possible!",
      time: "9:30 PM"),
  Message(
      sender: melisia,
      text: "Okay Would be waiting for your updates in next project!",
      time: "10:00 PM"),
  Message(
      sender: currentUser,
      text: "Voice Message",
      time: "10:20 PM",
      isVoiceMessage: true),
  Message(
      sender: currentUser,
      text: "Here I've explained everything make sure you fulfill all my expectations!",
      time: "10:22 PM"),
];