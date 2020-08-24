class Department {
  String areaOfAdministration;
  String category;
  String email;
  String name;
  String userType;

  Department(
      {this.areaOfAdministration,
        this.category,
        this.email,
        this.name,
        this.userType});

  factory Department.fromJson(Map<String, dynamic> json) => Department(
    areaOfAdministration: json["areaOfAdministration"],
    category: json["category"],
    email: json["email"],
    name: json["name"],
    userType: json["userType"],
  );

  Map<String, dynamic> toJson() => {
    "areaOfAdministration": areaOfAdministration,
    "category": category,
    "email": email,
    "name": name,
    "userType": userType,
  };
}
