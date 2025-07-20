import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/theme.dart';

class StorySection extends StatelessWidget {
  const StorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading stories'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs
              .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
              .where((user) => user.uid != FirebaseAuth.instance.currentUser?.uid)
              .toList();

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            itemCount: users.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const AddStoryButton();
              }
              final user = users[index - 1];
              return StoryCircle(user: user);
            },
          );
        },
      ),
    );
  }
}

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
              color: AppTheme.backgroundColor,
              border: Border.all(color: AppTheme.dividerColor, width: 2),
            ),
            child: const Icon(
              Icons.add,
              size: 30,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add story',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class StoryCircle extends StatelessWidget {
  final UserModel user;

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
              border: Border.all(color: AppTheme.primaryColor, width: 2.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: CircleAvatar(
                radius: 28,
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
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 70,
            child: Text(
              user.name.split(' ').first,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}