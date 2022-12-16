import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'helperAd.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WebViewController controller;

  Future<InitializationStatus> _initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    return MobileAds.instance.initialize();
  }

  @override
  void initState() {
    super.initState();
    _initGoogleMobileAds();
    _loadRewardedAd();
  }

  RewardedAd? _rewardedAd;
  bool clicked = false;

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print("add unit is ${ad.adUnitId}");
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                ad.dispose();
                _rewardedAd = null;
              });
              _loadRewardedAd();
            },
          );

          setState(() {
            _rewardedAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load a rewarded ad: ${err.message}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
    javascriptMode: JavascriptMode.unrestricted,
    onWebViewCreated: (WebViewController webViewController) async {
    webViewController.clearCache();
    controller = webViewController;
    await controller.loadUrl('https://web-view-react.vercel.app/');
    },
    onPageFinished: (String _) async {
    await controller.evaluateJavascript('''
    document.getElementById('mybutton').addEventListener('click', function(e) {
      nitin.postMessage('END OF PAGE!!!');
  });
''');
    },
    javascriptChannels: <JavascriptChannel>{
    JavascriptChannel(
    name: 'nitin',
    onMessageReceived: (JavascriptMessage message) {
    print(message.message);
    _rewardedAd?.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
    print(ad.adUnitId);
    });
    print('skfjkshfjkdshafjkhdasjkfhjk');
    }),
    },
    );
}}
