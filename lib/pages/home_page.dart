import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magang_absen/models/request.dart';
import 'package:magang_absen/pages/absen_page.dart';
import 'package:magang_absen/pages/rekap_page.dart';
import 'package:intl/intl.dart';
import 'package:magang_absen/services/api_services.dart';
import 'package:magang_absen/services/utils.dart';
import 'package:quickalert/quickalert.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        _chipTop(screen),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            clipBehavior: Clip.none,
            shrinkWrap: true,
            children: [
              const Gap(25),
              ..._createHeader(context),
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

  List<Widget> _createHeader(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    var api = ApiServices.to();

    return [
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'logo',
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: kElevationToShadow[4],
                ),
                child: Image.asset(
                  'assets/icon.png',
                  width: 50,
                ),
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
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 3),
            ],
          ),
          child: Stack(
            children: [
              Container(
                color: Colors.blue,
                alignment: Alignment.centerRight,
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [Colors.black, Colors.transparent],
                    ).createShader(
                      Rect.fromLTRB(
                        0,
                        0,
                        rect.width,
                        rect.height,
                      ),
                    );
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    'assets/corak-batik.webp',
                    height: 400,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            api.userInfo?.fullname ??
                                api.userInfo?.username ??
                                '-',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(DateFormat.yMMMd().format(DateTime.now())),
                          const Spacer(),
                          Text(
                            api.userInfo?.satker ?? '-',
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
                  AspectRatio(
                    aspectRatio: 7 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black,
                          strokeAlign: BorderSide.strokeAlignOutside,
                        ),
                        color: Colors.white,
                      ),
                      clipBehavior: Clip.antiAlias,
                      margin: const EdgeInsets.all(5),
                      child: Image.network(
                        api.userInfo?.foto?.pict.downloadURL ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];
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
                onTap: () => _openRekapPage(context),
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

  void _openRekapPage(BuildContext context) {
    Get.to(const RekapPage());
  }

  void _openCheckInPage(BuildContext context) {
    var masuk = ApiServices.to().absenMasuk;

    if (masuk != null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.info,
        title: 'Absen Masuk',
        text:
            'Anda Sudah Absen Masuk ${formatTanggal(masuk.time.toLocal())} ${formatJam(masuk.time.toLocal())}',
      );
      return;
    }

    Get.to(const AbsenPage(
      type: Method.masuk,
    ));
  }

  void _openCheckOutPage(BuildContext context) {
    var pulang = ApiServices.to().absenPulang;

    if (pulang != null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.info,
        title: 'Absen Pulang',
        text:
            'Anda Sudah Absen Masuk ${formatTanggal(pulang.time.toLocal())} ${formatJam(pulang.time.toLocal())}',
      );
      return;
    }

    Get.to(const AbsenPage(
      type: Method.pulang,
    ));
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
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.label,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
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
