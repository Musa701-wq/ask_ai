// import 'package:docusense_ai/app_localization.dart';
// import 'package:docusense_ai/providers/auth_state.dart';
// import 'package:docusense_ai/screens/signin_screen.dart' as signin;
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../providers/pdf_provider.dart';
// import '../../../providers/file_provider.dart';
// import '../../../utils/constants.dart';
//
// class UploadSection extends StatefulWidget {
//   const UploadSection({super.key});
//
//   @override
//   State<UploadSection> createState() => _UploadSectionState();
// }
//
// class _UploadSectionState extends State<UploadSection> {
//   bool _isLocalLoading = false;
//   bool _showFileStatus = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final pdfProvider = Provider.of<PdfProvider>(context);
//     final fileProvider = Provider.of<FileProvider>(context);
//
//     // Combine both loading states
//     final bool isLoading = pdfProvider.isProcessingFile || _isLocalLoading;
//
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(25),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: AppConstants.primaryColor.withOpacity(0.08),
//                 blurRadius: 15,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//             border: Border.all(color: AppConstants.borderColor, width: 1),
//           ),
//           child: Column(
//             children: [
//               // Upload Area
//               GestureDetector(
//                 onTap: () => _handleUpload(pdfProvider, context),
//                 child: Container(
//                   padding: const EdgeInsets.all(40),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: isLoading
//                           ? AppConstants.primaryColor.withOpacity(0.5)
//                           : AppConstants.borderColor,
//                       width: 2,
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                     color: isLoading
//                         ? AppConstants.primaryColor.withOpacity(0.05)
//                         : Colors.white,
//                   ),
//                   child: Column(
//                     children: [
//                       // Animated loading icon
//                       AnimatedSwitcher(
//                         duration: const Duration(milliseconds: 300),
//                         child: isLoading
//                             ? const SizedBox(
//                                 width: 48,
//                                 height: 48,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 3,
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                     AppConstants.primaryColor,
//                                   ),
//                                 ),
//                               )
//                             : Icon(
//                                 Icons.cloud_upload_outlined,
//                                 size: 48,
//                                 color: AppConstants.primaryColor,
//                               ),
//                       ),
//                       const SizedBox(height: 15),
//                       AnimatedSwitcher(
//                         duration: const Duration(milliseconds: 300),
//                         child: Text(
//                           isLoading
//                               ? 'Uploading...'
//                               : AppLocalizations.of(context).uploadPdf,
//                           key: ValueKey(isLoading),
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: AppConstants.textColor,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       AnimatedSwitcher(
//                         duration: const Duration(milliseconds: 300),
//                         child: Text(
//                           isLoading
//                               ? 'Processing your file...'
//                               : AppLocalizations.of(context).tapToSelectFile,
//                           key: ValueKey(isLoading),
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: AppConstants.subtitleColor,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               // Loading indicator with better animation
//               if (isLoading) ...[
//                 AnimatedOpacity(
//                   opacity: isLoading ? 1.0 : 0.0,
//                   duration: const Duration(milliseconds: 300),
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         width: 32,
//                         height: 32,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 3,
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             AppConstants.primaryColor,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'Loading your file...',
//                         style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                       ),
//                       const SizedBox(height: 16),
//                     ],
//                   ),
//                 ),
//               ],
//
//               // Upload Button
//               AnimatedOpacity(
//                 opacity: isLoading ? 0.7 : 1.0,
//                 duration: const Duration(milliseconds: 300),
//                 child: SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: isLoading
//                         ? null
//                         : () => _handleUpload(pdfProvider, context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppConstants.primaryColor,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       elevation: isLoading ? 2 : 4,
//                       shadowColor: AppConstants.primaryColor.withOpacity(0.3),
//                     ),
//                     child: AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 300),
//                       child: isLoading
//                           ? const Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 SizedBox(
//                                   width: 16,
//                                   height: 16,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                       Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(width: 8),
//                                 Text(
//                                   'Processing...',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             )
//                           : Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.cloud_upload, size: 20),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   AppLocalizations.of(context).uploadPdf,
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),
//
//         // File Status Section with smooth appearance
//         if (_showFileStatus && fileProvider.hasFile && !isLoading)
//           _buildFileStatusSection(fileProvider),
//       ],
//     );
//   }
//
//   Future<void> _handleUpload(
//     PdfProvider pdfProvider,
//     BuildContext context,
//   ) async {
//     final authState = Provider.of<AuthState>(context, listen: false);
//
//     if (!authState.isUserSignedIn) {
//       signin.showSignInDialog(context);
//     } else {
//       // Set local loading state first for immediate feedback
//       setState(() {
//         _isLocalLoading = true;
//         _showFileStatus = false; // Hide file status while loading
//       });
//
//       // Add a small delay to ensure loading state is visible
//       await Future.delayed(const Duration(milliseconds: 50));
//
//       try {
//         // Start both the file processing and a 5-second delay
//         final processingFuture = pdfProvider.selectAndUploadFile();
//         final fiveSecondDelay = Future.delayed(const Duration(seconds: 5));
//
//         // Wait for both to complete (whichever takes longer)
//         await Future.wait([processingFuture, fiveSecondDelay]);
//
//         // After 5 seconds, show the file status
//         if (mounted) {
//           setState(() {
//             _showFileStatus = true;
//           });
//         }
//       } finally {
//         // Ensure loading state is cleared even if there's an error
//         if (mounted) {
//           setState(() {
//             _isLocalLoading = false;
//           });
//         }
//       }
//     }
//   }
//
//   Widget _buildFileStatusSection(FileProvider fileProvider) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 500),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppConstants.lightPurple,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.check_circle, color: AppConstants.primaryColor, size: 24),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'File Selected',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: AppConstants.primaryColor,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   fileProvider.fileName!,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: AppConstants.subtitleColor,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 if (fileProvider.fileSize != null) ...[
//                   const SizedBox(height: 2),
//                   Text(
//                     fileProvider.formattedFileSize,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: AppConstants.subtitleColor.withOpacity(0.7),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           IconButton(
//             onPressed: () {
//               fileProvider.clearFile();
//               fileProvider.clearSelection();
//               setState(() {
//                 _showFileStatus = false; // Hide file status when cleared
//               });
//             },
//             icon: Icon(Icons.close, color: AppConstants.subtitleColor),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:docusense_ai/app_localization.dart';
import 'package:docusense_ai/providers/auth_state.dart';
import 'package:docusense_ai/screens/signin_screen.dart' as signin;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/pdf_provider.dart';
import '../../../providers/file_provider.dart';
import '../../../utils/constants.dart';

