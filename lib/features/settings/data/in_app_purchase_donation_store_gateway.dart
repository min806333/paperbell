import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import '../domain/donation_product.dart';
import 'donation_store_gateway.dart';

class InAppPurchaseDonationStoreGateway implements DonationStoreGateway {
  InAppPurchaseDonationStoreGateway({InAppPurchase? inAppPurchase})
    : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance {
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseDetails,
      onDone: () => _purchaseSubscription?.cancel(),
    );
  }

  final InAppPurchase _inAppPurchase;
  final StreamController<DonationPurchaseEvent> _purchaseEventsController =
      StreamController<DonationPurchaseEvent>.broadcast();
  final Map<String, ProductDetails> _productDetailsById = {};
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  @override
  Stream<DonationPurchaseEvent> get purchaseEvents =>
      _purchaseEventsController.stream;

  @override
  Future<DonationCatalogResult> loadCatalog() async {
    final isStoreAvailable = await _inAppPurchase.isAvailable();
    if (!isStoreAvailable) {
      return const DonationCatalogResult(
        isStoreAvailable: false,
        availableProducts: {},
        missingProducts: {
          DonationProduct.small,
          DonationProduct.medium,
          DonationProduct.large,
        },
      );
    }

    final response = await _inAppPurchase.queryProductDetails(
      DonationProduct.values.map((product) => product.productId).toSet(),
    );

    _productDetailsById
      ..clear()
      ..addEntries(
        response.productDetails.map(
          (details) => MapEntry(details.id, details),
        ),
      );

    final availableProducts = <DonationProduct>{};
    final missingProducts = <DonationProduct>{};

    for (final product in DonationProduct.values) {
      if (_productDetailsById.containsKey(product.productId)) {
        availableProducts.add(product);
      } else {
        missingProducts.add(product);
      }
    }

    return DonationCatalogResult(
      isStoreAvailable: response.error == null,
      availableProducts: availableProducts,
      missingProducts: missingProducts,
    );
  }

  @override
  Future<bool> startPurchase(DonationProduct product) async {
    final details = _productDetailsById[product.productId];
    if (details == null) {
      return false;
    }

    return _inAppPurchase.buyConsumable(
      purchaseParam: PurchaseParam(productDetails: details),
      autoConsume: true,
    );
  }

  void _handlePurchaseDetails(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      final product = DonationProduct.fromProductId(purchase.productID);
      if (product == null) {
        continue;
      }

      final status = switch (purchase.status) {
        PurchaseStatus.pending => DonationPurchaseStatus.pending,
        PurchaseStatus.purchased || PurchaseStatus.restored =>
          DonationPurchaseStatus.success,
        PurchaseStatus.canceled => DonationPurchaseStatus.cancelled,
        PurchaseStatus.error => DonationPurchaseStatus.failed,
      };

      _purchaseEventsController.add(
        DonationPurchaseEvent(
          product: product,
          status: status,
          errorMessage: purchase.error?.message,
        ),
      );

      if (purchase.pendingCompletePurchase) {
        unawaited(_inAppPurchase.completePurchase(purchase));
      }
    }
  }

  @override
  Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    await _purchaseEventsController.close();
  }
}
