import 'package:json_annotation/json_annotation.dart';
import 'package:localstorage/localstorage.dart';
import 'package:video_app/chat/models/Message.dart';
import 'package:video_app/auth/models/User.dart';
import 'package:dash_chat/dash_chat.dart';

part 'Chat.g.dart';


@JsonSerializable()
class Chat {
  User chatWith;
  List<Message> messages;

  @JsonKey(ignore: true)
  String id;
  @JsonKey(ignore: true)
  List<ChatMessage> dashMessages;
  @JsonKey(ignore: true)
  int unReadedMessages;

  Chat(this.chatWith, this.messages) {
    this.unReadedMessages = 0;
    this.dashMessages = new List();
    this.id = chatWith.id;

    this.messages.forEach((element) {
      this.dashMessages.add(ChatMessage(
          text: element.txt,
          user: ChatUser(name: element.from.getFullName(), uid: element.from.id, avatar: element.from.avatar),
          createdAt: element.createdAt));
    });
  }

  addChatMessage(User from, String txt) {
    dashMessages.add(ChatMessage(text: txt, user: ChatUser(name: from.getFullName(), uid: from.id, avatar: from.avatar)));
    this.unReadedMessages++;
    /**LocalStorage storage = LocalStorage('unreadStorage');
    final item = new UnreadItem(id: id,unread: unReadedMessages);
    final UnreadList list = new UnreadList();
    list.items.add(item);
    storage.setItem("unread", item);*/
  }

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
  Map<String, dynamic> toJson() => _$ChatToJson(this);

}
