import 'dart:io';
import 'package:flutter/material.dart';
import '../styles.dart';

class ResultPage extends StatelessWidget {
  final File imageFile;
  final String label;
  final double accuracy;

  const ResultPage({
    super.key,
    required this.imageFile,
    required this.label,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        backgroundColor: kColorBrown,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: kBgColor,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Plant Recognised: $label',
              style: kTitleTextStyle,
            ),
            const SizedBox(height: 10),
            Text(
              'Accuracy: ${accuracy * 100}%',
              style: kResultRatingTextStyle,
            ),
            const SizedBox(height: 20),
            Image.file(
              imageFile,
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width * 0.8,
            ),
          ],
        ),
      ),
    );
  }
}
