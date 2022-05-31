class TransferHistoryModel {
  String id;
  String accountId="www";
  String firstName="logan";
  String lastName="smith";
  String mobile="1231231231";
  String avatar="https://source.unsplash.com/300x300/?portrait";

  TransferHistoryModel(
      {this.id,
      this.firstName,
      this.lastName,
      this.mobile,
      this.avatar,
      this.accountId});

  factory TransferHistoryModel.fromJson(Map<String, dynamic> json) {
    return new TransferHistoryModel(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        mobile: json['mobile'] as String,
        avatar: json['avatar'] as String,
        accountId: json['account_id'] as String);
  }
}
