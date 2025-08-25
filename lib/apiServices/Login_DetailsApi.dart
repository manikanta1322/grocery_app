// ignore_for_file: avoid_print, camel_case_types

import 'package:flutter/material.dart';
import 'package:grocery_app/apiServices/ApiHelper.dart';
import 'package:grocery_app/constants/apiConstants.dart';

class Login_DetailsApi {
  signIn(BuildContext context, Map<String, String> param) async {
    var url = '$GA_JB_SIGNIN';
    print("Request URL: $url");
    var response = await ApiHelper().getTypeRaw(context, url, param);
    return response;
  }

  logIn(BuildContext context, Map<String, String> param) async {
    var url = '$GA_JB_LOGIN';
    print("Request URL: $url");
    var response = await ApiHelper().getTypeRaw(context, url, param);
    return response;
  }
}
