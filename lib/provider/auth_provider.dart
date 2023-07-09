import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_proj1/keys.dart';
import 'package:firebase_proj1/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  //basically a provider
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  AuthType _authType = AuthType.signIn;

  AuthType get authType => _authType;

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore
      .instance; //creating instance of firestore which is used to store and instance of  firebaseauth too
  setAuthType() {
    _authType =
        _authType == AuthType.signIn ? AuthType.signUp : AuthType.signIn;

    notifyListeners();
  }

  authenticate() async {
    UserCredential userCredential;
    try {
      if (_authType == AuthType.signUp) {
        userCredential = await firebaseAuth.createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);

        await userCredential.user!.sendEmailVerification();

        await firebaseFirestore
            .collection("users")
            .doc(userCredential.user!.uid)
            .set({
          "email": userCredential.user!.email,
          "uid": userCredential.user!.uid,
          "user_name": userNameController.text,
        });
      }
      if (_authType == AuthType.signIn) {
        userCredential = await firebaseAuth.signInWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);
      }
    } on FirebaseAuthException catch (error) {
      Keys.scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
        content: Text(
          error.code,
        ),
        backgroundColor: Colors.red,
      ));
    } catch (error) {
      Keys.scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
        content: Text(
          error.toString(),
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  bool? emailVerified;
  updateEmailVerificationState() async {
    emailVerified = firebaseAuth.currentUser!.emailVerified;
    if (!emailVerified!) {
      Timer.periodic(const Duration(seconds: 3), (timer) async {
        await firebaseAuth.currentUser!.reload();
        final user = FirebaseAuth.instance.currentUser;
        if (user!.emailVerified) {
          emailVerified = user.emailVerified;
          timer.cancel();
          notifyListeners();
        }
      });
    }
  }

  TextEditingController resetEmailController = TextEditingController();
  resetPassword(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text("Enter your email"),
            content: CustomTextField(
                controller: resetEmailController,
                iconData: Icons.email,
                hintText: "Enter email"),
            actions: [
              TextButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context).pop();
                    try {
                      await firebaseAuth.sendPasswordResetEmail(
                          email: resetEmailController.text);
                      Keys.scaffoldMessengerKey.currentState!
                          .showSnackBar(const SnackBar(
                        content: Text("Email sent successfully"),
                        backgroundColor: Colors.green,
                      ));
                      navigator;
                    } catch (e) {
                      Keys.scaffoldMessengerKey.currentState!
                          .showSnackBar(SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      ));
                      navigator;
                    }
                  },
                  child: const Text("Submit"))
            ],
          );
        });
  }

  TextEditingController phoneController =
      TextEditingController(text: "+919910759477");

  verifyPhoneNumber(BuildContext context) async {
    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneController.text,
        timeout: const Duration(seconds: 30),
        verificationCompleted: (AuthCredential authCredential) {
          Keys.scaffoldMessengerKey.currentState!.showSnackBar(const SnackBar(
            content: Text("Verification completed"),
            backgroundColor: Colors.green,
          ));
        },
        verificationFailed: (FirebaseAuthException exception) {
          Keys.scaffoldMessengerKey.currentState!.showSnackBar(const SnackBar(
            content: Text("Verification failed"),
            backgroundColor: Colors.red,
          ));
        },
        codeSent: (String? verId, int? forceCodeResent) {
          Keys.scaffoldMessengerKey.currentState!.showSnackBar(const SnackBar(
            content: Text("Code sent successfully"),
            backgroundColor: Colors.green,
          ));
          verificationId = verId;
          optDialogBox(context);
        },
        codeAutoRetrievalTimeout: (String verId) {
          Keys.scaffoldMessengerKey.currentState!.showSnackBar(const SnackBar(
            content: Text("Time out"),
            backgroundColor: Colors.black,
          ));
        },
      );
    } on FirebaseAuthException catch (e) {
      Keys.scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
        content: Text(e.message!),
        backgroundColor: Colors.green,
      ));
    }
  }

  String? verificationId;
  TextEditingController otpController = TextEditingController();
  optDialogBox(BuildContext context) {
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text("Enter your OTP"),
            content: CustomTextField(
              controller: otpController,
              iconData: Icons.code,
              hintText: "Enter OTP",
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    signInWithPhone();
                  },
                  child: const Text("Submit"))
            ],
          );
        });
  }

  signInWithPhone() async {
    await firebaseAuth.signInWithCredential(PhoneAuthProvider.credential(
        verificationId: verificationId!, smsCode: otpController.text));
  }

  GoogleSignIn googleSignIn = GoogleSignIn();

  signInWithGoogle() async {
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      try {
        GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        await firebaseAuth.signInWithCredential(authCredential);
      } on FirebaseAuthException catch (e) {
        Keys.scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
          content: Text(e.message!),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      Keys.scaffoldMessengerKey.currentState!.showSnackBar(const SnackBar(
        content: Text("Account not selected"),
        backgroundColor: Colors.red,
      ));
    }
  }

  logOut() async {
    try {
      await firebaseAuth.signOut();
      await googleSignIn.signOut();
    } catch (error) {
      Keys.scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
        content: Text(
          error.toString(),
        ),
        backgroundColor: Colors.red,
      ));
    }
  }
}

enum AuthType {
  signUp,
  signIn,
}
