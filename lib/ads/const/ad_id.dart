import 'dart:io';
import 'package:injectable/injectable.dart';

import 'ad_id_name.dart';

Map<String, Map<String, String>> myAdsId = {
  Environment.dev: Platform.isIOS
      ? {}
      : {
          MyAdIdName.appOpenResume: 'ca-app-pub-3940256099942544/9257395921',
          MyAdIdName.interSplash: 'ca-app-pub-3940256099942544/1033173712',
          MyAdIdName.nativeLanguage: 'ca-app-pub-3940256099942544/2247696110',
          MyAdIdName.nativeLanguageClick: 'ca-app-pub-3940256099942544/2247696110',
          MyAdIdName.nativeOnboard1Ad: 'ca-app-pub-3940256099942544/2247696110',
          MyAdIdName.nativeOnboardFull1Ad: 'ca-app-pub-3940256099942544/2247696110',
          MyAdIdName.nativeOnboardFull2Ad: 'ca-app-pub-3940256099942544/2247696110',
          MyAdIdName.nativeOnboard3Ad: 'ca-app-pub-3940256099942544/2247696110',
          MyAdIdName.interAll: 'ca-app-pub-3940256099942544/1033173712',
          MyAdIdName.rewardedAd: 'ca-app-pub-3940256099942544/5224354917',
          MyAdIdName.nativeBanner: 'ca-app-pub-3940256099942544/2247696110',
          MyAdIdName.interOnboard: 'ca-app-pub-3940256099942544/1033173712',
          MyAdIdName.nativeFull: 'ca-app-pub-3940256099942544/2247696110',
          MyAdIdName.nativeAll: 'ca-app-pub-3940256099942544/2247696110',
        },
  Environment.prod: Platform.isIOS
      ? {}
      : {
          MyAdIdName.appOpenResume: 'ca-app-pub-1189834344037075/8055734319',
          MyAdIdName.interSplash: 'ca-app-pub-1189834344037075/5939088897',
          MyAdIdName.nativeLanguage: 'ca-app-pub-1189834344037075/1490325966',
          MyAdIdName.nativeLanguageClick: 'ca-app-pub-1189834344037075/5237999287',
          MyAdIdName.nativeOnboard1Ad: 'ca-app-pub-1189834344037075/9739516927',
          MyAdIdName.nativeOnboardFull1Ad: '',
          MyAdIdName.nativeOnboardFull2Ad: '',
          MyAdIdName.nativeOnboard3Ad: 'ca-app-pub-1189834344037075/5281593288',
          MyAdIdName.interAll: 'ca-app-pub-1189834344037075/2404234227',
          MyAdIdName.rewardedAd: '',
          MyAdIdName.nativeBanner: '',
          MyAdIdName.interOnboard: '',
          MyAdIdName.nativeFull: '',
          MyAdIdName.nativeAll: 'ca-app-pub-1189834344037075/4838825874',
        },
};
