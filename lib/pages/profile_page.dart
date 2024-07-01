import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:magang_absen/main.dart';
import 'package:magang_absen/models/anggota_update_request.dart';
import 'package:magang_absen/pages/face_data_page.dart';
import 'package:magang_absen/services/api_services.dart';
import 'package:magang_absen/services/utils.dart';
import 'package:patterns_canvas/patterns_canvas.dart';
import 'package:quickalert/quickalert.dart';
import 'package:toastification/toastification.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiServices _apiServices = ApiServices.to();
  final TextEditingController _ubahPasswordLama = TextEditingController();
  final TextEditingController _ubahPasswordText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        CustomPaint(
          painter: BGPainter(),
          child: SafeArea(
            child: AspectRatio(
              aspectRatio: 9 / 5,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blue,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      offset: Offset(5, 5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/icon.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  const SizedBox(width: 10),
                                  // const Text("Kejari Kota Gorontalo"),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _apiServices.userInfo!.fullname ??
                                  _apiServices.userInfo!.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _apiServices.userInfo!.satker,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                decorationStyle: TextDecorationStyle.solid,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    AspectRatio(
                      aspectRatio: 7 / 9,
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.black,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                        ),
                        child: Image.network(
                          _apiServices.userInfo?.foto?.pict.downloadURL ?? "",
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
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _item(
            title: "Data Wajah",
            desc: "Input Data Wajah Untuk Pengenalan Wajah Saat Absen",
            icon: const Icon(Icons.face),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FaceDataPage(),
                ),
              );
            }),
        _item(
          icon: const Icon(Icons.password),
          title: "Lupa Password",
          desc: "Ubah Password",
          onTap: _ubahPassword,
        ),
        _item(
          icon: const Icon(Icons.file_open),
          title: "Foto Profile",
          desc: "Ubah Foto Profile",
          onTap: _ubahFotoProfile,
        ),
        _item(
          icon: const Icon(Icons.logout),
          title: "Logout",
          onTap: _logout,
        ),
      ],
    );
  }

  Widget _item({
    required String title,
    Icon? icon,
    String? desc,
    void Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Colors.black54),
        ),
        elevation: 8,
        shadowColor: Colors.yellow,
        child: ListTile(
          isThreeLine: desc is String,
          leading: icon,
          title: Text(title),
          subtitle: desc is String
              ? Text(
                  desc,
                  style: const TextStyle(fontSize: 12),
                )
              : null,
          onTap: onTap,
          trailing: const Icon(Icons.arrow_right),
        ),
      ),
    );
  }

  void _ubahPassword() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Ubah Password',
      widget: Column(
        children: [
          TextFormField(
            controller: _ubahPasswordLama,
            decoration: const InputDecoration(
              labelText: "Password Lama",
            ),
          ),
          TextFormField(
            controller: _ubahPasswordText,
            decoration: const InputDecoration(
              labelText: "Password Baru",
              helperText: 'Minimal 5 Huruf Tanpa Spasi',
            ),
          ),
        ],
      ),
      confirmBtnText: "Simpan",
      showCancelBtn: true,
      onConfirmBtnTap: () async {
        if (_ubahPasswordText.text.contains(" ")) {
          toast("Info", "Password Tidak Boleh Memiliki Spasi");
          return;
        }
        if (_ubahPasswordText.text.length < 5) {
          toast("Info", "Password Harus Lebih Dari 4 Huruf");
          return;
        }
        if (_ubahPasswordLama.text != _apiServices.user!.password) {
          toast("Info", "Password Lama Salah");
          return;
        }
        var toasti = toastification.show(
            showProgressBar: false,
            context: context,
            title: const Text('Ubah Password...'));
        var result = await _apiServices.updateAnggota(AnggotaUpdateRequest(
          credential: _apiServices.user!,
          data: AnggotaUpdateData(
            password: _ubahPasswordText.text,
          ),
        ));
        toastification.dismiss(toasti);
        if (mounted) {
          QuickAlert.show(
            context: context,
            type: result.success ? QuickAlertType.info : QuickAlertType.error,
            title: 'Ubah Password',
            text: result.message,
            onConfirmBtnTap: () {
              if (result.success) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginPage(
                      anggota: _apiServices.user!,
                    ),
                  ),
                  (route) => false,
                );
              } else {
                Navigator.pop(context);
              }
            },
          );
        }
      },
    );
  }

  void _ubahFotoProfile() async {
    var picker = ImagePicker();
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (mounted && image != null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.info,
        title: 'Update Foto Profile',
        widget: Center(
          child: Container(
            clipBehavior: Clip.antiAlias,
            height: MediaQuery.sizeOf(context).height * .3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black),
            ),
            child: AspectRatio(
              aspectRatio: 7 / 9,
              child: Image.file(
                File(image.path),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        showCancelBtn: true,
        onCancelBtnTap: () {
          Navigator.pop(context);
        },
        onConfirmBtnTap: () {
          Navigator.pop(context);
          _updateFotoProfile(image);
        },
        confirmBtnText: "Update",
      );
    }
  }

  Future _updateFotoProfile(XFile image) async {
    if (mounted) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.custom,
        title: 'Update Foto',
        widget: FutureBuilder(
          future: uploadPict(await image.readAsBytes(), _apiServices.user!),
          builder: (_, snap) {
            if (snap.hasError) {
              return Text(snap.error?.toString() ?? "Error Upload File");
            }
            if (snap.hasData) {
              return FutureBuilder(
                future: _apiServices.updateAnggota(
                  AnggotaUpdateRequest(
                    credential: _apiServices.user!,
                    data: AnggotaUpdateData(
                      profilePict: snap.data!,
                    ),
                  ),
                ),
                builder: (_, snap) {
                  if (snap.hasError) {
                    return Text(
                        snap.error?.toString() ?? "Gagal Update Foto Profile");
                  }
                  if (snap.hasData) {
                    _apiServices.userInfo = snap.data!.data;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(snap.data!.message),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Kembali"),
                        ),
                      ],
                    );
                  }
                  return const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      Text("Updating User Profile..."),
                    ],
                  );
                },
              );
            }
            return const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                Text("Uploading File..."),
              ],
            );
          },
        ),
        showConfirmBtn: false,
      );
    }
  }

  void _logout() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: "Logout",
      text: "Anda Yakin?",
      showCancelBtn: true,
      confirmBtnText: "Batal",
      cancelBtnText: "Keluar",
      onConfirmBtnTap: () {
        Navigator.pop(context);
      },
      onCancelBtnTap: () {
        deleteCred();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      },
    );
  }
}

class BGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const VerticalStripesThick(
      bgColor: Color(0xff0509050),
      fgColor: Color(0xfffdbf6f),
    ).paintOnWidget(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
