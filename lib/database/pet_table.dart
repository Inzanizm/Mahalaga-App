class PetTable {
  int? id;
  String name;
  String species;
  String breed;
  int age;
  String status;
  int weight;
  String blood;
  String allergy;
  String mark;
  String? image;

  PetTable({
    this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.status,
    required this.weight,
    required this.blood,
    required this.allergy,
    required this.mark,
    this.image,
  });

  factory PetTable.fromMap(Map<String, dynamic> map) {
    return PetTable(
      id: map['id'] as int,
      name: map['name'] as String,
      species: map['species'] as String,
      breed: map['breed'] as String,
      age: map['age'] as int,
      status: map['status'] as String,
      weight: map['weight'] as int,
      blood: map['blood'] as String,
      allergy: map['allergy'] as String,
      mark: map['mark'] as String,
      image: map['image'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'status': status,
      'weight': weight,
      'blood': blood,
      'allergy': allergy,
      'mark': mark,
      'image': image,
    };
  }
}
