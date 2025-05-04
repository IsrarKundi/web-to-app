import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class InternetController extends GetxController {
  RxBool hasInternet = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkConnectivity();
    Connectivity().onConnectivityChanged.listen((result) {
      hasInternet.value = (result != ConnectivityResult.none);
    });
  }

  // Check for internet connectivity
  Future<void> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    hasInternet.value = (connectivityResult != ConnectivityResult.none);
  }
}
