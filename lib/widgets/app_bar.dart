import 'package:docusense_ai/app_localization.dart';
import 'package:flutter/material.dart';
import '../screens/home/SettingsScreen.dart';
import '../utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:docusense_ai/providers/language_provider.dart';
import 'package:docusense_ai/screens/signin_screen.dart';
import '../providers/auth_state.dart';
import '../Auth/google_sign_out.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.5),
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppConstants.primaryColor,
                  AppConstants.secondaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'I',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context).appTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppConstants.textColor,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: ElevatedButton(
            onPressed: () async {
              if (authState.isUserSignedIn) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color(0xFFF5F5FF),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(AppLocalizations.of(context).confirmSignOut),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    AppLocalizations.of(context).cancel,
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppConstants.primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    unifiedSignOut(context);
                                    authState.signOut();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    AppLocalizations.of(context).confirm,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                final signInAttempted = await showSignInDialog(context);
                if (signInAttempted && context.mounted) {
                  if (authState.isUserSignedIn) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context).signedInSuccessfully,
                        ),
                        backgroundColor: AppConstants.primaryColor,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
            ),
            child: Text(
              authState.isUserSignedIn
                  ? AppLocalizations.of(context).signOut
                  : AppLocalizations.of(context).signIn,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.language),
          onPressed: () {
            _showLanguageDialog(context);
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return SettingsScreen();
            }));
          },
        ),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return _LanguageDialog();
      },
    );
  }

  String _getFlagEmoji(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'nl':
        return '🇳🇱';
      case 'ar':
        return '🇸🇦';
      case 'zh':
        return '🇨🇳';
      default:
        return '🌐';
    }
  }
}

// Separate StatefulWidget for the language dialog
class _LanguageDialog extends StatefulWidget {
  @override
  State<_LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<_LanguageDialog> {
  bool _isChangingLanguage = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(localizations.selectLanguage),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 400,
          minWidth: 280,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(localizations.english, 'en'),
              _buildLanguageOption(localizations.spanish, 'es'),
              _buildLanguageOption(localizations.french, 'fr'),
              _buildLanguageOption(localizations.german, 'de'),
              _buildLanguageOption(localizations.dutch, 'nl'),
              _buildLanguageOption(localizations.arabic, 'ar'),
              _buildLanguageOption(localizations.chinese, 'zh'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isChangingLanguage
              ? null
              : () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Text(
            localizations.cancel,
            style: TextStyle(
              color: _isChangingLanguage ? Colors.grey : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(String language, String code) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isSelected = languageProvider.currentLocale.languageCode == code;

        return ListTile(
          enabled: !_isChangingLanguage,
          leading: Text(
            _getFlagEmoji(code),
            style: const TextStyle(fontSize: 24),
          ),
          title: Text(
            language,
            style: TextStyle(
              color: _isChangingLanguage ? Colors.grey : null,
            ),
          ),
          trailing: isSelected
              ? const Icon(Icons.check, color: Colors.green)
              : null,
          onTap: isSelected || _isChangingLanguage
              ? null
              : () async {
            if (_isChangingLanguage) return;

            setState(() {
              _isChangingLanguage = true;
            });

            try {
              // Get provider reference before async gap
              final languageProvider = Provider.of<LanguageProvider>(
                context,
                listen: false,
              );

              // Change the locale
              await languageProvider.setLocale(Locale(code));

              // Small delay to ensure state is updated
              await Future.delayed(const Duration(milliseconds: 100));

              // Close dialog if still mounted
              if (mounted && context.mounted) {
                Navigator.of(context).pop();
              }
            } catch (e) {
              debugPrint('Error changing language: $e');

              if (mounted) {
                setState(() {
                  _isChangingLanguage = false;
                });

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to change language. Please try again.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            }
          },
        );
      },
    );
  }

  String _getFlagEmoji(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'nl':
        return '🇳🇱';
      case 'ar':
        return '🇸🇦';
      case 'zh':
        return '🇨🇳';
      default:
        return '🌐';
    }
  }
}