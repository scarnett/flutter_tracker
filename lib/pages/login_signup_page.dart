import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:logger/logger.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/auth.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/model/message.dart';
import 'package:flutter_tracker/services/authentication.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/app_utils.dart';
import 'package:flutter_tracker/utils/message_utils.dart';
import 'package:flutter_tracker/utils/shadow_utils.dart';
import 'package:flutter_tracker/validators/common_validators.dart';
import 'package:flutter_tracker/widgets/backdrop.dart';
import 'package:flutter_tracker/widgets/wavy_background.dart';

class LoginSignUpPage extends StatefulWidget {
  final BaseAuthService authService;
  final Function(String, String) onSignedIn;
  final VoidCallback onVerify;

  LoginSignUpPage({
    Key key,
    this.authService,
    this.onSignedIn,
    this.onVerify,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginSignUpPageState();
}

enum FormMode {
  LOGIN,
  SIGNUP,
  VERIFY,
  FORGOT_PASSWORD,
}

class _LoginSignUpPageState extends State<LoginSignUpPage>
    with TickerProviderStateMixin {
  AnimationController _backdropAnimationController;
  final _formKey = GlobalKey<FormState>();

  String _name;
  String _email;
  String _password;

  // Initial form is signup
  FormMode _formMode = FormMode.SIGNUP;
  bool _isLoading;

  Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    _isLoading = false;

    setState(() {
      _backdropAnimationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 350),
      );
    });

