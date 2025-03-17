// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:mockito/annotations.dart';
// import 'package:icy/data/repositories/auth_repository.dart';
// import 'package:icy/services/api_service.dart';
// import 'package:icy/data/models/user_model.dart';
// import 'package:icy/data/datasources/local_storage_service.dart';
// import 'package:icy/abstractions/utils/api_constants.dart';

// // Generate mock files
// @GenerateMocks([ApiService, LocalStorageService])
// import 'auth_repository_test.mocks.dart';

// void main() {
//   late MockApiService mockApiService;
//   late MockLocalStorageService mockLocalStorageService;
//   late AuthRepository authRepository;

//   setUp(() {
//     mockApiService = MockApiService();
//     mockLocalStorageService = MockLocalStorageService();
//     authRepository = AuthRepository(
//       apiService: mockApiService,
//       localStorageService: mockLocalStorageService,
//     );
//   });

//   group('login', () {
//     final testEmail = 'test@example.com';
//     final testPassword = 'password123';
//     final mockUserJson = {
//       'id': '123',
//       'email': testEmail,
//       'fullName': 'Test User',
//       'avatar': 'https://example.com/avatar.png',
//       'department': 'Test Department',
//       'username': 'testuser', // Required field
//       'role': 'user', // Required field
//     };

//     test('should return UserModel when login is successful', () async {
//       // Arrange
//       when(mockApiService.login(testEmail, testPassword)).thenAnswer((_) async {
//         return {'success': true, 'user': mockUserJson, 'token': 'fake-token'};
//       });

//       // Act
//       final result = await authRepository.login(testEmail, testPassword);

//       // Assert
//       expect(result, isA<UserModel>());
//       expect(result?.email, testEmail);
//       verify(mockApiService.login(testEmail, testPassword)).called(1);
//       verify(mockLocalStorageService.saveAuthUser(any)).called(1);
//     });

//     test('should return null when login fails', () async {
//       // Arrange
//       when(mockApiService.login(testEmail, testPassword)).thenAnswer((_) async {
//         return {'success': false, 'message': 'Invalid credentials'};
//       });

//       // Act
//       final result = await authRepository.login(testEmail, testPassword);

//       // Assert
//       expect(result, isNull);
//       verify(mockApiService.login(testEmail, testPassword)).called(1);
//       verifyNever(mockLocalStorageService.saveAuthUser(any));
//     });
//   });

//   group('getCurrentUser', () {
//     test('should return cached user when available', () async {
//       // Arrange
//       final mockUser = UserModel(
//         id: '123',
//         email: 'test@example.com',
//         fullName: 'Test User',
//         avatar: 'https://example.com/avatar.png',
//         department: 'Test Department',
//         username: 'testuser', // Added required field
//         role: 'user', // Added required field
//       );

//       when(
//         mockLocalStorageService.getAuthUser(),
//       ).thenAnswer((_) async => mockUser);

//       // Add mock for API call that might happen
//       when(
//         mockApiService.get(ApiConstants.currentUserEndpoint),
//       ).thenAnswer((_) async => {'success': true, 'data': mockUser.toJson()});

//       // Act
//       final result = await authRepository.getCurrentUser();

//       // Assert
//       expect(result, equals(mockUser));
//       verify(mockLocalStorageService.getAuthUser()).called(1);
//     });

//     test(
//       'should try to fetch user from server when cached user exists',
//       () async {
//         // Arrange
//         final mockUser = UserModel(
//           id: '123',
//           email: 'test@example.com',
//           fullName: 'Test User',
//           avatar: 'https://example.com/avatar.png',
//           department: 'Test Department',
//           username: 'testuser', // Added required field
//           role: 'user', // Added required field
//         );

//         final serverUser = UserModel(
//           id: '123',
//           email: 'test@example.com',
//           fullName: 'Updated User',
//           avatar: 'https://example.com/avatar2.png',
//           department: 'Test Department',
//           username: 'testuser', // Added required field
//           role: 'user', // Added required field
//         );

//         when(
//           mockLocalStorageService.getAuthUser(),
//         ).thenAnswer((_) async => mockUser);

//         when(mockApiService.get(any)).thenAnswer((_) async {
//           return {'success': true, 'data': serverUser.toJson()};
//         });

//         // Act
//         final result = await authRepository.getCurrentUser();

//         // Assert
//         expect(result?.fullName, 'Updated User');
//         verify(mockLocalStorageService.getAuthUser()).called(1);
//         verify(mockApiService.get(any)).called(1);
//         verify(mockLocalStorageService.saveAuthUser(any)).called(1);
//       },
//     );

//     test('should return null when no cached user and not logged in', () async {
//       // Arrange
//       when(mockLocalStorageService.getAuthUser()).thenAnswer((_) async => null);

//       // Act
//       final result = await authRepository.getCurrentUser();

//       // Assert
//       expect(result, isNull);
//       verify(mockLocalStorageService.getAuthUser()).called(1);
//       verifyNever(mockApiService.get(any));
//     });
//   });
// }
