import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sicc/Model/Crate.dart';
import 'package:uuid/uuid.dart';

class SiccApi {

  static String apiUrlKey = "API_URL";
  static String apiKey = "PRIV_KEY";
  static String enrollmentToken = "PUB_KEY";

  Future<List<Crate>> getCrates() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Response res = await get(Uri.parse("${prefs.getString(SiccApi.apiUrlKey)}/list.php"));

    if(res.statusCode == 200){
      List<dynamic> body = jsonDecode(res.body);

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
    );

    if(res.statusCode == 200)
      {
        List<dynamic> body = jsonDecode(res.body);
        return Crate.fromJson(body[0]);
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

  Future<bool> configure(String apiUrl, String username, String apiToken) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString(SiccApi.apiUrlKey, apiUrl);
    prefs.setString(SiccApi.apiKey, apiToken);
    String enrollmentKey = const Uuid().v4();

    bool userCreation = await createUser(username, enrollmentKey);
    if(!userCreation)
      {
        SiccApi.resetConfig();
        throw "Cannot create your account. Are you connected to Internet ?";
      }

    prefs.setString(SiccApi.enrollmentToken, enrollmentKey);

    return true;
  }

  Future<bool> createUser(String username, String enrollmentToken) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if(!prefs.containsKey(SiccApi.apiUrlKey) || prefs.getString(SiccApi.apiUrlKey)  == "" ||
        !prefs.containsKey(SiccApi.apiKey) || prefs.getString(SiccApi.apiKey) == "")
      {
        throw "API is not configured yet";
      }

    Map<String, dynamic> jsonBody = {"username": username, "enrollmentToken": enrollmentToken};
    
    Response res = await post(
      Uri.parse("${prefs.getString(SiccApi.apiUrlKey) ?? "http://127.0.0.1"}/create_user.php"),
      headers: <String, String>{
        'X-API-TOKEN': prefs.getString(SiccApi.apiKey) ?? ""
      },
      body: jsonEncode(jsonBody)
    );

    if(res.statusCode == 201)
      {
        return true;
      }
    else
      {
        return false;
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

    return true;
  }

}