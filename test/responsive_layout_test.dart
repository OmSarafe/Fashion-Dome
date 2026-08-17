import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResponsiveLayout', () {
    test('uses compact padding on narrow phones', () {
      expect(ResponsiveLayout.horizontalPadding(320), 16);
      expect(ResponsiveLayout.horizontalPadding(390), 24);
      expect(ResponsiveLayout.horizontalPadding(700), 32);
      expect(ResponsiveLayout.horizontalPadding(1200), 40);
    });

    test('scales the product grid across supported widths', () {
      expect(ResponsiveLayout.productGridColumns(320), 1);
      expect(ResponsiveLayout.productGridColumns(360), 2);
      expect(ResponsiveLayout.productGridColumns(700), 3);
      expect(ResponsiveLayout.productGridColumns(900), 4);
      expect(ResponsiveLayout.productGridColumns(1280), 5);
    });

    test('caps content width on large displays', () {
      expect(ResponsiveLayout.usableWidth(390), 390);
      expect(ResponsiveLayout.usableWidth(1600), 1280);
      expect(ResponsiveLayout.usableWidth(900, maxWidth: 760), 760);
    });
  });
}
