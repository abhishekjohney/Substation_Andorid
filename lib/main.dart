import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:substationapp/controller/substationncontroller.dart';
import 'package:substationapp/views/substationHome.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final SubstationController substationController = Get.put(SubstationController());
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Substationhome(),
    );
  }
}