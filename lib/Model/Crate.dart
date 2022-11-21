class Item {
  final String uuid;
  String name;
  int quantity;

  Item({
    required this.uuid,
    required this.name,
    required this.quantity
  });


  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      uuid: json["uuid"],
      name: json["name"],
      quantity: json["quantity"]
    );
  }

  Map<String, dynamic> toJson() => {
    "uuid": uuid,
    "name": name,
    "quantity": quantity
  };
}

class Crate {

  final String uuid;
  String name;
  List<Item> items;

  Crate({
    required this.uuid,
    required this.name,
    required this.items
  });

  factory Crate.fromJson(Map<String, dynamic> json) {

    // Sort items by alphabetical order
    List<Item> items = json["items"].map((dynamic item) => Item.fromJson(item)).toList().cast<Item>();
    items.sort((a,b){
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return Crate(
      uuid: json["uuid"],
      name: json["name"],
      items: items
    );
  }

  Map<String, dynamic> toJson() => {
    "uuid": uuid,
    "name": name,
    "items": items.map((Item item) => item.toJson()).toList()
  };
}