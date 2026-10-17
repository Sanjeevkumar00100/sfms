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

final supabase = Supabase.instance.client;

class SFMSApp extends StatelessWidget {
  const SFMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SFMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const SFMSLoginPage(),
    );
  }
}

// ============================================================
// LOGIN
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
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final profile = await supabase.rpc(
        'sfms_get_my_profile',
      );

      if (!mounted) return;

      final role =
    profile['role']?.toString().trim().toUpperCase() ?? '';

if (role.isEmpty) {
  throw Exception(
    'Profile returned by Supabase:\n$profile',
  );
}

switch (role) {
        case 'ADMIN':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminDashboard(),
            ),
          );
          break;

        case 'MANAGER':
        case 'ACCOUNTANT':
        case 'CASHIER':
        case 'FIELD_STAFF':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const StaffDashboard(),
            ),
          );
          break;

        case 'CUSTOMER':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const CustomerDashboard(),
            ),
          );
          break;

        default:
          throw Exception(
            'Your user role is not configured.',
          );
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
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 450,
            ),
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.account_balance,
                        size: 70,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'SFMS',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Small Finance Management System',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: emailController,
                        keyboardType:
                            TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon:
                              Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Enter email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon:
                              const Icon(Icons.lock_outline),
                          border:
                              const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword =
                                    !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Enter password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      if (errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(12),
                          margin:
                              const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child: Text(
                            errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade800,
                            ),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              loading ? null : login,
                          child: loading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child:
                                      CircularProgressIndicator(),
                                )
                              : const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
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

// ============================================================
// ADMIN DASHBOARD
// ============================================================

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() =>
      _AdminDashboardState();
}

class _AdminDashboardState
    extends State<AdminDashboard> {
  bool loading = true;

  String? organizationId;
  String? branchId;

  int memberCount = 0;
  int accountCount = 0;
  int staffCount = 0;
  int transactionCount = 0;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      setState(() {
        loading = true;
        errorMessage = null;
      });

      final profile = await supabase.rpc(
        'sfms_get_my_profile',
      );

      organizationId =
          profile['organization_id']?.toString();

      branchId =
          profile['branch_id']?.toString();

      if (organizationId == null ||
          organizationId!.isEmpty) {
        throw Exception(
          'Organization ID not found.',
        );
      }

      final members = await supabase
          .from('members')
          .select('id')
          .eq(
            'organization_id',
            organizationId!,
          );

      final accounts = await supabase
          .from('customer_accounts')
          .select('id')
          .eq(
            'organization_id',
            organizationId!,
          );

      final staff = await supabase
          .from('staff_profiles')
          .select('id')
          .eq(
            'organization_id',
            organizationId!,
          );

      final transactions = await supabase
          .from('transactions')
          .select('id')
          .eq(
            'organization_id',
            organizationId!,
          );

      if (!mounted) return;

      setState(() {
        memberCount = members.length;
        accountCount = accounts.length;
        staffCount = staff.length;
        transactionCount = transactions.length;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const SFMSLoginPage(),
      ),
      (_) => false,
    );
  }

  Widget statCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              child: Icon(icon),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget actionButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Card(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.blue,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SFMS Admin Dashboard',
        ),
        actions: [
          IconButton(
            onPressed: loadDashboard,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadDashboard,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 15,
                        runSpacing: 15,
                        children: [
                          SizedBox(
                            width: 250,
                            child: statCard(
                              'Members',
                              memberCount.toString(),
                              Icons.people,
                            ),
                          ),
                          SizedBox(
                            width: 250,
                            child: statCard(
                              'Accounts',
                              accountCount.toString(),
                              Icons.account_balance,
                            ),
                          ),
                          SizedBox(
                            width: 250,
                            child: statCard(
                              'Staff',
                              staffCount.toString(),
                              Icons.badge,
                            ),
                          ),
                          SizedBox(
                            width: 250,
                            child: statCard(
                              'Transactions',
                              transactionCount.toString(),
                              Icons.receipt_long,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 1.3,
                        children: [
                          actionButton(
                            context,
                            'Add Member',
                            Icons.person_add,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AddMemberPage(),
                                ),
                              );
                            },
                          ),
                          actionButton(
                            context,
                            'Open Account',
                            Icons.account_balance_wallet,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const OpenAccountPage(),
                                ),
                              );
                            },
                          ),
                          actionButton(
                            context,
                            'Deposit',
                            Icons.add_circle,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const DepositPage(),
                                ),
                              );
                            },
                          ),
                          actionButton(
                            context,
                            'Withdrawal',
                            Icons.remove_circle,
                            () {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Withdrawal module coming next.',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}

// ============================================================
// ADD MEMBER
// ============================================================

class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});

  @override
  State<AddMemberPage> createState() =>
      _AddMemberPageState();
}

