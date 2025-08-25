// ignore_for_file: use_build_context_synchronously, unused_local_variable, prefer_typing_uninitialized_variables


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/constants/apiConstants.dart';
import 'package:grocery_app/globalFuctions/globalFunctions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ApiHelper {
  //All Post type request will handle here
  getTypePost(
    BuildContext context,
    String uri,
    Map<String, String> params,
  ) async {
    String jsonResponse;
    var url = apiBaseUrl + uri;
    if (kDebugMode) {
      print(url);
    }
    if (kDebugMode) {
      print("params>>>>>$params");
    }

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields.addAll(params);
    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var value = await response.stream.bytesToString();

        jsonResponse = value.toString();

        var jsonMap = json.decode(jsonResponse);
        // print(jsonMap);

        return jsonMap;
      } else {
        Tgg.errorHandler(context, response.statusCode);
        if (kDebugMode) {
          print(response.reasonPhrase);
        }
      }
    } on SocketException {
      if (kDebugMode) {
        print("error");
      }
      throw ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Check Internet')));
      // Twl.createAlert(context,'dfd','dfdfd');
    }
  }

  //All Get type request will handle here
  getTypeGet(BuildContext context, String uri) async {
    var client = http.Client();
    var jsonMap;
    if (kDebugMode) {
      print("object");
    }
    try {
      var response = await client.get(Uri.parse(apiBaseUrl + uri));
      if (kDebugMode) {
        print("printthe respondse iubn api helper $response");
      }
      if (kDebugMode) {
        print(apiBaseUrl + uri);
      }
      if (response.statusCode == 200) {
        var jsonString = response.body;
        jsonMap = json.decode(jsonString);

        return jsonMap;
      } else {
        Tgg.errorHandler(context, response.statusCode);
      }
    } on SocketException {
      if (kDebugMode) {
        print("error");
      }
      throw ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Check Internet')));
    } on Exception {
      return jsonMap;
    }
  }

  Future<dynamic> getTypeRaw(
    BuildContext context,
    String uri,
    Map<String, dynamic> params,
  ) async {
    String jsonResponse;
    var url = apiBaseUrl + uri;
    if (kDebugMode) {
      print("API URL: $url");
    }

    var headers = {'Content-Type': 'application/json'};

    var request = http.Request('POST', Uri.parse(url));
    request.body = json.encode(params);
    if (kDebugMode) {
      print('Request Body: ${request.body}');
    }
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      // Read the response body
      String responseBody = await response.stream.bytesToString();
      if (kDebugMode) {
        print("Response Body: $responseBody");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseBody.isNotEmpty) {
          try {
            var jsonMap = json.decode(responseBody);
            print("printing the jsonMap $jsonMap");

            return jsonMap;
          } catch (e) {
            return {'status': '500', 'error': 'Invalid JSON format'};
          }
        } else {
          return {'status': '404', 'error': 'Empty response from server'};
        }
      } else if (response.statusCode == 400) {
        if (responseBody.isNotEmpty) {
          try {
            var jsonMap = json.decode(responseBody);

            return jsonMap;
          } catch (e) {
            return {
              'status': '400',
              'error': 'Invalid JSON format for 400 error',
            };
          }
        } else {
          return {'status': '400', 'error': 'Empty error response from server'};
        }
      } else if (response.statusCode == 500) {
        return {'status': '500', 'error': 'Internal Server Error'};
      } else {
        return {
          'status': response.statusCode.toString(),
          'error': 'Unhandled status code',
        };
      }
    } on SocketException {
      return {'status': '500', 'error': 'No Internet connection'};
    } catch (e) {
      return {'status': '500', 'error': 'An unexpected error occurred'};
    }
  }
}
