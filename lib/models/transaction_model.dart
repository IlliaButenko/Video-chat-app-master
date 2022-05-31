class Transaction {
  String id;
  String transactionId;
  String sourceId;
  String destinationId;
  String fromAccountId;
  String toAccountId;
  String name;
  String name2;
  String phone;
  String phone2;
  double amount;
  double amountAvailable;
  String type;
  String status;
  String created;
  String remark;
  String sourcePhone;

  Transaction(
      {this.id,
      this.transactionId,
      this.sourceId,
      this.destinationId,
      this.name,
      this.name2,
      this.phone,
      this.phone2,
      this.amount,
      this.type,
      this.status,
      this.created,
      this.remark,
        this.fromAccountId,
        this.toAccountId,
        this.amountAvailable,
      this.sourcePhone});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return new Transaction(
        id: json['id'] as String,
        transactionId: json['transactionId'] as String,
        sourceId: json['sourceId'] as String,
        destinationId: json['destinationId'] as String,
        name: json['name'] as String,
        name2: json['name2'] as String,
        phone: json['phone'] as String,
        phone2: json['phone2'] as String,
        amount: double.parse(json['amount']),
        amountAvailable: 0,
        type: json['type'] as String,
        toAccountId: json['account_id'] as String,
        status: json['status'] as String,
        remark: json['remark'] as String,
        created: json['created'] as String);
  }
}