class _AddMemberPageState
    extends State<AddMemberPage> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  bool saving = false;

  String? organizationId;
  String? branchId;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final profile = await supabase.rpc(
        'sfms_get_my_profile',
      );

      if (!mounted) return;

      setState(() {
        organizationId =
            profile['organization_id']?.toString();
        branchId =
            profile['branch_id']?.toString();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<String> generateMemberNumber() async {
    final rows = await supabase
        .from('members')
        .select('member_number')
        .eq(
          'organization_id',
          organizationId!,
        )
        .order(
          'member_number',
          ascending: false,
        )
        .limit(1);

    if (rows.isEmpty) {
      return 'MEM000001';
    }

    final last =
        rows.first['member_number']?.toString() ?? '';

    final match =
        RegExp(r'(\d+)$').firstMatch(last);

    if (match == null) {
      return 'MEM000001';
    }

    final number =
        int.tryParse(match.group(1)!) ?? 0;

    return 'MEM${(number + 1).toString().padLeft(6, '0')}';
  }

  Future<void> saveMember() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (organizationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Organization is not available.',
          ),
        ),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final memberNumber =
          await generateMemberNumber();

      await supabase.from('members').insert({
        'organization_id': organizationId,
        'branch_id': branchId,
        'member_number': memberNumber,
        'full_name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'status': 'ACTIVE',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Member created: $memberNumber',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Member'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 650,
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration:
                            const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null ||
                              v.trim().isEmpty) {
                            return 'Enter name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: phoneController,
                        keyboardType:
                            TextInputType.phone,
                        decoration:
                            const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null ||
                              v.trim().isEmpty) {
                            return 'Enter phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: addressController,
                        maxLines: 3,
                        decoration:
                            const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              saving ? null : saveMember,
                          child: saving
                              ? const CircularProgressIndicator()
                              : const Text(
                                  'SAVE MEMBER',
                                ),
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

// ============================================================
// OPEN ACCOUNT
// ============================================================

class OpenAccountPage extends StatefulWidget {
  const OpenAccountPage({super.key});

  @override
  State<OpenAccountPage> createState() =>
      _OpenAccountPageState();
}

class _OpenAccountPageState
    extends State<OpenAccountPage> {
  String? organizationId;
  String? branchId;

  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> paymentMethods = [];

  String? selectedMember;
  int? selectedProduct;
  int? selectedPaymentMethod;

  final amountController =
      TextEditingController(text: '0');

  final referenceController =
      TextEditingController();

  final narrationController =
      TextEditingController();

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final profile = await supabase.rpc(
        'sfms_get_my_profile',
      );

      organizationId =
          profile['organization_id']?.toString();

      branchId =
          profile['branch_id']?.toString();

      if (organizationId == null) {
        throw Exception(
          'Organization ID not found.',
        );
      }

      final memberData = await supabase
          .from('members')
          .select(
            'id, member_number, full_name',
          )
          .eq(
            'organization_id',
            organizationId!,
          )
          .eq('status', 'ACTIVE')
          .order('member_number');

      final productData = await supabase
          .from('account_products')
          .select(
            'id, product_code, product_name',
          )
          .eq('status', 'ACTIVE')
          .order('product_code');

      final methodData = await supabase
          .from('payment_methods')
          .select(
            'id, payment_code, payment_name, '
            'requires_reference',
          )
          .order('id');

      if (!mounted) return;

      setState(() {
        members =
            List<Map<String, dynamic>>.from(
          memberData.map(
            (x) => Map<String, dynamic>.from(x),
          ),
        );

        products =
            List<Map<String, dynamic>>.from(
          productData.map(
            (x) => Map<String, dynamic>.from(x),
          ),
        );

        paymentMethods =
            List<Map<String, dynamic>>.from(
          methodData.map(
            (x) => Map<String, dynamic>.from(x),
          ),
        );

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Load error: $e',
          ),
        ),
      );
    }
  }

  Future<void> openAccount() async {
    final amount =
        double.tryParse(
          amountController.text.trim(),
        ) ??
        0;

    if (selectedMember == null ||
        selectedProduct == null ||
        selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select member, product and payment method.',
          ),
        ),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception(
          'User is not logged in.',
        );
      }

      final response = await supabase.rpc(
        'open_customer_account',
        params: {
          'p_organization_id':
              organizationId,
          'p_branch_id':
              branchId,
          'p_member_id':
              selectedMember,
          'p_product_id':
              selectedProduct,
          'p_opening_amount':
              amount,
          'p_payment_method_id':
              selectedPaymentMethod,
          'p_initiated_by':
              user.id,
          'p_reference_number':
              referenceController.text.trim().isEmpty
                  ? null
                  : referenceController.text.trim(),
          'p_narration':
              narrationController.text.trim().isEmpty
                  ? null
                  : narrationController.text.trim(),
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account opened successfully: $response',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    referenceController.dispose();
    narrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Open Account'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 650,
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedMember,
                      decoration:
                          const InputDecoration(
                        labelText: 'Member',
                        border: OutlineInputBorder(),
                      ),
                      items: members.map((m) {
                        return DropdownMenuItem<String>(
                          value: m['id'].toString(),
                          child: Text(
                            '${m['member_number']} - ${m['full_name']}',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMember = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<int>(
                      value: selectedProduct,
                      decoration:
                          const InputDecoration(
                        labelText: 'Account Product',
                        border: OutlineInputBorder(),
                      ),
                      items: products.map((p) {
                        final id =
                            int.tryParse(
                          p['id'].toString(),
                        );

                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(
                            '${p['product_code']} - ${p['product_name']}',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedProduct = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText: 'Opening Amount',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<int>(
                      value: selectedPaymentMethod,
                      decoration:
                          const InputDecoration(
                        labelText: 'Payment Method',
                        border: OutlineInputBorder(),
                      ),
                      items: paymentMethods.map((m) {
                        final id =
                            int.tryParse(
                          m['id'].toString(),
                        );

                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(
                            '${m['payment_code']} - ${m['payment_name']}',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod =
                              value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller:
                          referenceController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Reference Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller:
                          narrationController,
                      maxLines: 3,
                      decoration:
                          const InputDecoration(
                        labelText: 'Narration',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            saving ? null : openAccount,
                        child: saving
                            ? const CircularProgressIndicator()
                            : const Text(
                                'OPEN ACCOUNT',
                              ),
                      ),
                    ),
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

// ============================================================
// DEPOSIT PAGE
// ============================================================

class DepositPage extends StatefulWidget {
  const DepositPage({super.key});

  @override
  State<DepositPage> createState() =>
      _DepositPageState();
}

class _DepositPageState
    extends State<DepositPage> {
  final formKey = GlobalKey<FormState>();

  final amountController =
      TextEditingController();

  final referenceController =
      TextEditingController();

  final narrationController =
      TextEditingController();

  List<Map<String, dynamic>> accounts = [];
  List<Map<String, dynamic>> paymentMethods = [];

  String? organizationId;
  String? branchId;
  String? selectedAccount;

  int? selectedPaymentMethod;

  bool loading = true;
  bool saving = false;

  String? loadError;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ==========================================================
  // FIXED ACCOUNT LOADING
  // ==========================================================

  Future<void> loadData() async {
    try {
      if (mounted) {
        setState(() {
          loading = true;
          loadError = null;
        });
      }

      // Get logged-in user's organization and branch.
      final profile = await supabase.rpc(
        'sfms_get_my_profile',
      );

      organizationId =
          profile['organization_id']?.toString();

      branchId =
          profile['branch_id']?.toString();

      if (organizationId == null ||
          organizationId!.isEmpty) {
        throw Exception(
          'Organization ID was not found in your profile.',
        );
      }

      // --------------------------------------------------------
      // LOAD CUSTOMER ACCOUNTS
      // --------------------------------------------------------

      final accountData = await supabase
          .from('customer_accounts')
          .select(
            'id, account_number, account_name, '
            'current_balance, available_balance, '
            'member_id, organization_id, branch_id, status',
          )
          .eq(
            'organization_id',
            organizationId!,
          )
          .order(
            'account_number',
          );

      final allAccounts =
          List<Map<String, dynamic>>.from(
        accountData.map(
          (row) => Map<String, dynamic>.from(row),
        ),
      );

      // First try ACTIVE accounts matching branch.
      List<Map<String, dynamic>> loadedAccounts =
          allAccounts.where((account) {
        final status =
            account['status']
                ?.toString()
                .trim()
                .toUpperCase();

        final accountBranch =
            account['branch_id']
                ?.toString()
                .trim();

        return status == 'ACTIVE' &&
            accountBranch == branchId;
      }).toList();

      // --------------------------------------------------------
      // FALLBACK
      // --------------------------------------------------------

      if (loadedAccounts.isEmpty) {
        loadedAccounts =
            allAccounts.where((account) {
          final status =
              account['status']
                  ?.toString()
                  .trim()
                  .toUpperCase();

          return status == 'ACTIVE';
        }).toList();
      }

      // --------------------------------------------------------
      // PAYMENT METHODS
      // --------------------------------------------------------

      final methodData = await supabase
          .from('payment_methods')
          .select(
            'id, payment_code, payment_name, '
            'requires_reference',
          )
          .order('id');

      final loadedMethods =
          List<Map<String, dynamic>>.from(
        methodData.map(
          (row) => Map<String, dynamic>.from(row),
        ),
      );

      // --------------------------------------------------------
      // DEFAULT CASH
      // --------------------------------------------------------

      int? defaultPayment;

      for (final method in loadedMethods) {
        final code =
            method['payment_code']
                ?.toString()
                .trim()
                .toUpperCase();

        if (code == 'CASH') {
          final id = method['id'];

          if (id is num) {
            defaultPayment = id.toInt();
          } else {
            defaultPayment =
                int.tryParse(id.toString());
          }

          break;
        }
      }

      if (!mounted) return;

      setState(() {
        accounts = loadedAccounts;
        paymentMethods = loadedMethods;
        selectedPaymentMethod =
            defaultPayment;

        if (selectedAccount != null &&
            !loadedAccounts.any(
              (account) =>
                  account['id'].toString() ==
                  selectedAccount,
            )) {
          selectedAccount = null;
        }

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        accounts = [];
        loadError = e.toString();
      });
    }
  }

  Map<String, dynamic>? get selectedAccountData {
    if (selectedAccount == null) {
      return null;
    }

    for (final account in accounts) {
      if (account['id'].toString() ==
          selectedAccount) {
        return account;
      }
    }

    return null;
  }

  Map<String, dynamic>? get selectedMethod {
    if (selectedPaymentMethod == null) {
      return null;
    }

    for (final method in paymentMethods) {
      if (method['id'].toString() ==
          selectedPaymentMethod.toString()) {
        return method;
      }
    }

    return null;
  }

  bool get requiresReference {
    return selectedMethod?['requires_reference'] ==
        true;
  }

  String balance(dynamic value) {
    final number =
        double.tryParse(value?.toString() ?? '0') ??
            0;

    return '₹${number.toStringAsFixed(2)}';
  }

  Future<void> deposit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a customer account.',
          ),
        ),
      );
      return;
    }

    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select payment method.',
          ),
        ),
      );
      return;
    }

    final amount =
        double.tryParse(
          amountController.text.trim(),
        );

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid amount.',
          ),
        ),
      );
      return;
    }

    if (requiresReference &&
        referenceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Reference number is required.',
          ),
        ),
      );
      return;
    }

    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'User session not found.',
          ),
        ),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final response = await supabase.rpc(
        'deposit_customer_account',
        params: {
          'p_organization_id':
              organizationId,
          'p_branch_id':
              branchId,
          'p_account_id':
              selectedAccount,
          'p_amount':
              amount,
          'p_payment_method_id':
              selectedPaymentMethod,
          'p_initiated_by':
              user.id,
          'p_reference_number':
              referenceController.text.trim().isEmpty
                  ? null
                  : referenceController.text.trim(),
          'p_narration':
              narrationController.text.trim().isEmpty
                  ? null
                  : narrationController.text.trim(),
        },
      );

      if (!mounted) return;

      final result =
          Map<String, dynamic>.from(
        response as Map,
      );

      if (result['success'] == false) {
        throw Exception(
          result['message'] ??
              'Deposit failed.',
        );
      }

      await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text(
              'Deposit Successful',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Account: ${result['account_number'] ?? ''}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Transaction: ${result['transaction_number'] ?? ''}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Amount: ${result['amount'] ?? amount}',
                ),
                const SizedBox(height: 8),
                Text(
                  'New Balance: ${result['new_balance'] ?? ''}',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      amountController.clear();
      referenceController.clear();
      narrationController.clear();

      await loadData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Deposit failed: $e',
          ),
          duration:
              const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  Widget noAccounts() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 550,
          ),
          child: Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(24),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const Icon(
                    Icons
                        .account_balance_wallet_outlined,
                    size: 70,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'No Active Accounts',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No ACTIVE customer accounts were returned for this organization.',
                    textAlign:
                        TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (organizationId != null)
                    SelectableText(
                      'Organization: $organizationId',
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  if (branchId != null) ...[
                    const SizedBox(height: 5),
                    SelectableText(
                      'Branch: $branchId',
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: loadData,
                    icon: const Icon(
                      Icons.refresh,
                    ),
                    label: const Text(
                      'Refresh Accounts',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child:
                        const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget loadErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 700,
          ),
          child: Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(24),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Unable to Load Deposit Data',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  SelectableText(
                    loadError ?? 'Unknown error',
                    textAlign:
                        TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: loadData,
                    icon: const Icon(
                      Icons.refresh,
                    ),
                    label: const Text(
                      'Try Again',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget depositForm() {
    final account =
        selectedAccountData;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 750,
          ),
          child: Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.add_circle,
                          size: 32,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Deposit Money',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${accounts.length} active account(s)',
                          style:
                              const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // ACCOUNT
                    DropdownButtonFormField<
                        String>(
                      value: selectedAccount,
                      isExpanded: true,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Customer Account',
                        border:
                            OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons
                              .account_balance_wallet,
                        ),
                      ),
                      items:
                          accounts.map((account) {
                        return DropdownMenuItem<
                            String>(
                          value: account['id']
                              .toString(),
                          child: Text(
                            '${account['account_number']} - ${account['account_name']}',
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedAccount =
                              value;
                        });
                      },
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Select account';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    if (account != null)
                      Container(
                        width:
                            double.infinity,
                        padding:
                            const EdgeInsets.all(
                                18),
                        decoration:
                            BoxDecoration(
                          borderRadius:
                              BorderRadius
                                  .circular(12),
                          color: Colors.blue
                              .withOpacity(
                                  0.08),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              account[
                                      'account_number']
                                  ?.toString() ??
                                  '',
                              style:
                                  const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                                height: 6),
                            Text(
                              account[
                                      'account_name']
                                  ?.toString() ??
                                  '',
                            ),
                            const SizedBox(
                                height: 10),
                            Row(
                              children: [
                                const Text(
                                  'Current Balance: ',
                                ),
                                Text(
                                  balance(
                                    account[
                                        'current_balance'],
                                  ),
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 15),

                    // AMOUNT
                    TextFormField(
                      controller:
                          amountController,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Deposit Amount',
                        border:
                            OutlineInputBorder(),
                        prefixText: '₹ ',
                        prefixIcon: Icon(
                          Icons.currency_rupee,
                        ),
                      ),
                      validator: (value) {
                        final amount =
                            double.tryParse(
                          value ?? '',
                        );

                        if (amount == null ||
                            amount <= 0) {
                          return 'Enter a valid amount';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    // PAYMENT METHOD
                    DropdownButtonFormField<int>(
                      value:
                          selectedPaymentMethod,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Payment Method',
                        border:
                            OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.payments_outlined,
                        ),
                      ),
                      items:
                          paymentMethods.map(
                        (method) {
                          final id =
                              int.tryParse(
                            method['id']
                                .toString(),
                          );

                          return DropdownMenuItem<
                              int>(
                            value: id,
                            child: Text(
                              '${method['payment_code']} - ${method['payment_name']}',
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod =
                              value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Select payment method';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    // REFERENCE
                    TextFormField(
                      controller:
                          referenceController,
                      decoration:
                          InputDecoration(
                        labelText:
                            requiresReference
                                ? 'Reference Number *'
                                : 'Reference Number',
                        border:
                            const OutlineInputBorder(),
                        prefixIcon:
                            const Icon(
                          Icons.receipt_long,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // NARRATION
                    TextFormField(
                      controller:
                          narrationController,
                      maxLines: 3,
                      decoration:
                          const InputDecoration(
                        labelText: 'Narration',
                        border:
                            OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.notes,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width:
                          double.infinity,
                      height: 52,
                      child:
                          ElevatedButton.icon(
                        onPressed:
                            saving
                                ? null
                                : deposit,
                        icon: saving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                ),
                              )
                            : const Icon(
                                Icons.add,
                              ),
                        label: Text(
                          saving
                              ? 'Processing...'
                              : 'DEPOSIT MONEY',
                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    referenceController.dispose();
    narrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Deposit',
        ),
        actions: [
          IconButton(
            onPressed: loadData,
            icon: const Icon(
              Icons.refresh,
            ),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : loadError != null
              ? loadErrorWidget()
              : accounts.isEmpty
                  ? noAccounts()
                  : depositForm(),
    );
  }
}

// ============================================================
// STAFF DASHBOARD
// ============================================================

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  Future<void> logout(
    BuildContext context,
  ) async {
    await supabase.auth.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const SFMSLoginPage(),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SFMS Staff Dashboard',
        ),
        actions: [
          IconButton(
            onPressed: () =>
                logout(context),
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 700,
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.badge,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 15),
                const Text(
                  'Staff Dashboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.account_balance,
                    ),
                    title: const Text(
                      'Deposit',
                    ),
                    subtitle: const Text(
                      'Deposit money into customer accounts',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const DepositPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CUSTOMER DASHBOARD
// ============================================================

class CustomerDashboard
    extends StatelessWidget {
  const CustomerDashboard({super.key});

  Future<void> logout(
    BuildContext context,
  ) async {
    await supabase.auth.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const SFMSLoginPage(),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My SFMS Account',
        ),
        actions: [
          IconButton(
            onPressed: () =>
                logout(context),
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 80,
              color: Colors.blue,
            ),
            SizedBox(height: 15),
            Text(
              'Customer Dashboard',
              style: TextStyle(
                fontSize: 26,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Customer account features will be added here.',
            ),
          ],
        ),
      ),
    );
  }
}