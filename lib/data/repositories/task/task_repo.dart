import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:taskify/config/strings.dart';

import '../../../api_helper/api_base_helper.dart';
import '../../../config/end_points.dart';

class TaskRepo {
  Future<Map<String, dynamic>> createTask(
      {required String title,
      required int statusId,
      // required int priorityId,
      required String startDate,
      required String dueDate,
      required String desc,
      // required int project,
      required String note,
      required List<int> userId,
      String? search}) async {
    try {
      Map<String, dynamic> body = {
        "title": title,
        "status_id": statusId,
        //  "priority_id": priorityId,
        "start_date": startDate,
        "due_date": dueDate,
        "description": desc,
        //  "project": project,
        "note": note,
        "user_id": userId,
      };
      if (search != null) {
        body["search"] = search;
      }

      final response = await ApiBaseHelper.post(
        url: createTaskUrl,
        useAuthToken: true,
        body: body,
      );
      print("task working ${response['data']}");
      // rows = response['data'] as List<dynamic>;
      // for (var row in rows) {
      //   task.add(CreateTaskModel.fromJson(row as Map<String, dynamic>));
      // }
      return response;
    } catch (error) {
      print("=======Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

// Store user_id in Hive
  static Future<void> setUserId(int userId) async {
    Box box = await Hive.openBox(userBox);
    await box.put('user_id', userId);
  }

// Fetch tasks (with user_id from Hive if not explicitly passed)
 // ===================== SET ROLE =====================
static Future<void> setRole(String role) async {
  Box box = await Hive.openBox(userBox);
  await box.put('role', role);
  print("[INFO] Role saved: $role");
}

// ===================== GET TASK =====================
Future<Map<String, dynamic>> getTask({
  int? offset,
  int? limit,
  required bool token,
  String? search,
  List<int>? userId, // optional override
  List<int>? projectId,
  List<int>? clientId,
  List<int>? priorityId,
  List<int>? statusId,
  String? toDate,
  String? fromDate,
  int? id,
  bool? subtask,
  int? isFav,
}) async {
  try {
    print("====== ENTERING getTask ======");

    // 🔹 Fetch stored user_id if not provided
    if (userId == null || userId.isEmpty) {
      Box box = await Hive.openBox(userBox);
      int? storedUserId = box.get('user_id');
      if (storedUserId != null) {
        userId = [storedUserId];
        print("[INFO] Using stored user_id: $storedUserId");
      }
    }

    // 🔹 Fetch role from Hive
    Box box = await Hive.openBox(userBox);
    String role = box.get('role', defaultValue: "member");
    print("[INFO] Current role: $role");

    // ===================== BODY (only for member) =====================
    Map<String, dynamic> body = {};
    if (role == "member") {
      if (userId != null && userId.isNotEmpty) {
        body["user_ids[]"] = userId;
      }
    }

    print(">>> FINAL BODY BEFORE API CALL: $body");

    // ===================== API CALL =====================
    Map<String, dynamic> response;

    if (role == "member") {
      // ----- MEMBER -----
      if (subtask == true && id != null) {
        response = await ApiBaseHelper.getApi(
          url: getAllTaskUrl,
          useAuthToken: token,
          params: body,
        );
      } else if (id != null) {
        response = await ApiBaseHelper.getApi(
        url: "$getAllTaskUrl?user_ids[]=${userId!.first}",

          useAuthToken: token,
          params: body,
        );
      } else {
        response = await ApiBaseHelper.getApi(
          url: getAllTaskUrl,
          useAuthToken: token,
          params: body,
        );
      }
    } else {
      // ----- ADMIN -----
      if (subtask == true && id != null) {
        response = await ApiBaseHelper.getApi(
          url: getAllTaskUrl,
          useAuthToken: token,
          params: {},
        );
      } else if (id != null) {
        response = await ApiBaseHelper.getApi(
         url: "$getAllTaskUrl?user_ids[]=${userId!.first}",

          useAuthToken: token,
          params: {},
        );
      } else {
        response = await ApiBaseHelper.getApi(
          url: getAllTaskUrl,
          useAuthToken: token,
          params: {},
        );
      }
    }

    if (response['error'] == true) {
      throw Exception('Server error: ${response['message']}');
    }

    print("====== EXITING getTask SUCCESSFULLY ======");
    return response;
  } catch (error, stack) {
    print("!!! ERROR in getTask: $error");
    print("STACKTRACE: $stack");
    throw Exception('Failed to fetch tasks: $error');
  }
}

  Future<Map<String, dynamic>> getTasksFav({
    int? limit,
    int? offset,
    String? search = "",
    int? isFav,
  }) async {
    try {
      Map<String, dynamic> body = {};

// Add parameters to the request body, avoiding null values
      if (search?.isNotEmpty ?? false) body["search"] = search;
      if (limit != null) body["limit"] = limit;
      if (offset != null) body["offset"] = offset;
      if (isFav != null) body["is_favorites"] = isFav;

      print("Request body: $body");

      // Make API call based on whether an id is provided
      final response = await ApiBaseHelper.getApi(
        url: getAllTaskUrl,
        useAuthToken: true,
        params: body,
      );

      print("BODY $body RESPONSE PROJECT $response");
      return response;
    } catch (error) {
      print("=======Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> getDeleteTask({
    required String id,
    required bool token,
  }) async {
    // Map<String, dynamic> rows;

    try {
      print("rftgyhujikl Id $id");
      final response = await ApiBaseHelper.deleteApi(
          url: "$deleteTask/$id", useAuthToken: true, body: {});

      // rows = response as Map<String, dynamic>;
      // for (var row in rows) {
      //   Todos.add(TodosModel.fromJson(row as Map<String, dynamic>));
      // }
      return response;
    } catch (error) {
      print("=======Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateTask({
    required int id,
    required String title,
    required int statusId,
    // required int priorityId,
    required String startDate,
    required String dueDate,
    required String desc,
    required String note,
    required List<int> userId,
  }) async {
    print("tgyhjkl }");

    try {
      Map<String, dynamic> body = {
        "id": id,
        "title": title,
        "status_id": statusId,
        // "priority_id": priorityId,
        "start_date": startDate,
        "due_date": dueDate,
        "description": desc,
        "note": note,
        "user_id": userId,
      };
      final response = await ApiBaseHelper.post(
          url: updateTaskUrl, useAuthToken: true, body: body);
      print("ertyguhnjmk,l");
      print("ye response hai, $response");
      // rows = response['data']['data'] as Map<String, dynamic>;

      return response;
    } catch (error) {
      print("=======Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateTaskPinned({
    required int id,
    required int isPinned,
  }) async {
    try {
      Map<String, dynamic> body = {
        "id": id,
        "is_pinned": isPinned,
      };

      final response = await ApiBaseHelper.patch(
        url: "$getAllTaskUrl/$id/pinned",
        useAuthToken: true,
        body: body,
      );
      return response;
    } catch (error) {
      print("=======Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> updateTaskFavorite({
    required int id,
    required int isFavorite,
  }) async {
    try {
      print("u gkujg 4=$isFavorite");
      Map<String, dynamic> body = {
        "id": id,
        "is_favorite": isFavorite,
      };

      final response = await ApiBaseHelper.patch(
        url: "$getAllTaskUrl/$id/favorite",
        useAuthToken: true,
        body: body,
      );
      return response;
    } catch (error) {
      print("=======Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> getTaskMedia({
    int? id,
    int? limit,
    int? offset,
    String? search = "",
  }) async {
    try {
      Map<String, dynamic> body = {};
      print("oeiurfotesu $search");
// Add parameters to the request body, avoiding null values
      if (search?.isNotEmpty ?? false) body["search"] = search;
      if (limit != null) body["limit"] = limit;
      if (offset != null) body["offset"] = offset;

      final response = await ApiBaseHelper.getApi(
        url: "$taskMediaUrl/$id",
        useAuthToken: true,
        params: body,
      );

      print("BODY $body RESPONSE PROJECT $response");
      return response;
    } catch (error) {
      print("=======Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> getTaskTimeLineStatus({
    int? id,
    int? limit,
    int? offset,
    String? search = "",
  }) async {
    try {
      Map<String, dynamic> body = {};

// Add parameters to the request body, avoiding null values
      if (search?.isNotEmpty ?? false) body["search"] = search;
      if (limit != null) body["limit"] = limit;
      if (offset != null) body["offset"] = offset;

      final response = await ApiBaseHelper.getApi(
        url: "$taskTimelineStatusUrl$id/status-timelines",
        useAuthToken: true,
        params: body,
      );

      print("BODY $body RESPONSE PROJECT $response");
      return response;
    } catch (error) {
      print("=======Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> getDeleteTaskMedia({
    required String id,
    required bool token,
  }) async {
    try {
      final response = await ApiBaseHelper.delete(
          url: "$deleteTaskMediaUrl/$id", useAuthToken: true, body: {});

      return response;
    } catch (error) {
      print("=======Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> uploadTaskMedia({
    required int id,
    required List<File> media,
  }) async {
    try {
      // Convert List<File> into List<MultipartFile>
      List<MultipartFile> mediaFiles = await Future.wait(
        media.map(
          (file) async => await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ),
      );
      print("fvgNDJGvhn ${mediaFiles.length}");
      mediaFiles.asMap().forEach((index, file) {
        print('File $index:');
        print('  - Length: ${file.length}');
        print('  - Filename: ${file.filename}');
      });

      FormData formData = FormData.fromMap({
        "id": id.toString(),
        "media_files[]": mediaFiles,
      });

      // Make API call
      final response = await ApiBaseHelper.postMedia(
        url: "$uploadTaskMediaUrl",
        useAuthToken: true,
        formData: formData,
      );

      return response;
    } catch (error) {
      print("=======Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
}
