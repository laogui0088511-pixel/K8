import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 腾讯h5地图
class ChatWebViewMap extends StatefulWidget {
  const ChatWebViewMap({
    super.key,
    this.mapAppKey = "",
    this.mapThumbnailSize = "1200*600",
    this.mapBackUrl = "http://callback",
    this.latitude,
    this.longitude,
  });

  final String mapAppKey;
  final String mapThumbnailSize;
  final String mapBackUrl;
  final double? latitude;
  final double? longitude;

  @override
  State<ChatWebViewMap> createState() => _ChatWebViewMapState();
}

class _ChatWebViewMapState extends State<ChatWebViewMap> {
  late final WebViewController webViewController;
  String url = '';
  int progress = 0;
  double? latitude;
  double? longitude;
  String? description;

  /// 定位获取
  late String locationUrl;
  late String thumbnailUrl;

  /// 根据定位坐标预览
  late String previewLocationUrl;

  _initUrl() {
    locationUrl =
        "https://apis.map.qq.com/tools/locpicker?search=1&type=0&backurl=${widget.mapBackUrl}&key=${widget.mapAppKey}&referer=myapp&policy=1";
    thumbnailUrl =
        "https://apis.map.qq.com/ws/staticmap/v2/?center=&zoom=18&size=${widget.mapThumbnailSize}&maptype=roadmap&markers=size:large|color:0xFFCCFF|label:k|&key=${widget.mapAppKey}";
    previewLocationUrl =
        "https://apis.map.qq.com/uri/v1/geocoder?coord=${widget.latitude},${widget.longitude}&referer=${widget.mapAppKey}";
  }

  bool get isPreview => widget.longitude != null && widget.latitude != null;

  @override
  void initState() {
    super.initState();
    _initUrl();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (v) {
            if (!mounted) return;
            if (v == progress || (v < 100 && v - progress < 5)) return;
            setState(() => progress = v);
          },
          onPageFinished: (u) {
            url = u;
          },
          onNavigationRequest: (request) {
            final uriStr = request.url;
            Logger.print('click: $uriStr');
            if (uriStr.startsWith(widget.mapBackUrl)) {
              try {
                final uri = Uri.parse(uriStr);
                Logger.print('${uri.queryParameters}');
                var result = <String, String>{};
                result.addAll(uri.queryParameters);
                var lat = result['latng'];
                var list = lat!.split(',');
                result['latitude'] = list[0];
                result['longitude'] = list[1];
                result['url'] = sprintf(thumbnailUrl, [lat, lat]);
                Logger.print('${result['url']}');
                latitude = double.tryParse(result['latitude']!);
                longitude = double.tryParse(result['longitude']!);
                description = jsonEncode(result);
              } catch (e) {
                Logger.print('e:$e');
              }
              return NavigationDecision.prevent;
            } else if (uriStr
                .contains('qqmap://map/routeplan?type=drive&referer=')) {
              return NavigationDecision.prevent;
            } else if (uriStr.contains('qqmap://map/nearby?coord=')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(isPreview ? previewLocationUrl : locationUrl));
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _confirm() async {
    if (null == latitude || null == longitude) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: StrRes.plsSelectLocation.toText
            ..style = Styles.ts_0C1C33_17sp_semibold,
          actions: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              behavior: HitTestBehavior.translucent,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: StrRes.determine.toText
                  ..style = Styles.ts_0089FF_17sp_semibold,
              ),
            ),
          ],
        ),
      );
      return;
    }
    Navigator.pop(context, {
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: TitleBar.back(
        onTap: () async {
          if (await webViewController.canGoBack()) {
            webViewController.goBack();
          } else {
            Get.back();
          }
        },
        title: StrRes.location,
        right: isPreview
            ? null
            : GestureDetector(
                onTap: _confirm,
                behavior: HitTestBehavior.translucent,
                child: StrRes.determine.toText..style = Styles.ts_0C1C33_17sp,
              ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: webViewController),
            if (progress < 100) LinearProgressIndicator(value: progress / 100),
          ],
        ),
      ),
    );
  }
}
