import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_without_getx/data/service/network_caller.dart';
import 'package:task_manager_without_getx/data/urls.dart';
import 'package:task_manager_without_getx/ui/screens/change_password_screen.dart';
import 'package:task_manager_without_getx/ui/screens/sign_in_screen.dart';
import 'package:task_manager_without_getx/ui/widgets/centered_circular_progress_indicator.dart';
import 'package:task_manager_without_getx/ui/widgets/screen_background.dart';
import 'package:task_manager_without_getx/ui/widgets/snack_bar_message.dart';

class PinVerificationScreen extends StatefulWidget {
  const PinVerificationScreen({super.key});

  static const String name = '/pin-verification';

  @override
  State<PinVerificationScreen> createState() =>
      _PinVerificationScreenState();
}

class _PinVerificationScreenState extends State<PinVerificationScreen> {
  final TextEditingController _otpTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _otpVerifyLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  Text(
                    'Pin Verification',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A 6 digits OTP has been sent to your email address',
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(
                        color: Colors.grey
                    ),
                  ),
                  const SizedBox(height: 24),
                  PinCodeTextField(
                    length: 6,
                    animationType: AnimationType.fade,
                    keyboardType: TextInputType.number,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 50,
                      fieldWidth: 50,
                      activeFillColor: Colors.white,
                      selectedColor: Colors.green,
                      inactiveColor: Colors.grey
                    ),
                    animationDuration: Duration(milliseconds: 300),
                    backgroundColor: Colors.transparent,
                    controller: _otpTEController,
                    appContext: context,
                  ),
                  const SizedBox(height: 16),
                  Visibility(
                    visible: _otpVerifyLoading == false,
                    replacement: CenteredCircularProgressIndicator(),
                    child: ElevatedButton(
                      onPressed: _onTapSubmitButton,
                      child: Text('Verify'),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Have an account? ",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: 0.4,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = _onTapSignInButton,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTapSubmitButton() {
    // if (_formKey.currentState!.validate()) {
    //   // TODO: Sign in with API
    // }
    if (_formKey.currentState!.validate()) {
      _verifyOtp();
    }

  }

  Future<void> _verifyOtp() async {
    _otpVerifyLoading = true;
    setState(() {});

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? Email = sharedPreferences.getString('email') ?? '';

    NetworkResponse response = await NetworkCaller.getRequest(
        url: Urls.verifyOtpUrl(Email,_otpTEController.text.trim())
    );

    if (response.isSuccess) {
      await sharedPreferences.setString('otp', _otpTEController.text.trim());
      showSnackBarMessage(context, "Your otp has been successfully verified");
      Navigator.pushNamed(context, ChangePasswordScreen.name);
    } else {
      _otpVerifyLoading = false;
      setState(() {});
      showSnackBarMessage(context, response.errorMessage!);
    }
  }

  void _onTapSignInButton() {
    Navigator.pushNamedAndRemoveUntil(
        context, SignInScreen.name, (predicate) => false);
  }

  @override
  void dispose() {
    _otpTEController.dispose();
    super.dispose();
  }
}
