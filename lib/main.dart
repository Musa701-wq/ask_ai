import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:docusense_ai/firebase_options.dart';
import 'package:docusense_ai/providers/ad_provider.dart';
import 'package:docusense_ai/providers/auth_state.dart';
import 'package:docusense_ai/providers/summary_provider.dart';
import 'package:docusense_ai/screens/chat/chat_screen.dart';
import 'package:docusense_ai/screens/quiz/quiz_screen.dart';
import 'package:docusense_ai/screens/splash/splash_screen.dart';
import 'package:docusense_ai/screens/summary/summary_screen.dart';
import 'package:docusense_ai/utils/ads_manager.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'providers/pdf_provider.dart';
import 'providers/file_provider.dart';
import 'app_localization.dart';
import 'providers/language_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await MobileAds.instance.initialize();
  await dotenv.load(fileName: ".env");

  // 🔥 Request tracking permission (only for iOS)
  final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  if (status == TrackingStatus.notDetermined) {
    await AppTrackingTransparency.requestTrackingAuthorization();
  }

  // AdMob initialization - CRITICAL: Initialize before requesting tracking
  await AdManager.initialize();
  debugPrint('✅ AdMob initialized');

  // Initialize AdProvider and load saved data
  final adProvider = AdProvider();
  await adProvider.initialize();


  // Initialize AuthState
  final authState = AuthState();
  authState.checkAuthState(); // Check if user is already signed in
  await analytics.logEvent(name: 'debug_view_test');
  print('📊 Logged debug_view_test event for DebugView');

  runApp(SecureVault(adProvider: adProvider, authState: authState));
}

class SecureVault extends StatelessWidget {
  final AdProvider adProvider;
  final AuthState authState;

  const SecureVault({
    super.key,
    required this.adProvider,
    required this.authState,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: adProvider),
        ChangeNotifierProvider.value(value: authState), // Use initialized instance
        ChangeNotifierProvider(create: (_) => FileProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProxyProvider<FileProvider, PdfProvider>(
          create: (context) => PdfProvider(fileProvider: FileProvider()),
          update: (context, fileProvider, pdfProvider) =>
              PdfProvider(fileProvider: fileProvider),
        ),
        ChangeNotifierProxyProvider<FileProvider, SummaryProvider>(
          create: (context) => SummaryProvider(fileProvider: FileProvider()),
          update: (context, fileProvider, summaryProvider) =>
              SummaryProvider(fileProvider: fileProvider),
        ),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'IntelliDocs AI',
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: scaffoldMessengerKey,
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('es'), // Spanish
              Locale('fr'), // French
              Locale('de'), // German
              Locale('nl'), // Dutch
              Locale('ar'), // Arabic
              Locale('zh'), // Chinese
            ],
            locale: languageProvider.currentLocale,
            theme: ThemeData(
              primaryColor: const Color(0xFF8A2BE2),
              colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: const Color(0xFF8A2BE2),
                secondary: const Color(0xFF6A0DAD),
              ),
              useMaterial3: true,
            ),
            home: const SplashScreen(),
            routes: {
              '/chat': (context) => const ChatScreen(),
              '/summary': (context) => const SummaryScreen(),
              '/quiz': (context) => const QuizScreen(),
            },
          );
        },
      ),
    );
  }
}