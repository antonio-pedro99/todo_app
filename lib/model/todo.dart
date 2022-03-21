class Todo {
  int id;
  String name;
  bool status;
  String time;
  //Category category;

  Todo({this.id, this.name, this.status, this.time});

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map["id"],
      name: map["name"],
      status: map["status"],
      time:
          "${DateTime.now().day.toString().padLeft(2, '0')} - ${DateTime.now().month.toString().padLeft(2, '0')} - ${DateTime.now().year.toString()}",
    );
  }

  Map toMap() {
    return {
      "id": id,
      "name": name,
      "status": status
    };
  }
}
