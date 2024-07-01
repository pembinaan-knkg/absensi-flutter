import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:magang_absen/firebase_options.dart';
import 'package:magang_absen/locator.dart';
import 'package:magang_absen/main.dart';
import 'package:magang_absen/services/api_services.dart';
import 'package:magang_absen/services/utils.dart';
import 'package:quickalert/quickalert.dart';
import 'package:get/get.dart';

class SplashWidget extends StatefulWidget {
  const SplashWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SplashWidgetState();
  }
}

class _SplashWidgetState extends State<SplashWidget> {
  Widget next = const LoginPage();

  @override
  void initState() {
    super.initState();
    setup().then((_) {
      Get.off(next, transition: Transition.downToUp);
    }).onError((e, trace) {
      debugPrintStack(stackTrace: trace);
      QuickAlert.show(
        context: context,
        title: 'Error',
        text: e.toString(),
        type: QuickAlertType.error,
        onConfirmBtnTap: () {
          Get.off(next, transition: Transition.downToUp);
        },
      );
    });
  }

  Future setup() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await initializeDateFormatting('id');
    setupServices();
    var cred = await loadCred();
    next = LoginPage(
      anggota: cred,
    );
    if (cred != null) {
      var user = await ApiServices.to().auth(cred);
      if (user.anggota != null) {
        next = const Main();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
