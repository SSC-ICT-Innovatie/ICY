class ApiConstants {
  // API base URL
  static const String baseUrl = 'http://localhost:5001/api/v1';

  // Auth routes
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/register';
  static const String registerEndpoint =
      '/auth/register'; // Alias for signupEndpoint
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String currentUserEndpoint = '/auth/me';
  static const String requestVerificationCodeEndpoint =
      '/auth/request-verification-code';
  static const String verifyEmailCodeEndpoint = '/auth/verify-email-code';

  // Auth storage keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';

  // User routes
  static const String usersEndpoint = '/users';
  static const String userProfileEndpoint = '/users/profile';

  // Survey routes
  static const String surveysEndpoint = '/surveys';
  static const String dailySurveysEndpoint = '/surveys/daily';
  static const String userSurveysEndpoint = '/surveys/my';

  // Achievement routes
  static const String achievementsEndpoint = '/achievements';
  static const String badgesEndpoint = '/achievements/badges';
  static const String userBadgesEndpoint = '/achievements/badges/my';
  static const String myBadgesEndpoint = '/achievements/badges/my';
  static const String challengesEndpoint = '/achievements/challenges';
  static const String userChallengesEndpoint = '/achievements/challenges/my';
  static const String recentAchievementsEndpoint = '/achievements/recent';

  // Team routes
  static const String teamsEndpoint = '/teams';
  static const String myTeamEndpoint = '/teams/my';
  static const String teamMembersEndpoint = '/teams/members';
  static const String leaderboardEndpoint = '/teams/leaderboard';
  static const String leaguesEndpoint = '/teams/leagues';

  // Department routes
  static const String departmentsEndpoint = '/departments';

  // Marketplace routes
  static const String marketplaceEndpoint = '/marketplace';
  static const String marketplaceCategoriesEndpoint = '/marketplace/categories';
  static const String marketplaceItemsEndpoint = '/marketplace/items';
  static const String marketplacePurchasesEndpoint = '/marketplace/purchases';
}
