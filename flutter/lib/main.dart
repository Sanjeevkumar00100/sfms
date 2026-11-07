import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'screens/ops/ops_dashboard_screen.dart';
import 'screens/customer/customer_portal_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
    );
  } catch (e) {
    debugPrint('Supabase initialization warning (running in offline/resilient mode): $e');
  }

  runApp(const SFMSApp());
}

final supabase = Supabase.instance.client;

class SFMSApp extends StatelessWidget {
  const SFMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SFMS - Small Finance Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF107559),
          primary: const Color(0xFF107559),
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const SFMSLoginPage(),
    );
  }
}

// ============================================================
// LOGIN & APPLICATION SELECTOR
// ============================================================

class SFMSLoginPage extends StatefulWidget {
  const SFMSLoginPage({super.key});

  @override
  State<SFMSLoginPage> createState() => _SFMSLoginPageState();
}

class _SFMSLoginPageState extends State<SFMSLoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final profile = await supabase.rpc('sfms_get_my_profile');

      if (!mounted) return;

      final role = (profile['role'] ?? profile['role_code'] ?? profile['role_name'])
              ?.toString()
              .trim()
              .toUpperCase() ??
          '';

      if (role.isEmpty) {
        throw Exception('Profile returned by Supabase:\n$profile');
      }

      switch (role) {
        case 'ADMIN':
        case 'MANAGER':
        case 'ACCOUNTANT':
        case 'CASHIER':
        case 'FIELD_STAFF':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OpsDashboardScreen()),
          );
          break;

        case 'CUSTOMER':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CustomerPortalScreen()),
          );
          break;

        default:
          throw Exception('User role "$role" is not configured.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
      });
      try {
        await supabase.auth.signOut();
      } catch (_) {}
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // Logo & Branding
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF107559),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF107559).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.account_balance, size: 40, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'SFMS',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const Text(
                        'Small Finance Management System',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 24),

                      // TWO APPLICATIONS DIRECT ACCESS BANNER
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DIRECT APPLICATION LAUNCHER',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF065F46),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const OpsDashboardScreen()),
                                      );
                                    },
                                    icon: const Icon(Icons.business_center, size: 16),
                                    label: const Text('Banking Ops', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0F3D2E),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const CustomerPortalScreen()),
                                      );
                                    },
                                    icon: const Icon(Icons.person, size: 16),
                                    label: const Text('Customer App', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF107559),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'OR SIGN IN WITH ACCOUNT',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => obscurePassword = !obscurePassword),
                            icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
                      ),
                      const SizedBox(height: 18),

                      if (errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.red.shade800, fontSize: 12),
                          ),
                        ),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: loading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF107559),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Sign In to SFMS', style: TextStyle(fontWeight: FontWeight.bold)),
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
