import 'package:fumble/core/config/app_config.dart';

/// User-facing copy for Fumble V1 (no localization).
abstract final class AppConstant {
  AppConstant._();

  static const String appName = 'Fumble';
  static const String brand = 'FUMBLE';

  static const String tabfumble = 'FUMBLE';
  static const String tabMyfumble = 'MY FUMBLE';
  static const String tabConnections = 'CONNECTIONS';

  static const String readyTo = 'Ready to';
  static const String fumbleQuestion = 'Fumble?';
  static const String tapTheQr = 'Tap the button when';
  static const String readyToScan = 'you\'re ready to connect';
  static const String fumbleCta = 'FUMBLE';

  static const String loginTitle = 'Welcome back';
  static const String loginSubtitle =
      'Sign in to access your Fumble profile and connections.';
  static const String signupTitle = 'Create your account';
  static const String signupSubtitle =
      'Join Fumble to exchange contact cards privately in person.';
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String nameLabel = 'Name';
  static const String emailHint = 'name@example.com';
  static const String passwordHint = 'Enter your password';
  static const String passwordCreateHint = 'At least 6 characters';
  static const String nameHint = 'Your full name';
  static const String bioHint = 'Filmmaker Creative Director. Love dogs!';
  static const String phoneHint = 'Phone number';
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
  static const String bioLabel = 'Bio';
  static const String aboutMeLabel = 'ABOUT ME';
  static const String locationLabel = 'Location';
  static const String phoneLabel = 'Phone';
  static const String call = 'Call';
  static const String text = 'Text';
  static const String addBio = 'Add a short bio';
  static const String addAboutMe = 'Add a few words about yourself';
  static const String addLocation = 'Add your location';
  static const String addPhone = 'Add phone number';
  static const String sharefumble = 'Share Fumble';
  static const String changePhoto = 'Change photo';
  static const String takePhoto = 'Take photo';
  static const String chooseFromLibrary = 'Choose from library';
  static const String avatars = 'Avatars';
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
      'Complete your profile to get a Fumble code.';

  static String sharefumbleMessage(String code) =>
      'Fumble with me — code $code';

  static String memberSinceLabel(String date) => '$memberSince $date';

  static String firstNamefumble(String firstName) =>
      '${firstName.toUpperCase()} FUMBLE';

  static String youFumbled(String name) => 'You Fumbled $name';

  static const String connectionsTitle = 'CONNECTIONS';
  static const String connectionsEmptyTitle = 'No connections yet';
  static const String connectionsEmptyBody =
      'Tap your QR on the home tab to scan someone\'s code.';
  static const String fumbledOn = 'Fumbled';
  static const String metAtPrefix = 'Met at';
  static String metAt(String place) => '$metAtPrefix $place';
  /// Placeholder subtitle on connection tiles until place copy is finalized.
  static const String metAtCoffeeBar = 'Met at The Coffee Bar';
  static const String dataNotFound = 'No connections yet';

  static const String scannerHint = 'Point your camera at their Fumble code.';
  static const String tapToCancel = 'Tap to cancel';
  static const String authenticating = 'Authenticating…';
  static const String openSettings = 'Open Settings';
  static const String cameraPermissionSettings =
      'Camera access is disabled. Please open Settings and allow Fumble to use your camera.';
  static const String galleryPermissionSettings =
      'Photo access is disabled. Please open Settings and allow Fumble to access your photos.';
  static const String photoPermissionTitle = 'Permission needed';
  static const String locationPermissionTitle = 'Permission needed';
  static const String locationPermissionSettings =
      'Location access is disabled. Please open Settings and allow Fumble to use your location.';
  static const String invalidQr = 'This isn\'t a valid Fumble code.';
  static const String malformedQr = 'This Fumble code is malformed.';
  static const String unsupportedQrVersion =
      'This Fumble code isn\'t supported.';
  static const String qrMissingUserId = 'This Fumble code is missing a user.';
  static const String qrMissingFumbleCode =
      'This Fumble code is missing a code.';
  static const String qrMissingName = 'This Fumble code is missing a name.';
  static const String previewNeedsNetwork =
      'Connect to the internet to finish this Fumble.';

  static const String previewTitle = 'Connect?';
  static const String previewSubtitle = 'Confirm to exchange contact cards.';
  static const String confirmFumble = 'Connect';
  static const String successTitle = 'Connected';
  static const String successBody = 'You\'ve exchanged contact cards.';

