import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_message.dart';
import 'package:flutter/material.dart';

class ChatScreenCustom extends StatelessWidget {
  const ChatScreenCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(
          child: ChatMessages(),
        ),
        NewMessage(),
      ],
    );
  }
}
