import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/customButton.dart';
import '../widgets/customTextFormField.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();
  bool _agreeTerms = false;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> registerUser() async {
    try {
      final response = await http.post(
        Uri.parse('http://143.244.131.156:8000/signup'),
        headers: <String, String>{"content-type": 'application/json'},
        body: jsonEncode(<String, String>{
          'name': nameController.text,
          'email': emailController.text,
          'password': passwordController.text
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (kDebugMode) {
          print(responseBody);
        }
        await storage.write(
            key: 'access_token', value: responseBody['access_token']);
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
        appBar: AppBar(
          backgroundColor: const Color(0xf215171a),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height * 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xf215171a),
                Color.fromRGBO(55, 47, 50, 1.0),
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
                children: [
                  Image.asset('assets/images/memes.gif'),
                  const SizedBox(height: 20),
                  const Text(
                    'Registration',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Hello there, Register to continue',
                    style: TextStyle(
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Name ",
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                                fontSize: 15)),
                        const SizedBox(height: 10),
                        CustomTextFormField(
                            controller: nameController,
                            hintText: 'Enter your name'),
                        const SizedBox(height: 20),
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
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Checkbox(
                              activeColor: const Color(0xff23272C),
                              checkColor: Colors.blue,
                              value: _agreeTerms,
                              onChanged: (bool? value) {
                                setState(() {
                                  _agreeTerms = value ?? false;
                                });
                              },
                            ),
                            Flexible(
                              child: RichText(
                                text: const TextSpan(
                                  text: 'I agree to the ',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  children: [
                                    TextSpan(
                                      text:
                                          'Terms & Conditions & Privacy Policy',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          btnText: 'Register Now',
                          onPressed: () {
                            if (_formKey.currentState!.validate() &&
                                _agreeTerms) {
                              registerUser();
                            } else if (!_agreeTerms) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'You must agree to the terms & conditions')));
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Have an account ? ",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400),
                            ),
                            GestureDetector(
                              child: const Text(
                                "Log In",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
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
    );
  }
}
