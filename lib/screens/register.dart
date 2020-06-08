import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:letschat/helper/HelperFunctions.dart';
import 'package:letschat/services/auth.dart';
import 'package:letschat/services/database.dart';
import 'package:letschat/widgets/widget.dart';

import 'chatRoom.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final formKey = GlobalKey<FormState>();
  TextEditingController _mobileNumberController = new TextEditingController();
  TextEditingController _userNameController = new TextEditingController();
  TextEditingController _smsCodeController = new TextEditingController();

  QuerySnapshot registerSnapshot;
  initiateSearch(){
    databaseMethods.getUserByUserPhoneNumber(_mobileNumberController.text.toString()).then((val){
      registerSnapshot = val;
    });
  }

  DatabaseMethods databaseMethods = new DatabaseMethods();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String phoneNumber, smsCode, verifyId;
  bool codeSent = false;
  bool isLoading = false;

  Future<bool> sendCodeToPhoneNumber(String mobileNumber, BuildContext context) async {

    if(formKey.currentState.validate()) {
      final PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout = (
          String verId) {
        this.verifyId = verId;
      };

      final PhoneCodeSent phoneCodeSent = (String verId,
          [int forceCodeResend]) {
        this.verifyId = verId;
        setState(() {
          this.codeSent = true;
        });
      };

      final PhoneVerificationCompleted verificationCompleted = (
          AuthCredential authCredential) {
        AuthService().signIn(authCredential);
        initiateSearch();
        if(registerSnapshot.documents.length == 0) {
          Map<String, String> userInfoMap = {
            "phoneNumber" : _mobileNumberController.text.toString(),
            "userName": _userNameController.text.toString()
          };
          databaseMethods.uploadUserInfo(userInfoMap);
          HelperFunctions.saveMyUserNameSharedPreference(_userNameController.text.toString());
        }
        else {
          HelperFunctions.saveMyUserNameSharedPreference(registerSnapshot.documents[0].data["userName"]);
        }

        HelperFunctions.saveUserLoggedInSharedPreference(true);
        HelperFunctions.savePhoneNumberSharedPreference(_mobileNumberController.text);
        print("verified");
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => AuthService().handleAuth(),
        ));
      };

      final PhoneVerificationFailed verificationFailed = (
          AuthException authException) {
        print('${authException.message}');
        return AlertDialog(
          title: Text(
              "Phone Verification Failed",
            style: TextStyle(
              color: Colors.black
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  "Try again after sometime",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          actions: [
            FlatButton(
              child: Text("Ok"),
              textColor: Colors.white,
              color: Colors.red,
              onPressed: () {
                setState(() {
                  codeSent = false;
                });
              },
          )
          ],
        );
      };
      
      _auth.verifyPhoneNumber(
          phoneNumber: mobileNumber,
          timeout: Duration(seconds: 60),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: phoneCodeSent,
          codeAutoRetrievalTimeout: autoRetrievalTimeout
      );
    }
  }

  signInwhileTyping() {
    if(formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      AuthService().signInWithOTP(_smsCodeController.text, verifyId);
      initiateSearch();
      if(registerSnapshot.documents.length == 0) {
        Map<String, String> userInfoMap = {
          "phoneNumber" : _mobileNumberController.text.toString(),
          "userName": _userNameController.text.toString()
        };
        databaseMethods.uploadUserInfo(userInfoMap);
        HelperFunctions.saveMyUserNameSharedPreference(_userNameController.text.toString());
      }
      else {
        HelperFunctions.saveMyUserNameSharedPreference(registerSnapshot.documents[0].data["userName"]);
      }
      HelperFunctions.saveUserLoggedInSharedPreference(true);
      HelperFunctions.savePhoneNumberSharedPreference(_mobileNumberController.text.toString());

      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => AuthService().handleAuth(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Let's Chat",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26.0,
            ),
          ),
        ),
      ),
      body: isLoading ? Container(
        child: Center(child: CircularProgressIndicator(backgroundColor: Colors.red,)),
      ) : GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 120),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 16,),
                codeSent ? Text("Enter OTP", style: TextStyle(color: Colors.red, fontSize: 26),) : Text(
                  "Hello there, Welcome!",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 26,
                  ),
                ),
                SizedBox(height: 8,),
                codeSent ? Text("OTP has been sent to your number", style: TextStyle(color: Color(0xFFFF9800)),) : Text(
                  "Enter Mobile Number to continue",
                  style: TextStyle(
                    color: Color(0xFFFF9800),
                  ),
                ),
                SizedBox(height: 32,),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      codeSent ? TextFormField(
                        validator: (val){
                          return val.isEmpty || val.length != 6 ? "OTP Invalid" : null;
                        },
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6)
                        ],
                        keyboardType: TextInputType.number,
                        controller: _smsCodeController,
                        style: simpleTextStyle(),
                        decoration: textFieldInputDecoration("OTP"),
                      ) : TextFormField(
                        validator: (val){
                          return val.isEmpty || val.length != 10 ? "Please provide valid Phone Number" : null;
                        },
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10)
                        ],
                        keyboardType: TextInputType.number,
                        controller: _mobileNumberController,
                        style: simpleTextStyle(),
                        decoration: textFieldInputDecoration("Mobile Number"),
                      ),
                      SizedBox(height: 8,),
                      codeSent ? Container() : TextFormField(
                        validator: (val){
                          return val.isEmpty || val.length < 4 ? "Too Short" : null;
                        },
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(10)
                        ],
                        controller: _userNameController,
                        style: simpleTextStyle(),
                        decoration: textFieldInputDecoration("User Name"),
                      ),
                      SizedBox(height: 32,),
                      GestureDetector(
                        onTap: (){
                          phoneNumber = "+91" + _mobileNumberController.text.trim();
                          codeSent ? signInwhileTyping() : sendCodeToPhoneNumber(phoneNumber, context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFEF5350),
                                  const Color(0xFFE53935)
                                ]
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                            BoxShadow(
                            color: Color(0xFFD50000),
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 2.0,
                            ),]
                          ),
                          child: codeSent ? Text(
                            "SUBMIT",
                            style: mediumTextStyle(),
                          ) : Text(
                            "GET OTP",
                            style: mediumTextStyle(),
                          ),
                        ),
                      ),
                      SizedBox(height: 8,),
                      codeSent ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:[
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  codeSent = false;
                                });
                                },
                              child: Text(
                                  "Edit Phone Number",
                                style: TextStyle(
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                phoneNumber = "+91" + _mobileNumberController.text.trim();
                                codeSent ? signInwhileTyping() : sendCodeToPhoneNumber(phoneNumber, context);
                              },
                              child: Text(
                                "Re-send OTP",
                                style:TextStyle(
                                  color: Colors.black87,
                                )
                              ),
                            ),
                          ],
                        ),
                      ) : Container(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
