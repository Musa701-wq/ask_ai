/*

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';


class AdManager {
  // ✅ Ad instances
  static RewardedAd? _rewardedChatAd;
  static RewardedAd? _rewardedQuizAd;
  static RewardedAd? _rewardedSummaryAd;

  // Loading states
  static bool _isChatAdLoading = false;
  static bool _isQuizAdLoading = false;
  static bool _isSummaryAdLoading = false;

  // Retry counters
  static int _chatAdRetries = 0;
  static int _quizAdRetries = 0;
  static int _summaryAdRetries = 0;
  static const int _maxRetries = 3;

  // Last load times
  static DateTime? _lastChatAdLoadTime;
  static DateTime? _lastQuizAdLoadTime;
  static DateTime? _lastSummaryAdLoadTime;

  static const Duration _minLoadInterval = Duration(seconds: 30);

  // REAL AD IDs
  static const String nativeAdUnitId = 'ca-app-pub-3774337907915828/7524917203';
  static const String rewardedChatAdUnitId = 'ca-app-pub-3774337907915828/4104546947';
  static const String rewardedQuizAdUnitId = 'ca-app-pub-3774337907915828/9205379126';
  static const String rewardedSummaryAdUnitId = 'ca-app-pub-3774337907915828/5417628611';

  // 🔥 ADD YOUR TEST DEVICE IDs HERE
  static const List<String> testDeviceIds = [
    // Example: 'YOUR_DEVICE_ID_HERE',
    // To find your device ID, check logcat/console on first ad load
  ];

  // ---------------------------------------------------------------------------
  // 🔥 IMPROVED: Initialize AdMob with better configuration
  // ---------------------------------------------------------------------------
  static Future<void> initialize() async {
    try {
      // Wait for initialization to complete
      await MobileAds.instance.initialize();

      final configuration = RequestConfiguration(
        testDeviceIds: testDeviceIds,
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
        maxAdContentRating: MaxAdContentRating.pg, // ✅ Add content rating
      );

      MobileAds.instance.updateRequestConfiguration(configuration);

      debugPrint('✅ AdMob initialized successfully');

      // 🔥 PRELOAD ALL ADS after initialization
      await Future.delayed(const Duration(milliseconds: 500));
      loadRewardedChatAd();
      loadRewardedQuizAd();
      loadRewardedSummaryAd();

    } catch (e) {
      debugPrint('❌ AdMob initialization failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 🔥 IMPROVED: Native Ad with better error handling
  // ---------------------------------------------------------------------------
  static NativeAd? createNativeAd({
    Function(Ad)? onAdLoaded,
    Function(Ad, LoadAdError)? onAdFailedToLoad,
  }) {
    try {
      final nativeAd = NativeAd(
        adUnitId: nativeAdUnitId,
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            debugPrint('✅ Native Ad loaded');
            onAdLoaded?.call(ad);
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('❌ Native Ad failed: ${error.message} (Code: ${error.code})');
            ad.dispose();
            onAdFailedToLoad?.call(ad, error);

            // 🔥 AUTO-RETRY after 5 seconds
            Future.delayed(const Duration(seconds: 5), () {
              createNativeAd(
                onAdLoaded: onAdLoaded,
                onAdFailedToLoad: onAdFailedToLoad,
              );
            });
          },
          onAdOpened: (ad) => debugPrint('👁️ Native opened'),
          onAdClosed: (ad) => debugPrint('👋 Native closed'),
          onAdImpression: (ad) => debugPrint('📊 Native impression'),
        ),
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.small,
          mainBackgroundColor: Colors.white,
          cornerRadius: 12.0,
          callToActionTextStyle: NativeTemplateTextStyle(
            textColor: Colors.white,
            backgroundColor: const Color(0xFF8A2BE2),
            style: NativeTemplateFontStyle.bold,
            size: 16.0,
          ),
          primaryTextStyle: NativeTemplateTextStyle(
            textColor: Colors.black87,
            style: NativeTemplateFontStyle.bold,
            size: 16.0,
          ),
          secondaryTextStyle: NativeTemplateTextStyle(
            textColor: Colors.grey,
            style: NativeTemplateFontStyle.normal,
            size: 14.0,
          ),
          tertiaryTextStyle: NativeTemplateTextStyle(
            textColor: Colors.grey,
            style: NativeTemplateFontStyle.normal,
            size: 12.0,
          ),
        ),
        nativeAdOptions: NativeAdOptions(
          adChoicesPlacement: AdChoicesPlacement.topRightCorner,
        ),
      );

      nativeAd.load();
      return nativeAd;
    } catch (e) {
      debugPrint('❌ Native Ad error: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // 🔥 IMPROVED: Chat Ad with retry logic
  // ---------------------------------------------------------------------------
  static Future<void> loadRewardedChatAd() async {
    if (_lastChatAdLoadTime != null) {
      final timeSince = DateTime.now().difference(_lastChatAdLoadTime!);
      if (timeSince < _minLoadInterval) {
        debugPrint('⏳ Chat ad throttled');
        return;
      }
    }

    if (_isChatAdLoading || _rewardedChatAd != null) {
      debugPrint('ℹ️ Chat ad already loading/loaded');
      return;
    }

    _isChatAdLoading = true;
    _lastChatAdLoadTime = DateTime.now();

    try {
      await RewardedAd.load(
        adUnitId: rewardedChatAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('✅ Chat ad loaded');
            _rewardedChatAd = ad;
            _isChatAdLoading = false;
            _chatAdRetries = 0; // Reset retry counter
          },
          onAdFailedToLoad: (error) {
            debugPrint('❌ Chat ad failed: ${error.message} (Code: ${error.code})');
            _rewardedChatAd = null;
            _isChatAdLoading = false;

            // 🔥 EXPONENTIAL BACKOFF RETRY (20s, 40s, 60s)
            if (_chatAdRetries < _maxRetries) {
              _chatAdRetries++;
              final retryDelay = Duration(seconds: 20 * _chatAdRetries);
              debugPrint('🔄 Retrying chat ad in ${retryDelay.inSeconds}s (Attempt $_chatAdRetries/$_maxRetries)');

              Future.delayed(retryDelay, () {
                if (_rewardedChatAd == null) loadRewardedChatAd();
              });
            } else {
              debugPrint('⛔ Max retries reached for chat ad');
              _chatAdRetries = 0; // Reset for next time
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ Chat ad error: $e');
      _isChatAdLoading = false;
    }
  }

  // ---------------------------------------------------------------------------
  // 🔥 IMPROVED: Quiz Ad with retry logic
  // ---------------------------------------------------------------------------
  static Future<void> loadRewardedQuizAd() async {
    if (_lastQuizAdLoadTime != null) {
      final timeSince = DateTime.now().difference(_lastQuizAdLoadTime!);
      if (timeSince < _minLoadInterval) {
        debugPrint('⏳ Quiz ad throttled');
        return;
      }
    }

    if (_isQuizAdLoading || _rewardedQuizAd != null) {
      debugPrint('ℹ️ Quiz ad already loading/loaded');
      return;
    }

    _isQuizAdLoading = true;
    _lastQuizAdLoadTime = DateTime.now();

    try {
      await RewardedAd.load(
        adUnitId: rewardedQuizAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('✅ Quiz ad loaded');
            _rewardedQuizAd = ad;
            _isQuizAdLoading = false;
            _quizAdRetries = 0;
          },
          onAdFailedToLoad: (error) {
            debugPrint('❌ Quiz ad failed: ${error.message} (Code: ${error.code})');
            _rewardedQuizAd = null;
            _isQuizAdLoading = false;

            if (_quizAdRetries < _maxRetries) {
              _quizAdRetries++;
              final retryDelay = Duration(seconds: 20 * _quizAdRetries);
              debugPrint('🔄 Retrying quiz ad in ${retryDelay.inSeconds}s');

              Future.delayed(retryDelay, () {
                if (_rewardedQuizAd == null) loadRewardedQuizAd();
              });
            } else {
              _quizAdRetries = 0;
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ Quiz ad error: $e');
      _isQuizAdLoading = false;
    }
  }

  // ---------------------------------------------------------------------------
  // 🔥 IMPROVED: Summary Ad with retry logic
  // ---------------------------------------------------------------------------
  static Future<void> loadRewardedSummaryAd() async {
    if (_lastSummaryAdLoadTime != null) {
      final timeSince = DateTime.now().difference(_lastSummaryAdLoadTime!);
      if (timeSince < _minLoadInterval) {
        debugPrint('⏳ Summary ad throttled');
        return;
      }
    }

    if (_isSummaryAdLoading || _rewardedSummaryAd != null) {
      debugPrint('ℹ️ Summary ad already loading/loaded');
      return;
    }

    _isSummaryAdLoading = true;
    _lastSummaryAdLoadTime = DateTime.now();

    try {
      await RewardedAd.load(
        adUnitId: rewardedSummaryAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('✅ Summary ad loaded');
            _rewardedSummaryAd = ad;
            _isSummaryAdLoading = false;
            _summaryAdRetries = 0;
          },
          onAdFailedToLoad: (error) {
            debugPrint('❌ Summary ad failed: ${error.message} (Code: ${error.code})');
            _rewardedSummaryAd = null;
            _isSummaryAdLoading = false;

            if (_summaryAdRetries < _maxRetries) {
              _summaryAdRetries++;
              final retryDelay = Duration(seconds: 20 * _summaryAdRetries);
              debugPrint('🔄 Retrying summary ad in ${retryDelay.inSeconds}s');

              Future.delayed(retryDelay, () {
                if (_rewardedSummaryAd == null) loadRewardedSummaryAd();
              });
            } else {
              _summaryAdRetries = 0;
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ Summary ad error: $e');
      _isSummaryAdLoading = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Check if Ad is Ready
  // ---------------------------------------------------------------------------
  static bool isChatAdReady() => _rewardedChatAd != null;
  static bool isQuizAdReady() => _rewardedQuizAd != null;
  static bool isSummaryAdReady() => _rewardedSummaryAd != null;

  // ---------------------------------------------------------------------------
  // Show Ads (same as before but with auto-reload)
  // ---------------------------------------------------------------------------
  static void showChatAd({
    required Function(int rewardAmount) onUserEarnedReward,
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailedToShow,
  }) {
    if (_rewardedChatAd == null) {
      debugPrint('❌ Chat ad not ready');
      onAdFailedToShow?.call();
      loadRewardedChatAd(); // Try loading immediately
      return;
    }

    _rewardedChatAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedChatAd = null;
        onAdDismissed?.call();
        loadRewardedChatAd(); // Preload next
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('❌ Chat ad show failed: ${error.message}');
        ad.dispose();
        _rewardedChatAd = null;
        onAdFailedToShow?.call();
        loadRewardedChatAd(); // Preload next
      },
    );

    _rewardedChatAd!.show(
      onUserEarnedReward: (ad, reward) {
        onUserEarnedReward(reward.amount.toInt());
      },
    );
  }

  static void showQuizAd({
    required Function(int rewardAmount) onUserEarnedReward,
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailedToShow,
  }) {
    if (_rewardedQuizAd == null) {
      debugPrint('❌ Quiz ad not ready');
      onAdFailedToShow?.call();
      loadRewardedQuizAd();
      return;
    }

    _rewardedQuizAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedQuizAd = null;
        onAdDismissed?.call();
        loadRewardedQuizAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedQuizAd = null;
        onAdFailedToShow?.call();
        loadRewardedQuizAd();
      },
    );

    _rewardedQuizAd!.show(
      onUserEarnedReward: (ad, reward) {
        onUserEarnedReward(reward.amount.toInt());
      },
    );
  }

  static void showSummaryAd({
    required Function(int rewardAmount) onUserEarnedReward,
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailedToShow,
  }) {
    if (_rewardedSummaryAd == null) {
      debugPrint('❌ Summary ad not ready');
      onAdFailedToShow?.call();
      loadRewardedSummaryAd();
      return;
    }

    _rewardedSummaryAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedSummaryAd = null;
        onAdDismissed?.call();
        loadRewardedSummaryAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedSummaryAd = null;
        onAdFailedToShow?.call();
        loadRewardedSummaryAd();
      },
    );

    _rewardedSummaryAd!.show(
      onUserEarnedReward: (ad, reward) {
        onUserEarnedReward(reward.amount.toInt());
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------
  static void disposeAds() {
    _rewardedChatAd?.dispose();
    _rewardedQuizAd?.dispose();
    _rewardedSummaryAd?.dispose();

    _rewardedChatAd = null;
    _rewardedQuizAd = null;
    _rewardedSummaryAd = null;

    _isChatAdLoading = false;
    _isQuizAdLoading = false;
    _isSummaryAdLoading = false;
  }
}
*/
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';


