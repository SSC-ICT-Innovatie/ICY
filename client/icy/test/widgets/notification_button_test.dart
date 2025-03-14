import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:icy/features/notifications/bloc/notifications_bloc.dart';
import 'package:icy/features/notifications/widgets/notifications_button.dart';

// Generate mock files
@GenerateMocks([NotificationsBloc])
import 'notification_button_test.mocks.dart';

void main() {
  late MockNotificationsBloc mockNotificationsBloc;

  setUp(() {
    mockNotificationsBloc = MockNotificationsBloc();
    when(mockNotificationsBloc.state).thenReturn(NotificationsInitial());
    when(mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());
  });

  testWidgets('NotificationsButton renders correctly', (
    WidgetTester tester,
  ) async {
    // Build NotificationsButton
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<NotificationsBloc>.value(
            value: mockNotificationsBloc,
            child: const NotificationsButton(),
          ),
        ),
      ),
    );

    // Verify button is rendered
    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);

    // Verify no badge is shown when showBadge is false
    expect(find.byType(Positioned), findsNothing);
  });

  testWidgets('NotificationsButton shows badge when showBadge is true', (
    WidgetTester tester,
  ) async {
    // Build NotificationsButton with showBadge=true
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<NotificationsBloc>.value(
            value: mockNotificationsBloc,
            child: const NotificationsButton(showBadge: true),
          ),
        ),
      ),
    );

    // Verify badge is shown
    expect(find.byType(Positioned), findsOneWidget);
    expect(find.byType(Container), findsWidgets);
  });

  testWidgets('NotificationsButton loads notifications when tapped', (
    WidgetTester tester,
  ) async {
    // Build NotificationsButton
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<NotificationsBloc>.value(
            value: mockNotificationsBloc,
            child: const NotificationsButton(),
          ),
        ),
      ),
    );

    // Tap the button
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    // Verify LoadNotifications event was added to the bloc
    verify(mockNotificationsBloc.add(const LoadNotifications())).called(1);
  });
}
