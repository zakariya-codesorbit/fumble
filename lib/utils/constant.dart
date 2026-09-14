import 'package:fumble/core/config/app_config.dart';

/// User-facing copy for FLUMBLE V1 (no localization).
abstract final class AppConstant {
  AppConstant._();

  static const String appName = 'Flumble';
  static const String brand = 'FLUMBLE';

  static const String tabFlumble = 'FLUMBLE';
  static const String tabMyFlumble = 'MY FLUMBLE';
  static const String tabConnections = 'CONNECTIONS';

  static const String readyTo = 'Ready to';
  static const String fumbleQuestion = 'Fumble?';
  static const String tapTheButton = 'Tap the button when';
  static const String readyToConnect = 'you\'re ready to connect.';
  static const String fumbleCta = 'FUMBLE';

  static const String loginTitle = 'Welcome back';
  static const String loginSubtitle =
      'Sign in to access your Flumble profile and connections.';
  static const String signupTitle = 'Create your account';
  static const String signupSubtitle =
      'Join Flumble to exchange contact cards privately in person.';
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String nameLabel = 'Name';
  static const String emailHint = 'name@example.com';
  static const String passwordHint = 'Enter your password';
  static const String passwordCreateHint = 'At least 6 characters';
  static const String nameHint = 'Your full name';
  static const String bioHint = 'Filmmaker. Creative Director.';
  static const String phoneHint = 'Phone number';
  static const String aboutMeHint = 'A short introduction about you';
  static const String locationHint = 'City, State';
  static const String loginCta = 'Log in';
  static const String signupCta = 'Sign up';
  static const String forgotPassword = 'Forgot password?';
  static const String noAccount = 'Don\'t have an account?';
  static const String hasAccount = 'Already have an account?';
  static const String resetPasswordTitle = 'Reset password';
  static const String resetPasswordSubtitle =
      'Enter your email and we\'ll send you a secure link to reset your password.';
  static const String sendResetLink = 'Send reset link';
  static const String resetEmailSent = 'Check your email for a reset link.';

  static const String scanToFumble = 'SCAN TO FUMBLE';
  static const String memberSince = 'Member since';
  static const String editProfile = 'Edit profile';
  static const String aboutMe = 'ABOUT ME';
  static const String bioLabel = 'Bio';
  static const String phoneLabel = 'Phone';
  static const String aboutMeLabel = 'About me';
  static const String locationLabel = 'Location';
  static const String call = 'Call';
  static const String text = 'Text';
  static const String addBio = 'Add a short bio';
  static const String addAboutMe = 'Tell people about yourself';
  static const String addLocation = 'Add location';
  static const String addPhone = 'Add phone number';
  static const String shareFlumble = 'Share Flumble';
  static const String changePhoto = 'Change photo';
  static const String chooseFromLibrary = 'Choose from library';
  static const String removePhoto = 'Remove photo';
  static const String photoUpdated = 'Photo updated';
  static const String photoUploadFailed =
      'Couldn\'t save photo. Try a smaller image.';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String logout = 'Log out';
  static const String deleteAccount = 'Delete account';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Terms of Service';
  static const String settings = 'Settings';
  static const String completeProfile =
      'Complete your profile to get a FLUMBLE code.';

  static String shareFlumbleMessage(String code) =>
      'Fumble with me on Flumble — code $code';

  static String memberSinceLabel(String date) => '$memberSince $date';

  static String firstNameFlumble(String firstName) =>
      '${firstName.toUpperCase()} FLUMBLE';

  static const String connectionsTitle = 'CONNECTIONS';
  static const String connectionsEmptyTitle = 'No connections yet';
  static const String connectionsEmptyBody =
      'Tap FUMBLE on the home tab to scan someone\'s QR code.';
  static const String fumbledOn = 'Fumbled';
  static const String dataNotFound = 'No connections yet';

  static const String scannerTitle = 'Scan FLUMBLE';
  static const String scannerHint =
      'Point your camera at their FLUMBLE QR code.';
  static const String cameraPermissionDenied =
      'Camera access is required to scan FLUMBLE codes.';
  static const String openSettings = 'Open Settings';
  static const String invalidQr = 'This isn\'t a valid FLUMBLE code.';

  static const String previewTitle = 'Connect?';
  static const String previewSubtitle = 'Confirm to exchange contact cards.';
  static const String confirmFumble = 'Confirm';
  static const String successTitle = 'Connected';
  static const String successBody = 'You\'ve exchanged contact cards.';
  static const String viewConnections = 'View connections';
  static const String done = 'Done';

  static const String loading = 'Loading…';
  static const String retry = 'Retry';
  static const String offline = 'You\'re offline';
  static const String pendingSync = 'Waiting to sync…';
  static const String somethingWrong = 'Something went wrong';
  static const String ok = 'OK';
  static const String delete = 'Delete';
  static const String closeTooltip = 'Close';
  static const String reloadTooltip = 'Reload';

  static const String deleteAccountConfirm =
      'This permanently deletes your account, profile photo, and connections. This cannot be undone.';
  static const String logoutConfirm = 'Log out of Flumble?';

  static const String nameRequired = 'Please enter your name';
  static const String emailRequired = 'Please enter your email';
  static const String emailInvalid = 'Enter a valid email';
  static const String passwordRequired = 'Please enter your password';
  static const String passwordTooShort =
      'Password must be at least 6 characters';

  static const String profileUpdated = 'Profile updated';
  static const String cannotFumbleSelf = 'You can\'t fumble yourself';
  static const String alreadyConnected = 'You\'re already connected';
  static const String connectionCreated = 'Connection created';

  static const String authEmailInUse =
      'An account already exists for this email.';
  static const String authInvalidEmail = 'Enter a valid email address.';
  static const String authWeakPassword =
      'Password must be at least 6 characters.';
  static const String authWrongCredentials = 'Incorrect email or password.';
  static const String authTooManyRequests = 'Too many attempts. Try again later.';
  static const String authNetworkError = 'Network error. Check your connection.';
  static const String authRequiresRecentLogin = 'Please log in again to continue.';
  static const String authFailed = 'Authentication failed.';
  static const String authAccountCreationFailed = 'Account creation failed.';
  static const String authLoginFailed = 'Login failed.';
  static const String authNotSignedIn = 'Not signed in.';
  static const String authPleaseLogIn = 'Please log in again.';
  static const String firestoreUnavailable =
      'Firestore is not enabled yet. Open Firebase Console → Build → Firestore Database → Create database, then try again.';
  static const String firestoreUnavailableShort =
      'Firestore is not enabled in Firebase Console yet.';

  static const String flumbleCodeNotFound = 'FLUMBLE code not found.';
  static const String unableToResolveCode = 'Unable to resolve this FLUMBLE code.';
  static const String profileMissing = 'Your profile is missing.';
  static const String defaultUserName = 'Flumble user';

  static String fumbledOnLabel(String date) => '$fumbledOn $date';

  static String settingsAppVersionLabel(String version, String build) =>
      '${AppConfig.displayName} $version ($build)';
}
