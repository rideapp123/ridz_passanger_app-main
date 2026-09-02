import '../enums/value_type.dart';

abstract class PaymentHelper {
  static String calculateDiscount({
    /// Can be a percentage or an absolute value
    required double discountValue,
    required ValueType? discountType,
    required String billAmount,
    required double? minimumAmount,
  }) {
    final double bill = billAmount.isEmpty ? 0 : double.parse(billAmount);

    if (minimumAmount != null && bill < minimumAmount) {
      return '0';
    }

    if (discountType == ValueType.absolute) {
      return (discountValue > bill ? bill : discountValue).toString();
    } else if (discountType == ValueType.percentage) {
      final double discount = (discountValue / 100) * bill;
      return (discount > bill ? bill : discount).toStringAsFixed(2);
    } else {
      return '0';
    }
  }

  static double calculateFinalAmount({
    required String billAmount,

    /// Can be a percentage or an absolute value
    required double discountValue,
    required ValueType? discountType,
    required double? minimumAmount,
  }) {
    final double bill = billAmount.isEmpty ? 0 : double.parse(billAmount);

    if (minimumAmount != null && bill < minimumAmount) {
      return double.parse(bill.toStringAsFixed(2));
    }

    final double discount = discountType == ValueType.percentage
        ? (discountValue / 100) * bill
        : discountValue;

    final double finalDiscount = discount > bill ? bill : discount;
    return double.parse((bill - finalDiscount).toStringAsFixed(2));
  }
}
