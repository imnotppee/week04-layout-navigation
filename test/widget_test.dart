import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travel_app/main.dart';
import 'package:travel_app/models/saved_destinations.dart';
import 'package:travel_app/router/app_router.dart';
import 'package:travel_app/screens/about_screen.dart';
import 'package:travel_app/screens/destination_detail_screen.dart';
import 'package:travel_app/screens/explore_screen.dart';
import 'package:travel_app/screens/home_screen.dart';
import 'package:travel_app/screens/saved_screen.dart';
import 'package:travel_app/widgets/destination_card.dart';

void main() {
  testWidgets('App boots with 5 tabs and can switch to About and Explore', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    appRouter.go('/');
    await tester.pumpWidget(const TravelApp());
    await tester.pumpAndSettle();

    // Verify 5 bottom navigation tabs
    expect(find.text('หน้าหลัก'), findsOneWidget);
    expect(find.text('สำรวจ'), findsOneWidget);
    expect(find.text('บันทึก'), findsOneWidget);
    expect(find.text('โปรไฟล์'), findsOneWidget);
    expect(find.text('เกี่ยวกับ'), findsOneWidget);

    expect(find.byType(HomeScreen), findsOneWidget);

    // Tap "เกี่ยวกับ" tab
    await tester.tap(find.text('เกี่ยวกับ'));
    await tester.pumpAndSettle();
    expect(find.byType(AboutScreen), findsOneWidget);

    // Tap "สำรวจ" tab
    await tester.tap(find.text('สำรวจ'));
    await tester.pumpAndSettle();
    expect(find.byType(ExploreScreen), findsOneWidget);
  });

  testWidgets('ExploreScreen category filter chips work properly (Step 7.1)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    appRouter.go('/explore');
    await tester.pumpWidget(const TravelApp());
    await tester.pumpAndSettle();

    // Verify category chips
    expect(find.widgetWithText(FilterChip, 'ทั้งหมด'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'ทะเล'), findsOneWidget);

    // Tap 'ทะเล' filter
    await tester.tap(find.widgetWithText(FilterChip, 'ทะเล'));
    await tester.pumpAndSettle();

    // Destinations tagged with 'ทะเล': ภูเก็ต, บาหลี
    expect(find.widgetWithText(DestinationCard, 'ภูเก็ต'), findsOneWidget);
    expect(find.widgetWithText(DestinationCard, 'บาหลี'), findsOneWidget);
    expect(find.widgetWithText(DestinationCard, 'เชียงใหม่'), findsNothing);
  });

  testWidgets('SavedScreen displays favorited items and updates reactively (Step 8)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Ensure initial saved items include '1' (Bangkok)
    if (!SavedDestinationsManager.instance.isSaved('1')) {
      SavedDestinationsManager.instance.toggleSave('1');
    }

    appRouter.go('/saved');
    await tester.pumpWidget(const TravelApp());
    await tester.pumpAndSettle();

    expect(find.byType(SavedScreen), findsOneWidget);
    expect(find.widgetWithText(DestinationCard, 'กรุงเทพฯ'), findsOneWidget);

    // Tap card to navigate to detail
    await tester.tap(find.widgetWithText(DestinationCard, 'กรุงเทพฯ'));
    await tester.pumpAndSettle();
    expect(find.byType(DestinationDetailScreen), findsOneWidget);

    // Toggle favorite from Detail Screen AppBar
    final favButton = find.byType(IconButton).last;
    await tester.tap(favButton);
    await tester.pumpAndSettle();

    // Pop back to SavedScreen
    appRouter.go('/saved');
    await tester.pumpAndSettle();
  });

  testWidgets('Checkpoint 5.1 Fallback: Invalid ID 999 shows not found screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const TravelApp());
    appRouter.go('/explore/destinations/999');
    await tester.pumpAndSettle();

    // Verify "ไม่พบข้อมูลที่ต้องการ" is displayed
    expect(find.text('ไม่พบข้อมูลที่ต้องการ'), findsOneWidget);
    expect(find.textContaining('ไม่พบ Destination รหัส "999" ในระบบ'), findsOneWidget);
    expect(find.text('กลับไปหน้าสำรวจ'), findsOneWidget);

    // Tap back button
    await tester.tap(find.text('กลับไปหน้าสำรวจ'));
    await tester.pumpAndSettle();
    expect(find.byType(ExploreScreen), findsOneWidget);
  });
}
