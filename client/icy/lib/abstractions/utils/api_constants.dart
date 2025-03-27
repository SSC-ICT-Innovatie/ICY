class ApiConstants {
  static bool get isProduction => false;
  static String get apiBaseUrl =>
      isProduction
          ? 'https://api.icy-app.com/api/v1'
          : 'http://localhost:5001/api/v1';

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String logoutEndpoint = '/auth/logout';
  static const String currentUserEndpoint = '/auth/me';
  static const String requestVerificationEndpoint =
      '/auth/request-verification';
  static const String verifyEmailEndpoint = '/auth/verify-email-code';
  static const String verifyEmailCodeEndpoint = '/auth/verify-email-code';

  static const String departmentsEndpoint = '/departments';

  static const String achievementsEndpoint = '/achievements';
  static const String badgesEndpoint = '/achievements/badges';
  static const String myBadgesEndpoint = '/achievements/badges/my';
  static const String recentAchievementsEndpoint = '/achievements/recent';
  static const String challengesEndpoint = '/achievements/challenges';
  static const String userChallengesEndpoint = '/achievements/challenges/my';
  static const String completeAchievementEndpoint = '/achievements/complete';

  static const String surveysEndpoint = '/surveys';
  static const String mySurveysEndpoint = '/surveys/my';
  static const String dailySurveysEndpoint = '/surveys/daily';
  static const String completeSurveyEndpoint = '/surveys/complete';

  static const String teamsEndpoint = '/teams';
  static const String myTeamEndpoint = '/teams/my';
  static const String teamMembersEndpoint = '/teams/members';
  static const String leaderboardEndpoint = '/teams/leaderboard';
  static const String leaguesEndpoint = '/teams/leagues';

  static const String marketplaceEndpoint = '/marketplace';
  static const String marketplaceItemsEndpoint = '/marketplace/items';
  static const String marketplaceCategoriesEndpoint = '/marketplace/categories';
  static const String marketplacePurchasesEndpoint = '/marketplace/purchases';

  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'auth_user';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
}
