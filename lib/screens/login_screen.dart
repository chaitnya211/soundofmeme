import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:soundofmeme/screens/sign_up_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/customButton.dart';
import '../widgets/customTextFormField.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();

  Future<void> loginUser() async {
    try {
      final response = await http.post(
          Uri.parse('http://143.244.131.156:8000/login'),
          headers: <String, String>{"content-type": "application/json"},
          body: jsonEncode({
            'email': emailController.text,
            'password': passwordController.text
          }));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        await storage.write(key: 'access_token', value: responseBody['access_token']);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ));
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xf215171a),
                  Color.fromRGBO(65, 47, 50, 1.0),
                  Color(0xff1A1D21),
                  Color(0xff1A1D21),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/images/memes.gif'),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Center(
                        child: Text(
                          'Login',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Hello there, Login to continue',
                        style: TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Email Id",
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15)),
                          const SizedBox(height: 10),
                          CustomTextFormField(
                              controller: emailController,
                              hintText: 'Enter your email',
                              keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 20),
                          const Text("Password ",
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15)),
                          const SizedBox(height: 10),
                          CustomTextFormField(
                            controller: passwordController,
                            hintText: 'Enter password',
                            keyboardType: TextInputType.visiblePassword,
                          ),
                          const SizedBox(height: 60),
                          CustomButton(
                            btnText: 'Login',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                loginUser();
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account ? ",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400),
                              ),
                              GestureDetector(
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900),
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpScreen(),
                                      ));
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
