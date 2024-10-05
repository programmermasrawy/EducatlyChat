part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadMessages extends ChatEvent {
  final String userId;

  LoadMessages(this.userId);
}

class SendMessage extends ChatEvent {
  final String message;
  final String recipientId;

  SendMessage({
    required this.message,
    required this.recipientId,
  });

  @override
  List<Object> get props => [message];
}

class UpdateTypingStatus extends ChatEvent {
  final bool isTyping;

  UpdateTypingStatus(this.isTyping);

  @override
  List<Object> get props => [isTyping];
}