    _checkUser();
  }

  @override
  void dispose() {
    _backdropAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) {
        _listenUser();

        return WillPopScope(
          onWillPop: () => _willPop(viewModel),
          child: Scaffold(
            resizeToAvoidBottomPadding: true,
            body: _buildBody(context),
          ),
        );
      },
    );
  }

  Future<bool> _willPop(
    GroupsViewModel viewModel,
  ) {
    return Future.value(true);
  }

  Widget _buildBody(
    BuildContext context,
  ) {
    List<Widget> items = []..addAll(
        PresetWaves().showVerticalWaves(
          waves: PresetWaves().defaultWaves(),
        ),
      );

    items
      ..add(_showBody(context))
      ..add(_showBack())
      ..add(showLoadingBackdrop(
        _backdropAnimationController,
        condition: _isLoading,
      ));

    return Stack(
      children: items,
    );
  }

  void _checkUser() {
    widget.authService.getCurrentUser().then((user) async {
      final store = StoreProvider.of<AppState>(context);

      if (user == null) {
        store.dispatch(SetAuthStatusAction(AuthStatus.NOT_LOGGED_IN));
      } else {
        if (!user.isEmailVerified && (_formMode != FormMode.VERIFY)) {
          _formMode = FormMode.VERIFY;
        } else {
          if (user.isEmailVerified) {
            widget.onVerify();
          } else {
            user.reload(); // Reload the firebase user. Without this, the 'isEmailVerified' will always return false even of the user verified
          }

          store.dispatch(SetAuthStatusAction((user.isEmailVerified)
              ? AuthStatus.LOGGED_IN
              : AuthStatus.NEEDS_ACCOUNT_VERIFICATION));
        }
      }
    });
  }

  void _listenUser() async {
    if (_formMode == FormMode.VERIFY) {
      widget.authService.getCurrentUser().then((user) async {
        if (user != null) {
          // TODO: can this be slowed down?

          if (user.isEmailVerified) {
            widget.onVerify();
          } else {
            user.reload(); // Reload the firebase user. Without this, the 'isEmailVerified' will always return false even if the user is verified
          }

          final store = StoreProvider.of<AppState>(context);
          store.dispatch(SetAuthStatusAction((user.isEmailVerified)
              ? AuthStatus.LOGGED_IN
              : AuthStatus.NEEDS_ACCOUNT_VERIFICATION));
        }
      });
    }
  }

  Widget _showBody(
    BuildContext context,
  ) {
    List<Widget> items = []
      ..add(buildLogo(height: 120.0))
      ..addAll(
          (_formMode == FormMode.VERIFY) ? _showVerify() : _showForms(context));

    return SafeArea(
      top: true,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Container(
              height: double.infinity,
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: items,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*
  Widget _showOnboardingButtons() {
    List<Widget> buttons = [];
    buttons..addAll([
      _showOnboradingSkipButton(),
    ]);

    return Stack(
      children: <Widget>[
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: buttons,
          ),
        ),
      ],
    );
  }
  */

  List<Widget> _showForms(
    BuildContext context,
  ) {
    List<Widget> fields = [];

    if (_isFormMode(FormMode.SIGNUP)) {
      fields..add(_showNameInput());
    }

    fields..add(_showEmailInput());

    if (_isFormMode(FormMode.FORGOT_PASSWORD)) {
      fields
        ..addAll([
          _showPrimaryButton(context),
          _showCancelButton(),
        ]);
    } else {
      fields
        ..addAll([
          _showPasswordInput(),
          _showPrimaryButton(context),
          _showSecondaryButton(),
        ]);
    }

    if (_isFormMode(FormMode.LOGIN)) {
      fields..add(_showForgotPassword());
    }

    return fields;
  }

  Widget _showBack() {
    return Positioned(
      top: 26.0,
      left: 5.0,
      child: RawMaterialButton(
        shape: CircleBorder(),
        constraints: BoxConstraints.tight(Size(40.0, 40.0)),
        onPressed: () => _tapOnboarding(),
        child: Icon(
          Icons.arrow_back,
          color: Colors.white.withAlpha(90),
          size: 26.0,
        ),
      ),
    );
  }

  Widget _showNameInput() {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: _inputField(
        'Name',
        Icons.person,
        onSaved: (value) => (_name = value),
        isRequired: false,
        textCapitalization: TextCapitalization.words,
        validator: (value) => CommonValidators.validateName(value),
      ),
    );
  }

  Widget _showEmailInput() {
    double topPadding = _isFormMode(FormMode.SIGNUP) ? 15.0 : 0.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, topPadding, 0.0, 0.0),
      child: _inputField(
        'Email',
        Icons.email,
        onSaved: (value) => (_email = value),
        validator: (value) => CommonValidators.validateEmail(value),
      ),
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: _inputField(
        'Password',
        Icons.lock,
        obscureText: true,
        onSaved: (value) => (_password = value),
        validator: (value) => CommonValidators.validatePassword(value),
      ),
    );
  }

  Widget _inputField(
    String text,
    IconData icon, {
    Color color: Colors.white,
    int colorAlpha: 90,
    bool obscureText: false,
    bool isRequired: true,
    Function onSaved,
    textCapitalization: TextCapitalization.none,
    validator: Function,
  }) {
    return TextFormField(
      maxLines: 1,
      obscureText: obscureText,
      autofocus: false,
      textCapitalization: textCapitalization,
      style: TextStyle(
        color: color,
      ),
      decoration: InputDecoration(
        hintText: text,
        hintStyle: TextStyle(
          color: color.withAlpha(colorAlpha),
        ),
        icon: Icon(
          icon,
          color: color.withAlpha(colorAlpha),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: color.withAlpha(colorAlpha),
            width: 2.0,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: color.withAlpha(colorAlpha)),
        ),
      ),
      validator: validator,
      onSaved: (value) => (onSaved != null) ? onSaved(value) : null,
    );
  }

  Widget _showSecondaryButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: FlatButton(
        child: (_formMode == FormMode.LOGIN)
            ? Text(
                'Dont have an account?\nCreate one.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  shadows: commonTextShadow(),
                ),
              )
            : Text(
                'Already have an account? Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  shadows: commonTextShadow(),
                ),
              ),
        onPressed: (_formMode == FormMode.LOGIN)
            ? _changeFormToSignUp
            : _changeFormToLogin,
      ),
    );
  }

  /*
  Widget _showOnboradingSkipButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: SizedBox(
        height: 50.0,
        child: FlatButton(
          color: AppTheme.primaryAccent,
          child: Text(
            'Skip',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          onPressed: () => setState(() {
            _formMode = FormMode.LOGIN;
          }),
        ),
      ),
    );
  }
  */

  Widget _showPrimaryButton(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: RaisedButton(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          color: AppTheme.primaryAccent,
          child: (_formMode == FormMode.LOGIN)
              ? Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                )
              : (_formMode == FormMode.FORGOT_PASSWORD)
                  ? Text(
                      'Reset password',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Create account',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                    ),
          onPressed: () => _validateAndSubmit(context),
        ),
      ),
    );
  }

  Widget _showForgotPassword() {
    return FlatButton(
      child: Text(
        'Forgot your password?',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.0,
          shadows: commonTextShadow(),
        ),
      ),
      onPressed: () => _changeFormToForgotPassword(),
    );
  }

  Widget _showCancelButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: FlatButton(
        child: Text(
          'Cancel',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.0,
            shadows: commonTextShadow(),
          ),
        ),
        onPressed: () => _cancelVerify(),
      ),
    );
  }

  List<Widget> _showVerify() {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 20.0),
        child: Text(
          'A link to verify your account has been sent to your email',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Text(
          'If you did not receive an email then please tap the button below to resend',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white30,
            fontSize: 18.0,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: RaisedButton(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            color: AppTheme.primaryAccent,
            child: Text(
              'Resend verification email',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              final store = StoreProvider.of<AppState>(context);
              widget.authService.sendEmailVerification(store: store);
            },
          ),
        ),
      ),
      _showCancelButton(),
    ];
  }

  // Check if form is valid before perform login or signup
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      closeKeyboard(context);
      return true;
    }

    _isLoading = false;
    _backdropAnimationController.reverse();
    return false;
  }

  // Perform login or signup
  void _validateAndSubmit(
    BuildContext context,
  ) async {
    final store = StoreProvider.of<AppState>(context);

    setState(() {
      _isLoading = true;
      _backdropAnimationController.forward();
    });

    if (_validateAndSave()) {
      FirebaseUser user;

      try {
        if (_formMode == FormMode.LOGIN) {
          user = await widget.authService.signIn(_email, _password);
          logger.d('Signed in: $user.uid');

          setState(() {
            _isLoading = false;
            user = user;
          });
        } else if (_formMode == FormMode.FORGOT_PASSWORD) {
          final store = StoreProvider.of<AppState>(context);
          await widget.authService.resetPassword(_email, store: store);
          _changeFormToLogin();

          setState(() {
            _isLoading = false;
            user = null;
          });
        } else {
          _changeFormToVerify();

          setState(() {
            _isLoading = false;
            user = user;
          });

          store.dispatch(
              SetAuthStatusAction(AuthStatus.NEEDS_ACCOUNT_VERIFICATION));

          user = await widget.authService.signUp(
            _name,
            _email,
            _password,
            store: store,
          );

          widget.authService.sendEmailVerification(store: store);

          // Updates the name in the user record
          if (_name != null) {
            store.dispatch(UpdateFamilyDataEventAction(
              family: {
                'name': _name,
              },
              userId: user.uid,
            ));
          }

          logger.d('Signed up user: $user.uid');
        }

        if ((user != null) && (_formMode == FormMode.LOGIN)) {
          widget.onSignedIn(_email, _password);
        }
      } catch (e) {
        // logger.e('Error: $e'); // TODO: sentry?
        setState(() {
          _isLoading = false;
          _backdropAnimationController.reverse();
        });

        /*
        String _errorMessage;

        if (_isIos) {
          _errorMessage = e.details;
        } else {
          _errorMessage = e.message;
        }
        */

        buildToastMessage(Message(
          message:
              'Account not found. Please try again or contact support if this problem persists.', // _errorMessage,
          type: MessageType.ERROR,
        )).show(context);
      }
    }
  }

  void _cancelVerify() {
    _changeFormToLogin();
  }

  void _changeFormToSignUp() {
    if (_formKey.currentState != null) {
      _formKey.currentState.reset();
    }

    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _changeFormToLogin() {
    if (_formKey.currentState != null) {
      _formKey.currentState.reset();
    }

    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  void _changeFormToForgotPassword() {
    if (_formKey.currentState != null) {
      _formKey.currentState.reset();
    }

    setState(() {
      _formMode = FormMode.FORGOT_PASSWORD;
    });
  }

  void _changeFormToVerify() {
    if (_formKey.currentState != null) {
      _formKey.currentState.reset();
    }

    setState(() {
      _formMode = FormMode.VERIFY;
    });
  }

  bool _isFormMode(
    FormMode formMode,
  ) {
    if (formMode == _formMode) {
      return true;
    }

    return false;
  }

  void _tapOnboarding() {
    StoreProvider.of<AppState>(context)
        .dispatch(SetAuthStatusAction(AuthStatus.ONBOARDING));
  }
}
