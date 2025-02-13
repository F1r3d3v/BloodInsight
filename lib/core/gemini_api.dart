import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiAPI {
  GeminiAPI({required String apiKey})
      : _model = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: apiKey,
        );

  final GenerativeModel _model;

  Future<String> generateContent(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? '';
    } catch (err) {
      throw Exception('Error generating content: $err');
    }
  }

  Future<Map<String, dynamic>> generateContentAsJson(
    String prompt,
    String format,
  ) async {
    try {
      final content = [
        Content.text(prompt),
        Content.text('Respond only with valid JSON format.\n\n$format'),
      ];

      final response = await _model.generateContent(
        content,
        generationConfig: GenerationConfig(
          temperature: 0.1,
          topK: 1,
          topP: 1,
        ),
      );

      final text = response.text ?? '';

      // Remove Markdown code block markers if present
      final forrmatted = text
          .replaceAll(RegExp(r'```json\n?'), '')
          .replaceAll(RegExp(r'```\n?'), '')
          .trim();

      try {
        return jsonDecode(forrmatted) as Map<String, dynamic>;
      } catch (err) {
        throw Exception('Response is not valid JSON: $text');
      }
    } catch (err) {
      throw Exception('Error generating content: $err');
    }
  }
}
