import 'package:chat_app/models/user.dart';
import 'package:chat_app/utils/keyboard_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatsTab extends StatefulWidget {
  const ChatsTab({super.key});

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String currentUserId;

  List<User> userList = [];

  Widget buildItem(BuildContext context, DocumentSnapshot? documentSnapshot) {
    final firebaseAuth = FirebaseAuth.instance;
    if (documentSnapshot != null) {
      ChatUser userChat = ChatUser.fromDocument(documentSnapshot);
      if (userChat.id == currentUserId) {
        return const SizedBox.shrink();
      } else {
        return TextButton(
          onPressed: () {
            if (KeyboardUtils.isKeyboardShowing()) {
              KeyboardUtils.closeKeyboard(context);
            }
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => ChatPage(
            //               peerId: userChat.id,
            //               peerAvatar: userChat.photoUrl,
            //               peerNickname: userChat.displayName,
            //               userAvatar: firebaseAuth.currentUser!.photoURL!,
            //             )));
          },
          child: ListTile(
            leading: userChat.photoUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                      userChat.photoUrl,
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      loadingBuilder: (BuildContext ctx, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                                color: Colors.grey,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null),
                          );
                        }
                      },
                      errorBuilder: (context, object, stackTrace) {
                        return const Icon(Icons.account_circle, size: 50);
                      },
                    ),
                  )
                : const Icon(
                    Icons.account_circle,
                    size: 50,
                  ),
            title: Text(
              userChat.displayName,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: InputDecoration(
              label: Text('Search'),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: StreamBuilder(
              stream: _firestore
                  .collection('users')
                  .where('receiver', isEqualTo: user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data?.docs ?? [];

                userList.clear();

                for (var message in messages) {
                  final senderId = message['sender'];
                  final receiverId = message['receiver'];
                  print(message);

                  // // Kiểm tra nếu người gửi là user hiện tại hoặc người nhận là user hiện tại
                  // if (senderId == user?.uid || receiverId == user?.uid) {
                  //   final otherUserId =
                  //       senderId == user?.uid ? receiverId : senderId;

                  //   _firestore
                  //       .collection('users')
                  //       .doc(otherUserId)
                  //       .get()
                  //       .then((snapshot) {
                  //     final otherUserName = snapshot.data?['name'];
                  //     final otherUserAvatar = snapshot.data?['avatar'];

                  //     final user = User(
                  //       uid: otherUserId,
                  //       name: otherUserName ?? '',
                  //       avatar: otherUserAvatar ?? '',
                  //     );

                  //     setState(() {
                  //       userList.add(user);
                  //     });
                  //   }).catchError((error) {
                  //     print('Error getting user data: $error');
                  //   });
                  // }
                }

                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No user found...'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final senderId = messages[index]['sender'];

                      return FutureBuilder<DocumentSnapshot>(
                        future:
                            _firestore.collection('users').doc(senderId).get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('Loading...');
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          final senderData = snapshot.data;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(senderData?['avatar']),
                            ),
                            title: Text(
                              senderData?['name'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(senderData?['content'],
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          );
                        },
                      );
                    },
                  );
                }
              }),
        ),
      ],
    );
  }
}
