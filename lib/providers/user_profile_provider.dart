import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/user_profile_api_service.dart';

const defaultUserProfile = UserProfile(
  fullName: 'Alexander Sterling',
  email: 'alex.sterling@evergreen.co',
  phone: '+1 (555) 012-3456',
  location: 'Seattle, WA',
  bio:
      'Senior Event Coordinator with over 10 years of experience in sustainable corporate retreats and nature-focused summits.',
);

final userProfileApiServiceProvider = Provider<UserProfileApiService>((ref) {
  return UserProfileApiService();
});

final userProfileProvider = StateProvider<UserProfile>((ref) {
  return defaultUserProfile;
});
