import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_admin_assistant/features/settings/application/donation_purchase_controller.dart';
import 'package:life_admin_assistant/features/settings/data/donation_store_gateway.dart';
import 'package:life_admin_assistant/features/settings/domain/donation_product.dart';

void main() {
  test('shows unavailable feedback when the store is not available', () async {
    final gateway = _FakeDonationStoreGateway(
      catalogResult: const DonationCatalogResult(
        isStoreAvailable: false,
        availableProducts: {},
        missingProducts: {
          DonationProduct.small,
          DonationProduct.medium,
          DonationProduct.large,
        },
      ),
    );
    final container = ProviderContainer(
      overrides: [
        donationStoreGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);

    await container.read(donationPurchaseControllerProvider.notifier).refreshCatalog();
    await container
        .read(donationPurchaseControllerProvider.notifier)
        .startPurchase(DonationProduct.small);

    final state = container.read(donationPurchaseControllerProvider);
    expect(state.isStoreAvailable, isFalse);
    expect(state.feedback?.message, contains('스토어'));
  });

  test('shows missing product feedback when the product is not configured', () async {
    final gateway = _FakeDonationStoreGateway(
      catalogResult: const DonationCatalogResult(
        isStoreAvailable: true,
        availableProducts: {DonationProduct.small},
        missingProducts: {
          DonationProduct.medium,
          DonationProduct.large,
        },
      ),
    );
    final container = ProviderContainer(
      overrides: [
        donationStoreGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);

    await container.read(donationPurchaseControllerProvider.notifier).refreshCatalog();
    await container
        .read(donationPurchaseControllerProvider.notifier)
        .startPurchase(DonationProduct.large);

    final state = container.read(donationPurchaseControllerProvider);
    expect(state.feedback?.message, contains('상품'));
  });

  test('clears purchase state and emits success feedback after purchase event', () async {
    final gateway = _FakeDonationStoreGateway(
      catalogResult: const DonationCatalogResult(
        isStoreAvailable: true,
        availableProducts: {
          DonationProduct.small,
          DonationProduct.medium,
          DonationProduct.large,
        },
        missingProducts: {},
      ),
    );
    final container = ProviderContainer(
      overrides: [
        donationStoreGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);

    await container.read(donationPurchaseControllerProvider.notifier).refreshCatalog();
    await container
        .read(donationPurchaseControllerProvider.notifier)
        .startPurchase(DonationProduct.medium);

    gateway.emit(
      const DonationPurchaseEvent(
        product: DonationProduct.medium,
        status: DonationPurchaseStatus.success,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    final state = container.read(donationPurchaseControllerProvider);
    expect(state.purchasingProduct, isNull);
    expect(state.feedback?.message, contains('고맙'));
  });
}

class _FakeDonationStoreGateway implements DonationStoreGateway {
  _FakeDonationStoreGateway({required this.catalogResult});

  final DonationCatalogResult catalogResult;

  final StreamController<DonationPurchaseEvent> _controller =
      StreamController<DonationPurchaseEvent>.broadcast();

  void emit(DonationPurchaseEvent event) {
    _controller.add(event);
  }

  @override
  Stream<DonationPurchaseEvent> get purchaseEvents => _controller.stream;

  @override
  Future<DonationCatalogResult> loadCatalog() async => catalogResult;

  @override
  Future<bool> startPurchase(DonationProduct product) async => true;

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}
