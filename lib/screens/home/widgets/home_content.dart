// import 'package:docusense_ai/utils/ads_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:docusense_ai/screens/home/widgets/recent_files_section.dart';
// import 'package:docusense_ai/screens/home/widgets/upload_section.dart';
// import 'welcome_section.dart';
//
// class HomeContent extends StatefulWidget {
//   const HomeContent({super.key});
//
//   @override
//   State<HomeContent> createState() => _HomeContentState();
// }
//
// class _HomeContentState extends State<HomeContent> {
//   BannerAd? _bannerAd;
//
//   @override
//   void initState() {
//     super.initState();
//     _bannerAd = AdManager.createBannerAd();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             const WelcomeSection(),
//             const SizedBox(height: 30),
//
//             // banner ad implementation
//             if (_bannerAd != null)
//               Container(
//                 alignment: Alignment.center,
//                 width: _bannerAd!.size.width.toDouble(),
//                 height: _bannerAd!.size.height.toDouble(),
//                 child: AdWidget(ad: _bannerAd!),
//               ),
//
//             const SizedBox(height: 20),
//             const UploadSection(),
//             const RecentFilesSection(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _bannerAd?.dispose();
//     super.dispose();
//   }
// }


import 'package:docusense_ai/utils/ads_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:docusense_ai/screens/home/widgets/recent_files_section.dart';
import 'package:docusense_ai/screens/home/widgets/upload_section.dart';
import 'welcome_section.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  BannerAd? _bannerAd;
  NativeAd? _nativeAd;
  bool _isBannerAdLoaded = false;
  bool _isNativeAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  void _loadAds() {

    // Load Native Ad
    _nativeAd = AdManager.createNativeAd(
      onAdLoaded: (ad) {
        setState(() {
          _isNativeAdLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        setState(() {
          _isNativeAdLoaded = false;
          _nativeAd = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const WelcomeSection(),
            const SizedBox(height: 30),

            // Native Ad
            if (_isNativeAdLoaded && _nativeAd != null)
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: 320,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AdWidget(ad: _nativeAd!),
              ),

            const UploadSection(),
            const SizedBox(height: 30),

            const RecentFilesSection(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _nativeAd?.dispose();
    super.dispose();
  }
}
