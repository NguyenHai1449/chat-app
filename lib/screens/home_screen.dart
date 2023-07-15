import 'package:chat_app/datas/dummy_data.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Chat App'),
      ),
      body: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      ChatScreen(conversation: conversations[index])));
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(conversations[index].avatar),
              ),
              title: Text(conversations[index].name),
              subtitle: Text(conversations[index].lastMessage),
            ),
          );
        },
      ),
    );
  }
}
