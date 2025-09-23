import 'package:flutter/material.dart';
import 'package:master_demo_app/Api/hooks/auth.dart';
import 'package:master_demo_app/Screens/HomeScreen.dart';

import 'package:master_demo_app/Screens/Register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> signinWithGoogle() async {
    try {
      await doSignInWithGoogle();
    Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: \\${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await doSignInWithEmailAndPassword(_emailController.text, _passwordController.text);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login successful (demo)')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: \\${e.toString()}'), backgroundColor: Colors.red));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in the details'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFe3f0fc), Color(0xFFcbe5fa)]),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top icon
                        Container(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CircleAvatar(
                            backgroundColor: Colors.blue.shade50,
                            radius: 32,
                            child: Icon(Icons.login, size: 36, color: Colors.blue.shade700),
                          ),
                        ),
                        // Title
                        const Text(
                          'Sign in with email',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'A Model to help you understand programming better',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54, fontSize: 15),
                        ),
                        const SizedBox(height: 24),
                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined),
                            hintText: 'Email',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                        ),
                        const SizedBox(height: 16),
                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline),
                            hintText: 'Password',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => (v == null || v.length < 6) ? 'Enter min. 6 characters' : null,
                        ),
                        const SizedBox(height: 8),
                        // Forgot password
                        Row(
                          children: [
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size(0, 0)),
                              child: const Text('Forgot password?', style: TextStyle(fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Get Started button
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              handleLogin();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Get Started', style: TextStyle(color: Colors.white, fontSize: 17)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Register button
                        SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => RegisterScreen()),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black54),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Register', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Or sign in with
                        Row(
                          children: const [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('Or sign in with', style: TextStyle(fontSize: 13)),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Social buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _socialButton('G', Colors.red, signinWithGoogle),
                            _socialButton('f', Colors.blue, () {}),
                            _socialButton('', Colors.black, () {}),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(fontSize: 24, color: color, fontWeight: FontWeight.bold, fontFamily: label == '' ? null : 'Roboto'),
          ),
        ),
      ),
    );
  }
}
