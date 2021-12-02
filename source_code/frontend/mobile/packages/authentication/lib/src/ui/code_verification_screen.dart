import 'dart:async';

import 'package:authentication/authentication.dart';
import 'package:authentication/src/api/phone_number_verifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class CodeVerificationScreen extends StatefulWidget {
  static const verificationStates = {
    _VerificationState("assets/images/enter_verification_code.svg",
        Colors.black, Color(0xFFF3F3F3)),
    _VerificationState("assets/images/valid_verification_code.svg",
        Color(0xFF2BC25F), Color(0x1F2BC25F)),
    _VerificationState("assets/images/invalid_verification_code.svg",
        Color(0xFFFE1917), Color(0x1FF3F3F3)),
  };
  final PhoneNumberVerifier phoneNumberVerifier;

  const CodeVerificationScreen(this.phoneNumberVerifier, {Key? key})
      : super(key: key);

  @override
  _CodeVerificationScreenState createState() => _CodeVerificationScreenState();
}

class _VerificationState {
  final String imageUrl;
  final Color codeFieldTextColor;
  final Color codeFieldBackgroundColor;

  const _VerificationState(
    this.imageUrl,
    this.codeFieldTextColor,
    this.codeFieldBackgroundColor,
  );
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen> {
  bool isContinueButtonEnabled = false;
  bool isVerifyingCode = false;
  _VerificationState verificationState =
      CodeVerificationScreen.verificationStates.first;
  String code = "";
  int resendCodeCountDown = 0;

  StreamSubscription? verificationStateStreamSubscription;

  @override
  void initState() {
    super.initState();
    verificationStateStreamSubscription =
        widget.phoneNumberVerifier.verificationStateChanges.listen((event) {
      if (isVerifyingCode) {
        setState(() => isVerifyingCode = false);
      }
      if (event == PhoneNumberVerificationState.completed) {
        setState(() => verificationState =
            CodeVerificationScreen.verificationStates.elementAt(1));
      } else if (event == PhoneNumberVerificationState.failed) {
        if (widget.phoneNumberVerifier.exception?.exceptionType ==
            AuthenticationExceptionType.invalidVerificationCode) {
          setState(() => verificationState =
              CodeVerificationScreen.verificationStates.last);
        } else {
          // TODO handle
        }
      }
    });
    widget.phoneNumberVerifier.resendCodeCounter?.currentValueStream
        .listen((event) => setState(() => resendCodeCountDown = event));
  }

  @override
  void deactivate() {
    verificationStateStreamSubscription?.pause();
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    verificationStateStreamSubscription?.resume();
  }

  @override
  void dispose() {
    verificationStateStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(verificationState.imageUrl,
                      package: "authentication"),
                  const SizedBox(height: 25),
                  Text(
                    "Enter Verification Code",
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Input the 6-digit code that we have sent to ${widget.phoneNumberVerifier.currentPhoneNumber}",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 39),
                  SizedBox(
                    child: PinCodeTextField(
                        showCursor: false,
                        keyboardType: TextInputType.number,
                        pinTheme: PinTheme(
                          fieldHeight: 43,
                          fieldWidth: 43,
                          inactiveColor: verificationState.codeFieldTextColor,
                          activeColor: verificationState.codeFieldTextColor,
                          borderWidth: 0.6,
                          inactiveFillColor:
                              verificationState.codeFieldBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                          selectedColor: theme.primaryColor,
                          shape: PinCodeFieldShape.box,
                        ),
                        appContext: context,
                        length: 6,
                        onChanged: (newValue) {
                          if (newValue.length >= 6) {
                            code = newValue;
                            setState(() => isContinueButtonEnabled = true);
                          } else if (isContinueButtonEnabled) {
                            setState(() => isContinueButtonEnabled = false);
                          }
                        }),
                  ),
                  const SizedBox(height: 30),
                  RoundedCornerButton(
                    onPressed: isContinueButtonEnabled ? _verifyCode : null,
                  ),
                  Text(
                    "00:${resendCodeCountDown.toStringAsFixed(2)}",
                    style: TextStyle(color: theme.errorColor),
                  ),
                  const Text(
                    "Haven’t received the code yet?",
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: resendCodeCountDown == 0 ? () {} : null,
                    child: const Text(
                      "Resend Code",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
            ),
            if (isVerifyingCode) ...[
              Container(
                color: const Color(0x70000000),
              ),
              Align(
                alignment: Alignment.center,
                child: Wrap(
                  // width: min(screenWidth * 0.75, 350),
                  // height: 350,
                  children: [
                    Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 25),
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                                color: theme.primaryColor),
                            const SizedBox(height: 30),
                            const Text("Verifying the code")
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ],
        ),
      ),
    );
  }

  void _verifyCode() {
    setState(() {
      isVerifyingCode = true;
    });
    // verify
  }
}
