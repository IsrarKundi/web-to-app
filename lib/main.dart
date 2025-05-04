import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

// SplashScreen widget to show the container for 3 seconds
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToWebViewPage();
  }

  // Navigate to WebViewPage after 3 seconds
  Future<void> _navigateToWebViewPage() async {
    await Future.delayed(Duration(seconds: 3));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WebViewPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          color: Colors.white,
          child: Center(
            child: Text(
              'EVERYDAY\nFRANCE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w400,
                fontFamily: 'DomaineDisplay',
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// WebViewPage widget
class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {
  late WebViewController _controller;
  bool _hasInternet = true;
  String? _currentUrl;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _initConnectivity();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // Update the current URL when a page finishes loading
            setState(() {
              _currentUrl = url;
            });
          },
          onWebResourceError: (WebResourceError error) {
            // Optionally handle errors without showing a SnackBar
          },
        ),
      )
      ..loadRequest(Uri.parse('https://everydayfrance.com'));
  }

  // Initialize connectivity and listen for changes
  Future<void> _initConnectivity() async {
    final connectivity = Connectivity();
    // Check initial connectivity
    final initialStatus = await connectivity.checkConnectivity();
    setState(() {
      _hasInternet = initialStatus.isNotEmpty && !initialStatus.contains(ConnectivityResult.none);
    });

    // Listen for connectivity changes
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final hasInternet = results.isNotEmpty && !results.contains(ConnectivityResult.none);
      setState(() {
        _hasInternet = hasInternet;
      });
      if (hasInternet && _currentUrl != null) {
        _controller.loadRequest(Uri.parse(_currentUrl!));
      } else if (hasInternet) {
        _controller.loadRequest(Uri.parse('https://everydayfrance.com'));
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false; // Prevent app from closing
    }
    return true; // Allow app to close if no back history
  }

  // No Internet Widget
  Widget _noInternetWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/pngs/no_internet.png", width: 70, height: 70),
            const SizedBox(height: 16),
            Text(
              'No Internet Connection',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your network settings and try again.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: _hasInternet
              ? WebViewWidget(controller: _controller)
              : _noInternetWidget(),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
    ),
    home: SplashScreen(),
  ));
}