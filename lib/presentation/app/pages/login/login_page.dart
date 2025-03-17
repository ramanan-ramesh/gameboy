import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/app/models/app_data_modifier.dart';
import 'package:gameboy/presentation/app/blocs/authentication/auth_bloc.dart';
import 'package:gameboy/presentation/app/blocs/authentication/auth_events.dart';
import 'package:gameboy/presentation/app/blocs/authentication/auth_states.dart';
import 'package:gameboy/presentation/app/blocs/bloc_extensions.dart';
import 'package:gameboy/presentation/app/blocs/master_page/master_page_events.dart';
import 'package:gameboy/presentation/app/extensions.dart';
import 'package:gameboy/presentation/app/pages/login/username_edit_field.dart';

import 'form_submitter_button.dart';
import 'password_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late AuthenticationBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthenticationBloc(
        (context.getAppData() as AppDataModifier).googleWebClientId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationBloc>(
      create: (context) => _authBloc,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _LoginPageForm(),
          ),
        ),
      ),
    );
  }
}

class _LoginPageForm extends StatefulWidget {
  const _LoginPageForm({super.key});

  @override
  State<_LoginPageForm> createState() => _LoginPageFormState();
}

class _LoginPageFormState extends State<_LoginPageForm>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  TabController? _tabController;
  static const String _googleLogoAsset = 'assets/logos/google.webp';
  static const double _roundedCornerRadius = 25.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(_roundedCornerRadius)),
      ),
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _createTabBar(),
            const SizedBox(height: 16.0),
            FocusTraversalOrder(
              order: NumericFocusOrder(1),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildUserNamePasswordForm(),
              ),
            ),
            const SizedBox(height: 24.0),
            FocusTraversalOrder(
              order: NumericFocusOrder(2),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200, minWidth: 150),
                child: _buildSubmitButton(context),
              ),
            ),
            const SizedBox(height: 24.0),
            _buildAlternateLoginMethods(context),
          ],
        ),
      ),
    );
  }

  StatefulWidget _buildSubmitButton(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      builder: (BuildContext context, AuthenticationState state) {
        var isSubmitted = false;
        if (state is AuthenticationFailure) {
          isSubmitted = false;
        } else if (state is Authenticating) {
          isSubmitted = true;
        }
        return LoginFormSubmitterButton(
          icon: Icons.login_rounded,
          isSubmitted: isSubmitted,
          context: context,
          formState: _formKey,
          isEnabledInitially: true,
          validationSuccessCallback: () {
            String username = _usernameController.text;
            String password = _passwordController.text;

            context.addAuthenticationEvent(AuthenticateWithUsernamePassword(
                userName: username,
                passWord: password,
                isLogin: _tabController!.index == 0));
          },
        );
      },
      listener: (BuildContext context, AuthenticationState state) {
        if (state is AuthenticationSuccess) {
          context.addMasterPageEvent(
              ChangeUser.signIn(authProviderUser: state.authProviderUser));
        }
      },
    );
  }

  Column _buildAlternateLoginMethods(BuildContext context) {
    return Column(
      children: [
        Text(
          'Sign in with',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGoogleLoginProviderButton(context),
          ],
        ),
      ],
    );
  }

  Widget _buildGoogleLoginProviderButton(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: InkWell(
        splashColor: Colors.white30,
        onTap: () {
          context.addAuthenticationEvent(AuthenticateWithGoogle());
        },
        child: Ink.image(
          image: AssetImage(_googleLogoAsset),
          fit: BoxFit.cover,
          height: 60,
          width: 60,
        ),
      ),
    );
  }

  Widget _createTabBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_roundedCornerRadius),
      clipBehavior: Clip.hardEdge,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_roundedCornerRadius),
          border: Border.all(color: Colors.green),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Theme.of(context).tabBarTheme.indicatorColor,
            borderRadius: BorderRadius.circular(_roundedCornerRadius),
          ),
          tabs: [
            Tab(text: 'Login'),
            Tab(text: 'Register'),
          ],
        ),
      ),
    );
  }

  Widget _buildUserNamePasswordForm() {
    return Form(
      key: _formKey,
      child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        builder: (BuildContext context, AuthenticationState state) {
          return FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Column(
              children: [
                FocusTraversalOrder(
                  order: NumericFocusOrder(1),
                  child: _createUserNameField(state),
                ),
                const SizedBox(height: 16.0),
                FocusTraversalOrder(
                  order: NumericFocusOrder(2),
                  child: _createPasswordField(state),
                )
              ],
            ),
          );
        },
        listener: (BuildContext context, AuthenticationState state) {},
      ),
    );
  }

  Widget _createPasswordField(AuthenticationState authState) {
    String? errorText;
    if (authState is AuthenticationFailure) {
      if (authState.failureReason == AuthenticationFailures.wrongPassword) {
        errorText = 'Wrong password entered';
      }
    }
    return PasswordField(
      controller: _passwordController,
      textInputAction: TextInputAction.done,
      labelText: 'Password',
      errorText: errorText,
      validator: (password) {
        if (password != null) {
          if (password.length <= 6) {
            return 'Password is too short';
          }
        }
        return null;
      },
    );
  }

  Widget _createUserNameField(AuthenticationState authState) {
    String? errorText;
    if (authState is AuthenticationFailure) {
      if (authState.failureReason ==
          AuthenticationFailures.usernameAlreadyExists) {
        errorText =
            'This username is already registered. You can login with it instead';
      } else if (authState.failureReason ==
          AuthenticationFailures.noSuchUsernameExists) {
        errorText = 'No such username exists. You can register with it instead';
      }
    }
    return UsernameEditField(
      textInputAction: TextInputAction.next,
      controller: _usernameController,
      inputDecoration: InputDecoration(
        icon: const Icon(Icons.person_2_rounded),
        labelText: 'UserName',
        errorText: errorText,
      ),
    );
  }
}
