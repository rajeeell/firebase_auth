import 'package:firebase_proj1/provider/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void didChangeDependencies() {
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (mounted) authProvider.updateEmailVerificationState();
    super.didChangeDependencies();
  }

  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, model, _) {
      return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  model.logOut();
                },
                icon: const Icon(Icons.logout))
          ],
        ),
        body: Center(
          child: model.emailVerified??false
          ? const Text("Email verified")
          :const Text("Email is not verified"),
        ),
      );
    });
  }
}
