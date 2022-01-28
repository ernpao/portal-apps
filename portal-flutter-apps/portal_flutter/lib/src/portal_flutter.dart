import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glider_portal/glider_portal.dart';
import 'package:hover/hover.dart';

import 'chat/chat.dart';
import 'feed/feed.dart';
import 'portal_flutter_body.dart';
import 'profile/profile.dart';
import 'state/state.dart';

class PortalFlutter extends StatelessWidget {
  PortalFlutter({Key? key}) : super(key: key);

  /// State management model for authentication
  final portalAuthFlow = PortalAuthFlow();
  final chatEngineAuthFlow = ChatEngineAuthFlow();

  final navigationState = NavigationState(
    initialContentIndex: 0,
    items: [
      NavigationItem(
        icon: FontAwesomeIcons.solidComment,
        name: "Chat",
        content: const ChatEngineChatPage(),
        showHeader: false,
      ),
      NavigationItem(
        icon: FontAwesomeIcons.solidUser,
        name: "Profile",
        content: const ProfilePage(),
      ),
      NavigationItem(
        icon: FontAwesomeIcons.thLarge,
        name: "Feed",
        content: const FeedPage(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Application(
      providers: [
        ChangeNotifierProvider<AuthState>.value(value: chatEngineAuthFlow),
        ChangeNotifierProvider<NavigationState>.value(value: navigationState),
      ],
      theme: HoverThemeData.light.data,
      child: AuthStateConsumer(
        builder: (context, authState) {
          switch (authState.currentState) {
            case AuthenticationFlowState.LOGGED_IN:
              return const PortalFlutterBody();
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
    return AuthStateConsumer(
      builder: (context, authState) {
        return Scaffold(
          body: !authState.awaitingResponse
              ? Center(
                  child: SingleChildScrollView(
                    controller: ScrollController(),
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
    return AuthStateConsumer(
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
    return AuthStateConsumer(
      builder: (context, authState) {
        return Scaffold(
          body: !authState.awaitingResponse
              ? Center(
                  child: SingleChildScrollView(
                    controller: ScrollController(),
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
    return AuthStateConsumer(
      builder: (context, authState) {
        return Scaffold(
          body: !authState.awaitingResponse
              ? Center(
                  child: SingleChildScrollView(
                    controller: ScrollController(),
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
