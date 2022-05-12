class User {
  String? id;
  String? email;
  String? firstName;
  String? lastName;
  String? password;
  String? createdAt;
  List<Tasks>? tasks;

  User(
      {this.id,
      this.email,
      this.firstName,
      this.lastName,
      this.password,
      this.createdAt,
      this.tasks});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    password = json['password'];
    createdAt = json['createdAt'];
    if (json['tasks'] != null) {
      tasks = <Tasks>[];
      json['tasks'].forEach((v) {
        tasks!.add(new Tasks.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['password'] = this.password;
    data['createdAt'] = this.createdAt;
    if (this.tasks != null) {
      data['tasks'] = this.tasks!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Tasks {
  int? id;
  String? name;
  String? description;
  String? createdAt;
  String? userId;
  String? completeAt;

  Tasks(
      {this.id,
      this.name,
      this.description,
      this.createdAt,
      this.userId,
      this.completeAt});

  Tasks.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    createdAt = json['createdAt'];
    userId = json['userId'];
    completeAt = json['completeAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['createdAt'] = this.createdAt;
    data['userId'] = this.userId;
    data['completeAt'] = this.completeAt;
    return data;
  }
}
