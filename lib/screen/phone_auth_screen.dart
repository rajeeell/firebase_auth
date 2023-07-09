import 'package:firebase_proj1/provider/auth_provider.dart';
import 'package:firebase_proj1/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PhoneAuthScreen extends StatelessWidget {
  const PhoneAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(builder: (context, model, _) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
            CustomTextField(
                controller: model.phoneController,
                iconData: Icons.phone,
                hintText: "Enter phone number"),
            TextButton(
                onPressed: () {
                  model.verifyPhoneNumber(context);
                },
                child: const Text("Send OTP"))
          ]),
        );
      }),
    );
  }
}
