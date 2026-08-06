// import 'package:docusense_ai/app_localization.dart';
// import 'package:docusense_ai/providers/pdf_provider.dart';
// import 'package:docusense_ai/providers/ad_provider.dart';
// import 'package:docusense_ai/utils/gemini_service.dart';
// import 'package:docusense_ai/utils/ads_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_chat_core/flutter_chat_core.dart';
// import 'package:uuid/uuid.dart';
// import 'package:provider/provider.dart';
//
// class ChatMessageHandler extends ChangeNotifier {
//   final ChatController chatController;
//   final Uuid uuid;
//   final User botUser;
//   bool _isTyping = false;
//   bool _isAdLoading = false; // Track ad loading state
//
//   bool get isTyping => _isTyping;
//   bool get isAdLoading => _isAdLoading;
//
//   ChatMessageHandler({
//     required this.chatController,
//     required this.uuid,
//     required this.botUser,
//   });
//
//   void addWelcomeMessage(BuildContext context) {
//     final pdfProvider = context.read<PdfProvider>();
//     final fileName = pdfProvider.uploadedFileName ?? 'your document';
//
//     chatController.insertMessage(
//       TextMessage(
//         id: uuid.v4(),
//         authorId: botUser.id,
//         text: AppLocalizations.of(
//           context,
//         ).chatWelcomeMessage.replaceAll('%fileName', fileName),
//         createdAt: DateTime.now(),
//       ),
//     );
//   }
//
//   Future<void> handleUserMessage({
//     required String text,
//     required BuildContext context,
//   }) async {
//     final adProvider = context.read<AdProvider>();
//     final pdfProvider = context.read<PdfProvider>();
//
//     // Check if user has available prompts
//     if (adProvider.availablePrompts <= 0) {
//       showNoPromptsDialog(context);
//       return;
//     }
//
//     // Use one prompt
//     adProvider.usePrompt();
//
//     // Add user message
//     _addUserMessage(text);
//
//     // Show typing indicator
//     _setTyping(true);
//
//     // Get AI response
//     try {
//       debugPrint("🎁 Sending message to Gemini");
//       final response = await getGeminiResponse(
//         text,
//         fileContent: pdfProvider.uploadedFileContent,
//         fileName: pdfProvider.uploadedFileName,
//       );
//
//       // Hide typing indicator
//       _setTyping(false);
//
//       // Add bot response
//       _addBotMessage(response);
//
//       // Show interstitial ad after every 3 messages (optional)
//       _checkAndShowInterstitialAd(adProvider);
//     } catch (e) {
//       debugPrint("🎁 Error from Gemini: $e");
//       _setTyping(false);
//       _addBotMessage(AppLocalizations.of(context).errorTryAgain);
//     }
//   }
//
//   void _setTyping(bool value) {
//     _isTyping = value;
//     notifyListeners();
//   }
//
//   void _checkAndShowInterstitialAd(AdProvider adProvider) {
//     // Show interstitial ad after every 3 messages
//     if (adProvider.messageCount % 3 == 0) {
//       AdManager.showInterstitialAd();
//     }
//     adProvider.incrementMessageCount();
//   }
//
//   void showNoPromptsDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('No Prompts Available'),
//         content: const Text(
//           'Watch a short ad to get more prompts and continue chatting with your document.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Maybe Later'),
//           ),
//           ElevatedButton(
//             onPressed: _isAdLoading
//                 ? null // Disable button when loading
//                 : () {
//               Navigator.pop(context);
//               showRewardedAd(context);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.orange[700],
//               disabledBackgroundColor: Colors.grey[400],
//             ),
//             child: _isAdLoading
//                 ? const SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//               ),
//             )
//                 : const Text(
//               'Watch Ad',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void showRewardedAd(BuildContext context) {
//     final adProvider = context.read<AdProvider>();
//
//     // Check if ad is ready
//     if (!AdManager.isRewardedAdReady()) {
//       _showAdNotReadyDialog(context);
//       return;
//     }
//
//     // Set loading state
//     _isAdLoading = true;
//     adProvider.setAdLoading(true);
//     notifyListeners();
//
//     AdManager.showRewardedAd(
//       onUserEarnedReward: (int rewardAmount) {
//         debugPrint("✅ User earned reward: $rewardAmount");
//         adProvider.addPrompts(1);
//         _isAdLoading = false;
//         adProvider.setAdLoading(false);
//         notifyListeners();
//
//         // Reload ad for next time
//         AdManager.loadRewardedChatAd();
//
//         // Show success message
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text(
//                 '+1 prompt added!', // Fixed to show only 1
//               ),
//               duration: Duration(seconds: 3),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       },
//       onAdDismissed: () {
//         debugPrint("👋 Ad dismissed");
//         _isAdLoading = false;
//         adProvider.setAdLoading(false);
//         notifyListeners();
//
//         // Reload ad for next time
//         AdManager.loadRewardedChatAd();
//       },
//     );
//   }
//
//   void _showAdNotReadyDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Row(
//           children: [
//             Icon(Icons.info_outline, color: Colors.blue),
//             SizedBox(width: 8),
//             Text('Ad Not Ready'),
//           ],
//         ),
//         content: const Text(
//           'The ad is currently loading. Please wait a moment and try again.\n\nThis usually takes just a few seconds.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               // Try to load the ad again
//               AdManager.loadRewardedChatAd();
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _addUserMessage(String text) {
//     chatController.insertMessage(
//       TextMessage(
//         id: uuid.v4(),
//         authorId: 'user_1',
//         text: text,
//         createdAt: DateTime.now(),
//       ),
//     );
//   }
//
//   void _addBotMessage(String text) {
//     chatController.insertMessage(
//       TextMessage(
//         id: uuid.v4(),
//         authorId: botUser.id,
//         text: text,
//         createdAt: DateTime.now(),
//       ),
//     );
//   }
// }


import 'package:docusense_ai/app_localization.dart';
import 'package:docusense_ai/providers/pdf_provider.dart';
import 'package:docusense_ai/providers/ad_provider.dart';
import 'package:docusense_ai/utils/gemini_service.dart';
import 'package:docusense_ai/utils/ads_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

class ChatMessageHandler extends ChangeNotifier {
  final ChatController chatController;
  final Uuid uuid;
  final User botUser;
  bool _isTyping = false;
  bool _isAdLoading = false;

  bool get isTyping => _isTyping;
  bool get isAdLoading => _isAdLoading;

  ChatMessageHandler({
    required this.chatController,
    required this.uuid,
    required this.botUser,
  });

  void addWelcomeMessage(BuildContext context) {
    final pdfProvider = context.read<PdfProvider>();
    final fileName = pdfProvider.uploadedFileName ?? 'your document';

    chatController.insertMessage(
      TextMessage(
        id: uuid.v4(),
        authorId: botUser.id,
        text: AppLocalizations.of(
          context,
        ).chatWelcomeMessage.replaceAll('%fileName', fileName),
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> handleUserMessage({
    required String text,
    required BuildContext context,
  }) async {
    final adProvider = context.read<AdProvider>();
    final pdfProvider = context.read<PdfProvider>();

    // Check if user has available prompts
    if (adProvider.availablePrompts <= 0) {
      showNoPromptsDialog(context);
      return;
    }

    // Use one prompt
    adProvider.usePrompt();

    // Add user message
    _addUserMessage(text);

    // Show typing indicator
    _setTyping(true);

    // Get AI response
    try {
      debugPrint("🎁 Sending message to Gemini");
      final response = await getGeminiResponse(
        text,
        fileContent: pdfProvider.uploadedFileContent,
        fileName: pdfProvider.uploadedFileName,
      );

      // Hide typing indicator
      _setTyping(false);

      // Add bot response
      _addBotMessage(response);

      // Show rewarded ad after every 3 messages
      _checkAndShowRewardedAd(context, adProvider);
    } catch (e) {
      debugPrint("🎁 Error from Gemini: $e");
      _setTyping(false);
      _addBotMessage(AppLocalizations.of(context).errorTryAgain);
    }
  }

  void _setTyping(bool value) {
    _isTyping = value;
    notifyListeners();
  }

  void _checkAndShowRewardedAd(BuildContext context, AdProvider adProvider) {
    // Show rewarded ad after every 3 messages
    if (adProvider.messageCount % 3 == 0) {
      _showAutoRewardedAd(context);
    }
    adProvider.incrementMessageCount();
  }

  void _showAutoRewardedAd(BuildContext context) {
    final adProvider = context.read<AdProvider>();

    // Check if ad is ready
    if (!AdManager.isChatAdReady()) {
      debugPrint("⚠️ Auto rewarded ad not ready");
      // Silently fail - don't interrupt user experience
      AdManager.loadRewardedChatAd();
      return;
    }

    AdManager.showChatAd(
      onUserEarnedReward: (int rewardAmount) {
        debugPrint("✅ User earned reward from auto ad: $rewardAmount");
        adProvider.addPrompts(1);

        // Reload ad for next time
        AdManager.loadRewardedChatAd();

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '+1 prompt added! 🎉',
              ),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      onAdDismissed: () {
        debugPrint("👋 Auto ad dismissed");
        // Reload ad for next time
        AdManager.loadRewardedChatAd();
      },
      onAdFailedToShow: () {
        debugPrint("❌ Auto ad failed to show");
        // Reload ad for next time
        AdManager.loadRewardedChatAd();
      },
    );
  }

  void showNoPromptsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Prompts Available'),
        content: const Text(
          'Watch a short ad to get more prompts and continue chatting with your document.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: _isAdLoading
                ? null
                : () {
              Navigator.pop(context);
              showRewardedAd(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              disabledBackgroundColor: Colors.grey[400],
            ),
            child: _isAdLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Text(
              'Watch Ad',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void showRewardedAd(BuildContext context) {
    final adProvider = context.read<AdProvider>();

    // Check if ad is ready
    if (!AdManager.isChatAdReady()) {
      _showAdNotReadyDialog(context);
      return;
    }

    // Set loading state
    _isAdLoading = true;
    adProvider.setAdLoading(true);
    notifyListeners();

    AdManager.showChatAd(
      onUserEarnedReward: (int rewardAmount) {
        debugPrint("✅ User earned reward: $rewardAmount");
        adProvider.addPrompts(1);
        _isAdLoading = false;
        adProvider.setAdLoading(false);
        notifyListeners();

        // Reload ad for next time
        AdManager.loadRewardedChatAd();

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '+1 prompt added!',
              ),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      onAdDismissed: () {
        debugPrint("👋 Ad dismissed");
        _isAdLoading = false;
        adProvider.setAdLoading(false);
        notifyListeners();

        // Reload ad for next time
        AdManager.loadRewardedChatAd();
      },
      onAdFailedToShow: () {
        debugPrint("❌ Ad failed to show");
        _isAdLoading = false;
        adProvider.setAdLoading(false);
        notifyListeners();

        // Reload ad for next time
        AdManager.loadRewardedChatAd();
      },
    );
  }

  void _showAdNotReadyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Ad Not Ready'),
          ],
        ),
        content: const Text(
          'The ad is currently loading. Please wait a moment and try again.\n\nThis usually takes just a few seconds.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Try to load the ad again
              AdManager.loadRewardedChatAd();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _addUserMessage(String text) {
    chatController.insertMessage(
      TextMessage(
        id: uuid.v4(),
        authorId: 'user_1',
        text: text,
        createdAt: DateTime.now(),
      ),
    );
  }

  void _addBotMessage(String text) {
    chatController.insertMessage(
      TextMessage(
        id: uuid.v4(),
        authorId: botUser.id,
        text: text,
        createdAt: DateTime.now(),
      ),
    );
  }
}

