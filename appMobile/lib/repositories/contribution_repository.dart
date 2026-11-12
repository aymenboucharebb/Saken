import 'package:dio/dio.dart';

import '../core/dio_client.dart';
import '../models/contribution.dart';

class ContributionRepository {
  ContributionRepository({required DioClient dioClient}) : _dio = dioClient.dio;

  final Dio _dio;

  Future<List<Contribution>> fetchAll() async {
    final response = await _dio.get<Map<String, dynamic>>('/contributions');
    final raw = response.data?['data'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => Contribution.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Contribution> fetchOne(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/contributions/$id');
    final root = response.data;
    if (root == null) {
      throw StateError('Cotisation introuvable.');
    }

    // Admin: { data: { data: {...} }, balances: [...] } or { data: {...}, balances }
    // Resident: { data: {...} }
    dynamic payload = root['data'] ?? root;
    if (payload is Map && payload['data'] is Map && payload.containsKey('balances')) {
      payload = payload['data'];
    }
    if (payload is! Map) {
      throw StateError('Cotisation introuvable.');
    }
    return Contribution.fromJson(Map<String, dynamic>.from(payload));
  }
}
