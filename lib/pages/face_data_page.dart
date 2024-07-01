import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:magang_absen/locator.dart';
import 'package:magang_absen/services/ml_services.dart';
import 'package:magang_absen/services/utils.dart';
import 'package:magang_absen/widgets/face_detector_view.dart';
import 'package:image/image.dart' as imglib;
import 'package:quickalert/quickalert.dart';

class FaceDataPage extends StatefulWidget {
  const FaceDataPage({super.key});

  @override
  State<StatefulWidget> createState() => _FaceDataPageState();
}

class _FaceDataPageState extends State<FaceDataPage> {
  final MLServices _mlServices = locator();
  Future<XFile> Function()? path;
  Face? face;
  CameraImage? image;
  final List<imglib.Image> _faces = [];
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          FaceDetectorView(
            onDetection: (image, faces, path) async {
              this.path = path;
              face = faces.firstOrNull;
              this.image = image;
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var face in _faces) Image.memory(imglib.encodeJpg(face))
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _test,
            child: const Icon(Icons.face),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _processData,
            child: const Icon(Icons.camera),
          ),
        ],
      ),
    );
  }

  Future _processData() async {
    if (_processing) return;
    setState(() {
      _processing = true;
    });
    if (_faces.length > 2) {
      toastHelper(
        context: context,
        title: 'Info',
        text: 'Maximal Data Gambar Tidak Lebih Dari 3',
      );
    } else if (face == null || path == null) {
      toastHelper(
          context: context, title: 'Error', text: 'Wajah Tidak Terdeteksi');
    } else {
      var img = cropFace((await fileToImage(await path!()))!, face!);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            elevation: 5,
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image(
                  image: MemoryImage(imglib.encodeJpg(img)),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _faces.add(img);
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Ambil"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Hapus"),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }
    }
    setState(() {
      _processing = false;
    });
  }

  void _test() async {
    if (path != null && face != null) {
      var img = await fileToImage(await path!());
      var target = await _mlServices.setCurrentPrediction(img!, face!);
      var t = 0.0;
      for (var f in _faces) {
        var d = await _mlServices.predictWithoutCrop(f);
        t += _mlServices.euclideanDistance(target, d);
      }
      t /= _faces.length;
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: t < 1 ? QuickAlertType.success : QuickAlertType.warning,
        title: t.toString(),
      );
    }
  }
}
