import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:letschat/helper/HelperFunctions.dart';
import 'package:letschat/helper/capitalize.dart';
import 'package:letschat/helper/constants.dart';
import 'package:letschat/services/database.dart';
import 'package:letschat/widgets/widget.dart';

import 'conversation.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

String _myPhoneNumber;
String _myUserName;

class _SearchScreenState extends State<SearchScreen> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController search = new TextEditingController();

  QuerySnapshot searchSnapshot;
  initiateSearch(){
    databaseMethods.getUserByUserPhoneNumber(search.text).then((val){
      setState(() {
        searchSnapshot = val;
      });
    });
  }

  Widget searchTile({String userPhoneNumber, String userUserName}) {
    return Container(
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.red[300],
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(Capitalize().capitalizeFirstLetter(userUserName), style: TextStyle(
                color: Colors.white,
                fontSize: 23,
              ),
              ),
              Text(userPhoneNumber, style: TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
              ),
            ],
          ),
          Spacer(),
          userPhoneNumber != _myPhoneNumber ? GestureDetector(
            onTap: (){
              createChatroomAndStartConversation(
                phoneNumber: userPhoneNumber,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text("Message",style: mediumTextStyle(),),
            ),
          ) : Container(),
        ],
      ),
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
    setState(() {

    });
  }

  Widget searchList(){
    return searchSnapshot != null ? ListView.builder(
        itemCount: searchSnapshot.documents.length,
        shrinkWrap: true,
        itemBuilder: (context, index){
          return searchTile(
            userPhoneNumber: searchSnapshot.documents[index].data["phoneNumber"],
            userUserName: searchSnapshot.documents[index].data["userName"]
          );
        }) : Container();
  }

  createChatroomAndStartConversation({String phoneNumber}){

    if(phoneNumber != _myPhoneNumber) {
      String chatroomid = getChatRoomId(phoneNumber, _myPhoneNumber);

      List<String> users = [phoneNumber, _myPhoneNumber];
      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatroomid": chatroomid
      };
      DatabaseMethods().createChatRoom(chatroomid, chatRoomMap);
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => ConversationScreen(phoneNumber, chatroomid)
      ));
    }
    else{
      print("You can't send message to yourself");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Search",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26.0,
            ),
          ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.redAccent,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10)
                      ],
                      keyboardType: TextInputType.number,
                      controller: search,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: "Search Phone Number",
                        hintStyle: TextStyle(
                          color: Colors.white54,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: initiateSearch(),
                    child: Container(
                        height: 40,
                        width: 40,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0x36FFFFFF),
                              const Color(0x0FFFFFFF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Image.asset("assets/images/search_white.png")),
                  ),
                ],
              ),
            ),
            searchList(),
          ],
        ),
      ),
    );
  }
}


getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}