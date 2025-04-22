import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:proact/network/network_exceptions.dart';

class NetworkApiServices {
  Future postAIPromptApi(String prompt) async {
    Map<String, dynamic> jsonObject = {
      'model': 'nvidia/llama-3.1-nemotron-70b-instruct:free',
      'messages': [
        {'role': 'user', "content": prompt}
      ]
    };
    // var jsonData = jsonDecode(datastr);
    String data = jsonEncode(jsonObject);
    if (kDebugMode) {
      // print(url);
      print(data);
    }
    dynamic responseJson;
    try {
      final response = await http
          .post(
            Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "Authorization":
                  "Bearer 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"
            },
            body: data,
          )
          .timeout(const Duration(seconds: 30));
      responseJson = returnResponse(response);
      if (kDebugMode) {
        print(responseJson);
      }
    } on SocketException {
      throw InternetException('');
    } on TimeoutException { 
      throw RequestTimeOut('');
    }
    return responseJson;
  }

  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;

      case 400:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;

      default:
        try {
          dynamic responseJson = jsonDecode(response.body);
          return responseJson;
        } catch (error) {
          error.printError();
        }
    }
  }
}
