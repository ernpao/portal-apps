import 'package:glider_portal/glider_portal.dart';

import 'app_authentication_state.dart';

class ChatEngineAuthFlow
    extends AppAuthenticationStateBase<ChatEngineActiveUser> {
  ChatEngineAuthFlow() : super(authInterface: ChatEngineAPI());

  @override
  ChatEngineActiveUser createAuthenticatedUser(
    JSON responseBody,
    String secret,
  ) {
    return ChatEngineActiveUser(responseBody, secret);
  }

  @override
  ChatEngineActiveUser loadStoredUser(String encodedUserData, String secret) {
    final json = JSON.parse(encodedUserData);
    return ChatEngineActiveUser(json, secret);
  }

  @override
  String encodeUserForStorage(ChatEngineActiveUser user) => user.data.encode();

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
