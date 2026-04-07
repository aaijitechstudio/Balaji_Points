/// Notifier for when profile (e.g. profile image) is updated so Home/Profile can refresh.
class ProfileRefreshNotifier {
  ProfileRefreshNotifier._();

  static bool _profileUpdated = false;

  static bool get profileUpdated => _profileUpdated;

  static void markProfileUpdated() {
    _profileUpdated = true;
  }

  static bool consumeProfileUpdated() {
    final v = _profileUpdated;
    _profileUpdated = false;
    return v;
  }
}