class AdManager {
  // ✅ Ad instances
  static RewardedAd? _rewardedChatAd;
  static RewardedAd? _rewardedQuizAd;
  static RewardedAd? _rewardedSummaryAd;

  // Loading states
  static bool _isChatAdLoading = false;
  static bool _isQuizAdLoading = false;
  static bool _isSummaryAdLoading = false;

  // Retry counters
  static int _chatAdRetries = 0;
  static int _quizAdRetries = 0;
  static int _summaryAdRetries = 0;
  static const int _maxRetries = 3;

  // Last load times
  static DateTime? _lastChatAdLoadTime;
  static DateTime? _lastQuizAdLoadTime;
  static DateTime? _lastSummaryAdLoadTime;

  static const Duration _minLoadInterval = Duration(seconds: 30);

  // REAL AD IDs - UNIFIED
  static const String nativeAdUnitId = 'ca-app-pub-3774337907915828/7524917203';
  static const String rewardedAdUnitId = 'ca-app-pub-3774337907915828/4104546947'; // ✅ Same for all rewarded ads

  // 🔥 ADD YOUR TEST DEVICE IDs HERE
  static const List<String> testDeviceIds = [
    // Example: 'YOUR_DEVICE_ID_HERE',
    // To find your device ID, check logcat/console on first ad load
  ];

