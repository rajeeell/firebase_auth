import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_proj1/screen/email_pass_screen.dart';
import 'package:firebase_proj1/screen/google_sign_in_screen.dart';
import 'package:firebase_proj1/screen/home_screen.dart';
import 'package:firebase_proj1/screen/phone_auth_screen.dart';
import 'package:firebase_proj1/widgets/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomeScreen();
          }
          return Scaffold(
              body: Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Select Auth provider",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  AuthButton(
                    iconData: Icons.email,
                    title: "Email/Password",
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const EmailPassScreen()));
                    },
                  ),
                  AuthButton(
                    iconData: Icons.phone,
                    title: "Phone",
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const PhoneAuthScreen()));
                    },
                  ),
                  AuthButton(
                    iconData: FontAwesome.google,
                    title: "Google",
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => GoogleSignInScreen()));
                    },
                  )
                ],
              ),
            ),
          ));
        });
  }
}
