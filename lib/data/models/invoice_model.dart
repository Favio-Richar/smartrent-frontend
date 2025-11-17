class InvoiceModel {
  final int id;
  final int userId;
  final int paymentId;
  final String pdfUrl;
  final int amount;
  final String plan;
  final String? authorizationCode;
  final String? last4;
  final DateTime createdAt;

  InvoiceModel({
    required this.id,
    required this.userId,
    required this.paymentId,
    required this.pdfUrl,
    required this.amount,
    required this.plan,
    required this.authorizationCode,
    required this.last4,
    required this.createdAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'],
      userId: json['userId'],
      paymentId: json['paymentId'],
      pdfUrl: json['pdfUrl'],
      amount: json['amount'],
      plan: json['plan'],
      authorizationCode: json['authorizationCode'],
      last4: json['last4'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
