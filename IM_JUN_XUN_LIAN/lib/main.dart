import 'package:flutter/material.dart';
// import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:openim_common/openim_common.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'app.dart';

void main() => Config.init(() {
      AndroidWebViewController.enableDebugging(false);
      runApp(const ChatApp());
    });
