class ChatMessage {
  String content;
  bool currentUser = false;

  ChatMessage({required this.content, this.currentUser = false});
}
