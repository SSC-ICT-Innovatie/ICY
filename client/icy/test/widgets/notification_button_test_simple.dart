import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icy/features/notifications/widgets/notifications_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:icy/features/notifications/bloc/notifications_bloc.dart';

@GenerateMocks([NotificationsBloc])
import 'notification_button_test_simple.mocks.dart';

void main() {
  late MockNotificationsBloc mockNotificationsBloc;

  setUp(() {
    mockNotificationsBloc = MockNotificationsBloc();
    when(mockNotificationsBloc.state).thenReturn(NotificationsInitial());
    when(mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());
  });

  testWidgets('NotificationsButton renders without badge', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<NotificationsBloc>.value(
            value: mockNotificationsBloc,
            child: Builder(
              builder: (context) => const NotificationsButton(showBadge: false),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(find.byType(Stack), findsOneWidget);
    expect(find.byType(Positioned), findsNothing);
  });
}
