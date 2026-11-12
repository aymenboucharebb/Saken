class Contribution {
  const Contribution({
    required this.id,
    required this.title,
    required this.amountPerApartment,
    required this.amountPerApartmentFormatted,
    required this.status,
    required this.statusLabel,
    this.remainingAmount,
    this.remainingAmountFormatted,
    this.isFullyPaid,
  });

  final int id;
  final String title;
  final double amountPerApartment;
  final String amountPerApartmentFormatted;
  final String status;
  final String statusLabel;
  final double? remainingAmount;
  final String? remainingAmountFormatted;
  final bool? isFullyPaid;

  bool get isActive => status == 'active';
  bool get hasRemaining => (remainingAmount ?? 0) > 0;

  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      id: json['id'] as int,
      title: json['title'] as String,
      amountPerApartment: (json['amount_per_apartment'] as num).toDouble(),
      amountPerApartmentFormatted:
          json['amount_per_apartment_formatted'] as String? ??
              '${json['amount_per_apartment']} DZD',
      status: json['status'] as String? ?? 'active',
      statusLabel: json['status_label'] as String? ?? 'Ouverte',
      remainingAmount: json['remaining_amount'] == null
          ? null
          : (json['remaining_amount'] as num).toDouble(),
      remainingAmountFormatted: json['remaining_amount_formatted'] as String?,
      isFullyPaid: json['is_fully_paid'] as bool?,
    );
  }
}
