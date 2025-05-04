// import 'dart:io';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';
//
// class WebViewPage extends StatefulWidget {
//   const WebViewPage({super.key});
//
//   @override
//   State<WebViewPage> createState() => _WebViewPageState();
// }
//
// class _WebViewPageState extends State<WebViewPage> {
//   late final WebViewController _controller;
//   bool _isLoading = true;
//   bool _hasInternet = true;
//   bool _isWebViewInitialized = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _checkConnectivity();
//
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(const Color(0x00000000))
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onProgress: (int progress) {},
//           onWebResourceError: (WebResourceError error) {
//             debugPrint('WebView error: $error');
//           },
//           onNavigationRequest: (NavigationRequest request) {
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse('https://everydayfrance.com'));
//
//     Future.delayed(const Duration(seconds: 6), () {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     });
//   }
//
//   Future<void> _checkConnectivity() async {
//     final connectivityResult = await Connectivity().checkConnectivity();
//     setState(() {
//       _hasInternet = connectivityResult != ConnectivityResult.none;
//     });
//   }
//
//   // Handle back button press
//   Future<bool> _onWillPop() async {
//     if (await _controller.canGoBack()) {
//       _controller.goBack();
//       return false; // Prevent default back button behavior
//     }
//     return true; // Allow default back button behavior (e.g., exit app or go back)
//   }
//
//   Widget _noInternetWidget() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       color: Theme.of(context).scaffoldBackgroundColor,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               'assets/pngs/no_internet.png',
//               width: 60,
//               height: 60,
//               color: Colors.red,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No Internet Connection',
//               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: Theme.of(context).colorScheme.onSurface,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Please check your network settings and try again.',
//               style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                 color: Theme.of(context).colorScheme.onSurfaceVariant,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () async {
//                 await _checkConnectivity();
//                 if (_hasInternet) {
//                   _controller.loadRequest(Uri.parse('https://everydayfrance.com'));
//                   setState(() => _isWebViewInitialized = true);
//                 }
//               },
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: true, // Allow popping if _onWillPop returns true
//       onPopInvoked: (didPop) async {
//         if (didPop) return; // If already popped, do nothing
//         final shouldPop = await _onWillPop();
//         if (shouldPop && mounted) {
//           Navigator.of(context).pop(); // Allow system to handle back navigation
//         }
//       },
//       child: SafeArea(
//         child: Scaffold(
//           body: Stack(
//             children: [
//               if (_hasInternet && !_isLoading)
//                 WebViewWidget(controller: _controller),
//               if (!_hasInternet) _noInternetWidget(),
//               if (_isLoading)
//                 Container(
//                   color: Colors.white,
//                   child: Center(
//                     child: Text(
//                       'EVERYDAY\nFRANCE',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.w400,
//                         fontFamily: 'DomaineDisplay',
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }