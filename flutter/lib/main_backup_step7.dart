import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(const SFMSApp());
}

class SFMSApp extends StatelessWidget {
  const SFMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SFMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const SFMSLoginPage(),
    );
  }
}

class SFMSLoginPage extends StatefulWidget {
  const SFMSLoginPage({super.key});

  @override
  State<SFMSLoginPage> createState() => _SFMSLoginPageState();
}

class _SFMSLoginPageState extends State<SFMSLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter email and password.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        _showMessage('Login failed.');
        return;
      }

      final profile =
          await Supabase.instance.client.rpc('sfms_get_my_profile');

      if (!mounted) return;

      final role = profile['role_code']?.toString() ?? '';

      if (role == 'ADMIN') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminDashboard(),
          ),
        );
      } else if (role == 'MANAGER') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const StaffDashboard(
              title: 'Manager Dashboard',
            ),
          ),
        );
      } else if (role == 'ACCOUNTANT') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const StaffDashboard(
              title: 'Accountant Dashboard',
            ),
          ),
        );
      } else if (role == 'CASHIER') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const StaffDashboard(
              title: 'Cashier Dashboard',
            ),
          ),
        );
      } else if (role == 'FIELD_STAFF') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const StaffDashboard(
              title: 'Field Staff Dashboard',
            ),
          ),
        );
      } else if (role == 'CUSTOMER') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CustomerDashboard(),
          ),
        );
      } else {
        await Supabase.instance.client.auth.signOut();
        _showMessage('Your account does not have a valid SFMS role.');
      }
    } on AuthException catch (error) {
      _showMessage(error.message);
    } on PostgrestException catch (error) {
      _showMessage('Profile error: ${error.message}');
    } catch (error) {
      _showMessage('Login error: $error');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance,
                          size: 42,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'SFMS',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Small Finance Management System',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: isLoading ? null : _login,
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: () {
                          _showMessage(
                            'Password recovery will be added next.',
                          );
                        },
                        child: const Text('Forgot Password?'),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Secure • Simple • Reliable',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SFMS Admin Dashboard'),
      ),
      body: const Center(
        child: Text(
          'Welcome to SFMS Administrator Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class StaffDashboard extends StatelessWidget {
  final String title;

  const StaffDashboard({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          'Welcome to $title',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SFMS Customer'),
      ),
      body: const Center(
        child: Text(
          'Welcome to SFMS Customer Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}