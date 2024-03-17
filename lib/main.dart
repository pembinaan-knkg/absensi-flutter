import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magang_absen/firebase_options.dart';
import 'package:magang_absen/pages/home_page.dart';
import 'package:magang_absen/locator.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:flutter_login/flutter_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setupServices();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: const LoginPage(),
    ),
  );
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: "APBM",
      logoTag: 'logo',
      titleTag: 'title',
      hideForgotPasswordButton: true,
      logo: const AssetImage('assets/icon.png'),
      userType: LoginUserType.name,
      userValidator: (v) => null,
      passwordValidator: (v) => null,
      onLogin: (v) => null,
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
    CustomScrollView(
      slivers: [
        SliverAppBar(
          leading: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_right),
          ),
          pinned: true,
          title: const Text("Notif Masuk"),
        ),
      ],
    ),
    CustomScrollView(
      slivers: [
        SliverAppBar(
          leading: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_right),
          ),
          pinned: true,
          title: const Text("Profile"),
        ),
      ],
    ),
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
              icon: const Icon(Icons.notifications),
              title: const Text("Notifications"),
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
