import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {

  uploadUserInfo(userInfoMap){
    Firestore.instance.collection("users")
        .add(userInfoMap).catchError((e){
      print(e.toString());
    });
  }

  getUserByUserPhoneNumber(String phoneNumber) async {
    return await Firestore.instance.collection("users")
        .where("phoneNumber", isEqualTo: phoneNumber)
        .getDocuments();
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////

  createChatRoom(String chatroomid, Map<String, dynamic> chatRoomMap){
    Firestore.instance.collection("ChatRoom")
        .document(chatroomid).setData(chatRoomMap).catchError((e){
      print(e.toString());
    });
  }

  addConversationMessages(String chatroomid, messageMap){
    Firestore.instance.collection("ChatRoom")
        .document(chatroomid)
        .collection("chats")
        .add(messageMap).catchError((e){
      print(e.toString());
    });
  }

  getConversationMessages(String chatroomid) async{
    return await Firestore.instance.collection("ChatRoom")
        .document(chatroomid)
        .collection("chats")
        .orderBy("time",descending: false)
        .snapshots();
  }

  getChatRooms(String userPhoneNumber) async{
    return await Firestore.instance.
    collection("ChatRoom")
        .where("users", arrayContains: userPhoneNumber)
        .snapshots();
  }
}