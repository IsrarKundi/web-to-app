// // splash_screen.dart
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'web_view_page.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   late final WebViewController _controller;
//   bool _isWebViewInitialized = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(const Color(0x00000000));
//
//     _loadWebsite(); // Start loading website immediately
//
//     // Wait for 3 seconds before navigating to the WebViewPage
//     Timer(const Duration(seconds: 5), () {
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const WebViewPage()),
//         );
//       }
//     });
//   }
//
//   void _loadWebsite() {
//     _controller.loadRequest(Uri.parse('https://everydayfrance.com'));
//     setState(() => _isWebViewInitialized = true);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: Text(
//           'EVERYDAY\nFRANCE',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontFamily: 'DomaineDisplay',
//             fontSize: 34,
//             fontWeight: FontWeight.w100,
//             color: Colors.black,
//           ),
//         ),
//       ),
//     );
//   }
// }
