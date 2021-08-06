import 'package:glider_portal/glider_portal.dart';

import 'app_authentication_state.dart';

class PortalAuthFlow extends AppAuthenticationStateBase<PortalUser> {
  PortalAuthFlow() : super(authInterface: PortalAuthAPI());

  @override
  String encodeUserForStorage(PortalUser user) => user.encode();

  @override
  PortalUser createAuthenticatedUser(
    JSON responseBody,
    String secret,
  ) =>
      PortalUser.fromJson(responseBody);

  @override
  PortalUser loadStoredUser(String encodedUserData, String secret) =>
      PortalUser.parse(encodedUserData);

  @override
  String createErrorMessageOnFailedAuth(WebResponse failedLoginResponse) {
    return failedLoginResponse.bodyAsJson()!.getProperty<String>("error")!;
  }

  @override
  String exceptionToErrorMessageString(Object error) {
    return error.toString();
  }
}
