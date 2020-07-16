import 'dart:convert';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _autoTimer;

  String get userId {
    return _userId;
  }

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> authenticate(
    String urlSegment,
    String email,
    String password,
  ) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyDekB4Dk7h_08wUlFaRIJxOpFDeVpD88h0";
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
            seconds: int.parse(
          responseData['expiresIn'],
        )),
      );
      final pref=await SharedPreferences.getInstance();
      final userData=json.encode({
        'token':_token,
        'userId':_userId,
        'expiryDate':_expiryDate.toIso8601String(),
      });
      pref.setString('userData', userData);
      _autoLogout();
      notifyListeners(); 
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final pref=await SharedPreferences.getInstance();
    if(!pref.containsKey('userData')){
      return false;
    }
    final userData=json.decode(pref.getString('userData'))  as Map<String ,dynamic>;
    final expiryDate=DateTime.parse(userData['expiryDate']);

    if(expiryDate.isBefore(DateTime.now())){
      return false;
    }
    _token = userData['token'];
    _userId = userData['userId'];
    _expiryDate=expiryDate;
    _autoLogout();
    notifyListeners();
    return true;
  }

  Future<void> signup(String email, String password) async {
    return authenticate(
      "signUp",
      email,
      password,
    );
  }

  Future<void> signin(String email, String password) async {
    return authenticate(
      "signInWithPassword",
      email,
      password,
    );
  }



  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_autoTimer != null) {
      _autoTimer.cancel();
    }
    _autoTimer = null;
    notifyListeners();
    final pref=await SharedPreferences.getInstance();
    pref.clear();
  }

  void _autoLogout() {
    if (_autoTimer != null) {
      _autoTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _autoTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
