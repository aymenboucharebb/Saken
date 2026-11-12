import 'package:dio/dio.dart';

import '../core/dio_client.dart';
import '../models/payment.dart';

class PaymentRepository {
  PaymentRepository({required DioClient dioClient}) : _dio = dioClient.dio;

  final Dio _dio;

  Future<List<Payment>> fetchAll() async {
    final response = await _dio.get<Map<String, dynamic>>('/payments');
    final raw = response.data?['data'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => Payment.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Payment> fetchOne(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/payments/$id');
    final payload = response.data?['data'] ?? response.data;
    if (payload is! Map) {
      throw StateError('Paiement introuvable.');
    }
    return Payment.fromJson(Map<String, dynamic>.from(payload));
  }

  Future<Payment> create({
    required int contributionId,
    required double amountPaid,
    required String date,
    String? receiptPath,
  }) async {
    final formData = FormData.fromMap({
      'contribution_id': contributionId,
      'amount_paid': amountPaid,
      'date': date,
      if (receiptPath != null && receiptPath.isNotEmpty)
        'receipt': await MultipartFile.fromFile(
          receiptPath,
          filename: receiptPath.split(RegExp(r'[\\/]')).last,
        ),
    });

    final response = await _dio.post<Map<String, dynamic>>(
      '/payments',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final payload = response.data?['data'] ?? response.data;
    if (payload is! Map) {
      throw StateError('Réponse paiement invalide.');
    }
    return Payment.fromJson(Map<String, dynamic>.from(payload));
  }
}
