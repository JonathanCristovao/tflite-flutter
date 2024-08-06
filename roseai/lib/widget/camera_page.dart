import 'dart:io';

import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

import 'package:image/image.dart' as img;
import '../classifier/classifier.dart';
import 'result_page.dart';

const _labelsFileName = 'assets/labels.txt';
const _modelFileName = 'model_unquant.tflite';

class CameraViewPage extends StatefulWidget {
  @override
  _CameraViewPageState createState() => _CameraViewPageState();
}

enum _ResultStatus {
  notStarted,
  notFound,
  found,
}

class _CameraViewPageState extends State<CameraViewPage> {
  CameraController? cameraController;
  List<CameraDescription>? cameras;
  bool _isAnalyzing = false;
  final picker = ImagePicker();
  File? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();

  _ResultStatus _resultStatus = _ResultStatus.notStarted;
  String _plantLabel = '';
  double _accuracy = 0.0;

  late Classifier _classifier;

  @override
  void initState() {
    super.initState();
    initializeCamera();
    _loadClassifier();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      cameraController = CameraController(cameras![0], ResolutionPreset.medium);
      cameraController!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }
  }

  Future<void> _loadClassifier() async {
    debugPrint(
      'Start loading of Classifier with '
      'labels at $_labelsFileName, '
      'model at $_modelFileName',
    );

    final classifier = await Classifier.loadWith(
      labelsFileName: _labelsFileName,
      modelFileName: _modelFileName,
    );
    _classifier = classifier!;
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  Future<void> takePicture() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }
    final XFile image = await cameraController!.takePicture();
    _analyzeAndNavigate(File(image.path));
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    final xScale = cameraController!.value.aspectRatio / deviceRatio;
    final double yScale = 1;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            child: AspectRatio(
              aspectRatio: deviceRatio,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(xScale, yScale, 1),
                child: CameraPreview(cameraController!),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.close, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildPickPhotoButton(
                    title: 'Pick from gallery',
                    source: ImageSource.gallery,
                  ),
                  const SizedBox(width: 20),
                  _buildTakePhotoButton(
                    title: 'Take a photo',
                    source: ImageSource.camera,
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    onPressed: () {
                      print('IconButton pressed ...');
                    },
                    heroTag: 'btn3',
                    child: const Icon(Icons.question_mark),
                    backgroundColor: Colors.white54,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(55))),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickPhotoButton({
    required ImageSource source,
    required String title,
  }) {
    return FloatingActionButton(
      onPressed: () => _onPickPhoto(source),
      child: const Icon(Icons.photo_library),
      backgroundColor: Colors.white54,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(55))),
    );
  }

  Widget _buildTakePhotoButton({
    required ImageSource source,
    required String title,
  }) {
    return FloatingActionButton(
      onPressed: takePicture,
      child: const Icon(Icons.camera_alt),
      backgroundColor: Colors.white54,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(55))),
    );
  }

  void _setAnalyzing(bool flag) {
    setState(() {
      _isAnalyzing = flag;
    });
  }

  void _analyzeAndNavigate(File image) async {
    _setAnalyzing(true);
    final imageInput = img.decodeImage(image.readAsBytesSync())!;
    final resultCategory = _classifier.predict(imageInput);
    _setAnalyzing(false);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FlutterSplashScreen.gif(
            gifPath: 'assets/example.gif',
            gifWidth: 269,
            gifHeight: 474,
            nextScreen: ResultPage(
              imageFile: image,
              label: resultCategory.label,
              accuracy: resultCategory.score,
            ),
            duration: const Duration(milliseconds: 3515),
            onInit: () async {
              debugPrint("onInit");
            },
            onEnd: () async {
              debugPrint("onEnd 1");
            },
          ),
        ));
  }

  void _onPickPhoto(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);
    _analyzeAndNavigate(imageFile);
  }
}
