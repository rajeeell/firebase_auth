import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_proj1/provider/auth_provider.dart';
import 'package:firebase_proj1/screen/home_screen.dart';
import 'package:firebase_proj1/screen/phone_auth_screen.dart';
import 'package:firebase_proj1/widgets/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:provider/provider.dart';

class GoogleSignInScreen extends StatelessWidget {
  const GoogleSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return Scaffold(
            body: Consumer<AuthProvider>(builder: (context, model, _) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: AuthButton(
                    iconData: FontAwesome.google,
                    title: "Google",
                    onTap: () {
                      model.signInWithGoogle();
                    },
                  ),
                ),
              );
            }),
          );
        });
  }
}