class UploadSection extends StatefulWidget {
  const UploadSection({super.key});

  @override
  State<UploadSection> createState() => _UploadSectionState();
}

class _UploadSectionState extends State<UploadSection> with SingleTickerProviderStateMixin {
  bool _showFileStatus = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pdfProvider = Provider.of<PdfProvider>(context);
    final fileProvider = Provider.of<FileProvider>(context);
    final localizations = AppLocalizations.of(context);

    final bool isLoading = pdfProvider.isProcessingFile;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryColor.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: AppConstants.borderColor, width: 1),
          ),
          child: Column(
            children: [
              // Upload Area - ONLY show when NOT loading
              if (!isLoading)
                GestureDetector(
                  onTap: () => _handleUpload(pdfProvider, context),
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppConstants.borderColor,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          localizations.uploadPdf,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localizations.tapToSelectFile,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppConstants.subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Progress Section - ONLY show when loading
              if (isLoading) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      // Animated upload icon with pulse effect
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.cloud_upload_outlined,
                            size: 48,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Status text with fade animation - Localized
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _getLocalizedStatus(pdfProvider.processingStatus, localizations),
                          key: ValueKey(pdfProvider.processingStatus),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // SINGLE Progress bar with percentage
                      Column(
                        children: [
                          // Progress bar container
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Stack(
                              children: [
                                // Animated progress fill
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: MediaQuery.of(context).size.width *
                                      pdfProvider.uploadProgress,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppConstants.primaryColor,
                                        AppConstants.primaryColor.withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppConstants.primaryColor.withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Percentage text with animation
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 300),
                            tween: Tween<double>(
                              begin: 0,
                              end: pdfProvider.uploadProgress,
                            ),
                            builder: (context, value, child) {
                              return Text(
                                '${(value * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryColor,
                                  letterSpacing: 1.2,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Helper text - Localized
                      Text(
                        _getWaitMessage(localizations),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.subtitleColor.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Upload Button - ONLY show when NOT loading
              if (!isLoading) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleUpload(pdfProvider, context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                      shadowColor: AppConstants.primaryColor.withOpacity(0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_upload, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          localizations.uploadPdf,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // File Status Section - Shows after successful upload
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: _showFileStatus && fileProvider.hasFile && !isLoading
              ? _buildFileStatusSection(fileProvider, localizations)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // Helper method to get localized status messages
  String _getLocalizedStatus(String status, AppLocalizations localizations) {
    if (status.isEmpty || status == 'Processing...') {
      return localizations.loading;
    }

    // Map English status messages to localized ones
    if (status.contains('Initializing')) {
      return localizations.loading;
    } else if (status.contains('Opening file picker')) {
      return localizations.tapToSelectFile;
    } else if (status.contains('File selected') || status.contains('reading')) {
      return localizations.loading;
    } else if (status.contains('Extracting text')) {
      return localizations.analyzingDocument;
    } else if (status.contains('Processing document')) {
      return localizations.analyzingDocument;
    } else if (status.contains('Finalizing')) {
      return localizations.loading;
    } else if (status.contains('complete')) {
      return localizations.ok;
    }

    return localizations.loading;
  }

  // Helper method to get wait message
  String _getWaitMessage(AppLocalizations localizations) {
    final locale = localizations.locale.languageCode;

    final messages = {
      'en': 'Please wait, this may take a moment...',
      'es': 'Por favor espere, esto puede tomar un momento...',
      'fr': 'Veuillez patienter, cela peut prendre un moment...',
      'de': 'Bitte warten Sie, dies kann einen Moment dauern...',
      'nl': 'Een moment geduld, dit kan even duren...',
      'ar': 'يرجى الانتظار، قد يستغرق هذا لحظة...',
      'zh': '请稍候，这可能需要一些时间...',
    };

    return messages[locale] ?? messages['en']!;
  }

  Future<void> _handleUpload(
      PdfProvider pdfProvider,
      BuildContext context,
      ) async {
    final authState = Provider.of<AuthState>(context, listen: false);

    if (!authState.isUserSignedIn) {
      signin.showSignInDialog(context);
    } else {
      setState(() {
        _showFileStatus = false;
      });

      await pdfProvider.selectAndUploadFile();

      // Show file status after upload completes
      if (mounted && pdfProvider.hasFileLoaded) {
        setState(() {
          _showFileStatus = true;
        });
      }
    }
  }

  Widget _buildFileStatusSection(FileProvider fileProvider, AppLocalizations localizations) {
    final locale = localizations.locale.languageCode;

    // Localized success messages
    final successMessages = {
      'en': 'Upload Successful!',
      'es': '¡Carga Exitosa!',
      'fr': 'Téléchargement Réussi!',
      'de': 'Upload Erfolgreich!',
      'nl': 'Upload Succesvol!',
      'ar': 'تم الرفع بنجاح!',
      'zh': '上传成功！',
    };

    final removeMessages = {
      'en': 'Remove file',
      'es': 'Eliminar archivo',
      'fr': 'Supprimer le fichier',
      'de': 'Datei entfernen',
      'nl': 'Bestand verwijderen',
      'ar': 'إزالة الملف',
      'zh': '删除文件',
    };

    return Container(
      key: const ValueKey('file_status'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Success icon with animation
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green.shade700,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  successMessages[locale] ?? successMessages['en']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fileProvider.fileName!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (fileProvider.fileSize != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.insert_drive_file,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        fileProvider.formattedFileSize,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Remove button
          IconButton(
            onPressed: () {
              fileProvider.clearFile();
              fileProvider.clearSelection();
              setState(() {
                _showFileStatus = false;
              });
            },
            icon: Icon(
              Icons.close_rounded,
              color: Colors.grey.shade600,
            ),
            tooltip: removeMessages[locale] ?? removeMessages['en']!,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
          ),
        ],
      ),
    );
  }
}