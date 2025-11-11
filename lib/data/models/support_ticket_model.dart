class SupportTicket {
  final String? id;
  final String subject;
  final String description;
  final String? category;
  final String? imageBase64; // opcional
  final String? status;
  final DateTime? createdAt;

  SupportTicket({
    this.id,
    required this.subject,
    required this.description,
    this.category,
    this.imageBase64,
    this.status,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'subject': subject,
        'description': description,
        if (category != null) 'category': category,
        if (imageBase64 != null) 'image_base64': imageBase64,
      };

  factory SupportTicket.fromJson(Map<String, dynamic> json) => SupportTicket(
        id: json['id']?.toString(),
        subject: json['subject'] ?? '',
        description: json['description'] ?? '',
        category: json['category'],
        status: json['status'],
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
      );
}
