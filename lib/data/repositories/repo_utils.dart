/// Small shared helpers for repository string / error checks.
abstract final class RepoUtils {
  static String? blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static bool filled(String? value) =>
      value != null && value.trim().isNotEmpty;

  static bool isOfflineError(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('network-request-failed') ||
        text.contains('unavailable') ||
        text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('network error') ||
        text.contains('clientexception');
  }
}
