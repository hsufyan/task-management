import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:taskify/config/strings.dart';
import '../config/error_message_code.dart';
import 'api.dart';
import '../utils/widgets/toast_widget.dart';
import '../../api_helper/header.dart';

class ApiBaseHelper {
  static Future<Map<String, dynamic>> loginPost({
    Map<String, dynamic>? body,
    required String url,
  }) async {
    try {
      final Dio dio = Dio();

      final response = await dio.post(url,
          data: body,
          options: Options(headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          }));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint(e.response?.data);
      throw ApiException(
          e.error is SocketException
              ? ErrorMessageKeysAndCode.noInternetCode
              : ErrorMessageKeysAndCode.defaultErrorMessageCode,
          isNoInternet: true);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      debugPrint("e: $e");
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> signUpPost({
    Map<String, dynamic>? body,
    required String url,
  }) async {
    try {
      final Dio dio = Dio();

      print('📤 Sending POST request to: $url');
      print('📦 Request Body: ${jsonEncode(body)}');

      final response = await dio.post(
        url,
        data: body,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }),
      );

      print('✅ Response Status Code: ${response.statusCode}');
      print('✅ Response Data: ${response.data}');

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('❌ DioException occurred!');
      debugPrint('❗ Status Code: ${e.response?.statusCode}');
      debugPrint('❗ Error Data: ${e.response?.data}');
      debugPrint('❗ Error Message: ${e.message}');
      throw ApiException(
        e.error is SocketException
            ? ErrorMessageKeysAndCode.noInternetCode
            : ErrorMessageKeysAndCode.defaultErrorMessageCode,
        isNoInternet: true,
      );
    } on ApiException catch (e) {
      print('❗ API Exception: ${e.errorMessage}');
      throw ApiException(e.errorMessage);
    } catch (e) {
      debugPrint('❗ Unexpected error occurred: $e');
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> post({
    Map<String, dynamic>? body,
    required String url,
    bool? useAuthToken,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      print("FDJ Fkd,zhgnd;x $body");
      body ??= {};
      print("FDJ Fkd,zhgnd;x $url");

      final Dio dio = Dio();
      final Map<String, String>? authHeaders = await headers;
      print("FDJ Fkd,z");

      final response = await dio.post(
        url,
        data: body,
        options: Options(
          headers: authHeaders,
        ),
      );
      print("dgklfgxcmg. $response");
      if (response.statusCode != 200) {
        flutterToastCustom(msg: "ghj ");
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e, stackTrace) {
      if (e.response != null) {
        print(e.response!.data);
        print(e.response!.headers);
        print(e.response!.requestOptions);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions.validateStatus);
        print(e.message);
      }
      print("sfgbgbdzvm  $stackTrace");
      if (e.response?.data != null) {
        return e.response?.data as Map<String, dynamic>;
      }
      debugPrint("Error Response Data: ${e.response?.data}");
      throw ApiException(
        e.error is SocketException
            ? ErrorMessageKeysAndCode.noInternetCode
            : ErrorMessageKeysAndCode.defaultErrorMessageCode,
        isNoInternet: true,
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      debugPrint("e: $e");
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> postImageWithText({
    Map<String, dynamic>? body,
    required String url,
    bool? useAuthToken,
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final Dio dio = Dio();
      print("ogk;lm $formData");
      for (var field in formData.fields) {
        print("Field: ${field.key} = ${field.value}");
        print("klesgkdx,nv ${field.key}");
      }
      final Map<String, String>? authHeaders = await headers;

      final response = await dio.post(url,
          data: formData, options: Options(headers: authHeaders));

      print("dgklfgxcmg. $response");
      if (response.statusCode != 200) {
        flutterToastCustom(msg: "ghj ");
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e, stackTrace) {
      if (e.response != null) {
        print(e.response!.data);
        print(e.response!.headers);
        print(e.response!.requestOptions);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions.validateStatus);
        print(e.message);
      }
      print("sfgbgbdzvm  $stackTrace");
      if (e.response?.data != null) {
        return e.response?.data as Map<String, dynamic>;
      }
      debugPrint("Error Response Data: ${e.response?.data}");
      throw ApiException(
        e.error is SocketException
            ? ErrorMessageKeysAndCode.noInternetCode
            : ErrorMessageKeysAndCode.defaultErrorMessageCode,
        isNoInternet: true,
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      debugPrint("e: $e");
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> postMedia({
    Map<String, dynamic>? body,
    required String url,
    bool? useAuthToken,
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final Dio dio = Dio();

      // Debugging FormData
      print("🚀 Sending FormData:");
      for (var field in formData.fields) {
        print("📄 Field: ${field.key} = ${field.value}");
      }
      for (var file in formData.files) {
        print("📂 File: ${file.key} = ${file.value.filename}");
      }

      final Map<String, String>? authHeaders = await headers;

      final response = await dio.post(
        url,
        data: formData,
        options: Options(headers: authHeaders),
      );
      if (response.data['error']) {
        throw ApiException(response.data['message']);
      }

      return <String, dynamic>{
        "data": Map.from(response.data),
        "status": 200,
      };
    } on DioException catch (e) {
      debugPrint(e.response?.data);
      throw ApiException(
          e.error is SocketException
              ? ErrorMessageKeysAndCode.noInternetCode
              : ErrorMessageKeysAndCode.defaultErrorMessageCode,
          isNoInternet: true);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      debugPrint("e: $e");
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<dynamic> postProfile({
    required String url,
    bool? useAuthToken,
    File? profile,
    String? type,
    int? id,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'upload': await MultipartFile.fromFile(profile!.path),
        'id': id,
        'type': type,
      });
      final Dio dio = Dio();
      final Map<String, String>? header = await headers;
      final response = await dio.post(
        url,
        data: formData,
        options: Options(headers: header),
      );
      if (response.data['error']) {
        throw ApiException(response.data['message']);
      }

      return <String, dynamic>{
        "data": Map.from(response.data),
        "status": 200,
      };
    } on DioException catch (e) {
      debugPrint(e.response?.data);
      throw ApiException(
          e.error is SocketException
              ? ErrorMessageKeysAndCode.noInternetCode
              : ErrorMessageKeysAndCode.defaultErrorMessageCode,
          isNoInternet: true);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      debugPrint("e: $e");
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<dynamic> patch({
    Map<String, dynamic>? body,
    required String url,
    bool? useAuthToken,
    // bool useLangCode = true,
    // String? refToken ,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      debugPrint("HEADER ? BODY $url $body");
      body ??= {};
      final Dio dio = Dio();
      FormData formData = FormData();
      final Map<String, String>? header = await headers;

      body.forEach((key, value) {
        if (value is File) {
          formData.files.add(MapEntry(
            key,
            MultipartFile.fromFileSync(value.path,
                filename: value.path.split('/').last),
          ));
        } else {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      final response = await dio.patch(
        url,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: header),
      );
      if (response.data['error']) {
        throw ApiException(response.data['message']);
      }

      return <String, dynamic>{
        "data": Map.from(response.data),
        "status": 200,
      };
    } on DioException catch (e) {
      debugPrint(e.response?.data);
      throw ApiException(
          e.error is SocketException
              ? ErrorMessageKeysAndCode.noInternetCode
              : ErrorMessageKeysAndCode.defaultErrorMessageCode,
          isNoInternet: true);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      debugPrint("e: $e");
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<dynamic> delete({
    Map<String, dynamic>? body,
    required String url,
    bool? useAuthToken,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      body ??= {};
      final Dio dio = Dio();
      FormData formData = FormData();
      final Map<String, String>? header = await headers;

      body.forEach((key, value) {
        if (value is File) {
          formData.files.add(MapEntry(
            key,
            MultipartFile.fromFileSync(value.path,
                filename: value.path.split('/').last),
          ));
        } else {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      final response = await dio.delete(
        url,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: header),
      );

      if (response.data['error']) {
        throw ApiException(response.data['message']);
      }

      return <String, dynamic>{
        "data": Map.from(response.data),
        "status": 200,
      };
    } on DioException catch (e) {
      flutterToastCustom(msg: e.response?.data['message']);
      throw ApiException(
          e.error is SocketException
              ? ErrorMessageKeysAndCode.noInternetCode
              : ErrorMessageKeysAndCode.defaultErrorMessageCode,
          isNoInternet: true);
    } on ApiException catch (e) {
      flutterToastCustom(msg: e.toString());
      throw ApiException(e.errorMessage);
    } catch (e) {
      print("e: $e");
      flutterToastCustom(msg: e.toString());
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> deleteApi({
    Map<String, dynamic>? body,
    required String url,
    bool? useAuthToken,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      body ??= {};
      final Dio dio = Dio();
      FormData formData = FormData();
      final Map<String, String>? header = await headers;

      body.forEach((key, value) {
        if (value is File) {
          formData.files.add(MapEntry(
            key,
            MultipartFile.fromFileSync(value.path,
                filename: value.path.split('/').last),
          ));
        } else {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      final response = await dio.delete(
        url,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: header),
      );

      if (response.data['error']) {
        throw ApiException(response.data['message']);
      }
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      flutterToastCustom(msg: e.response?.data['message']);

      throw ApiException(
          e.error is SocketException
              ? ErrorMessageKeysAndCode.noInternetCode
              : ErrorMessageKeysAndCode.defaultErrorMessageCode,
          isNoInternet: true);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      print("e: $e");
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<dynamic> get(
      {required String url,
      required bool useAuthToken,
      required Map<String, dynamic> params}) async {
    Response responseJson;
    final Dio dio = Dio();

    final Map<String, String>? header = await headers;
    try {
      final response = await dio.get(url,
          queryParameters: params, options: Options(headers: header));
      if (kDebugMode) {
        log('response api****PARAMS $params *********** $url *****************${response.statusCode}*********${response.data}');
      }
      responseJson = response;
    } on SocketException {
      throw ApiException('No Internet connection');
    }
    return responseJson;
  }

  // ===================== GET API =====================
  static Future<Map<String, dynamic>> getApi({
    required String url,
    required bool useAuthToken,
    required Map<String, dynamic> params,
  }) async {
    final Dio dio = Dio();

    print("====== ENTERING getApi ======");
    print("[DEBUG] URL=$url");
    print("[DEBUG] Params=$params");
    print("[DEBUG] useAuthToken=$useAuthToken");

    // Get default headers
    final Map<String, String>? header = await headers;
    print("[DEBUG] Headers retrieved from headers()=$header");

    // 🔹 Fetch workspace_id from Hive
    int? workspaceId;
    try {
      Box box = await Hive.openBox(userBox);
      workspaceId = box.get('workspace_id');
      print("[DEBUG] Hive returned workspace_id=$workspaceId");
      if (workspaceId != null) {
        header?["workspace-id"] = workspaceId.toString();
        print("[DEBUG] Added workspace-id header=$workspaceId");
      }
    } catch (e) {
      print("[WARN] Could not retrieve workspace_id: $e");
    }

    print("[DEBUG] Final Headers: $header");

    try {
      print("[DEBUG] Sending GET request...");
      final response = await dio.get(
        url,
        queryParameters: params,
        options: Options(headers: header),
      );

      print("[DEBUG] Response received");
      print("[DEBUG] Status Code=${response.statusCode}");
      print("[DEBUG] Response Data Type=${response.data.runtimeType}");
      print("[DEBUG] Response Data=${response.data}");

      print("====== EXITING getApi SUCCESSFULLY ======");
      return response.data as Map<String, dynamic>;
    } on SocketException catch (e) {
      print("[ERROR] SocketException: $e");
      throw ApiException('No Internet connection');
    } catch (e, stack) {
      print("[ERROR] Exception in getApi: $e");
      print("[ERROR] Stacktrace: $stack");
      throw ApiException('Error: $e');
    } finally {
      print("====== Exiting getApi ======");
    }
  }

  static Future<dynamic> getRole(
      {required String url,
      required bool useAuthToken,
      required Map<String, dynamic> params}) async {
    Response responseJson;
    final Dio dio = Dio();

    final Map<String, String>? header = await headers;

    try {
      final response = await dio.get(url,
          queryParameters: params, options: Options(headers: header));
      if (kDebugMode) {
        log('response api**** $url *****************${response.statusCode}*********${response.data}');
      }
      responseJson = response;
    } on SocketException {
      throw ApiException('No Internet connection');
    }
    return responseJson;
  }
}

class CustomException implements Exception {
  final String? _message;
  final String? _prefix;

  CustomException([this._message, this._prefix]);

  @override
  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends CustomException {
  FetchDataException([message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends CustomException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([message]) : super(message, "Unauthorised:");
}
