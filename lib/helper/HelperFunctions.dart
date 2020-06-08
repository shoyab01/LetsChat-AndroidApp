import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String sharedPreferenceUserLoggedInKey = "ISLOGGEDIN";
  static String sharedPreferencePhoneNumberKey = "PHONENUMBERKEY";
  static String sharedPreferenceMyUserNameKey = "PHONENUMBERKEY";

  //saving data to SharedPreference
  static Future<bool> saveUserLoggedInSharedPreference(bool isUserLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(sharedPreferenceUserLoggedInKey, isUserLoggedIn);
  }

  static Future<bool> savePhoneNumberSharedPreference(String phoneNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferencePhoneNumberKey, phoneNumber);
  }

  static Future<bool> saveMyUserNameSharedPreference(String myUserName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferenceMyUserNameKey, myUserName);
  }


  ////////////////////////////////////////////////////////////////////////////////////////////////////////////


  //getting data from SharedPreference
  static Future<bool> getUserLoggedInSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(sharedPreferenceUserLoggedInKey);
  }

  static Future<String> getphoneNumberSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(sharedPreferencePhoneNumberKey);
  }

  static Future<String> getMyUserNameSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(sharedPreferenceMyUserNameKey);
  }
}