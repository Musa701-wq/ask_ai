// import 'dart:convert';
// import 'package:file_picker/file_picker.dart';
// import 'package:doc_text_extractor/doc_text_extractor.dart';
//
// class FileHelper {
//   // This function returns both file content and metadata
//   static Future<Map<String, dynamic>?> pickAndReadFileWithInfo() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowedExtensions: ['txt', 'docx', 'doc', 'pdf', 'md'],
//       type: FileType.custom,
//     );
//
//     if (result == null) {
//       return null; // User canceled
//     }
//
//     final file = result.files.first;
//     String? content;
//
//     // Extract text content based on file type
//     if (file.extension == "txt" && file.bytes != null) {
//       content = utf8.decode(file.bytes!);
//     } else if (file.extension == "pdf" && file.path != null) {
//       try {
//         final extractor = TextExtractor();
//         final extractResult = await extractor.extractText(
//           file.path!,
//           isUrl: false,
//         );
//         content = extractResult.text;
//       } catch (e) {
//         return null;
//       }
//     } else if ((file.extension == "docx" || file.extension == "doc") &&
//         file.path != null) {
//       try {
//         final extractor = TextExtractor();
//         final extractResult = await extractor.extractText(
//           file.path!,
//           isUrl: false,
//         );
//         content = extractResult.text;
//       } catch (e) {
//         print('Failed to read document: $e');
//         return null;
//       }
//     }
//
//     if (content != null && content.isNotEmpty) {
//       return {
//         'content': content,
//         'name': file.name,
//         'size': file.size,
//         'path': file.path,
//         'extension': file.extension,
//       };
//     }
//
//     return null;
//   }
//
//   // Updated method without context parameter
//   static Future<String?> pickAndReadFile() async {
//     final result = await pickAndReadFileWithInfo();
//     return result?['content'];
//   }
//
//   // Function to create chunks of the file content
//   static List<String> createChunks(String content, {int wordsPerChunk = 100}) {
//     if (content.trim().isEmpty) return [];
//
//     // Normalize text and split into sentences
//     final cleaned = content.replaceAll(RegExp(r'\s+'), ' ').trim();
//     final sentences = cleaned.split(
//       RegExp(r'(?<=[.!?])\s+'),
//     ); // split by punctuation + space
//
//     List<String> chunks = [];
//     List<String> currentWords = [];
//
//     for (var sentence in sentences) {
//       final words = sentence.split(' ');
//
//       // Add sentence words
//       currentWords.addAll(words);
//
//       // If current chunk exceeds limit, close it here
//       if (currentWords.length >= wordsPerChunk) {
//         chunks.add(currentWords.join(' ').trim());
//         currentWords.clear();
//       }
//     }
//
//     // Add remaining words as the final chunk
//     if (currentWords.isNotEmpty) {
//       chunks.add(currentWords.join(' ').trim());
//     }
//
//     return chunks;
//   }
// }


import 'dart:convert';
import 'dart:isolate';
import 'package:file_picker/file_picker.dart';
import 'package:doc_text_extractor/doc_text_extractor.dart';

class FileHelper {
  // This function returns both file content and metadata
  static Future<Map<String, dynamic>?> pickAndReadFileWithInfo() async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['txt', 'docx', 'doc', 'pdf', 'md'],
        type: FileType.custom,
      );

      if (result == null) {
        return null; // User canceled
      }

      final file = result.files.first;
      String? content;

      // Extract text content based on file type
      if (file.extension == "txt" && file.bytes != null) {
        // For text files, decode directly
        content = utf8.decode(file.bytes!);
      } else if (file.extension == "pdf" && file.path != null) {
        // For PDF files, extract text
        try {
          final extractor = TextExtractor();
          final extractResult = await extractor.extractText(
            file.path!,
            isUrl: false,
          );
          content = extractResult.text;
        } catch (e) {
          print('Failed to extract PDF: $e');
          return null;
        }
      } else if ((file.extension == "docx" || file.extension == "doc") &&
          file.path != null) {
        // For Word documents, extract text
        try {
          final extractor = TextExtractor();
          final extractResult = await extractor.extractText(
            file.path!,
            isUrl: false,
          );
          content = extractResult.text;
        } catch (e) {
          print('Failed to read document: $e');
          return null;
        }
      } else if (file.extension == "md" && file.bytes != null) {
        // For markdown files
        content = utf8.decode(file.bytes!);
      }

      if (content != null && content.isNotEmpty) {
        return {
          'content': content,
          'name': file.name,
          'size': file.size,
          'path': file.path,
          'extension': file.extension,
        };
      }

      return null;
    } catch (e) {
      print('Error in pickAndReadFileWithInfo: $e');
      return null;
    }
  }

  // Updated method without context parameter
  static Future<String?> pickAndReadFile() async {
    final result = await pickAndReadFileWithInfo();
    return result?['content'];
  }

  // Function to create chunks of the file content
  static List<String> createChunks(String content, {int wordsPerChunk = 100}) {
    if (content.trim().isEmpty) return [];

    // Normalize text and split into sentences
    final cleaned = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    final sentences = cleaned.split(
      RegExp(r'(?<=[.!?])\s+'),
    ); // split by punctuation + space

    List<String> chunks = [];
    List<String> currentWords = [];

    for (var sentence in sentences) {
      final words = sentence.split(' ');

      // Add sentence words
      currentWords.addAll(words);

      // If current chunk exceeds limit, close it here
      if (currentWords.length >= wordsPerChunk) {
        chunks.add(currentWords.join(' ').trim());
        currentWords.clear();
      }
    }

    // Add remaining words as the final chunk
    if (currentWords.isNotEmpty) {
      chunks.add(currentWords.join(' ').trim());
    }

    return chunks;
  }

  // Create chunks asynchronously for large files
  static Future<List<String>> createChunksAsync(
      String content, {
        int wordsPerChunk = 100,
      }) async {
    if (content.trim().isEmpty) return [];

    // For very large files, process in isolate to avoid blocking UI
    if (content.length > 100000) {
      return await Isolate.run(() => createChunks(content, wordsPerChunk: wordsPerChunk));
    }

    return createChunks(content, wordsPerChunk: wordsPerChunk);
  }
}