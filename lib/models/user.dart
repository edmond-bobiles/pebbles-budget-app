class User {
  final String id;
  final String username;
  final String password;

  User({required this.id, required this.username, required this.password});

  Map<String, dynamic> toMap() =>
      {'id': id, 'username': username, 'password': password};

  factory User.fromMap(Map<String, dynamic> m) => User(
    id: m['id'],
    username: m['username'],
    password: m['password'],
  );
}
