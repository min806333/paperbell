import '../domain/donation_product.dart';

enum DonationPurchaseStatus { pending, success, cancelled, failed }

class DonationCatalogResult {
  const DonationCatalogResult({
    required this.isStoreAvailable,
    required this.availableProducts,
    required this.missingProducts,
  });

  final bool isStoreAvailable;
  final Set<DonationProduct> availableProducts;
  final Set<DonationProduct> missingProducts;
}

class DonationPurchaseEvent {
  const DonationPurchaseEvent({
    required this.product,
    required this.status,
    this.errorMessage,
  });

  final DonationProduct product;
  final DonationPurchaseStatus status;
  final String? errorMessage;
}

abstract class DonationStoreGateway {
  Stream<DonationPurchaseEvent> get purchaseEvents;

  Future<DonationCatalogResult> loadCatalog();

  Future<bool> startPurchase(DonationProduct product);

  Future<void> dispose();
}
