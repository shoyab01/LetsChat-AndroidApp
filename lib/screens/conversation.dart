import 'package:flutter/material.dart';
import 'package:letschat/helper/HelperFunctions.dart';
import 'package:letschat/helper/constants.dart';
import 'package:letschat/services/database.dart';

class ConversationScreen extends StatefulWidget {
  final String phoneNumber, chatroomid;
  ConversationScreen(this.phoneNumber, this.chatroomid);
  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

String _myPhoneNumber;

class _ConversationScreenState extends State<ConversationScreen> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController messageController = new TextEditingController();
  Stream chatMessagesStream;

  @override
  void initState() {
    getUserInfo();
    databaseMethods.getConversationMessages(widget.chatroomid).then((value){
      setState(() {
        chatMessagesStream = value;
      });
    });
    super.initState();
  }

  getUserInfo() async{
    _myPhoneNumber = await HelperFunctions.getphoneNumberSharedPreference();
    Constants.myPhoneNumber = _myPhoneNumber;
    setState(() {});
  }

  Widget chatMessageList() {
    return StreamBuilder(
      stream: chatMessagesStream,
      builder: (context, snapshot){
        return snapshot.hasData ? ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index){
              return MessageTile(snapshot.data.documents[index].data["message"], snapshot.data.documents[index].data["sendBy"] == _myPhoneNumber);
            }
        ) : Container();
      },
    );
  }

  sendMessage(){
    if(messageController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messageController.text,
        "sendBy": _myPhoneNumber,
        "time": DateTime.now().millisecondsSinceEpoch,
      };
      databaseMethods.addConversationMessages(widget.chatroomid, messageMap);
      messageController.text = "";
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.phoneNumber,
        ),
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                  padding: EdgeInsets.only(bottom: 70),
                  child: chatMessageList()
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.red[200],
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration.collapsed(
                          hintText: "Type your Heart out",
                          hintStyle: TextStyle(
                            color: Colors.black45,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        sendMessage();
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFE57373),
                                const Color(0xFFE53935),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Image.asset("assets/images/send.png")
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool isSendByMe;
  MessageTile(this.message, this.isSendByMe);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: isSendByMe ? 0 : 24, right: isSendByMe ? 24 : 0),
      margin: EdgeInsets.symmetric(vertical: 8),
      width: MediaQuery.of(context).size.width,
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: isSendByMe ? [
                  const Color(0xFFF44336),
                  const Color(0xFFB71C1C)
                ] : [
                  const Color(0xFFFFB74D),
                  const Color(0xFFFF9800)
                ]
            ),
            borderRadius: isSendByMe ? BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
                bottomLeft: Radius.circular(23)
            ) : BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
                bottomRight: Radius.circular(23)
            )
        ),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
          ),),
      ),
    );
  }
}
