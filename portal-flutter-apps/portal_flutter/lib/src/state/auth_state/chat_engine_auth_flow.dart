import 'package:glider_portal/glider_portal.dart';

import 'auth_state.dart';

class ChatEngineAuthFlow extends AuthStateBase<ChatEngineUser> {
  ChatEngineAuthFlow() : super(authInterface: ChatEnginePrivateAPI());

  @override
  ChatEngineUser createAuthenticatedUser(
    JSON responseBody,
    String secret,
  ) {
    return ChatEngineUser(responseBody, secret);
  }

  @override
  ChatEngineUser loadStoredUser(String encodedUserData, String secret) {
    final json = JSON.parse(encodedUserData);
    return ChatEngineUser(json, secret);
  }

  @override
  String encodeUserForStorage(ChatEngineUser user) => user.data.encode();

  @override
  String createErrorMessageOnFailedAuth(WebResponse failedLoginResponse) {
    final jsonBody = (failedLoginResponse.bodyAsJson())!;
    final detail = jsonBody.getProperty<String>("detail");
    final message = jsonBody.getProperty<String>("message");
    return (detail != null)
        ? detail
        : message ?? "Can't authenticate with the credentials provided.";
  }

  @override
  String exceptionToErrorMessageString(Object error) {
    return error.toString();
  }
}
