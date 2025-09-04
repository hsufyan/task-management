import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:taskify/api_helper/header.dart';
import '../../../api_helper/api_base_helper.dart';
import '../../../config/end_points.dart';
import '../../../config/strings.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../localStorage/hive.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  Future<Map<String, dynamic>> signIn(
      {required String email, required String password}) async {
    try {
      var box = await Hive.openBox(fcmBox);
      String? fcmToken = box.get('fcmTokenId');
      print("AUTH REPO EMAIL: $email PASSWORD: $password FCM ID $fcmToken");
      Map<String, dynamic> body = {
        'email': email,
        'password': password,
        'fcm_token': fcmToken,
      };
      print("AUTH REPO Body:$body");
      var responses = await ApiBaseHelper.loginPost(
        url: getUserLoginApi,
        body: body,
      );
      log("********************** $responses \n URL $getUserLoginApi  \n BODY $body ******************");

      return responses;
    } catch (error) {
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> signUp(
      {required String firstname,
      required String type,
      required String lastname,
      required String company,
      required String role,
      required String email,
      required String password,
      required String conpassword}) async {
    try {
      var responses =
          await ApiBaseHelper.signUpPost(url: getUserSignUpApi, body: {
        "type": type,
        "password": password,
        "email": email,
        "first_name": firstname,
        "last_name": lastname,
        "company": company,
        "role": role,
        "password_confirmation": conpassword
      });

      return responses;
    } catch (error) {
      flutterToastCustom(msg: error.toString());
      throw Exception('Error occurred');
      // return error;
    }
  }

  Future<Map<String, dynamic>> resetPassword(
      {required String email, required String password}) async {
    try {
      var box = await Hive.openBox(fcmBox);
      String? fcmToken = box.get('fcmTokenId');
      print("AUTH REPO EMAIL: $email PASSWORD: $password FCM ID $fcmToken");
      Map<String, dynamic> body = {
        'email': email,
        'password': password,
      };

      var responses = await ApiBaseHelper.post(
        url: getPasswordResetUpApi,
        useAuthToken: false,
        body: body,
      );
      print(
          "********************** $responses \n URL $getUserLoginApi  \n BODY $body ******************");

      return responses;
    } catch (error) {
      print("=======Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  void getFcmId({
    String? fcmId,
  }) async {
    try {
      final Dio dio = Dio();
      print("sdrfddfd $fcmId");
      final Map<String, String>? header = await headers;
      await dio.patch(
        getUserFcmApi,
        data: {
          'fcm_token': fcmId, // The FCM token you want to update
        },
        options: Options(
          headers: header,
        ),
      );
    } catch (e, stacktrace) {
      print('Exception: $e');
      print('Stacktrace: $stacktrace');
    }
  }
  //SIGN OUT METHOD

  static Future signOut() async {
    HiveStorage.clearToken();
  }
}
