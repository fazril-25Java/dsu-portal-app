import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../devices/device_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;

  Future<void> _sendMagicLink() async {
    setState(() => _loading = true);
    final email = _emailController.text.trim();
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        // redirectTo: 'io.supabase.flutter://login-callback/', // Optional: for mobile deep linking
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Magic link sent! Check your email.')),
      );
      // After sending magic link, navigate to device page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DevicePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _sendMagicLink,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Send Magic Link'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

