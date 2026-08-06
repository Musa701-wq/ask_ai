// // providers/pdf_provider.dart
// import 'package:docusense_ai/providers/file_provider.dart';
// import 'package:docusense_ai/utils/file_helper.dart';
// import 'package:flutter/material.dart';
// import '../models/app_state.dart';
//
// class PdfProvider extends ChangeNotifier {
//   AppState _state = const AppState();
//   final FileProvider _fileProvider;
//   bool _isProcessingFile = false;
//
//   PdfProvider({required FileProvider fileProvider})
//     : _fileProvider = fileProvider;
//
//   AppState get state => _state;
//   bool get isProcessingFile => _isProcessingFile;
//
//   // Get file info from file provider
//   String? get uploadedFileName => _fileProvider.fileName;
//   String? get uploadedFileContent => _fileProvider.fileContent;
//   String? get uploadedPdfPath => _fileProvider.filePath;
//
//   BottomNavItem get currentTab => _state.currentTab;
//
//   void changeTab(BottomNavItem tab) {
//     _state = _state.copyWith(
//       currentTab: tab,
//       isChatVisible: tab == BottomNavItem.chat,
//     );
//     notifyListeners();
//   }
//
//   void selectRecentFileAndNavigate(RecentFile file, BottomNavItem tab) {
//     _fileProvider.selectRecentFile(file);
//     changeTab(tab);
//   }
//
//   bool get hasFileLoaded => _fileProvider.hasFile;
//
//   Future<void> selectAndUploadFile() async {
//     if (_isProcessingFile) return;
//
//     _setState(isProcessingFile: true);
//
//     try {
//       final fileInfo = await FileHelper.pickAndReadFileWithInfo();
//
//       if (fileInfo != null && fileInfo['content'] != null) {
//         final String fileName = fileInfo['name']?.toString() ?? 'document.pdf';
//         final String fileContent = fileInfo['content']?.toString() ?? '';
//         final String? filePath = fileInfo['path']?.toString();
//         final int? fileSize = fileInfo['size'] is int
//             ? fileInfo['size'] as int
//             : (fileInfo['size'] != null
//                   ? int.tryParse(fileInfo['size'].toString())
//                   : null);
//
//         _fileProvider.setFile(
//           fileName,
//           fileContent,
//           path: filePath,
//           size: fileSize,
//         );
//       }
//     } catch (e) {
//       print('Error uploading file: $e');
//     } finally {
//       _setState(isProcessingFile: false);
//     }
//   }
//
//   void resetUpload() {
//     _fileProvider.clearFile();
//     notifyListeners();
//   }
//
//   void _setState({bool? isProcessingFile}) {
//     if (isProcessingFile != null) _isProcessingFile = isProcessingFile;
//     notifyListeners();
//   }
// }


// providers/pdf_provider.dart


import 'package:docusense_ai/providers/file_provider.dart';
import 'package:docusense_ai/utils/file_helper.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/app_state.dart';

class PdfProvider extends ChangeNotifier {
  AppState _state = const AppState();
  final FileProvider _fileProvider;
  bool _isProcessingFile = false;
  double _uploadProgress = 0.0;
  String _processingStatus = '';

  PdfProvider({required FileProvider fileProvider}) : _fileProvider = fileProvider;

  AppState get state => _state;
  bool get isProcessingFile => _isProcessingFile;
  double get uploadProgress => _uploadProgress;
  String get processingStatus => _processingStatus;

  // Get file info from file provider
  String? get uploadedFileName => _fileProvider.fileName;
  String? get uploadedFileContent => _fileProvider.fileContent;
  String? get uploadedPdfPath => _fileProvider.filePath;

  BottomNavItem get currentTab => _state.currentTab;

  void changeTab(BottomNavItem tab) {
    _state = _state.copyWith(
      currentTab: tab,
      isChatVisible: tab == BottomNavItem.chat,
    );
    notifyListeners();
  }

  void selectRecentFileAndNavigate(RecentFile file, BottomNavItem tab) {
    _fileProvider.selectRecentFile(file);
    changeTab(tab);
  }

  bool get hasFileLoaded => _fileProvider.hasFile;

  // Simulate smooth progress for file operations
  Future<void> _simulateProgress(double target, Duration duration) async {
    final steps = 20; // Number of progress updates
    final increment = (target - _uploadProgress) / steps;
    final stepDuration = duration ~/ steps;

    for (int i = 0; i < steps; i++) {
      if (!_isProcessingFile) break; // Stop if cancelled
      await Future.delayed(stepDuration);
      _uploadProgress = (_uploadProgress + increment).clamp(0.0, 1.0);
      notifyListeners();
    }
  }

  Future<void> selectAndUploadFile() async {
    if (_isProcessingFile) return;

    _isProcessingFile = true;
    _uploadProgress = 0.0;
    _processingStatus = 'Initializing...';
    notifyListeners();

    try {
      // Step 1: Start file picker
      _processingStatus = 'Opening file picker...';
      _uploadProgress = 0.05;
      notifyListeners();

      // Simulate progress while picker is open
      final progressTimer = Timer.periodic(
        const Duration(milliseconds: 100),
            (timer) {
          if (_uploadProgress < 0.15) {
            _uploadProgress += 0.01;
            notifyListeners();
          }
        },
      );

      final fileInfo = await FileHelper.pickAndReadFileWithInfo();
      progressTimer.cancel();

      if (fileInfo == null) {
        // User cancelled
        _isProcessingFile = false;
        _uploadProgress = 0.0;
        _processingStatus = '';
        notifyListeners();
        return;
      }

      // Step 2: File selected - quick progress jump
      _uploadProgress = 0.25;
      _processingStatus = 'File selected, reading...';
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 100));

      // Step 3: Reading file content with smooth progress
      _processingStatus = 'Extracting text content...';
      await _simulateProgress(0.65, const Duration(milliseconds: 800));

      if (fileInfo['content'] != null) {
        final String fileName = fileInfo['name']?.toString() ?? 'document.pdf';
        final String fileContent = fileInfo['content']?.toString() ?? '';
        final String? filePath = fileInfo['path']?.toString();
        final int? fileSize = fileInfo['size'] is int
            ? fileInfo['size'] as int
            : (fileInfo['size'] != null
            ? int.tryParse(fileInfo['size'].toString())
            : null);

        // Step 4: Processing content
        _processingStatus = 'Processing document...';
        await _simulateProgress(0.85, const Duration(milliseconds: 500));

        _fileProvider.setFile(
          fileName,
          fileContent,
          path: filePath,
          size: fileSize,
        );

        // Step 5: Finalizing
        _processingStatus = 'Finalizing...';
        await _simulateProgress(0.95, const Duration(milliseconds: 300));

        // Step 6: Complete
        _uploadProgress = 1.0;
        _processingStatus = 'Upload complete!';
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      print('Error uploading file: $e');
      _processingStatus = 'Upload failed';
      await Future.delayed(const Duration(seconds: 1));
    } finally {
      _isProcessingFile = false;
      _uploadProgress = 0.0;
      _processingStatus = '';
      notifyListeners();
    }
  }

  void resetUpload() {
    _fileProvider.clearFile();
    notifyListeners();
  }
}