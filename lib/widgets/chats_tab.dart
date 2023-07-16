import 'package:chat_app/datas/dummy_data.dart';
import 'package:flutter/material.dart';

class ChatsTab extends StatelessWidget {
  const ChatsTab({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: ListView.builder(
          itemCount: conversations.length,
          itemBuilder: (context, index) => ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(conversations[index].avatar),
            ),
            title: Text(
              conversations[index].name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              conversations[index].lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ))
      ],
    );
  }
}
