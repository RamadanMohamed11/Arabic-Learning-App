// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter_gemini/flutter_gemini.dart';
// import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
// import 'dart:ui' as ui;

// class GeminiTestView extends StatefulWidget {
//   final String targetLetter;

//   const GeminiTestView({
//     super.key,
//     required this.targetLetter,
//   });

//   @override
//   State<GeminiTestView> createState() => _GeminiTestViewState();
// }

// class _GeminiTestViewState extends State<GeminiTestView> {
//   final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();
//   final gemini = Gemini.instance;
//   String _resultText = "اكتب الحرف المستهدف ثم اضغط تحقق";
//   Color _resultColor = Colors.grey;
//   bool _isLoading = false;

//   void _clearPad() {
//     _signaturePadKey.currentState!.clear();
//     setState(() {
//       _resultText = "اكتب الحرف المستهدف ثم اضغط تحقق";
//       _resultColor = Colors.grey;
//     });
//   }

//   Future<void> _checkHandwriting() async {
//     setState(() {
//       _isLoading = true;
//       _resultText = "جاري التحليل...";
//       _resultColor = Colors.blue;
//     });

//     try {
//       // 1. تحويل الرسمة إلى صورة
//       final ui.Image image = await _signaturePadKey.currentState!.toImage();
//       final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//       final Uint8List imageBytes = byteData!.buffer.asUint8List();

//       print('DEBUG: Image size: ${imageBytes.length} bytes');

//       // 2. السؤال
//       final String prompt = 
//           "هل الحرف في هذه الصورة هو الحرف العربي '${widget.targetLetter}'؟ أجب بكلمة 'نعم' أو 'لا' فقط بدون أي مقدمات أو شرح إضافي.";

//       print('DEBUG: Prompt: $prompt');

//       // 3. إرسال للـ Gemini (auto-selects vision model)
//       final response = await gemini.textAndImage(
//         text: prompt,
//         images: [imageBytes],
//       );

//       print('DEBUG: Response received');
//       print('DEBUG: Response content: ${response?.content}');

//       // 4. تحليل الإجابة
//       final String? answer = response?.content?.parts?.last.text?.trim().toLowerCase();
      
//       print('DEBUG: Answer: $answer');

//       if (answer != null && answer.contains('نعم')) {
//         setState(() {
//           _resultText = "إجابة صحيحة! أحسنت ✓";
//           _resultColor = Colors.green;
//         });
//       } else {
//         setState(() {
//           _resultText = "إجابة خاطئة، حاول مرة أخرى ✗\nالإجابة: $answer";
//           _resultColor = Colors.red;
//         });
//       }

//     } catch (e) {
//       print('DEBUG: Error: $e');
//       setState(() {
//         _resultText = "حدث خطأ: ${e.toString()}";
//         _resultColor = Colors.orange;
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("اختبار Gemini - حرف: '${widget.targetLetter}'"),
//         backgroundColor: Colors.indigo,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const SizedBox(height: 20),
//             Text(
//               "ارسم حرف: ${widget.targetLetter}",
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Container(
//                 height: 300,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   border: Border.all(color: Colors.indigo, width: 2),
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.5),
//                       spreadRadius: 2,
//                       blurRadius: 5,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: SfSignaturePad(
//                   key: _signaturePadKey,
//                   backgroundColor: Colors.white,
//                   strokeColor: Colors.black,
//                   minimumStrokeWidth: 20.0,
//                   maximumStrokeWidth: 25.0,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: _isLoading ? null : _checkHandwriting,
//                   icon: const Icon(Icons.check_circle_outline),
//                   label: const Text('تحقق'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                     textStyle: const TextStyle(fontSize: 16),
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: _isLoading ? null : _clearPad,
//                   icon: const Icon(Icons.clear_all_rounded),
//                   label: const Text('مسح'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.redAccent,
//                     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                     textStyle: const TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 30),
//             if (_isLoading)
//               const CircularProgressIndicator()
//             else
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: _resultColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: _resultColor, width: 2)
//                   ),
//                   child: Text(
//                     _resultText,
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: _resultColor,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
