import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:fumble/utils/constant.dart';

enum VoiceMemoryFailure {
  unavailable,
  microphoneDenied,
  speechDenied,
}

class VoiceMemoryStartResult {
  const VoiceMemoryStartResult._({this.failure});

  const VoiceMemoryStartResult.ok() : this._();

  const VoiceMemoryStartResult.failed(VoiceMemoryFailure failure)
      : this._(failure: failure);

  final VoiceMemoryFailure? failure;

  bool get isOk => failure == null;

  String get message => switch (failure) {
        VoiceMemoryFailure.unavailable => AppConstant.speechUnavailable,
        VoiceMemoryFailure.microphoneDenied => AppConstant.micPermissionSettings,
        VoiceMemoryFailure.speechDenied => AppConstant.speechPermissionSettings,
        null => '',
      };
}

/// Speech-to-text helper for Record Memory → note autofill.
class VoiceMemoryService {
  VoiceMemoryService();

  final SpeechToText _speech = SpeechToText();
  var _initialized = false;
  String _baseNote = '';

  bool get isListening => _speech.isListening;

  Future<bool> _ensureInitialized({
    void Function(String status)? onStatus,
    void Function(String error)? onError,
  }) async {
    if (_initialized) return _speech.isAvailable;
    _initialized = true;
    return _speech.initialize(
      onStatus: onStatus,
      onError: (error) => onError?.call(error.errorMsg),
    );
  }

  Future<VoiceMemoryStartResult> start({
    required String currentNote,
    required void Function(String text) onTranscript,
    void Function(String status)? onStatus,
    void Function(String error)? onError,
  }) async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      return const VoiceMemoryStartResult.failed(
        VoiceMemoryFailure.microphoneDenied,
      );
    }

    await Permission.speech.request();

    final available = await _ensureInitialized(
      onStatus: onStatus,
      onError: onError,
    );
    if (!available) {
      return const VoiceMemoryStartResult.failed(
        VoiceMemoryFailure.unavailable,
      );
    }

    if (_speech.isListening) {
      await _speech.stop();
    }

    _baseNote = currentNote.trim();

    await _speech.listen(
      onResult: (result) {
        final spoken = result.recognizedWords.trim();
        if (spoken.isEmpty) return;
        final text = _baseNote.isEmpty ? spoken : '$_baseNote $spoken';
        onTranscript(text);
      },
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: 4),
      ),
    );

    return const VoiceMemoryStartResult.ok();
  }

  Future<void> stop() async {
    if (!_speech.isListening) return;
    await _speech.stop();
  }

  Future<void> cancel() async {
    if (!_speech.isListening) return;
    await _speech.cancel();
  }

  void dispose() {
    if (_speech.isListening) {
      _speech.cancel();
    }
  }
}
