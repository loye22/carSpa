// status_enum.dart
enum orderStatus {
  pending,
  canceled,
  inProgress,
  completed,
  init
}



// payment_status_enum.dart
enum PaymentStatus {
  paid,
  unpaid,
  partiallyPaid,
  init
}

// payment_method_enum.dart
enum PaymentMethod {
  cash,
  pos,
  bankTransfer,
  init
}




/// this function gonna parse the string back to orderstatus Enum
orderStatus parseToOrderStatus(String status) {
  switch (status) {
    case 'orderStatus.pending':
      return orderStatus.pending;
    case 'orderStatus.canceled':
      return orderStatus.canceled;
    case 'orderStatus.inProgress':
      return orderStatus.inProgress;
    case 'orderStatus.completed':
      return orderStatus.completed;
    default:
      return orderStatus.init; // Default case, can be `null` or any other fallback value
  }
}

/// this function gonna parse the string back to PaymentStatus Enum
PaymentStatus parseToPaymentStatus(String status) {
  switch (status) {
    case 'PaymentStatus.paid':
      return PaymentStatus.paid;
    case 'PaymentStatus.unpaid':
      return PaymentStatus.unpaid;
    case 'PaymentStatus.partiallyPaid':
      return PaymentStatus.partiallyPaid;
    default:
      return PaymentStatus.init; // Default case, can be `null` or any other fallback value
  }
}

/// this function gonna parse the string back to paymentMedtho Enum
PaymentMethod parseToPaymentMethod(String method) {
  switch (method) {
    case 'PaymentMethod.cash':
      return PaymentMethod.cash;
    case 'PaymentMethod.pos':
      return PaymentMethod.pos;
    case 'PaymentMethod.bankTransfer':
      return PaymentMethod.bankTransfer;
    default:
      return PaymentMethod.init; // Default case, can be `null` or any other fallback value
  }
}





