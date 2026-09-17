import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  final service = SupabaseService(Supabase.instance.client);
  ref.onDispose(service.dispose);
  return service;
});

/// Wraps Supabase Auth and the user's `profiles` row. Notifies listeners on every auth state change so
/// go_router can re-run its redirect.
class SupabaseService extends ChangeNotifier {
  SupabaseService(this._supabase) {
    _authSubscription = _supabase.auth.onAuthStateChange.listen(
      _onAuthStateChange,
      onError: _onAuthError,
    );
  }

  /// Must also be listed under Authentication → URL Configuration →
  /// Redirect URLs in the Supabase dashboard.
  static const passwordResetRedirect = 'learnist://reset';

  final SupabaseClient _supabase;
  late final StreamSubscription<AuthState> _authSubscription;
  final _authLinkErrors = StreamController<AuthException>.broadcast();
  bool _isRecoveringPassword = false;

  bool get isSignedIn => _supabase.auth.currentSession != null;

  /// `full_name` saved in the sign-up metadata, if any.
  String? get currentUserFullName => _metadataString('full_name');

  /// `username` saved in the sign-up metadata, if any.
  String? get currentUsername => _metadataString('username');

  /// `university` saved in the sign-up metadata, if any.
  String? get currentUserUniversity => _metadataString('university');

  /// Blank values count as missing so the UI can show its fallback.
  String? _metadataString(String key) {
    final value = _supabase.auth.currentUser?.userMetadata?[key];
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }

  /// True after the user opened a password reset link, until they save a new
  /// password or cancel. The router keeps them on /update-password meanwhile.
  bool get isRecoveringPassword => _isRecoveringPassword;

  /// Failures from auth deep links, e.g. an expired or already-used reset
  /// link. supabase_flutter reports these only as auth stream errors.
  Stream<AuthException> get authLinkErrors => _authLinkErrors.stream;

  void _onAuthStateChange(AuthState state) {
    switch (state.event) {
      case AuthChangeEvent.passwordRecovery:
        _isRecoveringPassword = true;
      case AuthChangeEvent.signedOut:
        _isRecoveringPassword = false;
      default:
        break;
    }
    notifyListeners();
  }

  void _onAuthError(Object error, StackTrace stackTrace) {
    logAuthError('Auth deep link', error, stackTrace);
    if (error is AuthException) _authLinkErrors.add(error);
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) {
    return _supabase.auth.signInWithPassword(email: email, password: password);
  }

  /// Asks the `is_username_available` database function. A direct select on
  /// `profiles` can't work here: RLS hides every row from signed-out users,
  /// so it would always report the name as free.
  ///
  /// Network errors propagate. If the function itself fails (for example it
  /// isn't deployed yet) this returns false and lets sign-up continue — the
  /// unique constraint still rejects duplicates.
  Future<bool> isUsernameTaken(String username) async {
    try {
      final available = await _supabase.rpc<bool>(
        'is_username_available',
        params: {'p_username': username},
      );
      return !available;
    } on PostgrestException catch (error, stackTrace) {
      logAuthError('Username pre-check', error, stackTrace);
      return false;
    }
  }

  /// Profile fields go in `data`; the `handle_new_user` trigger copies them
  /// into `public.profiles`. A null session in the response means the project
  /// requires email confirmation before the first sign-in.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
    required String university,
  }) {
    return _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'username': username,
        'university': university,
      },
    );
  }

  /// Supabase reports success even for unknown emails, so the UI can't be
  /// used to discover which addresses have accounts.
  Future<void> sendPasswordResetEmail(String email) {
    return _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: passwordResetRedirect,
    );
  }

  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    _isRecoveringPassword = false;
    notifyListeners();
  }

  /// Ends the temporary session the reset link created.
  Future<void> cancelPasswordRecovery() async {
    _isRecoveringPassword = false;
    await signOut();
  }

  Future<void> signOut() => _supabase.auth.signOut();

  /// Saves the editable profile fields to `public.profiles`, then mirrors
  /// them into the auth metadata the UI reads from.
  ///
  /// RLS turns an update of someone else's (or a missing) row into a silent
  /// no-op, so the updated row is selected back and an empty result throws
  /// [ProfileNotFoundException].
  Future<void> updateProfile({
    required String fullName,
    required String username,
    required String university,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw AuthSessionMissingException();

    final values = {
      'full_name': fullName,
      'username': username,
      'university': university,
    };
    final updated = await _supabase
        .from('profiles')
        .update(values)
        .eq('id', user.id)
        .select('id');
    if (updated.isEmpty) throw const ProfileNotFoundException();

    await _supabase.auth.updateUser(UserAttributes(data: values));
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _authLinkErrors.close();
    super.dispose();
  }
}

/// The signed-in user has no `profiles` row, or RLS hid it.
class ProfileNotFoundException implements Exception {
  const ProfileNotFoundException();
}

