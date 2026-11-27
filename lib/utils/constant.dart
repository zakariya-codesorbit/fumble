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
  static const String confirmPasswordLabel = 'Confirm password';
  static const String nameLabel = 'Name';
  static const String emailHint = 'name@example.com';
  static const String passwordHint = 'Enter your password';
  static const String passwordCreateHint =
      '8+ chars, upper, lower, number & symbol';
  static const String confirmPasswordHint = 'Re-enter your password';
  static const String passwordRuleMinLength = 'At least 8 characters';
  static const String passwordRuleLetterCase =
      'Uppercase and lowercase letters';
  static const String passwordRuleNumber = 'At least one number';
  static const String passwordRuleSymbol = 'At least one special character';
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
  static const String yourIdentity = 'YOUR IDENTITY';
  static const String myFumbleTitle = 'My Fumble';
  static String signedInAs(String email) => 'Signed in as $email';
  static const String youAreLabel = 'YOU ARE';
  static const String genderMale = 'MALE';
  static const String genderFemale = 'FEMALE';
  static const String yourVoiceLabel = 'YOUR VOICE';
  static const String voiceTemplateTitle = 'Voice template';
  static const String voiceTemplateBody =
      'Read the prompt below out loud once. We save it as a voice file that powers every dialogue video you generate.';
  static String voiceTemplatePrompt(String firstName) =>
      '“Hey, this is $firstName. I’m recording this so Fumble knows my voice. Tonight I’ll be the one laughing too loud, so text me when you’re close and I’ll come find you.”';
  static const String recordMyVoice = 'Record my voice';
  static const String recordingVoice = 'Recording…';
  static const String voiceSaved = 'Voice template saved';
  static const String voiceAlreadySaved = 'Voice template ready';
  static const String aiImageComingSoon = 'AI image generation is coming soon.';
  static const String memberSince = 'Member since';
  static const String editProfile = 'Edit profile';
  static const String editMyFumble = 'Edit My Fumble';
  static const String bioLabel = 'Bio';
  static const String aboutMeLabel = 'ABOUT ME';
  static const String locationLabel = 'Location';
  static const String phoneLabel = 'Phone';
  static const String phoneNumberLabel = 'Phone number';
  static const String whatsAppNumberLabel = 'WhatsApp number';
  static const String profilePhotoLabel = 'Profile photo';
  static const String chooseFile = 'Choose file';
  static const String noFileChosen = 'No file chosen';
  static const String saveProfile = 'Save profile';
  static const String optionalHint = 'Optional';
  static const String call = 'Call';
  static const String text = 'Text';
  static const String whatsApp = 'WhatsApp';
  static const String addBio = 'Add a short bio';
  static const String addAboutMe = 'Add a few words about yourself';
  static const String addLocation = 'Add your location';
  static const String addPhone = 'Add phone number';
  static const String sharefumble = 'Share Fumble';
  static const String changePhoto = 'Change photo';
  static const String takePhoto = 'Take photo';
  static const String cropPhotoTitle = 'Crop photo';
  static const String cropPhotoDone = 'Done';
  static const String cropPhotoCancel = 'Cancel';
  static const String chooseFromLibrary = 'Choose from library';
  static const String avatars = 'Avatars';
  static const String removePhoto = 'Remove photo';
  static const String photoUpdated = 'Photo updated';
  static const String photoUploadFailed =
      'Couldn\'t process that photo. Please try again.';
  static const String photoTooLarge =
      'Please choose an image smaller than 2 MB.';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String logout = 'Log out';
  static const String deleteAccount = 'Delete account';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Terms of Service';
  static const String termsAndConditions = 'Terms & Conditions';
  static const String legalGroup = 'LEGAL';
  static const String agreeLegalPrefix = 'I agree to the ';
  static const String agreeLegalAnd = ' and ';
  static const String agreeLegalRequired =
      'Please agree to the Privacy Policy and Terms & Conditions to continue.';
  static const String settings = 'Settings';
  static const String shareContactGroup = 'SHARE ON FUMBLE';
  static const String sharePhoneSetting = 'Phone number';
  static const String shareEmailSetting = 'Email';
  static const String shareWhatsAppSetting = 'WhatsApp number';
  static const String accountGroup = 'ACCOUNT';
  static const String completeProfile =
      'Complete your profile to get a Fumble code.';

  static String sharefumbleMessage(String code) =>
      'Fumble with me — code $code';

  static String memberSinceLabel(String date) => '$memberSince $date';

  static String firstNamefumble(String firstName) =>
      '${firstName.toUpperCase()} FUMBLE';

  static String youFumbled(String name) => 'You Fumbled $name';

  static String fumbledYou(String name) => '$name Fumbled you';

  static String youFumbledJustNow(String name) =>
      'You Fumbled $name just now. Want to remember the moment?';

  /// Connection detail remember prompt when the shared note is empty.
  static String rememberMomentEmptyYouInitiated(String name) =>
      'You fumbled $name. Want to remember the moment?';

  static String rememberMomentEmptyTheyInitiated(String name) =>
      '$name fumbled you. Want to remember the moment?';

  /// Connection detail remember prompt when a shared note exists.
  static String sharedMemoryYouInitiated(String name) =>
      'You fumbled $name. Your shared memory.';

  static String sharedMemoryTheyInitiated(String name) =>
      '$name fumbled you. Your shared memory.';

  static const String theMomentLabel = 'THE MOMENT';
  static const String openInMaps = 'Open in Maps';

  /// Placeholder on preview / detail when meeting place is empty.
  static const String enterFumbleLocation = 'Enter Fumble location';

  /// Shown on connection list cards when no place is saved.
  static const String fumbleLocationNotSet = 'Fumble location not set';
  static const String recordMemory = 'Record Memory';
  static const String listeningMemory = 'Listening…';
  static const String typeMemoryHint = 'Or type a memory about how you met...';
  static const String savedPermanentlyWithFumble =
      'Saved permanently with this Fumble.';
  static const String recordMemoryTab = 'RECORD MEMORY';
  static const String aiGenerationTab = 'AI GENERATION';
  static const String aiVideoMemoryTab = 'AI VIDEO MEMORY';
  static const String sayItLikeThis = 'SAY IT LIKE THIS';
  static const String aiMemoryLabel = 'AI MEMORY';
  static const String paintedFromYourMemory = 'PAINTED FROM YOUR MEMORY';
  static const String filmedFromYourMemory = 'FILMED FROM YOUR MEMORY';
  static const String addToIt = 'ADD TO IT';
  static const String addToItHint =
      'Anything your memory left out? e.g. gold streetlights, rooftop bar at dusk…';
  static const String pictureKeepsMoment =
      'Your picture keeps this moment: where you met, when, and what you remember.';
  static const String videoPlaysMoment =
      'The video plays this moment back: where you met, when, and what you remember.';
  static const String generate = 'Generate';
  static const String regenerateVideo = 'Regenerate video';
  static const String editLabel = 'EDIT';
  static const String aiImagePlaceholder = 'Fumble AI image';
  static const String aiComingSoon = 'AI generation is coming soon.';

  /// Temporary media used until real FalAI output is wired.
  static const String aiTestVideoUrl =
      'https://github.com/vibeappspro/dummy-data/raw/refs/heads/main/videos/sample-video-portrait-720p.mp4';
  static const List<String> memoryPrompts = [
    'Where did you meet?',
    'What were you doing?',
    'What happened, and what made the encounter memorable?',
  ];

  static const String speechUnavailable =
      'Speech recognition isn\'t available on this device.';
  static const String micPermissionTitle = 'Microphone access needed';
  static const String micPermissionSettings =
      'Fumble uses your microphone to record a short voice memory when you meet someone. Open Settings and allow Microphone for Fumble.';
  static const String speechPermissionTitle = 'Speech recognition needed';
  static const String speechPermissionSettings =
      'Fumble turns your voice memory into text so you can keep the moment. Open Settings and allow Speech Recognition for Fumble.';

  static const String connectionsTitle = 'CONNECTIONS';
  static const String connectionsTabFumbled = 'FUMBLED';
  static const String connectionsTabHalfFumble = 'HALF FUMBLE';
  static const String connectionsTabWait2Fumble = 'WAIT 2 FUMBLE';
  static const String connectionsTabFumblePlayground = 'FUMBLE PLAYGROUND';
  static const String connectionsTabAll = 'ALL';
  static const String wait2FumbleComingSoon =
      'Wait 2 Fumble is coming soon.';
  static const String wait2MakeYourOwn = 'MAKE YOUR OWN';
  static const String wait2PresetVideos = 'PRESET VIDEOS';
  static const String whileYouWait2Fumble = 'WHILE YOU WAIT 2 FUMBLE';
  static const String wait2CaptureHint =
      'Capture a 5 to 8 second vertical video of a moment — travels, a night out, whatever you want to remember until it becomes a Fumble.';
  static const String wait2WhoOrWhat = 'Who or what?';
  static const String wait2Where = 'Where?';
  static const String wait2WhatHappened =
      'What happened or what would you like to create?';
  static const String wait2FromGallery = 'FROM GALLERY';
  static const String wait2GenerateWithAi = 'GENERATE WITH AI';
  static const String generateImageMemory = 'Generate Image Memory';
  static const String generateVideoMemory = 'Generate Video Memory';
  static const String wait2SampleTitle = 'Italy Trip';
  static const String wait2SampleLocation = 'Milan, italy';
  static const String wait2SampleCaption = '“Business trip but had fun.”';
  static const String wait2PresetComingSoon =
      'Preset videos are coming soon.';
  static const String fumblePlaygroundComingSoon =
      'Fumble Playground is coming soon.';
  static const String fumblePlaygroundEyebrow = 'FUMBLE PLAYGROUND';
  static const String fumblePlaygroundHeadline = 'New adventures';
  static const String fumblePlaygroundTagline =
      'CONNECT IN SECONDS, HAVE FUN FOREVER';
  static const String whoAreYouFumblingWith = 'WHO ARE YOU FUMBLING WITH?';
  static const String pickAFumbleAbove = 'Pick a Fumble above';
  static const String generateAdventure = 'GENERATE ADVENTURE';
  static const String shareWithAFumble = 'SHARE WITH A FUMBLE';
  static const String connectionsEmptyTitle = 'No fumbles yet';
  static const String connectionsEmptyBody =
      'Fumble someone to save the moment here.';
  static const String addSomeone = 'Add Someone';
  static const String addSomeoneSubtitle =
      'Invite someone who is not on Fumble yet. Send them an invite, when they join and verify, you will connect from Half Fumble.';
  static const String sendInvitation = 'Send Invitation';
  static const String halfFumbleCta = 'Fumble';
  static const String resendInvitation = 'Resend Invitation';
  static const String resendFumble = 'Resend Fumble';
  static const String cancelInvitation = 'Cancel Invitation';
  static const String cancelFumble = 'Cancel Fumble';
  static const String acceptConnection = 'Accept Connection';
  static const String acceptFumble = 'Accept Fumble';
  static const String declineInvitation = 'Decline';
  static const String halfFumbleWantToFumbleYou =
      'Want to fumble you, review and accept.';

  static String wantToFumbleYou(String name) => '$name Want to fumble you';

  static String youWantToFumble(String name) => 'You Want to fumble $name';

  static String halfFumbled(String name) => 'Half Fumbled $name';

  static const String sendFumbleInvite = 'SEND FUMBLE INVITE';
  static const String halfFumbleStatusLabel = 'Half Fumble';
  static const String invitationSentLabel = 'Invitation sent';
  static const String pendingAcceptanceLabel = 'Pending acceptance';
  static const String whatsAppRequired = 'Please enter a WhatsApp number';
  static const String meetingLocationLabel = 'Meeting location';
  static const String meetingDateLabel = 'Meeting date';
  static const String personalNoteLabel = 'Personal note';
  static const String fullNameLabel = 'Full name';
  static const String emailAddressLabel = 'Email address';
  static const String halfFumblePermissionDenied =
      'Couldn\'t save invitation (Firestore permission). Deploy the latest rules for project fumble-2026.';
  static const String halfFumbleInviteShared =
      'Invitation ready — share the link to invite them.';
  static const String halfFumbleShareTitle = 'Send invitation';
  static const String halfFumbleShareSms = 'Text Message';
  static const String halfFumbleShareWhatsApp = 'WhatsApp';
  static const String halfFumbleShareMore = 'Share elsewhere';
  static const String halfFumbleShareMoreSubtitle =
      'Email, AirDrop, or other apps';
  static const String halfFumbleShareSmsFailed =
      'Couldn\'t open Messages. Try Share elsewhere.';
  static const String halfFumbleShareWhatsAppFailed =
      'Couldn\'t open WhatsApp. Try Share elsewhere.';
  static const String halfFumbleInviteRevoked = 'Invitation cancelled';
  static const String halfFumbleAlreadyInvited =
      'You already have an open Half Fumble for this email.';
  static const String halfFumbleAlreadyConnected =
      'You\'re already connected with this email.';
  static const String halfFumbleCannotInviteSelf =
      'You can\'t invite yourself.';
  static const String halfFumbleCannotResend =
      'This invitation can\'t be resent.';
  static const String halfFumbleCannotCancel =
      'This invitation can\'t be cancelled.';
  static const String halfFumbleInviteExpired = 'This invitation has expired.';
  static const String halfFumbleInviteNotFound = 'Invitation not found.';
  static const String halfFumbleInviteInvalid = 'This invitation is invalid.';
  static const String halfFumbleInviteUnavailable =
      'This invitation is no longer available.';
  static const String halfFumbleEmailMismatch =
      'Sign in with the invited email address to accept.';
  static const String halfFumbleEmailRequired =
      'Verify your email to accept this invitation.';
  static const String halfFumbleInviterMissing =
      'The person who invited you is no longer available.';
  static const String halfFumbleAccepted = 'You\'re now connected on Fumble.';
  static const String halfFumbleDeclined = 'Invitation declined.';
  static const String verifyEmailTitle = 'Verify your email';
  static const String verifyEmailBody =
      'Check your inbox and verify your email before accepting invitations.';
  static const String verifyEmailSignupTitle = 'Verify your email';
  static const String verifyEmailSignupBody =
      'A verification link has been sent to your email. Please verify your email, then log in to continue.';
  static const String verifyEmailSignupCta = 'Login';
  static const String authEmailNotVerified =
      'Please verify your email before logging in. Check your inbox for the link.';
  static const String fumbledOn = 'Fumbled';

  static String halfFumbleShareMessage({
    required String invitedEmail,
    required String storeUrl,
    required String appLink,
  }) =>
      'Hey! I\'ve added you on Fumble. Join me so we can connect and keep our '
      'memories together.\n\n'
      '1) Download Fumble (if you don\'t have it):\n$storeUrl\n\n'
      '2) Sign up with this email (required): $invitedEmail\n\n'
      '3) Verify your email, then log in — open Connections → Half Fumble to review invitations.\n\n'
      'Already have Fumble? Open this link:\n$appLink';

  static const String halfFumblePendingInviteTitle = 'Fumble invitation';
  static const String halfFumblePendingInviteBody =
      'Want to fumble you, review and accept.';
  static const String metAtPrefix = 'Met at';
  static String metAt(String place) => '$metAtPrefix $place';

  /// Placeholder subtitle on connection tiles until place copy is finalized.
  static const String metAtCoffeeBar = 'Met at The Coffee Bar';
  static const String dataNotFound = 'No connections yet';

  static const String scannerHint = 'Point your camera at their Fumble code.';
  static const String tapToCancel = 'Tap to cancel';
  static const String authenticating = 'Authenticating…';
  static const String openSettings = 'Open Settings';
  static const String cameraPermissionTitle = 'Camera access needed';
  static const String cameraPermissionSettings =
      'Fumble needs the camera to scan someone’s Fumble QR code and to take a profile photo. Open Settings and allow Camera for Fumble.';
  static const String galleryPermissionTitle = 'Photos access needed';
  static const String galleryPermissionSettings =
      'Fumble needs access to your photos so you can choose a profile picture for your Fumble card. Open Settings and allow Photos for Fumble.';
  static const String locationPermissionTitle = 'Location access needed';
  static const String locationPermissionSettings =
      'Fumble uses your location to save where you met and to set your phone country code. Open Settings and allow Location While Using for Fumble.';
  static const String locationServicesTitle = 'Location is off';
  static const String locationServicesSettings =
      'Location services are turned off on this device. Turn them on so Fumble can fill the meeting place when you Fumble someone.';
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
  static const String addMemoryNote = typeMemoryHint;

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

  /// Shown only if we need to explain deferred cloud delete (optional UX).
  static const String connectionRemovedOffline =
      'Connection removed. It will sync when you\'re back online.';

  static const String delete = 'Delete';
  static const String closeTooltip = 'Close';
  static const String reloadTooltip = 'Reload';

  static const String deleteAccountConfirm =
      'This permanently deletes your account, profile photo, and connections. This cannot be undone.';
  static const String logoutConfirm = 'Log out of Fumble?';

  static const String nameRequired = 'Please enter your name';
  static const String inviteeNameRequired = 'Please enter their full name';
  static const String emailRequired = 'Please enter your email';
  static const String inviteeEmailRequired = 'Please enter their email address';
  static const String emailInvalid = 'Enter a valid email';
  static const String inviteeEmailInvalid =
      'Enter a valid email address for the invitation';
  static const String passwordRequired = 'Please enter your password';
  static const String confirmPasswordRequired = 'Please confirm your password';
  static const String passwordTooShort =
      'Password must be at least 8 characters';
  static const String passwordNeedsUppercase =
      'Include at least one uppercase letter';
  static const String passwordNeedsLowercase =
      'Include at least one lowercase letter';
  static const String passwordNeedsNumber = 'Include at least one number';
  static const String passwordNeedsSymbol =
      'Include at least one special character';
  static const String passwordMismatch = 'Passwords do not match';
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
      'Use 8+ characters with upper, lower, number, and a symbol.';
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

  /// Fallback when PackageInfo is unavailable (matches pubspec Version 1).
  static String get appVersionLabel => settingsAppVersionLabel(
    AppConfig.appVersionName,
    '${AppConfig.appBuildNumber}',
  );
}
