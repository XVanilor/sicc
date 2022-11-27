import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/Model/Crate.dart';
import '/Model/User.dart';
import 'package:uuid/uuid.dart';

class SiccApi {

  static String apiUrlKey = "API_URL";
  static String apiKey = "PRIV_KEY";
  static String enrollmentToken = "PUB_KEY";
  static String username = "USERNAME";

  Future<List<Crate>> getCrates() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Response res = await get(
        Uri.parse("${prefs.getString(SiccApi.apiUrlKey)}/list.php"),
        headers: <String, String>{
          'X-API-TOKEN': prefs.getString(SiccApi.apiKey) ?? ""
        },
    ).timeout(const Duration(seconds: 5));

    if(res.statusCode == 200){
      List<dynamic> body = jsonDecode(res.body)["data"];

      List<Crate> crates = body.map((dynamic item) => Crate.fromJson(item)).toList().cast<Crate>();

      return crates;
    }

    else
      {
        throw "Cannot retrieve crates at time. Are you connected to Internet ?";
      }
  }

  Future<Crate> saveCrate(Crate crate) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Response res = await post(
        Uri.parse("${prefs.getString(SiccApi.apiUrlKey) ?? "http://127.0.0.1"}/save.php"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'X-API-TOKEN': prefs.getString(SiccApi.apiKey) ?? ""
        },
      body: jsonEncode(crate.toJson())
    ).timeout(const Duration(seconds: 5));

    if(res.statusCode == 200)
      {
        Map<String, dynamic> body = jsonDecode(res.body)["data"];
        return Crate.fromJson(body);
      }
    else
    {
      throw "Cannot save crate at time. Are you connected to Internet ?";
    }
  }

  Future<bool> deleteCrate(Crate crate) async {

    String crateUuid = crate.uuid;

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Response res = await delete(
      Uri.parse("${prefs.getString(SiccApi.apiUrlKey) ?? "http://127.0.0.1"}/delete.php?id=$crateUuid"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-API-TOKEN': prefs.getString(SiccApi.apiKey) ?? ""
      },
    );

    if(res.statusCode == 204)
    {
      return true;
    }
    else
    {
      throw "Cannot delete crate at time. Are you connected to Internet ?";
    }
  }

  Future<bool> configure(String apiUrl, String username, String apiKey) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if(Uri.tryParse(apiUrl) == null)
    {
      throw "URL is invalid";
    }
    prefs.setString(SiccApi.apiUrlKey, apiUrl);

    User? user = await createUser(username, apiKey);
    if(user == null)
      {
        SiccApi.resetConfig();
        throw "Cannot create your account. Are you connected to Internet ?";
      }

    prefs.setString(SiccApi.apiKey, user.apiKey);
    prefs.setString(SiccApi.enrollmentToken, user.enrollmentToken);
    prefs.setString(SiccApi.username, user.name);

    return true;
  }

  Future<User?> createUser(String username, String apiKey) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if(!prefs.containsKey(SiccApi.apiUrlKey) || prefs.getString(SiccApi.apiUrlKey)  == "")
      {
        throw "API URL is not configured yet";
      }

    Map<String, dynamic> jsonBody = {"username": username};
    
    Response res = await post(
      Uri.parse("${prefs.getString(SiccApi.apiUrlKey) ?? "http://127.0.0.1"}/register.php"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-API-TOKEN': apiKey
      },
      body: jsonEncode(jsonBody)
    ).timeout(const Duration(seconds: 5));

    if(res.statusCode == 201)
      {
        return User.fromJson(jsonDecode(res.body)["data"]);
      }
    else
      {
        return null;
      }
  }

  Future<bool> configureEnrollment(String apiUrl, String username, String enrollmentToken, String pinCode) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString(SiccApi.apiUrlKey, apiUrl);

    try {

      User? user = await enrollUser(username, enrollmentToken, pinCode);
      if(user == null)
      {
        SiccApi.resetConfig();
        throw "Cannot enroll your account. Are you connected to Internet ?";
      }

      prefs.setString(SiccApi.apiKey, user.apiKey);
      prefs.setString(SiccApi.enrollmentToken, user.enrollmentToken);
      prefs.setString(SiccApi.username, user.name);

    } catch (e)
    {
      throw e;
    }

    return true;
  }

  Future<User?> enrollUser(String username, String enrollmentToken, String pinCode) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> jsonBody = {"username": username, "pinCode": pinCode};

    Response res = await post(
        Uri.parse("${prefs.getString(SiccApi.apiUrlKey) ?? "http://127.0.0.1"}/enroll.php"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'X-ENROLLMENT-TOKEN': enrollmentToken
        },
        body: jsonEncode(jsonBody)
    ).timeout(const Duration(seconds: 5));

    if(res.statusCode == 201)
    {
      return User.fromJson(jsonDecode(res.body)["data"]);
    }
    if(res.statusCode == 401)
    {
      throw jsonDecode(res.body)["data"];
    }
    else
    {
      return null;
    }
  }

  static bool isConfigured(SharedPreferences prefs) {

    final apiUri = Uri.tryParse(prefs.getString(SiccApi.apiUrlKey) ?? "");
    final isApiUriValid = apiUri != null && apiUri.scheme.startsWith('http');

    return isApiUriValid && Uuid.isValidUUID(fromString: prefs.getString(SiccApi.apiKey) ?? "");
  }

  static Future<bool> resetConfig() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isConfigured = SiccApi.isConfigured(prefs);

    if(!isConfigured)
    {
      return true;
    }

    prefs.remove(SiccApi.apiUrlKey);
    prefs.remove(SiccApi.apiKey);
    prefs.remove(SiccApi.enrollmentToken);
    prefs.remove(SiccApi.username);

    return true;
  }

  Future<Crate?> getCrate(String crateUuid) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isConfigured = SiccApi.isConfigured(prefs);

    if(!isConfigured)
    {
      return null;
    }

    Response res = await get(
        Uri.parse("${prefs.getString(SiccApi.apiUrlKey) ?? "http://127.0.0.1"}/get_crate.php?uuid=$crateUuid"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'X-API-TOKEN': prefs.getString(SiccApi.apiKey) ?? ""
        },
    ).timeout(const Duration(seconds: 5));

    if(res.statusCode == 200)
    {
      return Crate.fromJson(jsonDecode(res.body)["data"]);
    }
    else
    {
      return null;
    }
  }

  Future<String?> getPIN() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isConfigured = SiccApi.isConfigured(prefs);

    if(!isConfigured)
    {
      return null;
    }

    Response res = await get(
      Uri.parse("${prefs.getString(SiccApi.apiUrlKey) ?? "http://127.0.0.1"}/get_pin.php"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-API-TOKEN': prefs.getString(SiccApi.apiKey) ?? ""
      },
    ).timeout(const Duration(seconds: 5));

    if(res.statusCode == 200)
    {
      return jsonDecode(res.body)["data"];
    }
    else
    {
      return null;
    }
  }
}