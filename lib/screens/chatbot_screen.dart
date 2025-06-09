import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/chat_message.dart';
import '../app_colors.dart';
import '../gen_l10n/app_localizations.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];

  int _getTimestamp() => DateTime.now().millisecondsSinceEpoch;

  Future<String?> _getAnswerFromFirestore(String input) async {
    final inputLower = input.toLowerCase();
    final langCode = Localizations.localeOf(context).languageCode;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('chatbot_qa')
          .where('lang', isEqualTo: langCode)
          .get();

      for (var doc in snapshot.docs) {
        final question = doc['q'].toString().toLowerCase();
        final keywords = List<String>.from(doc['keywords']);
        if (inputLower.contains(question) ||
            keywords.any((k) => inputLower.contains(k))) {
          return doc['a'];
        }
      }
    } catch (e) {
      debugPrint("Chatbot Firestore error: $e");
    }

    return null;
  }

  Future<String?> _getEsp32ContextReply() async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('sensor_data/soil_moisture/device_id_1')
          .get();
      final value = snapshot.value;

      if (value is num && value < 30) {
        return "⚠️ Soil moisture is low (${value.toInt()}%). Consider watering now.";
      }
    } catch (e) {
      debugPrint("ESP32 moisture check failed: $e");
    }
    return null;
  }

  String _getFallbackAnswer(String input) {
    final msg = input.toLowerCase();

    if (msg.contains("moisture") || msg.contains("dry")) {
      return "If your soil is dry, irrigate when moisture drops below 30%. Use mulch to retain moisture.";
    } else if (msg.contains("ph")) {
      return "If pH is too low (<6), add lime. If too high (>7), add sulfur or peat moss.";
    } else if (msg.contains("nitrogen")) {
      return "Low nitrogen? Use organic compost or urea-based fertilizer.";
    } else if (msg.contains("irrigation") || msg.contains("water")) {
      return "Irrigate early in the morning or late afternoon. Use drip systems for efficiency.";
    } else if (msg.contains("improve") && msg.contains("soil")) {
      return "Improve soil with compost, crop rotation, and regular NPK tests.";
    } else if (msg.contains("help")) {
      return "You can ask me about irrigation, plant care, soil pH, or fertilizer tips.";
    }

    return "Sorry, I’m still learning 🌱. Try asking about soil pH, moisture, or irrigation.";
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final timestamp = _getTimestamp();
    final userMsg = ChatMessage(text: text.trim(), isUser: true, timestamp: timestamp);
    setState(() => _messages.insert(0, userMsg));
    _controller.clear();

    String? reply = await _getAnswerFromFirestore(text);
    reply ??= _getFallbackAnswer(text);

    final contextTip = await _getEsp32ContextReply();
    if (contextTip != null) reply += "\n\n$contextTip";

    final botMsg = ChatMessage(text: reply, isUser: false, timestamp: _getTimestamp());

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _messages.insert(0, botMsg));
    });
  }

  void _clearChat() => setState(() => _messages.clear());

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(t.chatbotAssistant),
        backgroundColor: AppColors.forestGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: "Clear Chat",
            onPressed: _messages.isEmpty ? null : _clearChat,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(child: Text(t.askQuestion))
                : ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemBuilder: (context, index) => _buildChatCard(_messages[index]),
            ),
          ),
          const Divider(height: 1),
          _buildInputBar(t),
        ],
      ),
    );
  }

  Widget _buildChatCard(ChatMessage msg) {
    final alignment = msg.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bgColor = msg.isUser ? AppColors.forestGreen : Colors.white;
    final textColor = msg.isUser ? Colors.white : Colors.black87;

    return Align(
      alignment: alignment,
      child: Card(
        color: bgColor,
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(msg.text, style: TextStyle(fontSize: 15, color: textColor)),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(msg.timestamp)),
                  style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.7)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: t.askQuestion,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.forestGreen),
            onPressed: () => _sendMessage(_controller.text),
            tooltip: "Send",
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
