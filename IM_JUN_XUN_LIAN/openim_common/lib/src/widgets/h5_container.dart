import 'package:flutter/material.dart';
import 'package:openim_common/openim_common.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class H5Container extends StatefulWidget {
  const H5Container({super.key, required this.url, this.title});

  final String url;
  final String? title;

  @override
  State<H5Container> createState() => _H5ContainerState();
}

class _H5ContainerState extends State<H5Container> {
  late final WebViewController webViewController;
  int progress = 0;

  @override
  void initState() {
    super.initState();
    Logger.print('H5Container: ${widget.url}');
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (v) {
            if (!mounted) return;
            if (v == progress || (v < 100 && v - progress < 5)) return;
            setState(() => progress = v);
          },
          onNavigationRequest: (request) async {
            final uri = Uri.parse(request.url);
            if (![
              "http",
              "https",
              "file",
              "chrome",
              "data",
              "javascript",
              "about"
            ].contains(uri.scheme)) {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: widget.title != null ? TitleBar.back(title: widget.title) : null,
      body: Stack(
        children: [
          WebViewWidget(controller: webViewController),
          if (progress < 100) LinearProgressIndicator(value: progress / 100),
        ],
      ),
    );
  }
}
