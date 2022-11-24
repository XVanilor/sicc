import 'package:uuid/uuid.dart';

/// SICC Enrollment Protocol (SEP) Manager
/// Used for encode and decode QR codes data
class SEPManager {

  static String encodeQRData(String apiUrl, String enrollmentToken, String crateUuid)
  {
    return "siccapp://$apiUrl::$enrollmentToken::$crateUuid";
  }

  static SEPQrData? decodeQRData(String rawData)
  {
    // Check if protocol is fine
    if(!rawData.startsWith("siccapp://"))
    {
      return null;
    }
    rawData = rawData.replaceAll("siccapp://", "");
    // Extract data from string
    List<String> data = rawData.split("::");
    if(data.length != 3)
    {
      return null;
    }

    final apiUrl = data[0];
    final enrollmentToken = data[1];
    final crateUuid = data[2];

    // Testing data validity
    if(
      Uri.tryParse(apiUrl) == null || (!apiUrl.startsWith("http://") && !apiUrl.startsWith("https://")) ||
      !Uuid.isValidUUID(fromString: enrollmentToken) || !Uuid.isValidUUID(fromString: crateUuid)
      )
    {
      return null;
    }

    // All data are valid
    return SEPQrData(apiUrl: apiUrl, enrollmentToken: enrollmentToken, crateUuid: crateUuid);
  }
}

class SEPQrData {

  final String apiUrl;
  final String enrollmentToken;
  final String crateUuid;

  SEPQrData({
    required this.apiUrl,
    required this.enrollmentToken,
    required this.crateUuid
  });
}