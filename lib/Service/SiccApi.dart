import 'dart:convert';
import 'package:http/http.dart';
import 'package:sicc/Model/Crate.dart';

class SiccApi {

  // @TODO: Move those to configurables
  static String apiBaseUrl = "";
  // @TODO Register this API token in database when a QR code is generated (/a new crate is created)
  static String creatorApiToken = "";

  Future<List<Crate>> getCrates() async {

    Response res = await get(Uri.parse("${SiccApi.apiBaseUrl}/list.php"));

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
    
    Response res = await post(
        Uri.parse("${SiccApi.apiBaseUrl}/save.php"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'X-API-TOKEN': SiccApi.creatorApiToken
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

    Response res = await delete(
      Uri.parse("${SiccApi.apiBaseUrl}/delete.php?id=$crateUuid"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-API-TOKEN': SiccApi.creatorApiToken
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
}