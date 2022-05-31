import 'package:hive/hive.dart';

part 'user_model.g.dart';

class UserModel {
  int id;
  String uid;
  String accountId;
  String name;
  String avatar;
  String username;
  String firstName;
  String lastName;
  String password;
  String email;
  String phone;
  String mobile;
  String address;
  String occupation;
  String description;
  double code;
  dynamic customerType;
  final String created;
  int state;
  int friendStatus;
  int actionUserId;
  String token;

  UserModel(
      {this.id,
        this.uid,
      this.accountId,
      this.name,
      this.avatar,
      this.username,
      this.firstName,
      this.lastName,
      this.password,
      this.email,
      this.phone,
      this.mobile,
      this.address,
      this.code,
      this.friendStatus,
      this.customerType,
      this.description,
      this.occupation,
      this.actionUserId,
      this.token,
        this.state,
      this.created});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json["id"] is String ? int.parse(json["id"]) : json["id"],
        uid: json['uid'],
        name: json["name"] as String,
        email: json["email"] as String,
        phone: json['phone'] as String,
        mobile: json['mobile'] as String,
        firstName: json["firstName"] as String,
        lastName: json['lastName'] as String,
        avatar: json['avatar'] as String,
        customerType: json['customerType'],
        friendStatus: json['friendStatus'] is String ? int.parse(json['friendStatus']) : json['friendStatus'],
        token: json['token'],
        created: json['created'],
        actionUserId: (json['user_action_id'] != null)
            ? int.parse(json['user_action_id'])
            : -1,
        state: json['state'],
        accountId: json['account_id'] as String);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'mobile': mobile,
        'firstName': firstName,
        'lastName': lastName,
        'customerType': customerType,
        'friendStatus': friendStatus,
        'avatar': avatar,
        'created': created,
        'token': token,
        'state': state
      };
}
