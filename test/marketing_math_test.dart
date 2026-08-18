import 'package:flutter_test/flutter_test.dart';
import 'package:contentawy/core/utils/marketing_math.dart';

void main() {
  group('MarketingMath Unit Tests', () {
    test('calculateROAS returns correct value', () {
      expect(MarketingMath.calculateROAS(10000, 2500), equals(4.0));
      expect(MarketingMath.calculateROAS(0, 2500), equals(0.0));
      expect(MarketingMath.calculateROAS(5000, 0), equals(0.0));
    });

    test('calculateNetProfit and calculateROI calculate accurately', () {
      final profit = MarketingMath.calculateNetProfit(
        revenue: 12000,
        adSpend: 3000,
        cogs: 4000,
      );
      expect(profit, equals(5000.0));

      final roi = MarketingMath.calculateROI(
        revenue: 12000,
        adSpend: 3000,
        cogs: 4000,
      );
      // Total cost = 7000, profit = 5000 -> (5000/7000)*100 = 71.428...%
      expect(roi, closeTo(71.428, 0.01));
    });

    test('calculateCAC and calculateLTV calculate accurately', () {
      final cac = MarketingMath.calculateCAC(5000, 50);
      expect(cac, equals(100.0));

      final ltv = MarketingMath.calculateLTV(
        avgOrderValue: 400,
        purchaseFrequencyPerYear: 3,
        lifespanYears: 2,
      );
      expect(ltv, equals(2400.0));
    });

    test('calculateBreakEvenROAS handles percentage and decimal properly', () {
      expect(MarketingMath.calculateBreakEvenROAS(40), equals(2.5));
      expect(MarketingMath.calculateBreakEvenROAS(0.5), equals(2.0));
      expect(MarketingMath.calculateBreakEvenROAS(0), equals(0.0));
    });

    test('calculateEngagementRate calculates correctly', () {
      final engRate = MarketingMath.calculateEngagementRate(
        likes: 500,
        comments: 100,
        shares: 50,
        saves: 150,
        reachOrFollowers: 10000,
      );
      // Total interactions = 800 / 10000 * 100 = 8.0%
      expect(engRate, equals(8.0));
    });

    test('buildUTMUrl builds valid parameter query string', () {
      final url = MarketingMath.buildUTMUrl(
        baseUrl: 'myshop.com/summer',
        source: 'facebook',
        medium: 'cpc',
        campaign: 'offers_2026',
        content: 'video1',
      );

      expect(url, contains('https://myshop.com/summer?'));
      expect(url, contains('utm_source=facebook'));
      expect(url, contains('utm_medium=cpc'));
      expect(url, contains('utm_campaign=offers_2026'));
      expect(url, contains('utm_content=video1'));
    });
  });
}
