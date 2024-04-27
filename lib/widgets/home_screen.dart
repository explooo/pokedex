import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:pokedex/classifier/classifier.dart';

const _labelsFileName = 'assets/labels.txt';
const _modelFileName = 'model.tflite';

class home_screen extends StatefulWidget {
  const home_screen({super.key});

  @override
  State<home_screen> createState() => _home_screenState();
}

enum status {
  idle,
  notFound,
  found,
}

class _home_screenState extends State<home_screen> {
  final ImagePicker picker = ImagePicker();
  File? _selectedImageFile;
  status _status = status.idle;
  String _label = ''; // Name of Error Message
  double _accuracy = 0.0;
  bool _isAnalyzing = false;
  String _plantLabel = '';

  late Classifier _classifier;
  @override
  void initState() {
    super.initState();
    _loadClassifier();
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

    if (classifier != null) {
      _classifier = classifier;
    } else {
      // Handle the error
      debugPrint('Failed to load classifier');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _fabbutton(),
      body: Container(
        color: Theme.of(context).primaryColor,
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 50),
            ),
            Text(
              "Pokédex",
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pokemon',
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 30),
              child: Spacer(),
            ),
            _photoPriview(),
            Padding(
              padding: EdgeInsets.only(top: 30),
              child: _buildResultView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fabbutton() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      children: [
        SpeedDialChild(
          child: Icon(Icons.camera),
          label: 'Take Photo',
          onTap: () => _onPickPhoto(ImageSource.camera),
        ),
        SpeedDialChild(
          child: Icon(Icons.photo_library),
          label: 'Pick from Gallery',
          onTap: () => _onPickPhoto(ImageSource.gallery),
        ),
      ],
    );
  }

  Widget _photoPriview() {
    return PlantPhotoView(file: _selectedImageFile);
  }

  _onPickPhoto(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) {
      return;
    }

    final imageFile = File(pickedFile.path);
    setState(() {
      _selectedImageFile = imageFile;
    });

    _analyzeImage(imageFile);
  }

  void _setAnalyzing(bool flag) {
    setState(() {
      _isAnalyzing = flag;
    });
  }

  void _analyzeImage(File image) {
    _setAnalyzing(true);

    final imageInput = img.decodeImage(image.readAsBytesSync())!;

    final resultCategory = _classifier.predict(imageInput);

    final result = resultCategory.score >= 0.8 ? status.found : status.notFound;
    final plantLabel = resultCategory.label;
    final accuracy = resultCategory.score;

    _setAnalyzing(false);

    setState(() {
      _status = result;
      _plantLabel = plantLabel;
      _accuracy = accuracy;
    });
  }

  Widget _buildResultView() {
    var title = '';

    if (_status == status.notFound) {
      title = 'Fail to recognise';
    } else if (_status == status.found) {
      title = _plantLabel;
    } else {
      title = '';
    }

    //
    var accuracyLabel = '';
    if (_status == status.found) {
      accuracyLabel = 'Accuracy: ${(_accuracy * 100).toStringAsFixed(2)}%';
    }

    return Column(
      children: [
        Text("This is : $title",
            style: TextStyle(
              color: Theme.of(context).scaffoldBackgroundColor,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            )),
        const SizedBox(height: 10),
        Text(
          "with an accuracy of: $accuracyLabel",
          style: TextStyle(
            color: Theme.of(context).scaffoldBackgroundColor,
            fontSize: 18,
            // fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}

class PlantPhotoView extends StatelessWidget {
  final File? file;
  const PlantPhotoView({super.key, this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).secondaryHeaderColor,
        borderRadius: BorderRadius.circular(10),
      ),
      width: 300,
      height: 300,
      child: (file == null)
          ? const Center(
              child: Text(
              'No Image Selected',
            ))
          : ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(file!, fit: BoxFit.cover)),
    );
  }
}
