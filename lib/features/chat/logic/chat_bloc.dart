import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

import '../../../core/services/firebase_fcm_service.dart';
import '../data/model/message_model.dart';

part 'chat_event.dart';

part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FirebaseFirestore firestore;
  final FCMNotificationService notificationService; // FCM service

  ChatBloc({required this.firestore, required this.notificationService}) : super(ChatInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    // emit(ChatLoading());
    try {
      var messages = await getChatMessages(event.userId);

      messages ??= [];
      print("mahmoud ${messages.length}");
      emit(ChatLoaded(messages));
    } catch (error) {
      emit(ChatError('Failed to load messages.'));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    try {
      final message = {
        'text': event.message,
        'senderId': FirebaseAuth.instance.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'receiver': event.recipientId
      };

      await firestore.collection('chats').add(message);

      // Send FCM notification
      final recipientToken = await notificationService.getRecipientToken(event.recipientId);
      await notificationService.sendFCMNotification(
        token: recipientToken,
        title: 'New Message',
        body: event.message,
      );
    } catch (error) {
      emit(ChatError('Failed to send message.'));
    }
  }

  Future<List<MessageModel>> getChatMessages(String otherUserId) async {
    final sentMessagesStream = FirebaseFirestore.instance
        .collection('chats')
        .where('senderId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('receiver', isEqualTo: otherUserId)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => MessageModel.fromFireStore(doc)).toList());

    final receivedMessagesStream = FirebaseFirestore.instance
        .collection('chats')
        .where('receiver', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('senderId', isEqualTo: otherUserId)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => MessageModel.fromFireStore(doc)).toList());

    return Rx.combineLatest2<List<MessageModel>, List<MessageModel>, List<MessageModel>>(
      sentMessagesStream,
      receivedMessagesStream,
      (sentMessages, receivedMessages) => sentMessages + receivedMessages,
    ).first;
  }
}
