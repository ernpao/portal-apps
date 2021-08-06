import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:glider_portal/glider_portal.dart';
import 'package:hover/hover.dart';

import 'app_authentication_state/app_authentication_state.dart';
import 'app_authentication_state/portal_auth_flow.dart';
import 'app_authentication_state/chat_engine_auth_flow.dart';
import 'app_body.dart';

class App extends StatelessWidget {
  App({
    Key? key,
  }) : super(key: key);

  /// State management model for authentication
  final portalAuthFlow = PortalAuthFlow();
  final chatEngineAuthFlow = ChatEngineAuthFlow();

  @override
  Widget build(BuildContext context) {
    return Application(
      providers: [
        ChangeNotifierProvider<AppAuthenticationState>.value(
          value: chatEngineAuthFlow,
        ),
      ],
      theme: HoverThemeData.light.data,
      child: AppAuthenticationStateConsumer(
        builder: (context, authState) {
          switch (authState.currentState) {
            case AuthenticationFlowState.LOGGED_IN:
              return AppBody(authState: authState);
            case AuthenticationFlowState.LOGGED_OUT:
              return const _LoginPage();
            case AuthenticationFlowState.SIGNING_UP:
              return const _SignUpPage();
            case AuthenticationFlowState.AWAITING_VERIFICATION:
              return const _AwaitingVerificationPage();
            default:
              return const Text("Invalid State");
          }
        },
      ),
    );
  }
}

class _AwaitingVerificationPage extends StatelessWidget {
  const _AwaitingVerificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppAuthenticationStateConsumer(
      builder: (context, authState) {
        return Scaffold(
          body: !authState.awaitingResponse
              ? Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _ErrorMessage(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HoverHeading(
                              "You Have Successfully Signed Up!",
                              bottomPadding: 16,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                            ),
                            HoverText(
                              "Please verify your registration by clicking on the link on the \nemail we have sent to your email address.",
                              textAlign: TextAlign.center,
                              lineHeight: 1.5,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        HoverLinkText(
                          "Login With Your Account",
                          onTap: authState.resetFlow,
                        ),
                      ],
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppAuthenticationStateConsumer(
      builder: (context, authState) {
        if (authState.hasError) {
          return HoverText(
            authState.errorMessage!,
            color: Theme.of(context).errorColor,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _LoginPage extends StatelessWidget {
  const _LoginPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppAuthenticationStateConsumer(
      builder: (context, authState) {
        return Scaffold(
          body: !authState.awaitingResponse
              ? Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _ErrorMessage(),
                        HoverEmailLoginForm(
                          onSubmit: authState.logIn,
                          emailController: _loginEmailController,
                          passwordController: _loginPasswordController,
                        ),
                        HoverLinkText(
                          "Create An Account",
                          onTap: authState.startSignUp,
                        ),
                      ],
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class _SignUpPage extends StatelessWidget {
  const _SignUpPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppAuthenticationStateConsumer(
      builder: (context, authState) {
        return Scaffold(
          body: !authState.awaitingResponse
              ? Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _ErrorMessage(),
                        HoverEmailSignUpForm(
                          onSubmit: authState.signUpWithEmail,
                          emailController: _signUpEmailController,
                          passwordController: _signUpPasswordController,
                          passwordConfirmationController:
                              _signUpPasswordConfirmationController,
                        ),
                        HoverLinkText(
                          "Log In With Existing Account",
                          onTap: authState.cancelSignUp,
                        ),
                      ],
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

/// Text field controllers for login and sign up forms

final _loginEmailController = TextEditingController();
final _loginPasswordController = TextEditingController();
final _signUpEmailController = TextEditingController();
final _signUpPasswordController = TextEditingController();
final _signUpPasswordConfirmationController = TextEditingController();
