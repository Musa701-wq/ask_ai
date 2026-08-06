import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsManager {
  static final AnalyticsManager _instance = AnalyticsManager._internal();

  factory AnalyticsManager() {
    return _instance;
  }

  AnalyticsManager._internal();

  // Track Summary Generation
  static void trackSummaryGenerated() {
    debugPrint('📊 [Analytics] Summary Generated');
    // TODO: Add Firebase Analytics or your analytics service
     FirebaseAnalytics.instance.logEvent(name: 'summary_generated');
  }

  // Track Chat Message
  static void trackChatMessage() {
    debugPrint('📊 [Analytics] Chat Message Sent');
    // TODO: Add Firebase Analytics or your analytics service
     FirebaseAnalytics.instance.logEvent(name: 'chat_message_sent');
  }

  // Track Quiz Generation
  static void trackQuizGenerated() {
    debugPrint('📊 [Analytics] Quiz Generated');
    // TODO: Add Firebase Analytics or your analytics service
     FirebaseAnalytics.instance.logEvent(name: 'quiz_generated');
  }
}