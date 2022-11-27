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
  String? parentUuid;
  List<Item> items;
  List<Crate> crates;

  Crate({
    required this.uuid,
    required this.name,
    required this.items,
    required this.crates,
    this.parentUuid
  });

  int countItems()
  {
    int count = items.fold(0, (int value, Item element) => value+element.quantity);
    for(int i = 0; i < crates.length; i++)
      {
        count += crates[i].countItems();
      }

    return count;
  }

  int countChildCrates()
  {
    int count = crates.length;
    for(int i = 0; i < crates.length; i++)
      {
        count += crates[i].countChildCrates();
      }
    return count;
  }

  factory Crate.fromJson(Map<String, dynamic> json) {

    // Sort items by alphabetical order
    List<Item> items = json["items"].map((dynamic item) => Item.fromJson(item)).toList().cast<Item>();
    items.sort((a,b){
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    // Sort children crates by alphabetical order
    List<Crate> crates = json["crates"].map((dynamic c) => Crate.fromJson(c)).toList().cast<Crate>();
    crates.sort((a,b){
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return Crate(
      uuid: json["uuid"],
      name: json["name"],
      items: items,
      crates: crates,
      parentUuid: json["parent_uuid"]
    );
  }

  Map<String, dynamic> toJson() => {
    "uuid": uuid,
    "name": name,
    "parent_uuid": parentUuid,
    "items": items.map((Item item) => item.toJson()).toList(),
    "crates": crates.map((Crate c) => c.toJson()).toList()
  };
}