  // ---------------------------------------------------------------------------
  // 🔥 IMPROVED: Initialize AdMob with better configuration
  // ---------------------------------------------------------------------------
  static Future<void> initialize() async {
    try {
      // Wait for initialization to complete
      await MobileAds.instance.initialize();

      final configuration = RequestConfiguration(
        testDeviceIds: testDeviceIds,
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
        maxAdContentRating: MaxAdContentRating.pg, // ✅ Add content rating
      );

      MobileAds.instance.updateRequestConfiguration(configuration);

      debugPrint('✅ AdMob initialized successfully');

      // 🔥 PRELOAD ALL ADS after initialization
      await Future.delayed(const Duration(milliseconds: 500));
      loadRewardedChatAd();
      loadRewardedQuizAd();
      loadRewardedSummaryAd();

    } catch (e) {
      debugPrint('❌ AdMob initialization failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 🔥 IMPROVED: Native Ad with better error handling
  // ---------------------------------------------------------------------------
  static NativeAd? createNativeAd({
    Function(Ad)? onAdLoaded,
    Function(Ad, LoadAdError)? onAdFailedToLoad,
  }) {
    try {
      final nativeAd = NativeAd(
        adUnitId: nativeAdUnitId,
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            debugPrint('✅ Native Ad loaded');
            onAdLoaded?.call(ad);
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('❌ Native Ad failed: ${error.message} (Code: ${error.code})');
            ad.dispose();
            onAdFailedToLoad?.call(ad, error);

            // 🔥 AUTO-RETRY after 5 seconds
            Future.delayed(const Duration(seconds: 5), () {
              createNativeAd(
                onAdLoaded: onAdLoaded,
                onAdFailedToLoad: onAdFailedToLoad,
              );
            });
          },
          onAdOpened: (ad) => debugPrint('👁️ Native opened'),
          onAdClosed: (ad) => debugPrint('👋 Native closed'),
          onAdImpression: (ad) => debugPrint('📊 Native impression'),
        ),
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.small,
          mainBackgroundColor: Colors.white,
          cornerRadius: 12.0,
          callToActionTextStyle: NativeTemplateTextStyle(
            textColor: Colors.white,
            backgroundColor: const Color(0xFF8A2BE2),
            style: NativeTemplateFontStyle.bold,
            size: 16.0,
          ),
          primaryTextStyle: NativeTemplateTextStyle(
            textColor: Colors.black87,
            style: NativeTemplateFontStyle.bold,
            size: 16.0,
          ),
          secondaryTextStyle: NativeTemplateTextStyle(
            textColor: Colors.grey,
            style: NativeTemplateFontStyle.normal,
            size: 14.0,
          ),
          tertiaryTextStyle: NativeTemplateTextStyle(
            textColor: Colors.grey,
            style: NativeTemplateFontStyle.normal,
            size: 12.0,
          ),
        ),
        nativeAdOptions: NativeAdOptions(
          adChoicesPlacement: AdChoicesPlacement.topRightCorner,
        ),
      );

      nativeAd.load();
      return nativeAd;
    } catch (e) {
      debugPrint('❌ Native Ad error: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // 🔥 IMPROVED: Chat Ad with retry logic
  // ---------------------------------------------------------------------------
  static Future<void> loadRewardedChatAd() async {
    if (_lastChatAdLoadTime != null) {
      final timeSince = DateTime.now().difference(_lastChatAdLoadTime!);
      if (timeSince < _minLoadInterval) {
        debugPrint('⏳ Chat ad throttled');
        return;
      }
    }

    if (_isChatAdLoading || _rewardedChatAd != null) {
      debugPrint('ℹ️ Chat ad already loading/loaded');
      return;
    }

    _isChatAdLoading = true;
    _lastChatAdLoadTime = DateTime.now();

    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId, // ✅ Using unified ID
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('✅ Chat ad loaded');
            _rewardedChatAd = ad;
            _isChatAdLoading = false;
            _chatAdRetries = 0; // Reset retry counter
          },
          onAdFailedToLoad: (error) {
            debugPrint('❌ Chat ad failed: ${error.message} (Code: ${error.code})');
            _rewardedChatAd = null;
            _isChatAdLoading = false;

            // 🔥 EXPONENTIAL BACKOFF RETRY (20s, 40s, 60s)
            if (_chatAdRetries < _maxRetries) {
              _chatAdRetries++;
              final retryDelay = Duration(seconds: 20 * _chatAdRetries);
              debugPrint('🔄 Retrying chat ad in ${retryDelay.inSeconds}s (Attempt $_chatAdRetries/$_maxRetries)');

              Future.delayed(retryDelay, () {
                if (_rewardedChatAd == null) loadRewardedChatAd();
              });
            } else {
              debugPrint('⛔ Max retries reached for chat ad');
              _chatAdRetries = 0; // Reset for next time
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ Chat ad error: $e');
      _isChatAdLoading = false;
    }
  }

  // ---------------------------------------------------------------------------
  // 🔥 IMPROVED: Quiz Ad with retry logic
  // ---------------------------------------------------------------------------
  static Future<void> loadRewardedQuizAd() async {
    if (_lastQuizAdLoadTime != null) {
      final timeSince = DateTime.now().difference(_lastQuizAdLoadTime!);
      if (timeSince < _minLoadInterval) {
        debugPrint('⏳ Quiz ad throttled');
        return;
      }
    }

    if (_isQuizAdLoading || _rewardedQuizAd != null) {
      debugPrint('ℹ️ Quiz ad already loading/loaded');
      return;
    }

    _isQuizAdLoading = true;
    _lastQuizAdLoadTime = DateTime.now();

    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId, // ✅ Using unified ID
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('✅ Quiz ad loaded');
            _rewardedQuizAd = ad;
            _isQuizAdLoading = false;
            _quizAdRetries = 0;
          },
          onAdFailedToLoad: (error) {
            debugPrint('❌ Quiz ad failed: ${error.message} (Code: ${error.code})');
            _rewardedQuizAd = null;
            _isQuizAdLoading = false;

            if (_quizAdRetries < _maxRetries) {
              _quizAdRetries++;
              final retryDelay = Duration(seconds: 20 * _quizAdRetries);
              debugPrint('🔄 Retrying quiz ad in ${retryDelay.inSeconds}s');

              Future.delayed(retryDelay, () {
                if (_rewardedQuizAd == null) loadRewardedQuizAd();
              });
            } else {
              _quizAdRetries = 0;
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ Quiz ad error: $e');
      _isQuizAdLoading = false;
    }
  }

  // ---------------------------------------------------------------------------
  // 🔥 IMPROVED: Summary Ad with retry logic
  // ---------------------------------------------------------------------------
  static Future<void> loadRewardedSummaryAd() async {
    if (_lastSummaryAdLoadTime != null) {
      final timeSince = DateTime.now().difference(_lastSummaryAdLoadTime!);
      if (timeSince < _minLoadInterval) {
        debugPrint('⏳ Summary ad throttled');
        return;
      }
    }

    if (_isSummaryAdLoading || _rewardedSummaryAd != null) {
      debugPrint('ℹ️ Summary ad already loading/loaded');
      return;
    }

    _isSummaryAdLoading = true;
    _lastSummaryAdLoadTime = DateTime.now();

    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId, // ✅ Using unified ID
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('✅ Summary ad loaded');
            _rewardedSummaryAd = ad;
            _isSummaryAdLoading = false;
            _summaryAdRetries = 0;
          },
          onAdFailedToLoad: (error) {
            debugPrint('❌ Summary ad failed: ${error.message} (Code: ${error.code})');
            _rewardedSummaryAd = null;
            _isSummaryAdLoading = false;

            if (_summaryAdRetries < _maxRetries) {
              _summaryAdRetries++;
              final retryDelay = Duration(seconds: 20 * _summaryAdRetries);
              debugPrint('🔄 Retrying summary ad in ${retryDelay.inSeconds}s');

              Future.delayed(retryDelay, () {
                if (_rewardedSummaryAd == null) loadRewardedSummaryAd();
              });
            } else {
              _summaryAdRetries = 0;
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ Summary ad error: $e');
      _isSummaryAdLoading = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Check if Ad is Ready
  // ---------------------------------------------------------------------------
  static bool isChatAdReady() => _rewardedChatAd != null;
  static bool isQuizAdReady() => _rewardedQuizAd != null;
  static bool isSummaryAdReady() => _rewardedSummaryAd != null;

  // ---------------------------------------------------------------------------
  // Show Ads (same as before but with auto-reload)
  // ---------------------------------------------------------------------------
  static void showChatAd({
    required Function(int rewardAmount) onUserEarnedReward,
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailedToShow,
  }) {
    if (_rewardedChatAd == null) {
      debugPrint('❌ Chat ad not ready');
      onAdFailedToShow?.call();
      loadRewardedChatAd(); // Try loading immediately
      return;
    }

    _rewardedChatAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedChatAd = null;
        onAdDismissed?.call();
        loadRewardedChatAd(); // Preload next
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('❌ Chat ad show failed: ${error.message}');
        ad.dispose();
        _rewardedChatAd = null;
        onAdFailedToShow?.call();
        loadRewardedChatAd(); // Preload next
      },
    );

    _rewardedChatAd!.show(
      onUserEarnedReward: (ad, reward) {
        onUserEarnedReward(reward.amount.toInt());
      },
    );
  }

  static void showQuizAd({
    required Function(int rewardAmount) onUserEarnedReward,
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailedToShow,
  }) {
    if (_rewardedQuizAd == null) {
      debugPrint('❌ Quiz ad not ready');
      onAdFailedToShow?.call();
      loadRewardedQuizAd();
      return;
    }

    _rewardedQuizAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedQuizAd = null;
        onAdDismissed?.call();
        loadRewardedQuizAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedQuizAd = null;
        onAdFailedToShow?.call();
        loadRewardedQuizAd();
      },
    );

    _rewardedQuizAd!.show(
      onUserEarnedReward: (ad, reward) {
        onUserEarnedReward(reward.amount.toInt());
      },
    );
  }

  static void showSummaryAd({
    required Function(int rewardAmount) onUserEarnedReward,
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailedToShow,
  }) {
    if (_rewardedSummaryAd == null) {
      debugPrint('❌ Summary ad not ready');
      onAdFailedToShow?.call();
      loadRewardedSummaryAd();
      return;
    }

    _rewardedSummaryAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedSummaryAd = null;
        onAdDismissed?.call();
        loadRewardedSummaryAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedSummaryAd = null;
        onAdFailedToShow?.call();
        loadRewardedSummaryAd();
      },
    );

    _rewardedSummaryAd!.show(
      onUserEarnedReward: (ad, reward) {
        onUserEarnedReward(reward.amount.toInt());
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------
  static void disposeAds() {
    _rewardedChatAd?.dispose();
    _rewardedQuizAd?.dispose();
    _rewardedSummaryAd?.dispose();

    _rewardedChatAd = null;
    _rewardedQuizAd = null;
    _rewardedSummaryAd = null;

    _isChatAdLoading = false;
    _isQuizAdLoading = false;
    _isSummaryAdLoading = false;
  }
}