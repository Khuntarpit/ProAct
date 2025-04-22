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
      'model': 'meta-llama/llama-3-8b-instruct',
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