const usernameTakenMessage =
    "Bu foydalanuvchi nomi allaqachon band. Iltimos, boshqa nom tanlang.";
const passwordResetSentMessage =
    "Parolni tiklash havolasi pochtangizga yuborildi.";
const passwordUpdatedMessage = "Parolingiz muvaffaqiyatli yangilandi.";
const _networkMessage =
    "Internet aloqasi yo'q. Tarmoqni tekshirib, qayta urinib ko'ring.";
const _serverMessage =
    "Serverda xatolik yuz berdi. Birozdan so'ng qayta urinib ko'ring.";
const _genericMessage = "Nimadir xato ketdi. Iltimos, qayta urinib ko'ring.";

const _expiredLinkCodes = {
  'otp_expired',
  'flow_state_expired',
  'flow_state_not_found',
};

/// True only when the request never got a response from the server.
///
/// `package:http` wraps socket failures in [ClientException]. gotrue reuses
/// [AuthRetryableFetchException] for 5xx responses too, so only one without a
/// status code is a real connectivity failure.
bool isNetworkError(Object error) =>
    error is ClientException ||
    error is TimeoutException ||
    (error is AuthRetryableFetchException && error.statusCode == null);

/// User-facing Uzbek message for any auth failure.
String authErrorMessage(Object error) {
  if (isNetworkError(error)) return _networkMessage;
  if (error is AuthException) return _authExceptionMessage(error);
  return _genericMessage;
}

const profileUsernameTakenMessage = "Bu foydalanuvchi nomi band.";

/// User-facing Uzbek message for a failed profile update.
String profileUpdateErrorMessage(Object error) {
  if (isNetworkError(error)) return _networkMessage;
  if (error is ProfileNotFoundException) {
    return "Profilingiz topilmadi. Tizimdan chiqib, qayta kiring.";
  }
  if (error is PostgrestException) {
    return switch (error.code) {
      // unique_violation: someone took the username after our pre-check.
      '23505' => profileUsernameTakenMessage,
      // insufficient_privilege, or an RLS policy rejected the row.
      '42501' => "Profilni o'zgartirishga ruxsat yo'q.",
      _ => _serverMessage,
    };
  }
  if (error is AuthException) return _authExceptionMessage(error);
  return _genericMessage;
}

String _authExceptionMessage(AuthException error) {
  // A failing handle_new_user trigger returns HTTP 500 with this text. With
  // the pre-check in place, the only realistic cause is another user taking
  // the same username between the check and the sign-up.
  if (error.message.contains('Database error saving new user')) {
    return usernameTakenMessage;
  }
  if (error is AuthRetryableFetchException) return _serverMessage;

  // PKCE: the link was opened on a different device (or after reinstalling),
  // so the locally stored code verifier is missing.
  if (error is AuthPKCEGrantCodeExchangeError ||
      error.code == 'bad_code_verifier') {
    return "Havolani parolni tiklashni so'ragan qurilmada oching.";
  }
  // Errors carried in a redirect URL put `error_code` into statusCode.
  if (_expiredLinkCodes.contains(error.code) ||
      _expiredLinkCodes.contains(error.statusCode)) {
    return "Havola eskirgan yoki allaqachon ishlatilgan. "
        "Iltimos, yangi havola so'rang.";
  }

  return switch (error.code) {
    'email_exists' || 'user_already_exists' =>
      "Bu email bilan allaqachon ro'yxatdan o'tilgan. Tizimga kiring.",
    'invalid_credentials' => "Email yoki parol noto'g'ri.",
    'email_not_confirmed' =>
      "Emailingiz hali tasdiqlanmagan. Pochtangizdagi havolani bosing.",
    'weak_password' =>
      "Parol juda oddiy. Kamida 6 ta belgidan iborat kuchliroq parol kiriting.",
    'same_password' => "Yangi parol eskisidan farq qilishi kerak.",
    'session_not_found' || 'session_expired' || 'reauthentication_needed' =>
      "Sessiya muddati tugagan. Iltimos, yangi tiklash havolasini so'rang.",
    'email_address_invalid' || 'validation_failed' =>
      "Email manzili noto'g'ri kiritilgan.",
    'over_email_send_rate_limit' || 'over_request_rate_limit' =>
      "Juda ko'p urinish bo'ldi. Birozdan so'ng qayta urinib ko'ring.",
    'signup_disabled' => "Ro'yxatdan o'tish hozircha o'chirilgan.",
    _ => _genericMessage,
  };
}

/// Prints the raw error in debug builds so friendly messages never hide it.
void logAuthError(String action, Object error, StackTrace stackTrace) {
  if (!kDebugMode) return;
  debugPrint('[Auth] $action failed: ${error.runtimeType}: $error');
  debugPrintStack(stackTrace: stackTrace, maxFrames: 8);
}
