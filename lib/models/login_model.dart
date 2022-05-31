class LoginModel {
  String phone;
  String password;

  LoginModel({this.phone, this.password});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      phone: json["phone"] as String,
      password: json["password"] as String
    );
  }
}