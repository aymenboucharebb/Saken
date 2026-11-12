import '../core/config.dart';
import 'contribution.dart';

class Payment {
  const Payment({
    required this.id,
    required this.apartmentId,
    required this.contributionId,
    required this.amountPaid,
    required this.amountPaidFormatted,
    required this.date,
    this.receiptUrl,
    this.contribution,
  });

  final int id;
  final int apartmentId;
  final int contributionId;
  final double amountPaid;
  final String amountPaidFormatted;
  final String date;
  final String? receiptUrl;
  final Contribution? contribution;

  String? get absoluteReceiptUrl {
    final url = receiptUrl;
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final origin = AppConfig.apiBaseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    if (url.startsWith('/')) return '$origin$url';
    return '$origin/$url';
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    Contribution? contribution;
    final rawContribution = json['contribution'];
    if (rawContribution is Map<String, dynamic>) {
      contribution = Contribution.fromJson(rawContribution);
    } else if (rawContribution is Map) {
      contribution = Contribution.fromJson(Map<String, dynamic>.from(rawContribution));
    }

    return Payment(
      id: json['id'] as int,
      apartmentId: json['apartment_id'] as int,
      contributionId: json['contribution_id'] as int,
      amountPaid: (json['amount_paid'] as num).toDouble(),
      amountPaidFormatted:
          json['amount_paid_formatted'] as String? ?? '${json['amount_paid']} DZD',
      date: json['date'] as String? ?? '',
      receiptUrl: json['receipt_url'] as String?,
      contribution: contribution,
    );
  }
}
