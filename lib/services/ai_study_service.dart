import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AiStudyService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Picks a PDF file from the device and uploads it to the public 'pdfs' bucket
  Future<String?> uploadPdfAndGetUrl() async {
    try {
      // 1. Pick PDF file from device
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) {
        return null; // User canceled picker
      }

      final file = File(result.files.single.path!);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
      final filePath = 'uploads/$fileName';

      // 2. Upload file to Supabase storage 'pdfs' bucket
      await _supabase.storage.from('pdfs').upload(
        filePath,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      // 3. Get public URL of the uploaded file
      final publicUrl = _supabase.storage.from('pdfs').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload PDF: $e');
    }
  }

  /// Sends the PDF public URL and action to the Supabase Edge Function
  Future<Map<String, dynamic>> processPdf({
    required String pdfUrl,
    required String action, // 'notes', 'exam', or 'flashcards'
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'process-pdf',
        body: {
          'pdfUrl': pdfUrl,
          'action': action,
        },
      );

      final data = response.data;

      if (data == null) {
        throw Exception('Server returned an empty response.');
      }

      if (data is Map) {
        if (data.containsKey('error')) {
          throw Exception(data['error']);
        }

        if (data is Map<String, dynamic>) {
          return data;
        } else {
          return Map<String, dynamic>.from(data);
        }
      }

      if (data is String) {
        throw Exception('Server returned string instead of JSON: $data');
      }

      throw Exception('Unexpected response format received from server.');
    } catch (e) {
      print('AI Processing Error: $e');
      rethrow;
    }
  }
}