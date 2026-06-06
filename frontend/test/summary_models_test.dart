import 'package:flutter_test/flutter_test.dart';
import 'package:leksika/features/summary/data/models/document_model.dart';
import 'package:leksika/features/summary/data/models/notification_model.dart';

void main() {
  group('DocumentModel', () {
    test('parses backend flashcards from document response', () {
      final document = DocumentModel.fromJson({
        'id': 7,
        'file_name': 'materi-vpn.pdf',
        'summary': {'summary_text': 'Ringkasan VPN'},
        'created_at': '2026-06-06T01:00:00.000000Z',
        'flashcards': [
          {
            'id': 10,
            'document_id': 7,
            'question': 'Apa fungsi VPN?',
            'answer': 'Mengamankan koneksi jaringan.',
            'created_at': '2026-06-06T01:01:00.000000Z',
          },
        ],
      });

      expect(document.flashcards, hasLength(1));
      expect(document.flashcards.first.id, 10);
      expect(document.flashcards.first.documentId, 7);
      expect(document.flashcards.first.question, 'Apa fungsi VPN?');
      expect(document.flashcards.first.answer, 'Mengamankan koneksi jaringan.');
    });
  });

  group('NotificationModel', () {
    test('parses backend notification response', () {
      final notification = NotificationModel.fromJson({
        'id': 3,
        'document_id': 7,
        'title': 'Rangkuman Siap!',
        'message': 'Rangkuman untuk dokumen materi-vpn.pdf sudah siap.',
        'type': 'summary_success',
        'is_read': false,
        'created_at': '2026-06-06T01:02:00.000000Z',
      });

      expect(notification.id, 3);
      expect(notification.documentId, 7);
      expect(notification.title, 'Rangkuman Siap!');
      expect(notification.message, contains('materi-vpn.pdf'));
      expect(notification.type, 'summary_success');
      expect(notification.isRead, isFalse);
    });
  });
}
