import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:webview_refresher/webview_refresher.dart';
import 'dart:async';
import 'splash_screen.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {
  late WebViewController _controller;
  bool _hasInternet = true;
  bool _isLoading = true;
  String? _currentUrl;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  Completer<void>? _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _initConnectivity();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print("Page started: $url");
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            print("Page finished: $url");
            setState(() {
              _currentUrl = url;
              _isLoading = false;
            });
            _finishRefresh();
          },
          onWebResourceError: (WebResourceError error) {
            print("Web resource error: ${error.description}");
            setState(() {
              _isLoading = false;
            });
            _finishRefresh();
          },
        ),
      )
      ..loadRequest(Uri.parse('https://everydayfrance.com/dashboard/'));
  }

  Future<void> _initConnectivity() async {
    final connectivity = Connectivity();
    final initialStatus = await connectivity.checkConnectivity();
    setState(() {
      _hasInternet = initialStatus.isNotEmpty &&
          !initialStatus.contains(ConnectivityResult.none);
    });

    _connectivitySubscription =
        connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
          final hasInternet =
              results.isNotEmpty && !results.contains(ConnectivityResult.none);
          if (_hasInternet != hasInternet) {
            // Only update if connectivity state changes
            setState(() {
              _hasInternet = hasInternet;
            });
            if (hasInternet && _currentUrl != null) {
              print("Reloading URL: $_currentUrl");
              _controller.loadRequest(Uri.parse(_currentUrl!));
            } else if (hasInternet) {
              print("Reloading default URL");
              _controller.loadRequest(Uri.parse('https://everydayfrance.com/dashboard/'));
            }
          }
        });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _refreshCompleter?.complete(); // Ensure completer is resolved
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    }
    return true;
  }

  Widget _noInternetWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.transparent,
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

  void _finishRefresh() {
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      print("Completing refresh");
      _refreshCompleter!.complete();
      _refreshCompleter = null; // Reset completer
    }
  }

  Future<void> _onRefresh() async {
    print("Starting refresh...");
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      _refreshCompleter!.complete(); // Complete any existing refresh
    }
    _refreshCompleter = Completer<void>();
    if (_hasInternet) {
      _controller.reload();
    } else {
      final result = await Connectivity().checkConnectivity();
      if (result.isNotEmpty && !result.contains(ConnectivityResult.none)) {
        setState(() {
          _hasInternet = true;
        });
        _controller.reload();
      } else {
        _finishRefresh();
      }
    }
    return _refreshCompleter!.future;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: _hasInternet
                        ? WebviewRefresher(
                      controller: _controller,
                      onRefresh: _onRefresh,
                    )
                        : _noInternetWidget(),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.white.withOpacity(0),
                child: Center(
                  child: LoadingAnimationWidget.hexagonDots(
                    color: Colors.black,
                    size: 60,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}