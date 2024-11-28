class Province {
  final int id;
  final String name;

  Province({required this.id, required this.name});

  factory Province.fromJson(Map<String, dynamic> parsedJson) {

      return Province(
        id: parsedJson['id'],
        name: parsedJson['name'],
      );
  }
  Map<String, dynamic> toJson() {


    return {
      'id' : id,
      'name' : name,
    };
  }
}