  static String successBodyFor(String name) =>
      'You\'ve exchanged contact cards with $name.';
  static const String viewConnections = 'View connections';
  static const String done = 'Done';
  static const String noteLabel = 'NOTE';
  static const String addNote = 'Add Note';

  static String connectWith(String name) => 'Connect with $name';

  static String previewSubtitleFor(String name) =>
      'You\'re about to exchange contact cards with $name. Confirm to save their details to your connections.';

  static const String loading = 'Loading…';
  static const String retry = 'Retry';
  static const String offline = 'You\'re offline';
  static const String pendingSync = 'Pending sync';
  static const String syncStatusSyncing = 'Syncing';
  static const String syncStatusFailed = 'Sync failed';
  static const String somethingWrong = 'Something went wrong';
  static const String ok = 'OK';
  static const String removeConnection = 'Remove connection';
  static String removeConnectionConfirm(String name) =>
      'This will remove $name from your connections and remove you from theirs. This cannot be undone.';
  static const String connectionRemoved = 'Connection removed';
  static const String removeConnectionFailed =
      'Couldn\'t remove connection. Try again.';

  static const String delete = 'Delete';
  static const String closeTooltip = 'Close';
  static const String reloadTooltip = 'Reload';

  static const String deleteAccountConfirm =
      'This permanently deletes your account, profile photo, and connections. This cannot be undone.';
  static const String logoutConfirm = 'Log out of Fumble?';

  static const String nameRequired = 'Please enter your name';
  static const String emailRequired = 'Please enter your email';
  static const String emailInvalid = 'Enter a valid email';
  static const String passwordRequired = 'Please enter your password';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String phoneRequired = 'Please enter your phone number';
  static const String phoneInvalid = 'Enter a valid phone number';
  static const String photoRequired = 'Please add a photo to continue';
  static const String selectCountry = 'Select country';
  static const String searchCountry = 'Search country';

  static const String onboardingPhotoTitle = 'Add a photo';
  static const String onboardingPhotoSubtitle =
      'Your photo appears on your Fumble card when someone fumbles with you.';
  static const String onboardingPhotoHint = 'Tap to choose from your library';
  static const String onboardingPhoneTitle = 'Add your phone number';
  static const String onboardingPhoneSubtitle =
      'This number is shared when you exchange contact cards.';
  static const String onboardingContinue = 'Continue';
  static const String onboardingFinish = 'Finish';

  static String onboardingStepLabel(int current, int total) =>
      '$current of $total';

  static const String profileUpdated = 'Profile updated';
  static const String cannotFumbleSelf = 'You can\'t fumble yourself';
  static const String alreadyConnected = 'You\'re already connected';
  static const String connectionCreated = 'Connection created';

  static const String authEmailInUse =
      'An account already exists for this email. try logging in.';
  static const String authInvalidEmail = 'Enter a valid email address.';
  static const String authWeakPassword =
      'Password must be at least 6 characters.';
  static const String authWrongCredentials = 'Incorrect email or password.';
  static const String authTooManyRequests =
      'Too many attempts. Try again later.';
  static const String authNetworkError =
      'Network error. Check your connection.';
  static const String authRequiresRecentLogin =
      'Please log in again to continue.';
  static const String authFailed = 'Authentication failed.';
  static const String authAccountCreationFailed = 'Account creation failed.';
  static const String authLoginFailed = 'Login failed.';
  static const String authNotSignedIn = 'Not signed in.';
  static const String authPleaseLogIn = 'Please log in again.';
  static const String firestoreUnavailable =
      'Firestore is not enabled yet. Open Firebase Console → Build → Firestore Database → Create database, then try again.';
  static const String firestoreUnavailableShort =
      'Firestore is not enabled in Firebase Console yet.';

  static const String fumbleCodeNotFound = 'Fumble code not found.';
  static const String unableToResolveCode =
      'Unable to resolve this Fumble code.';
  static const String profileMissing = 'Your profile is missing.';
  static const String defaultUserName = 'Fumble user';

  static String fumbledOnLabel(String date) => '$fumbledOn $date';

  static String settingsAppVersionLabel(String version, String build) =>
      '${AppConfig.displayName} $version ($build)';
}
