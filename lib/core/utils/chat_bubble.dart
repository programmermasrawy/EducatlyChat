import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSender; // Use this to determine if it's a sender or receiver bubble

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isSender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: CustomPaint(
            painter: BubblePainter(isSender: isSender),
            child: Container(
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Text(
                message,
                style: TextStyle(color: isSender ? Colors.white : Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BubblePainter extends CustomPainter {
  final bool isSender;

  BubblePainter({required this.isSender});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = isSender ? Colors.blueAccent : Colors.grey[300]!
      ..style = PaintingStyle.fill;

    final path = Path();
    // Create the bubble shape with arrow
    if (isSender) {
      path.moveTo(0, 0);
      path.lineTo(size.width - 15, 0);
      path.lineTo(size.width, size.height / 2);
      path.lineTo(size.width - 15, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, 0);
    } else {
      path.moveTo(15, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, size.height / 2);
      path.lineTo(15, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
