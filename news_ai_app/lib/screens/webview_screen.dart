// lib/screens/webview_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  
  // Start with loading = true to show the spinner
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(CupertinoColors.systemBackground)
      ..setNavigationDelegate(
        NavigationDelegate(
          // Use onPageStarted to be more responsive
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onHttpError: (HttpResponseError error) {
            setState(() {
              _isLoading = false;
            });
            print('Page failed to load with status: ${error.response?.statusCode}');
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
            print('Page navigation failed: ${error.description}');
          },
        ),
      );

    // --- THIS IS THE FIX ---
    // We wait until the page transition animation is 100% complete
    // and the first frame is painted. THEN, we load the URL.
    // This stops the Platform View from conflicting with the animation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the widget is still in the tree (mounted)
      if (mounted) {
        _controller.loadRequest(Uri.parse(widget.url));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // Ensure this nav bar and its text are NOT const
      // so they can correctly inherit the app's theme.
      navigationBar: CupertinoNavigationBar(
        middle: Text('Source'),
        trailing: const _CloseButton(),
      ),
      child: Stack(
        children: [
          // The WebViewWidget itself is lightweight.
          // It's the loadRequest that's heavy.
          WebViewWidget(controller: _controller),
          
          // The spinner will show until onPageFinished is called.
          if (_isLoading)
            const Center(
              child: CupertinoActivityIndicator(radius: 20.0),
            ),
        ],
      ),
    );
  }
}

// At the bottom of lib/screens/webview_screen.dart
class _CloseButton extends StatelessWidget {
  const _CloseButton();

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: const Icon(CupertinoIcons.clear_thick),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}