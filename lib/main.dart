import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magang_absen/models/anggota.dart';
import 'package:magang_absen/pages/home_page.dart';
import 'package:magang_absen/pages/profile_page.dart';
import 'package:magang_absen/services/utils.dart';
import 'package:magang_absen/widgets/splash_widget.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:flutter_login/flutter_login.dart';

var globalState = GlobalKey<NavigatorState>();

void main() async {
  runApp(
    GetMaterialApp(
      navigatorKey: globalState,
      defaultTransition: Transition.cupertino,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: const SplashWidget(),
    ),
  );
}

class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
    this.anggota,
  });
  final Anggota? anggota;

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: "APBM",
      logoTag: 'logo',
      titleTag: 'title',
      hideForgotPasswordButton: true,
      savedEmail: anggota?.username ?? '',
      savedPassword: anggota?.password ?? '',
      logo: const AssetImage('assets/icon.png'),
      userType: LoginUserType.name,
      userValidator: (v) => null,
      passwordValidator: (v) => null,
      onLogin: (v) async {
        var anggota = Anggota(username: v.name, password: v.password);
        var res = await authenticate(anggota);
        if (res.anggota == null) return res.message;
        saveCred(anggota);
        return null;
      },
      onRecoverPassword: (v) => null,
      onSubmitAnimationCompleted: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Main(),
          ),
        );
      },
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  List<Widget> screens = [
    const HomePage(),
    const ProfilePage(),
  ];
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: GoogleFonts.poppins(),
      child: Scaffold(
        body: screens[_pageIndex],
        bottomNavigationBar: SalomonBottomBar(
          backgroundColor: Colors.lightBlue.withOpacity(.1),
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          currentIndex: _pageIndex,
          onTap: (index) => setState(() => _pageIndex = index),
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.home),
              title: const Text("Home"),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.person),
              title: const Text("Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
