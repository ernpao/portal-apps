import 'package:flutter/widgets.dart';
import 'package:glider_portal/glider_portal.dart';
import 'package:hover/hover.dart';

/// Abstraction of the state management model for user authentication.
abstract class AppAuthenticationState<T extends AuthenticatedUser>
    extends ChangeNotifier with ActiveUser, Secret, AuthenticationFlow {
  /// Indicates if the authentication flow
  /// has encountered an error.
  bool get hasError;

  /// An error message of the last error
  /// encountered by the authentication
  /// flow.
  String? get errorMessage;

  /// Indicates if the authentication flow
  /// is currently in a state of
  /// waiting for a response
  /// from the remote host.
  bool get awaitingResponse;

  /// The interface that will be used to
  /// connect to the remote host to access
  /// its authentication functions such as
  /// login and signup.
  AuthInterface get authInterface;

  /// Convert a successful login response and secret into
  /// an [AuthenticatedUser].
  T createAuthenticatedUser(JSON responseBody, String secret);

  @protected
  String encodeUserForStorage(T user);

  @protected
  T loadStoredUser(String encodedUserData, String secret);

  String createErrorMessageOnFailedAuth(WebResponse failedLoginResponse);
}

abstract class AppAuthenticationStateBase<T extends AuthenticatedUser>
    extends AppAuthenticationState<T> {
  AppAuthenticationStateBase({
    required this.authInterface,
  }) {
    _loadUser();
  }

  @override
  final AuthInterface authInterface;

  static const _kUser = "user";
  T? _activeUser;

  static const _kSecret = "secret";
  String? _secret;

  @override
  String get secret {
    assert(
      _secret != null,
      "The secret for this auth flow has not yet been initialized!",
    );
    return _secret!;
  }

  @override
  T? get activeUser => _activeUser;

  void _loadUser() async {
    final _storedEncodedUser = await Hover.loadSetting(_kUser);
    final _storedSecret = await Hover.loadSetting(_kSecret);
    if (_storedEncodedUser != null) {
      if (_storedEncodedUser.isNotEmpty) {
        assert(_storedSecret != null && _storedSecret.isNotEmpty);
        _activeUser = loadStoredUser(_storedEncodedUser, _storedSecret!);
        setState(AuthenticationFlowState.LOGGED_IN);
      }
    }
  }

  @override
  String? get errorMessage => _errorMessage;

  String? _errorMessage;

  @override
  bool get hasError => _errorMessage != null;

  void _getErrorFromResponse(WebResponse response) {
    assert(response.isNotSuccessful);
    _errorMessage = createErrorMessageOnFailedAuth(response);
  }

  void _clearError() => _errorMessage = null;

  bool _awaitingResponse = false;

  @override
  bool get awaitingResponse => _awaitingResponse;

  /// Set the `_awaitingResponse` flag to true and call `notifyListeners`.
  void _setAwait() {
    _awaitingResponse = true;
    notifyListeners();
  }

  /// Set the `_awaitingResponse` flag to false and call `notifyListeners`.
  void _clearAwait() {
    _awaitingResponse = false;
    notifyListeners();
  }

  @override
  Future<bool> processCredentials(String username, String password) async {
    _clearError();
    _setAwait();

    final loginResult = await authInterface.logIn(username, password);

    if (loginResult.isSuccessful) {
      _setAuthenticatedUser(loginResult, password);
    } else {
      _getErrorFromResponse(loginResult);
    }

    return loginResult.isSuccessful;
  }

  void _setAuthenticatedUser(WebResponse webResponse, String secret) async {
    _secret = secret;
    _activeUser = createAuthenticatedUser(webResponse.bodyAsJson()!, _secret!);
    assert(_secret != null);
    assert(_activeUser != null);
    await Hover.saveSetting(_kSecret, _secret!);
    await Hover.saveSetting(_kUser, encodeUserForStorage(_activeUser!));
  }

  @override
  Future<bool> processLogOut() async {
    _activeUser = null;
    _secret = null;
    await Hover.saveSetting(_kUser, "");
    await Hover.saveSetting(_kSecret, "");
    return true;
  }

  @override
  void onCancelOtpFail() {
    // No OTP so do nothing.
  }

  @override
  Future<bool> processOtpCancellation() async {
    // No OTP so just return true.
    return true;
  }

  @override
  Future<bool> validateOtp(String otp) async {
    // No OTP so just return true.
    return true;
  }

  @override
  bool get otpRequired => false;

  @override
  Future<bool> processSignUp(String username, String password) async {
    _clearError();
    _setAwait();
    final signUpResult = await authInterface.signUp(username, password);
    if (signUpResult.isNotSuccessful) {
      _getErrorFromResponse(signUpResult);
    }
    // else {
    // _setAuthenticatedUser(signUpResult, password);
    // }
    return signUpResult.isSuccessful;
  }

  @override
  void onCancelOtpSuccess() {
    // No OTP so do nothing.
  }

  @override
  void onSignUpCancelled() {
    _clearError();
    notifyListeners();
  }

  @override
  void onFailureToLogin() {
    _clearAwait();
  }

  @override
  void onSuccessfulLogin() async {
    _clearAwait();
  }

  @override
  void onFailureToLogout() {
    _clearAwait();
  }

  @override
  void onSuccessfulLogout() {
    _clearAwait();
  }

  @override
  void onFailureToSignUp() {
    _clearAwait();
  }

  @override
  void onSuccessfulSignUp() {
    _clearAwait();
  }

  @override
  void onSignUpTriggered() {
    _clearError();
    notifyListeners();
  }

  @override
  void onFailureToValidateOtp() {
    // No OTP so do nothing.
  }

  @override
  void onSuccessfulOtpValidation() {
    // No OTP so do nothing.
  }

  @override
  void onCancelOtpException(Object error) {
    // No OTP so do nothing.
  }

  @override
  void loginExceptionHandler(Object error) {
    _errorMessage = exceptionToErrorMessageString(error);
    _clearAwait();
  }

  @override
  void onLogoutException(Object error) {
    _errorMessage = exceptionToErrorMessageString(error);
    _clearAwait();
  }

  @override
  void signUpExceptionHandler(Object error) {
    _errorMessage = exceptionToErrorMessageString(error);
    _clearAwait();
  }

  @override
  void otpValidationExceptionHandler(Object error) {
    // No OTP so do nothing.
  }

  @override
  void onStateUpdated(AuthenticationFlowState newState) => notifyListeners();

  String exceptionToErrorMessageString(Object error);
}

class AppAuthenticationStateConsumer extends StatelessWidget {
  const AppAuthenticationStateConsumer({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final Widget Function(
    BuildContext context,
    AppAuthenticationState authState,
  ) builder;

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AppAuthenticationState>(context);
    return builder(context, authState);
  }
}
