import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf_uts/main.dart';

void main() {
  testWidgets('BookShelfApp loads and displays Home dashboard', (WidgetTester tester) async {
    // Set a realistic mobile device screen size (390 x 844 - iPhone 14 / modern Android)
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Build the BookShelf app
    await tester.pumpWidget(const BookShelfApp());
    await tester.pump();

    // Verify key UI elements matching UTS requirements exist
    expect(find.text('BookShelf'), findsOneWidget);
    expect(find.text('Add new book'), findsWidgets);
    expect(find.text('Your Last Read Book'), findsOneWidget);
    expect(find.text('Other Books'), findsOneWidget);
    expect(find.text('Currently Reading'), findsWidgets);
  });
}
