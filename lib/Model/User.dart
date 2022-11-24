class User {

  final String uuid;
  final String name;
  final String apiKey;
  final String enrollmentToken;

  User({
    required this.uuid,
    required this.name,
    required this.apiKey,
    required this.enrollmentToken
  });

  factory User.fromJson(Map<String, dynamic> json) {

    return User(
      uuid: json["uuid"],
      name: json["name"],
      apiKey: json["apiKey"],
      enrollmentToken: json["enrollmentToken"]
    );
  }

  Map<String, dynamic> toJson() => {
    "uuid": uuid,
    "name": name,
    "apiKey": apiKey,
    "enrollmentToken": enrollmentToken
  };
}