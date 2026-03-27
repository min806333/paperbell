import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_strings.dart';
import '../data/donation_store_gateway.dart';
import '../data/in_app_purchase_donation_store_gateway.dart';
import '../domain/donation_product.dart';

class DonationFeedback {
  const DonationFeedback({
    required this.id,
    required this.message,
  });

  final int id;
  final String message;
}

class DonationPurchaseState {
  const DonationPurchaseState({
    required this.isLoading,
    required this.isStoreAvailable,
    required this.availableProducts,
    required this.missingProducts,
    required this.purchasingProduct,
    required this.feedback,
  });

  const DonationPurchaseState.initial()
    : isLoading = true,
      isStoreAvailable = false,
      availableProducts = const {},
      missingProducts = const {},
      purchasingProduct = null,
      feedback = null;

  final bool isLoading;
  final bool isStoreAvailable;
  final Set<DonationProduct> availableProducts;
  final Set<DonationProduct> missingProducts;
  final DonationProduct? purchasingProduct;
  final DonationFeedback? feedback;

  DonationPurchaseState copyWith({
    bool? isLoading,
    bool? isStoreAvailable,
    Set<DonationProduct>? availableProducts,
    Set<DonationProduct>? missingProducts,
    DonationProduct? purchasingProduct,
    bool clearPurchasingProduct = false,
    DonationFeedback? feedback,
  }) {
    return DonationPurchaseState(
      isLoading: isLoading ?? this.isLoading,
      isStoreAvailable: isStoreAvailable ?? this.isStoreAvailable,
      availableProducts: availableProducts ?? this.availableProducts,
      missingProducts: missingProducts ?? this.missingProducts,
      purchasingProduct: clearPurchasingProduct
          ? null
          : purchasingProduct ?? this.purchasingProduct,
      feedback: feedback ?? this.feedback,
    );
  }
}

final donationStoreGatewayProvider = Provider<DonationStoreGateway>(
  (ref) {
    final gateway = InAppPurchaseDonationStoreGateway();
    ref.onDispose(gateway.dispose);
    return gateway;
  },
);

final donationPurchaseControllerProvider =
    NotifierProvider<DonationPurchaseController, DonationPurchaseState>(
      DonationPurchaseController.new,
    );

class DonationPurchaseController extends Notifier<DonationPurchaseState> {
  late final DonationStoreGateway _gateway;
  StreamSubscription<DonationPurchaseEvent>? _purchaseSubscription;
  int _feedbackSeed = 0;

  @override
  DonationPurchaseState build() {
    _gateway = ref.read(donationStoreGatewayProvider);
    _purchaseSubscription = _gateway.purchaseEvents.listen(_handlePurchaseEvent);
    ref.onDispose(() => _purchaseSubscription?.cancel());
    Future<void>.microtask(refreshCatalog);
    return const DonationPurchaseState.initial();
  }

  Future<void> refreshCatalog() async {
    state = state.copyWith(isLoading: true);
    final catalog = await _gateway.loadCatalog();
    state = state.copyWith(
      isLoading: false,
      isStoreAvailable: catalog.isStoreAvailable,
      availableProducts: catalog.availableProducts,
      missingProducts: catalog.missingProducts,
    );
  }

  Future<void> startPurchase(DonationProduct product) async {
    final strings = AppStrings.current;

    if (state.isLoading) {
      _emitFeedback(strings.donationStoreLoadingMessage);
      return;
    }

    if (!state.isStoreAvailable) {
      _emitFeedback(strings.donationStoreUnavailableMessage);
      return;
    }

    if (!state.availableProducts.contains(product)) {
      _emitFeedback(
        strings.donationProductUnavailableMessage(product.label(strings)),
      );
      return;
    }

    state = state.copyWith(purchasingProduct: product);

    final started = await _gateway.startPurchase(product);
    if (!started) {
      state = state.copyWith(clearPurchasingProduct: true);
      _emitFeedback(strings.donationStartFailedMessage(product.label(strings)));
    }
  }

  void _handlePurchaseEvent(DonationPurchaseEvent event) {
    final strings = AppStrings.current;
    final label = event.product.label(strings);

    switch (event.status) {
      case DonationPurchaseStatus.pending:
        state = state.copyWith(purchasingProduct: event.product);
        _emitFeedback(strings.donationPendingMessage(label));
      case DonationPurchaseStatus.success:
        state = state.copyWith(clearPurchasingProduct: true);
        _emitFeedback(strings.donationSuccessMessage(label));
      case DonationPurchaseStatus.cancelled:
        state = state.copyWith(clearPurchasingProduct: true);
        _emitFeedback(strings.donationCancelledMessage);
      case DonationPurchaseStatus.failed:
        state = state.copyWith(clearPurchasingProduct: true);
        _emitFeedback(strings.donationFailedMessage(event.errorMessage));
    }
  }

  void _emitFeedback(String message) {
    _feedbackSeed += 1;
    state = state.copyWith(
      feedback: DonationFeedback(id: _feedbackSeed, message: message),
    );
  }
}
