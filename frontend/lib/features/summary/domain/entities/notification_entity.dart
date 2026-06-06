import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    this.documentId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.createdAt,
  });

  final int id;
  final int? documentId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        documentId,
        title,
        message,
        type,
        isRead,
        createdAt,
      ];
}
