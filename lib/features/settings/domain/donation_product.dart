import '../../../app/localization/app_strings.dart';

enum DonationProduct {
  small('donation_coffee_small'),
  medium('donation_coffee_medium'),
  large('donation_coffee_large');

  const DonationProduct(this.productId);

  final String productId;

  String label(AppStrings strings) {
    return switch (this) {
      DonationProduct.small => strings.donationOptionOne,
      DonationProduct.medium => strings.donationOptionTwo,
      DonationProduct.large => strings.donationOptionSupport,
    };
  }

  static DonationProduct? fromProductId(String productId) {
    for (final product in DonationProduct.values) {
      if (product.productId == productId) {
        return product;
      }
    }
    return null;
  }
}
