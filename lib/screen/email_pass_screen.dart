import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_proj1/provider/auth_provider.dart';
import 'package:firebase_proj1/screen/home_screen.dart';
import 'package:firebase_proj1/widgets/custom_text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class EmailPassScreen extends StatelessWidget {
  const EmailPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, model, _) {
      return StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Scaffold(
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomTextField(
                            controller: model.emailController,
                            iconData: Icons.email,
                            hintText: "Email"),
                        if (model.authType == AuthType.signUp)
                          CustomTextField(
                              controller: model.userNameController,
                              iconData: Icons.person,
                              hintText: "Username"),
                        CustomTextField(
                            controller: model.passwordController,
                            iconData: Icons.password,
                            hintText: "Password"),
                        TextButton(
                          onPressed: () {
                            model.authenticate();
                          },
                          child: model.authType == AuthType.signUp
                              ? const Text("Sign Up")
                              : const Text("Sign In"),
                        ),
                        TextButton(
                            onPressed: () {
                              model.setAuthType();
                            },
                            child: model.authType == AuthType.signUp
                                ? const Text("Already have an acoount")
                                : const Text("Create an account")),
                        if (model.authType == AuthType.signIn)
                          TextButton(
                              onPressed: () {
                                model.resetPassword(context);
                              },
                              child: const Text("Reset  password")),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const HomeScreen();
            }
          });
    });
  }
}
