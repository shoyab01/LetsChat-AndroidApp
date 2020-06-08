import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:letschat/helper/HelperFunctions.dart';
import 'package:letschat/helper/capitalize.dart';
import 'package:letschat/helper/constants.dart';
import 'package:letschat/screens/register.dart';
import 'package:letschat/screens/search.dart';
import 'package:letschat/services/auth.dart';
import 'package:letschat/services/database.dart';
import 'conversation.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

String _myPhoneNumber;
String _myUserName;

class _ChatRoomState extends State<ChatRoom> {
  AuthService authMethods = new AuthService();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  Stream chatRoomsStream;

  Widget chatRoomList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot){
        return snapshot.hasData ? ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index){
              return Card(
                color: Colors.red,
                elevation: 7.0,
                child: ChatRoomTile(
                    snapshot.data.documents[index].data["chatroomid"]
                        .toString()
                        .replaceAll("_", "")
                        .replaceAll(_myPhoneNumber, ""),
                    "Name",
                    snapshot.data.documents[index].data["chatroomid"]
                ),
              );
            }) : Container();
      },
    );
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async{
    _myPhoneNumber = await HelperFunctions.getphoneNumberSharedPreference();
    _myUserName = await HelperFunctions.getMyUserNameSharedPreference();
    Constants.myPhoneNumber = _myPhoneNumber;
    Constants.myUserName = _myUserName;
    await databaseMethods.getChatRooms(_myPhoneNumber).then((value){
      setState(() {
        chatRoomsStream = value;
      });
    });

    setState(() {

    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chats",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26.0,
          ),
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: (){
              AuthService().signOut();
              HelperFunctions.saveUserLoggedInSharedPreference(false);
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => Register(),
              ));
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.exit_to_app)),
          ),
        ],
      ),
      body: chatRoomList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search,
        color: Colors.white,),
        backgroundColor: Colors.red[400],
        splashColor: Colors.red,
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => SearchScreen(),
          ));
        },
      ),
    );
  }
}


class ChatRoomTile extends StatelessWidget {
  final String userPhoneNumber;
  final String userUserName;
  final String chatroomid;
  ChatRoomTile(this.userPhoneNumber, this.userUserName, this.chatroomid);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => ConversationScreen(userPhoneNumber, chatroomid)
        ));
      },
      child: Container(
        color: Colors.redAccent,
        margin: EdgeInsets.all(2),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          children: <Widget>[
            Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50)
              ),
              child: Text(
                userUserName.substring(0, 1).toUpperCase(),
              ),
            ),
            SizedBox(width: 16,),
            Column(
              children: [
                Text(
                  Capitalize().capitalizeFirstLetter(userUserName),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
                Text(
                  userPhoneNumber,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
