import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome Text (Optional)
            const Text(
              "Welcome Back!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Login to continue",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Email Field
            CustomTextField(controller: emailController, label: "Email"),

            const SizedBox(height: 16),

            // Password Field
            CustomTextField(
              controller: passwordController,
              label: "Password",
              obscureText: true,
            ),

            const SizedBox(height: 8),

            // Forgot Password (Optional)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Navigate to forgot password screen
                },
                child: const Text("Forgot Password?"),
              ),
            ),

            const SizedBox(height: 20),

            // Login Button
            PrimaryButton(
              text: "Login",
              onPressed: () {
                // Add login logic here
              },
            ),

            const SizedBox(height: 16),

            // Register Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    // Navigate to register screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text("Register"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
