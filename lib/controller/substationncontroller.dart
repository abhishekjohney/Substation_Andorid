import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData;
import '../model/combolistmodel.dart';
import '../model/workrecordListModel.dart';
import '../utils/Constants.dart';
import 'package:flutter/material.dart';

class SubstationController extends GetxController {
  final Dio _dio = Dio();
  final TextEditingController searchController = TextEditingController();

  var isLoading = false.obs;
  RxBool showSearchResults = true.obs;

  RxList<ComboListModel> combolist = <ComboListModel>[].obs;
  RxList<WorkListModel> worklist = <WorkListModel>[].obs;

  RxString searchText = ''.obs;
  RxString worklistSearchText = ''.obs;

  List<ComboListModel> get filteredList {
    if (searchText.value.isEmpty) return [];
    return combolist
        .where((item) =>
    item.SSNAME?.toLowerCase().contains(searchText.value.toLowerCase()) ?? false)
        .toList();
  }

  List<WorkListModel> get filteredWorklist {
    final query = worklistSearchText.value.toLowerCase();
    if (query.isEmpty) return worklist;

    return worklist.where((item) {
      return (item.MAJOR?.toString().toLowerCase().contains(query) ?? false) ||
          (item.Project?.toString().toLowerCase().contains(query) ?? false) ||
          (item.TR?.toString().toLowerCase().contains(query) ?? false) ||
          (item.PACI?.toString().toLowerCase().contains(query) ?? false) ||
          (item.SGMAKE?.toString().toLowerCase().contains(query) ?? false) ||
          (item.SGTYPE?.toString().toLowerCase().contains(query) ?? false) ||
          (item.EntryDate?.toString().toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchSSList();
  }

  Future<void> fetchSSList() async {
    try {
      isLoading.value = true;
      final url = '${Constants.BASEURL}';

      FormData formData = FormData.fromMap({
        'title': 'GetSSList',
        'ReqSSName': 'combo list',
      });

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = response.data.toString().split('||JasonEnd')[0].trim();
        final decodedJson = json.decode(jsonResponse);
        final data = json.decode(decodedJson[0]['JSONData1']);

        combolist.value =
        List<ComboListModel>.from(data.map((e) => ComboListModel.fromJson(e)));
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load substations");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWorkList(String ssname) async {
    try {
      isLoading.value = true;
      final url = '${Constants.BASEURL}';

      FormData formData = FormData.fromMap({
        'title': 'GetWorkRecordsList',
        'ReqSSName': ssname,
      });

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = response.data.toString().split('||JasonEnd')[0].trim();
        final decodedJson = json.decode(jsonResponse);
        final data = json.decode(decodedJson[0]['JSONData1']);

        worklist.value =
        List<WorkListModel>.from(data.map((e) => WorkListModel.fromJson(e)));
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load work list");
    } finally {
      isLoading.value = false;
    }
  }

  String toDotNetDate(DateTime date) {
    final millis = date.millisecondsSinceEpoch;
    final offset = date.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return '\/Date($millis$sign$hours$minutes)\/';
  }

  // Add new work record
  Future<bool> addWorkRecord(WorkListModel newRecord) async {
    try {
      isLoading.value = true;
      final url = '${Constants.BASEURL}';
      // Convert EntryDate to .NET format if possible
      String entryDateStr = '';
      if (newRecord.EntryDate is DateTime) {
        entryDateStr = toDotNetDate(newRecord.EntryDate);
      } else if (newRecord.EntryDate is String) {
        try {
          final dt = DateTime.parse(newRecord.EntryDate);
          entryDateStr = toDotNetDate(dt);
        } catch (_) {
          entryDateStr = newRecord.EntryDate;
        }
      } else {
        entryDateStr = newRecord.EntryDate.toString();
      }
      final payload = {
        'title': 'UpdateWorkDetails',
        'description': 'Update Work Details',
        'ReqJSonData': jsonEncode([
          {
            'ActionType': 1,
            'RecordID': 0,
            'MAJOR': newRecord.MAJOR,
            'SSNAME': newRecord.SSNAME,
            'Project': newRecord.Project,
            'TR': newRecord.TR,
            'PACI': newRecord.PACI,
            'SGMAKE': newRecord.SGMAKE,
            'SGTYPE': newRecord.SGTYPE,
            'EntryDate': entryDateStr,
          }
        ]),
      };
      // Print payload for debugging
      // ignore: avoid_print
      print('AddWorkRecord Payload: ' + payload.toString());
      FormData formData = FormData.fromMap(payload);
      final response = await _dio.post(
        url,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      // Print response for debugging
      // ignore: avoid_print
      print('AddWorkRecord Response: ' + response.data.toString());
      if (response.statusCode == 200) {
        final jsonResponse = response.data.toString().split('||JasonEnd')[0].trim();
        final decodedJson = json.decode(jsonResponse);
        final newRecordId = decodedJson[0]['JSONData1'];
        Get.snackbar("Success", "Work record added. New Record ID: $newRecordId");
        // Optionally refresh the work list here
        // await fetchWorkList(newRecord.SSNAME);
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar("Error", "Failed to add work record");
      // ignore: avoid_print
      print('AddWorkRecord Error: ' + e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Edit work record
  Future<bool> editWorkRecord(WorkListModel updatedRecord) async {
    try {
      isLoading.value = true;
      final url = '${Constants.BASEURL}';
      // Convert EntryDate to .NET format if possible
      String entryDateStr = '';
      if (updatedRecord.EntryDate is DateTime) {
        entryDateStr = toDotNetDate(updatedRecord.EntryDate);
      } else if (updatedRecord.EntryDate is String) {
        try {
          final dt = DateTime.parse(updatedRecord.EntryDate);
          entryDateStr = toDotNetDate(dt);
        } catch (_) {
          entryDateStr = updatedRecord.EntryDate;
        }
      } else {
        entryDateStr = updatedRecord.EntryDate.toString();
      }
      final payload = {
        'title': 'UpdateWorkDetails',
        'description': 'Update Work Details',
        'ReqJSonData': jsonEncode([
          {
            'ActionType': 2,
            'RecordID': updatedRecord.RecordID,
            'MAJOR': updatedRecord.MAJOR,
            'SSNAME': updatedRecord.SSNAME,
            'Project': updatedRecord.Project,
            'TR': updatedRecord.TR,
            'PACI': updatedRecord.PACI,
            'SGMAKE': updatedRecord.SGMAKE,
            'SGTYPE': updatedRecord.SGTYPE,
            'EntryDate': entryDateStr,
          }
        ]),
      };
      // Print payload for debugging
      // ignore: avoid_print
      print('EditWorkRecord Payload: ' + payload.toString());
      FormData formData = FormData.fromMap(payload);
      final response = await _dio.post(
        url,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      // Print response for debugging
      // ignore: avoid_print
      print('EditWorkRecord Response: ' + response.data.toString());
      if (response.statusCode == 200) {
        final jsonResponse = response.data.toString().split('||JasonEnd')[0].trim();
        final decodedJson = json.decode(jsonResponse);
        final newRecordId = decodedJson[0]['JSONData1'];
        Get.snackbar("Success", "Work record updated. Record ID: $newRecordId");
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar("Error", "Failed to update work record");
      // ignore: avoid_print
      print('EditWorkRecord Error: ' + e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
