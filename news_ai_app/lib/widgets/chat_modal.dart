import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:news_ai_app/models/chat_message.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatModal extends StatefulWidget {
  final String articleId;

  const ChatModal({super.key, required this.articleId});

  @override
  State<ChatModal> createState() => _ChatModalState();
}

class _ChatModalState extends State<ChatModal> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    // It's crucial to dispose of controllers to prevent memory leaks.
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- Main API Call Logic ---
  Future<void> _handleSendQuery() async {
    final queryText = _textController.text.trim();
    if (queryText.isEmpty) {
      return; // Don't send empty messages
    }

    // 1. Add user's message to the UI immediately
    setState(() {
      _messages.add(ChatMessage(text: queryText, sender: MessageSender.user));
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    // 2. Prepare and send the request to your backend
    final url = Uri.parse('https://propylic-abdul-glaucous.ngrok-free.dev/query');
    final headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true'
    };
    final body = json.encode({
      'article_id': widget.articleId,
      'query_text': queryText,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final answer = data['answer'] as String;
        // 3a. Success: Add AI's answer
        _messages.add(ChatMessage(text: answer, sender: MessageSender.ai));
      } else {
        // 3b. Server Error: Add an error message
        final errorDetail = json.decode(response.body)['detail'];
        _messages.add(ChatMessage(text: 'Error: $errorDetail', sender: MessageSender.error));
      }
    } catch (e) {
      // 3c. Network Error: Add a generic error message
      _messages.add(ChatMessage(text: 'Failed to connect. Please check your network.', sender: MessageSender.error));
    }

    // 4. Update the UI to show the new message and stop loading
    setState(() {
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    // A small delay ensures the ListView has time to update before we scroll.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // --- UI Build Methods ---
  @override
  // In lib/widgets/chat_modal.dart

@override
Widget build(BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.75,
    decoration: BoxDecoration( // Use BoxDecoration
      color: CupertinoColors.systemGroupedBackground,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24), // More pronounced curve
        topRight: Radius.circular(24),
      ),
      boxShadow: [ // Add depth
        BoxShadow(
          color: CupertinoColors.black.withOpacity(0.2),
          blurRadius: 20,
          spreadRadius: -5,
        )
      ],
    ),
    child: Column(
      children: [
        _buildMessageList(),
        _buildTextInputArea(),
      ],
    ),
  );
}

  Widget _buildMessageList() {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8.0),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          // Align messages based on the sender
          final isUserMessage = message.sender == MessageSender.user;
          return Align(
            alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
            child: _buildChatBubble(message),
          );
        },
      ),
    );
  }

// In lib/widgets/chat_modal.dart

// In lib/widgets/chat_modal.dart

Widget _buildChatBubble(ChatMessage message) {
  final bool isUser = message.sender == MessageSender.user;
  final bool isError = message.sender == MessageSender.error;

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
    decoration: BoxDecoration(
        color: isError
            ? CupertinoColors.systemRed.withOpacity(0.8)
            : isUser
                ? CupertinoColors.activeBlue
                : CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ]),
    child: Text(
      message.text,
      // USE THEME:
      style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
            color: isUser || isError
                ? CupertinoColors.white
                : CupertinoColors.black,
            fontWeight: FontWeight.w500,
          ),
    ),
  );
}

Widget _buildTextInputArea() {
  // Get the theme style
  final textStyle = CupertinoTheme.of(context).textTheme.textStyle;

  return Container(
    padding: const EdgeInsets.all(8.0).copyWith(bottom: 24.0),
    decoration: BoxDecoration(
        border: const Border(top: BorderSide(color: CupertinoColors.systemGrey4)),
        color: CupertinoColors.systemBackground,
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ]),
    child: Row(
      children: [
        Expanded(
          child: CupertinoTextField(
            controller: _textController,
            placeholder: 'Ask a follow-up question...',
            // USE THEME:
            style: textStyle,
            // USE THEME:
            placeholderStyle: textStyle.copyWith(
              color: CupertinoColors.placeholderText,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CupertinoActivityIndicator(),
          )
        else
          CupertinoButton(
            onPressed: _handleSendQuery,
            child: const Icon(CupertinoIcons.arrow_up_circle_fill, size: 30),
          ),
      ],
    ),
  );
}
}