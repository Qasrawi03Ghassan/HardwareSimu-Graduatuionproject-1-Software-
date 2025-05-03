import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/message.dart';

class ChatBubble extends StatefulWidget {
  final String message;
  final bool theme;
  const ChatBubble({super.key, required this.theme, required this.message});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
        ),
        child: Text(
          widget.message,
          style: GoogleFonts.comfortaa(
            color: widget.theme ? Colors.white : Colors.black,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}
