// lib/widgets/chatbot_widget.dart

import 'package:flutter/material.dart';
import '../service/chatbot_service.dart'; // Sesuaikan path import

// Model sederhana untuk pesan (tidak berubah)
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatbotWidget extends StatefulWidget {
  const ChatbotWidget({super.key});

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  final List<ChatMessage> _messages = [
    ChatMessage(text: "Halo! Saya Pustakawan AI. Ada yang bisa dibantu?", isUser: false),
  ];
  final TextEditingController _controller = TextEditingController();
  final ChatbotService _chatbotService = ChatbotService();
  final ScrollController _scrollController = ScrollController();

  bool _isOpen = false;
  bool _isLoading = false;
  Offset _offset = const Offset(20, 20); // Posisi awal dari pojok kanan bawah

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
    // --- PERUBAHAN UTAMA: MENGGUNAKAN STACK UNTUK MENUMPuk WIDGET ---
    return Stack(
      children: [
        // WIDGET 1: JENDELA CHAT (MUNCUL/HILANG DENGAN ANIMASI)
        // Posisinya relatif terhadap posisi tombol
        Positioned(
          right: _offset.dx,
          bottom: _offset.dy + 80, // 80px di atas tombol
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isOpen ? 1.0 : 0.0,
            child: Visibility(
              visible: _isOpen,
              child: Container(
                width: 350,
                height: 500,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Pustakawan AI', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => setState(() => _isOpen = false),
                          )
                        ],
                      ),
                    ),
                    // Daftar Pesan
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(10),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return Align(
                            alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: message.isUser ? Colors.blue[300] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(message.text, style: TextStyle(color: message.isUser ? Colors.white : Colors.black87)),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Align(alignment: Alignment.centerLeft, child: CircularProgressIndicator()),
                      ),
                    // Input Area
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[200]!))),
                      child: Row(
                        children: [
                          Expanded(child: TextField(controller: _controller, decoration: const InputDecoration.collapsed(hintText: 'Ketik pertanyaan...'), onSubmitted: (_) => _sendMessage())),
                          IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: _sendMessage)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // WIDGET 2: TOMBOL CHAT (BISA DIGESER)
        Positioned(
          right: _offset.dx,
          bottom: _offset.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                double newDx = _offset.dx - details.delta.dx;
                double newDy = _offset.dy - details.delta.dy;

                // Batasan agar tidak keluar layar
                if (newDx < 10) newDx = 10;
                if (newDx > MediaQuery.of(context).size.width - 70) newDx = MediaQuery.of(context).size.width - 70;
                if (newDy < 10) newDy = 10;
                if (newDy > MediaQuery.of(context).size.height - 90) newDy = MediaQuery.of(context).size.height - 90;

                _offset = Offset(newDx, newDy);
              });
            },
            child: FloatingActionButton(
              onPressed: () => setState(() => _isOpen = !_isOpen),
              child: Icon(_isOpen ? Icons.close : Icons.chat_bubble_outline),
            ),
          ),
        ),
      ],
    );
  }
}