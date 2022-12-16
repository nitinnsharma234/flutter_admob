import 'dart:io';

class AdHelper {

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6780056179433413/6601944122';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }


}