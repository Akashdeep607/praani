import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'connectivity_service.dart';

class ConnectivityController extends GetxController {
  final ConnectivityService _service = ConnectivityService();

  var isOnline = true.obs;
  var isRetrying = false.obs;
  @override
  void onInit() {
    super.onInit();
    checkConnection();
    listenToChanges();
  }

  void checkConnection() async {
    isOnline.value = await _service.hasInternetAccess();
  }

  void listenToChanges() {
    Connectivity().onConnectivityChanged.listen((event) async {
      var result = await _service.hasInternetAccess();
      isOnline.value = result;

      if (!result) {
        showNoInternetDialog();
      } else {
        if (Get.isDialogOpen ?? false) {
          Get.back(); // close dialog when internet returns
        }
      }
    });
  }

  void showNoInternetDialog() {
    if (!(Get.isDialogOpen ?? false)) {
      Get.dialog(
        Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),

                  const Text(
                    'No Internet Connection',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),
                  const Text('Please check your connection.'),

                  const SizedBox(height: 30),

                  /// 👇 THIS IS THE KEY CHANGE
                  Obx(() {
                    return isRetrying.value
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              isRetrying.value = true;

                              var retry = await _service.hasInternetAccess();
                             await Future.delayed(const Duration(seconds: 2));
                              isRetrying.value = false;

                              if (retry) {
                                Get.back();
                              }
                            },
                            child: const Text('Retry'),
                          );
                  }),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
    }
  }
}
