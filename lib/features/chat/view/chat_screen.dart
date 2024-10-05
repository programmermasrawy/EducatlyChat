import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educalty_chat/core/constants/constants.dart';
import 'package:educalty_chat/features/chat/logic/chat_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/services/firebase_fcm_service.dart';
import '../../home/data/user_model.dart';

class ChatScreen extends StatefulWidget {
  final UserModel user; // Pass recipient ID for notifications

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isTyping = false;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTyping);
  }

  void _onTyping() {
    setState(() {
      isTyping = _messageController.text.isNotEmpty;
    });
    _firestore.collection('chat_rooms').doc(widget.user.id).update({
      '${FirebaseAuth.instance.currentUser!.uid}_isTyping': isTyping,
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTyping);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(
        firestore: FirebaseFirestore.instance,
        notificationService: FCMNotificationService(),
      )..add(LoadMessages(widget.user.id)),
      child: Scaffold(
        body: Column(
          children: [
            ChatAppBar(user: widget.user),
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ChatLoaded) {
                    Future.delayed(
                        const Duration(milliseconds: 100),
                        () => _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 100),
                              curve: Curves.easeIn,
                            ));
                    return ListView.builder(
                      itemCount: state.messages.length,
                      controller: _scrollController,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        final isMe = message.senderId == FirebaseAuth.instance.currentUser?.uid;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: isMe? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              BubbleSpecialOne(
                                text: message.text,
                                isSender: isMe,
                                color: Colors.purple.shade100,
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              Text(DateFormat('MM/dd HH:mm').format(message.timestamp.toDate()))
                            ],
                          ),
                        );
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blueAccent : Colors.grey[800],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              message.text,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is ChatError) {
                    return Center(child: Text(state.message));
                  }
                  return Container();
                },
              ),
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('chat_rooms').doc(widget.user.id).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  var data = snapshot.data!.data() != null ? snapshot.data!.data() as Map<String, dynamic> : null;
                  bool otherUserTyping = data == null ? false : data!['${widget.user.id}_isTyping'] ?? false;
                  if (otherUserTyping) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${widget.user.name} is typing...",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                }
                return Container();
              },
            ),
            _buildMessageInputBar(context),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      context.read<ChatBloc>().add(SendMessage(
            message: _messageController.text,
            recipientId: widget.user.id,
          ));
      _firestore.collection('chat_rooms').doc(widget.user.id).update({
        '${FirebaseAuth.instance.currentUser!.uid}_isTyping': false,
      });
      _messageController.clear();
    }
  }

  Widget _buildMessageInputBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8).copyWith(bottom: 22),
      color: const Color(0xff1B1A1F),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.grey),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              onSubmitted: (v) {
                _sendMessage();
              },
              decoration: InputDecoration(
                hintText: 'Message',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                fillColor: Colors.black,
                suffixIcon: Icon(Icons.access_time, color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.white), // Text color
            ),
          ),
          IconButton(
            icon: Icon(_messageController.text != '' ? Icons.send : Icons.mic, color: Colors.grey),
            onPressed: () {
              if (_messageController.text != '') {
                _sendMessage();
              }
            },
          ),
        ],
      ),
    );
  }
}

class ChatAppBar extends StatelessWidget {
  final UserModel user;

  const ChatAppBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E1D1D),
            Color(0xFF6A0FDC),
            Color(0xFF8A2BE2),
            Color(0xDF212121),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(CupertinoIcons.back, color: ChatAppColors.lightColor),
            onPressed: () => Navigator.pop(context),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                user.name,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          CircleAvatar(
            radius: 20,
            backgroundImage: CachedNetworkImageProvider(user.profileImage ?? ''),
          ),
        ],
      ),
    );
  }
}


