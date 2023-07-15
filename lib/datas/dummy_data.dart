import 'package:chat_app/models/conversation.dart';

final List<Conversation> conversations = [
  Conversation(
    avatar: 'https://picsum.photos/id/1/200/300',
    name: 'John Doe',
    lastMessage: 'Hello, how are you?',
  ),
  Conversation(
    avatar: 'https://picsum.photos/id/2/200/300',
    name: 'Jane Smith',
    lastMessage: 'Are we still meeting today?',
  ),
  Conversation(
    avatar: 'https://picsum.photos/id/3/200/300',
    name: 'David Johnson',
    lastMessage: 'See you later!',
  ),
];
