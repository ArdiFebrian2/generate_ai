import 'dart:io';

import 'package:flutter/material.dart';
import 'package:generate_ai/global_variabel.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController textEditingController = TextEditingController();
  String answer = '';
  File? image;
  bool isLoading = false;
  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
      });
    }
  }

  Future<void> sendRequest() async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: api_key,
    );

    final prompt = textEditingController.text.trim();
    if (prompt.isEmpty) {
      setState(() {
        answer = 'Please enter a prompt.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      answer = '';
    });

    final input = [
      Content.text(prompt),
      if (image != null) Content.data('image/jpeg', await image!.readAsBytes()),
    ];

    try {
      final response = await model.generateContent(input);
      setState(() {
        answer = response.text ?? 'No response from Gemini.';
      });
    } catch (e) {
      setState(() {
        answer = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade100,
        title: const Text('Gemini AI Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: textEditingController,
              decoration: const InputDecoration(
                hintText: 'Enter your request here',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: image == null ? Colors.grey.shade200 : null,
                image:
                    image != null
                        ? DecorationImage(
                          image: FileImage(image!),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  image == null
                      ? const Center(child: Text("No image selected"))
                      : null,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Pick Image'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : sendRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text('Send'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(answer),
          ],
        ),
      ),
    );
  }
}
