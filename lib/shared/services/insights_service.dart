import 'package:bloodinsight/core/gemini_api.dart';
import 'package:bloodinsight/features/bloodwork/data/bloodwork_model.dart';
import 'package:bloodinsight/features/user_profile/data/user_profile_model.dart';
import 'package:bloodinsight/shared/services/auth_service.dart';
import 'package:bloodinsight/shared/services/bloodwork_service.dart';
import 'package:bloodinsight/shared/services/user_profile_service.dart';

class InsightsException implements Exception {
  InsightsException(this.message);

  final String message;

  @override
  String toString() => message;
}

class InsightsService {
  InsightsService({
    required GeminiAPI gemini,
    required BloodworkService bloodworkService,
    required ProfileService profileService,
    required AuthService auth,
  })  : _gemini = gemini,
        _bloodworkService = bloodworkService,
        _profileService = profileService,
        _auth = auth;

  final GeminiAPI _gemini;
  final BloodworkService _bloodworkService;
  final ProfileService _profileService;
  final AuthService _auth;

  Future<Map<String, dynamic>> generateHealthInsights() async {
    // Get user profile
    final profile = await _profileService.getProfile(_auth.currentUser!.uid);
    if (profile == null) {
      throw InsightsException('User profile not found');
    }

    // Get latest 2 bloodworks
    final bloodworkStream = _bloodworkService.streamUserBloodwork();
    final bloodworkList = await bloodworkStream.first;
    if (bloodworkList.isEmpty) {
      throw InsightsException('No bloodwork records found');
    }

    final latestBloodwork = bloodworkList.first;
    final previousBloodwork =
        bloodworkList.length > 1 ? bloodworkList[1] : null;

    // Create prompt for Gemini
    final prompt = _createPrompt(profile, latestBloodwork, previousBloodwork);

    // Define expected JSON format with explicit types
    const jsonFormat = '''
Return JSON object with the following structure:
{
  "summary": String,  // Overall health assessment as a detailed string
  "age_related_insights": String,  // Age-specific insights as a string
  "bmi_analysis": {
    "status": String,  // One of: "Underweight", "Normal", "Overweight", "Obese"
    "recommendation": String  // Weight management advice as a string
  },
  "bloodwork_analysis": {
    "normal_markers": Array<String>,  // Array of marker names within normal range
    "concerns": Array<{
      "marker": String,  // Name of the blood marker
      "value": String,  // Current value with unit
      "recommendation": String  // Specific advice for this marker
    }>
  },
  "trends": Array<{
    "marker": String,  // Name of the blood marker
    "trend": String,  // One of: "improving", "stable", "declining"
    "description": String  // Detailed description of the trend
  }>,
  "lifestyle_recommendations": Array<String>,  // Array of recommendation strings
  "follow_up": {
    "required": Boolean,  // Whether follow-up is needed
    "timeframe": String,  // e.g., "3 months", "6 months", "1 year"
    "focus_areas": Array<String>  // Array of areas needing attention
  }
}''';

    // Generate insights using Gemini
    return _gemini.generateContentAsJson(prompt, jsonFormat);
  }

  String _createPrompt(
    UserProfile profile,
    Bloodwork latestBloodwork,
    Bloodwork? previousBloodwork,
  ) {
    final age = _profileService.calculateAge(profile);
    final bmi = _profileService.calculateBMI(profile);

    return '''
Generate health insights based on the following patient data:

Personal Information:
- Age: $age years
- Gender: ${profile.gender}
- Blood Type: ${profile.bloodType ?? 'Unknown'}
- Height: ${profile.height} cm
- Weight: ${profile.weight} kg
- BMI: ${bmi.toStringAsFixed(1)}

Latest Bloodwork (${latestBloodwork.dateCollected}):
${_formatBloodworkData(latestBloodwork)}

${previousBloodwork != null ? 'Previous Bloodwork (${previousBloodwork.dateCollected}):\n${_formatBloodworkData(previousBloodwork)}\n' : ''}

Provide a comprehensive health analysis including:
1. Overall health assessment
2. Age-specific health insights
3. BMI analysis and recommendations
4. Analysis of blood markers (normal ranges vs current values)
5. Lifestyle recommendations
6. Follow-up recommendations

Focus on actionable insights and clear recommendations.''';
  }

  String _formatBloodworkData(Bloodwork bloodwork) {
    final buffer = StringBuffer();

    for (final marker in bloodwork.markers) {
      buffer.writeln('- ${marker.name}: ${marker.value} ${marker.unit} '
          '(Range: ${marker.minRange}-${marker.maxRange} ${marker.unit})');
    }

    return buffer.toString();
  }
}
