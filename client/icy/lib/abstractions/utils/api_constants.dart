class ApiConstants {
  // Base API URL - change to production URL when deploying
  static const String baseUrl = 'http://localhost:5000/api/v1';

  // Various endpoint definitions for authentication, surveys, marketplace, etc.
  // Authentication endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String logoutEndpoint = '/auth/logout';
  static const String currentUserEndpoint = '/auth/me';

  // User endpoints
  static const String usersEndpoint = '/users';
  static const String userPreferencesEndpoint = '/users/preferences';
  static const String userStatsEndpoint = '/users/stats';

  // Survey endpoints
  static const String surveysEndpoint = '/surveys';
  static const String dailySurveysEndpoint = '/surveys/daily';

  // Marketplace endpoints
  static const String marketplaceCategoriesEndpoint = '/marketplace/categories';
  static const String marketplaceItemsEndpoint = '/marketplace/items';
  static const String marketplacePurchasesEndpoint = '/marketplace/purchases';

  // Team endpoints
  static const String teamsEndpoint = '/teams';
  static const String myTeamEndpoint = '/teams/my-team';
  static const String leaderboardEndpoint = '/teams/leaderboard';
  static const String leaguesEndpoint = '/teams/leagues';

  // Achievement endpoints
  static const String badgesEndpoint = '/achievements/badges';
  static const String myBadgesEndpoint = '/achievements/badges/my';
  static const String challengesEndpoint = '/achievements/challenges';
  static const String achievementsEndpoint = '/achievements/achievements';
  static const String recentAchievementsEndpoint =
      '/achievements/achievements/recent';

  // Local storage keys
  static const String authTokenKey = 'icy_auth_token';
  static const String refreshTokenKey = 'icy_refresh_token';
  static const String userIdKey = 'icy_user_id';
  static const String userPreferencesKey = 'icy_user_prefs';
}
