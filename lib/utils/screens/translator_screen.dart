import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:translator/translator.dart';
import 'package:sizer/sizer.dart';
import 'package:travel_minds/features/dashboard/screens/main/bottom_navigation.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreen();
}

class _TranslatorScreen extends State<TranslatorScreen> {
  final translator = GoogleTranslator();
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController inputController = TextEditingController();
  final TextEditingController translationController = TextEditingController();
  String fromLanguage = 'en';
  String toLanguage = 'fr';

  /// Prevents empty translations & handles errors
  textTranslator() async {
    if (inputController.text.isEmpty) return;

    try {
      final translation = await translator.translate(
        inputController.text,
        from: fromLanguage,
        to: toLanguage,
      );

      setState(() {
        translationController.text = translation.text;
      });
    } catch (e) {
      debugPrint("Translation Error: $e");
    }
  }

  /// Text-to-speech function
  speak(String text) async {
    if (text.isEmpty) return;
    await flutterTts.setLanguage(toLanguage);
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  Widget buildTextField(TextEditingController controller, String hintText, {bool isOutput = false}) {
    return Container(
      height: 20.h,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.3), // Same background for both fields
        borderRadius: BorderRadius.circular(20.sp),
        border: Border.all(color: Colors.white, width: 1.5), // Visible black border
      ),
      child: TextField(
        controller: controller,
        minLines: 6,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        readOnly: isOutput,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
          filled: true,
          fillColor: Colors.transparent,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none
            ),// Keep consistent background
          enabledBorder: OutlineInputBorder(

            borderSide: BorderSide.none // Border always visible
          ),
          // focusedBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(12),
          //   borderSide: BorderSide(color: Colors.blue, width: 2), // Highlight when selected
          // ),
          border: InputBorder.none
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(11, 16, 24, 1),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),
              IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (builder) => const BottomNavigationScreen()),
                        (route) => false,
                  );
                },
                icon: Icon(Icons.arrow_back_ios_new_outlined, size: 22.sp, color: Colors.white),
              ),
              const SizedBox(height: 30),
              Text(
                'translate_language'.tr,
                style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Input TextField
              buildTextField(inputController, "Type your text here..."),

              const SizedBox(height: 10),

              // Language Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: fromLanguage,
                      dropdownColor: Colors.black,
                      items: const ['en', 'fr', 'de', 'ja', 'zh', 'hi']
                          .map<DropdownMenuItem<String>>((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          fromLanguage = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Icon(Icons.arrow_forward, color: Colors.white),
                  const SizedBox(width: 20),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: toLanguage,
                      dropdownColor: Colors.black,
                      items: const ['en', 'fr', 'de', 'ja', 'zh', 'hi']
                          .map<DropdownMenuItem<String>>((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          toLanguage = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Translated TextField
              buildTextField(translationController, "Translated text will appear here...", isOutput: true),

              const SizedBox(height: 20),

              // Speak Button
              Center(
                child: IconButton(
                  onPressed: () {
                    speak(translationController.text);
                  },
                  icon: const Icon(Icons.volume_up_outlined, color: Colors.white, size: 30),
                ),
              ),

              // Translate Button
              GestureDetector(
                onTap: () {
                  textTranslator();
                },
                child: Center(
                  child: Container(
                    height: 5.h,
                    width: 40.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.sp),
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 123, 192, 215),
                          Color.fromARGB(255, 82, 200, 232),
                          Color.fromARGB(255, 22, 89, 112),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Translate",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 44, 66, 77),
                          fontSize: 17.5.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
