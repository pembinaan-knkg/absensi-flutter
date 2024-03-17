import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magang_absen/pages/absen_page.dart';
import 'package:magang_absen/pages/rekap_page.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImageProvider _bg = const AssetImage('assets/corak-batik.webp');

  @override
  void didChangeDependencies() {
    precacheImage(_bg, context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        _chipTop(screen),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              const Gap(25),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Image.asset(
                        'assets/icon.png',
                        width: 50,
                      ),
                    ),
                    const Gap(10),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'title',
                          child: Text(
                            "APBM",
                            style: GoogleFonts.nunito(
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                        ),
                        Text(
                          "Absen Pramubakti Mobile",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                        ),
                        Text(
                          "Kejaksaan Negeri Kota Gorontalo",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // Text(
                        //   "Kejaksaan Negeri Kota Gorontalo",
                        //   style: GoogleFonts.poppins(
                        //     textStyle: const TextStyle(height: 1),
                        //     color: Colors.white,
                        //     fontSize: 16,
                        //     fontWeight: FontWeight.w500,
                        //   ),
                        // ),
                      ],
                    )
                  ],
                ),
              ),
              const Gap(10),
              DefaultTextStyle(
                style: const TextStyle(color: Colors.white),
                child: Container(
                  height: screen.height * .2,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    // gradient: const LinearGradient(
                    //   colors: [Colors.lightBlue, Colors.blue],
                    //   stops: [.0, .3],
                    // ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 3),
                    ],
                  ),
                  child: Stack(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: _bg,
                            repeat: ImageRepeat.repeat,
                          ),
                        ),
                        child: Container(),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: FractionalOffset.bottomRight,
                            end: FractionalOffset.topLeft,
                            colors: [
                              const Color(0xff0d69ff).withOpacity(0.0),
                              const Color(0xff0069ff).withOpacity(1),
                              const Color(0xff0069ff).withOpacity(1),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hai Agnes",
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(DateFormat.yMMMd()
                                      .format(DateTime.now())),
                                  const Spacer(),
                                  Text(
                                    "PRAMU",
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Container(
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(20),
                          //     border: Border.all(color: Colors.black, width: 1),
                          //     color: Colors.white.withOpacity(.2),
                          //   ),
                          //   margin: const EdgeInsets.all(3),
                          //   width: 120,
                          //   height: double.infinity,
                          //   child: const Icon(Icons.person, size: 100),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(20),
              _createItems(context),
            ],
          ),
        ),
      ],
    );
  }

  Align _chipTop(Size screen) {
    return Align(
      alignment: Alignment.topCenter,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
        ),
        child: Container(
          width: screen.width,
          height: screen.height * .25,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _createItems(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _createRowItems(
            [
              Image.asset("assets/images/calendar.png"),
              Image.asset("assets/images/contract.png")
            ],
            ["Absen Masuk", "Absen Pulang"],
            [Colors.lightGreen, Colors.lightBlueAccent],
            [() => _openCheckInPage(context), () => _openCheckOutPage(context)],
          ),
          Row(
            children: [
              _AbsenItem(
                label: "Rekap Absen",
                icon: Image.asset("assets/images/mail.png"),
                onTap: () => _openIzinPage(context),
              ),
              Expanded(child: Container()),
            ],
          ),
        ],
      ),
    );
  }

  Row _createRowItems(
    List<Widget> icons,
    List<String> labels,
    List<Color> colors,
    List<void Function()> onTaps,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < icons.length; i++)
          _AbsenItem(
            label: labels[i],
            icon: icons[i],
            onTap: onTaps.length != icons.length ? null : onTaps[i],
            color: colors.length != icons.length ? null : colors[i],
          )
      ],
    );
  }

  void _openIzinPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => const RekapPage(rekapType: RekapType.masuk),
      ),
    );
  }

  void _openCheckInPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: AbsenPage(
            onSuccess: (imgPath) {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.success,
                title: "Sukses",
                text:
                    "Anda Berhasil Absen Masuk Di Tanggal ${_formatTanggal(DateTime.now())} Jam ${_formatWaktu(DateTime.now())}",
                onConfirmBtnTap: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                confirmBtnText: "Kembali",
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatTanggal(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  String _formatWaktu(DateTime date) {
    return DateFormat.Hm().format(date);
  }

  // void _showImage(XFile imagePath, BuildContext context, DateTime time) {
  //   Navigator.of(context).pushReplacement(
  //     MaterialPageRoute(
  //       builder: (_) => AbsenResult(
  //         imagePath: imagePath,
  //         time: time,
  //         onConfirm: () {},
  //       ),
  //     ),
  //   );
  // }

  void _openCheckOutPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: AbsenPage(
            onSuccess: (image) {
              QuickAlert.show(
                disableBackBtn: true,
                context: context,
                type: QuickAlertType.success,
                title: "Sukses",
                text:
                    "Anda Berhasil Absen Pulang Di Tanggal ${_formatTanggal(DateTime.now())} Jam ${_formatWaktu(DateTime.now())}",
                onConfirmBtnTap: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                confirmBtnText: "Kembali",
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AbsenItem extends StatefulWidget {
  const _AbsenItem({
    required this.label,
    required this.icon,
    this.color,
    this.onTap,
  });

  final Color? color;
  final String label;
  final Widget icon;
  final void Function()? onTap;

  @override
  State<_AbsenItem> createState() => __AbsenItemState();
}

class __AbsenItemState extends State<_AbsenItem> with TickerProviderStateMixin {
  late final _iconController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              if (widget.onTap != null) widget.onTap!();
            },
            onTapDown: (ev) {
              _iconController
                  .forward()
                  .then((value) => _iconController.reverse());
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(dimension: 60, child: widget.icon),
                  const Gap(15),
                  Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rubik(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
