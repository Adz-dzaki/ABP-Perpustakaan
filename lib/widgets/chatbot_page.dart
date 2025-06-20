// lib/widgets/chatbot_page.dart

import 'package:flutter/material.dart';
import '../service/chatbot_service.dart'; // Sesuaikan path import

// Model sederhana untuk pesan
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final List<ChatMessage> _messages = [
    ChatMessage(text: "Halo! Saya Pustakawan AI. Ada yang bisa saya bantu?", isUser: false),
  ];
  final TextEditingController _controller = TextEditingController();
  final ChatbotService _chatbotService = ChatbotService();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Anda bisa memuat histori chat di sini jika ada
  }

  void _sendMessage() async {
    final messageText = _controller.text;
    if (messageText.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: messageText, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final botReply = await _chatbotService.sendMessage(messageText);
      setState(() {
        _messages.add(ChatMessage(text: botReply, isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: "Maaf, terjadi error.", isUser: false));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Tidak perlu AppBar karena kita akan membuatnya sendiri di dalam Column
      body: SafeArea(
        child: Column(
          children: [
            // Header Halaman Chat
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Text(
                'Pustakawan AI',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Daftar Pesan
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Align(
                    alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                          color: message.isUser ? Colors.blue.shade600 : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 3)
                          ]
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(fontFamily: 'Poppins', color: message.isUser ? Colors.white : Colors.black87),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: CircularProgressIndicator(),
              ),
            // Input Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 5)
                  ]
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ketik pertanyaan...',
                        hintStyle: TextStyle(fontFamily: 'Poppins'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      padding: const EdgeInsets.all(12),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}