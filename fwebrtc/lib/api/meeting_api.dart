import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fwebrtc/constans.dart';
import 'package:fwebrtc/utils/user.utils.dart';
import 'package:http/http.dart' as http;

Dio dio = Dio();

String MEETING_API_URL = "http://$hosturl:4000/api/meeting";
var client = http.Client();
Future<http.Response> startMeeting() async {
  // dio.interceptors.add(PrettyDioLogger());
  Map<String, String> requestHeaders = {
    'content-type': 'application/json',
  };
  var userId = await loadUserId();

  var response = await client.post(
    Uri.parse('$MEETING_API_URL/start'),
    headers: requestHeaders,
    body: jsonEncode({"hostId": userId, "hostName": ""}),
  );
  log("start meeting ${response.body}");
  if (response.statusCode == 200) {
    return response;
  } else {
    return null!;
  }

  // try {
  //   var response = await dio.post('$MEETING_API_URL/start',
  //       data: {"hostId": userId, "hostName": ""});

  //   if (response.statusCode == 200) {
  //     log(response.data.toString());
  //     return response;
  //   } else {
  //     return null;
  //   }
  // } catch (e) {
  //   print(e);
  // }
}

Future<http.Response> joinMeeting(String meetId) async {
  var response =
      await http.get(Uri.parse('$MEETING_API_URL/join?meetingId=$meetId'));
  log(response.body);
  // try {
  //   var response1 = await dio
  //       .get("$MEETING_API_URL/join", queryParameters: {"meetingId": meetId});
  //   log("dio response " + response1.toString());
  // } on DioError catch (e) {
  //   log("Dio Error " + e.toString());
  // }

  if (response.statusCode == 200) {
    log("data join meeting ${response.statusCode} ${response.body}");
    return response;
  } else {
    throw UnsupportedError('Not a valid Meeting');
  }
}
