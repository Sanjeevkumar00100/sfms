import 'package:flutter/material.dart';
import '../../services/banking_service.dart';
import '../../models/banking_models.dart';
import '../common/receipt_dialog.dart';

class CustomerPortalScreen extends StatefulWidget {
  const CustomerPortalScreen({super.key});

  @override
  State<CustomerPortalScreen> createState() => _CustomerPortalScreenState();
}

class _CustomerPortalScreenState extends State<CustomerPortalScreen> {
  final BankingService _service = BankingService();
  String _currentMemberId = 'MEM002'; // Default: Priya Sharma
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final member = _service.getMemberById(_currentMemberId);
    if (member == null) {
      return const Scaffold(body: Center(child: Text('Customer not found')));
    }

    final accounts = _service.getAccountsForMember(member.id);
    final primaryAccount = accounts.isNotEmpty ? accounts.first : null;
    final loans = _service.getLoansForMember(member.id);
    final deposits = _service.getTermDepositsForMember(member.id);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F3D2E),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SFMS Mobile Banking',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Customer: ${member.fullName}',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          // Customer Switcher
          PopupMenuButton<String>(
            tooltip: 'Switch Customer Profile',
            icon: const Icon(Icons.switch_account),
            onSelected: (id) => setState(() => _currentMemberId = id),
            itemBuilder: (_) => _service.members.map((m) {
              return PopupMenuItem(value: m.id, child: Text('${m.fullName} (${m.occupation})'));
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: _buildCurrentBody(member, accounts, primaryAccount, loans, deposits),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Passbook'),
          NavigationDestination(icon: Icon(Icons.send_outlined), selectedIcon: Icon(Icons.send), label: 'Pay'),
          NavigationDestination(icon: Icon(Icons.savings_outlined), selectedIcon: Icon(Icons.savings), label: 'Deposits'),
          NavigationDestination(icon: Icon(Icons.credit_card_outlined), selectedIcon: Icon(Icons.credit_card), label: 'Cards'),
        ],
      ),
    );
  }

  Widget _buildCurrentBody(
    MemberModel member,
    List<CustomerAccountModel> accounts,
    CustomerAccountModel? primaryAccount,
    List<LoanModel> loans,
    List<TermDepositModel> deposits,
  ) {
    switch (_navIndex) {
      case 0:
        return _buildHomeTab(member, accounts, primaryAccount, loans, deposits);
      case 1:
        return _buildPassbookTab(accounts);
      case 2:
        return _buildTransferTab(accounts);
      case 3:
        return _buildDepositsTab(member, accounts, deposits);
      case 4:
        return _buildCardTab(primaryAccount);
      default:
        return _buildHomeTab(member, accounts, primaryAccount, loans, deposits);
    }
  }

  // ==========================================
  // TAB 0: HOME
  // ==========================================
  Widget _buildHomeTab(
    MemberModel member,
    List<CustomerAccountModel> accounts,
    CustomerAccountModel? primaryAccount,
    List<LoanModel> loans,
    List<TermDepositModel> deposits,
  ) {
    final totalSavings = accounts.fold<double>(0.0, (sum, a) => sum + a.balance);
    final totalFD = deposits.fold<double>(0.0, (sum, d) => sum + d.principal);
    final totalLoans = loans.where((l) => l.status == 'ACTIVE').fold<double>(0.0, (sum, l) => sum + l.outstandingPrincipal);
    final netWorth = (totalSavings + totalFD) - totalLoans;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Account Balance Banner Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF064E3B), Color(0xFF0F766E), Color(0xFF1E3A8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PRIMARY SAVINGS A/C', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                      Text(
                        primaryAccount != null ? 'A/C •••• ${primaryAccount.accountNumber.substring(primaryAccount.accountNumber.length - 4)}' : 'No Account',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                    child: const Text('IFSC: SFMS0001001', style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Available Balance', style: TextStyle(color: Colors.white60, fontSize: 11)),
              Text(
                '₹${(primaryAccount?.balance ?? 0.0).toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Divider(color: Colors.white24, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Net Relationship Value:', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text(
                    '₹${netWorth.toStringAsFixed(2)}',
                    style: const TextStyle(color: Color(0xFF6EE7B7), fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Quick Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _actionButton(Icons.send, 'Send Money', () => setState(() => _navIndex = 2)),
            _actionButton(Icons.receipt_long, 'Passbook', () => setState(() => _navIndex = 1)),
            _actionButton(Icons.savings, 'Open FD', () => setState(() => _navIndex = 3)),
            _actionButton(Icons.credit_card, 'Card Settings', () => setState(() => _navIndex = 4)),
          ],
        ),
        const SizedBox(height: 24),

        // Active Loans Quick Alert
        if (loans.any((l) => l.status == 'ACTIVE')) ...[
          const Text('Active Loan & Upcoming EMI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          ...loans.where((l) => l.status == 'ACTIVE').map((loan) {
            return Card(
              color: const Color(0xFFECFDF5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFA7F3D0),
                      child: Icon(Icons.assignment, color: Color(0xFF0F3D2E)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loan.loanType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('Due Date: ${loan.nextDueDate} • Outstanding: ₹${loan.outstandingPrincipal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        try {
                          _service.repayLoanEMI(
                            loanId: loan.id,
                            amount: loan.emiAmount,
                            initiatedBy: 'CUSTOMER',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('EMI of ₹${loan.emiAmount.toStringAsFixed(0)} paid!')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF107559),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      child: Text('Pay ₹${loan.emiAmount.toStringAsFixed(0)}'),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
        ],

        // Recent Transactions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            TextButton(
              onPressed: () => setState(() => _navIndex = 1),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ..._service.transactions.where((t) => accounts.any((a) => a.id == t.accountId)).take(5).map((t) {
          final isCredit = t.type == 'CREDIT';
          return Card(
            elevation: 0.5,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isCredit ? Colors.green.shade50 : Colors.red.shade50,
                child: Icon(
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
                  size: 18,
                ),
              ),
              title: Text(t.narration.isNotEmpty ? t.narration : t.category, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: Text(t.timestamp, style: const TextStyle(fontSize: 11)),
              trailing: Text(
                '${isCredit ? '+' : '-'}₹${t.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
                  fontSize: 13,
                ),
              ),
              onTap: () => ReceiptDialog.show(context, t),
            ),
          );
        }),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF107559), size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: PASSBOOK
  // ==========================================
  Widget _buildPassbookTab(List<CustomerAccountModel> accounts) {
    final accIds = accounts.map((a) => a.id).toSet();
    final myTxns = _service.transactions.where((t) => accIds.contains(t.accountId)).toList();

    return myTxns.isEmpty
        ? const Center(child: Text('No passbook entries found'))
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: myTxns.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final t = myTxns[index];
              final isCredit = t.type == 'CREDIT';
              return Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(t.narration, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('Ref: ${t.reference} • ${t.timestamp}', style: const TextStyle(fontSize: 11)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isCredit ? '+' : '-'}₹${t.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                      Text('Bal: ₹${t.balanceAfter.toStringAsFixed(2)}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  onTap: () => ReceiptDialog.show(context, t),
                ),
              );
            },
          );
  }

  // ==========================================
  // TAB 2: TRANSFER
  // ==========================================
  Widget _buildTransferTab(List<CustomerAccountModel> accounts) {
    if (accounts.isEmpty) return const Center(child: Text('No account available'));
    String fromAccId = accounts.first.id;
    final toAccCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    final pinCtrl = TextEditingController();

    return StatefulBuilder(
      builder: (context, setSubState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Instant Money Transfer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Text('Send money directly to any SFMS Account', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: fromAccId,
                decoration: const InputDecoration(labelText: 'From Account', border: OutlineInputBorder()),
                items: accounts.map((a) {
                  return DropdownMenuItem(value: a.id, child: Text('${a.accountNumber} (₹${a.availableBalance})'));
                }).toList(),
                onChanged: (v) => setSubState(() => fromAccId = v!),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: toAccCtrl,
                decoration: const InputDecoration(
                  labelText: 'Beneficiary SFMS Account Number *',
                  hintText: 'e.g. 1001002341 (Rajesh Kumar)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: amtCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (₹) *',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: pinCtrl,
                obscureText: true,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'Transaction PIN (Default: 1234) *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final amt = double.tryParse(amtCtrl.text.trim()) ?? 0;
                    if (amt <= 0 || toAccCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required transfer fields')),
                      );
                      return;
                    }
                    if (pinCtrl.text.trim() != '1234') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Incorrect PIN! Default demo PIN is 1234')),
                      );
                      return;
                    }
                    try {
                      _service.transferFunds(
                        fromAccountId: fromAccId,
                        toAccountNumber: toAccCtrl.text.trim(),
                        amount: amt,
                        initiatedBy: 'CUSTOMER',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Transferred ₹$amt successfully!')),
                      );
                      amtCtrl.clear();
                      toAccCtrl.clear();
                      pinCtrl.clear();
                      setState(() => _navIndex = 0);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Authorize & Send Instantly'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF107559),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 3: DEPOSITS
  // ==========================================
  Widget _buildDepositsTab(MemberModel member, List<CustomerAccountModel> accounts, List<TermDepositModel> deposits) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Term Deposit Calculator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('High-yield Fixed and Recurring deposits with up to 8.1% interest', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () {
                    if (accounts.isEmpty) return;
                    try {
                      _service.createTermDeposit(
                        memberId: member.id,
                        linkedAccountId: accounts.first.id,
                        type: 'FIXED_DEPOSIT',
                        principal: 25000,
                        termMonths: 12,
                        interestRate: 7.75,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opened 1-Year Fixed Deposit of ₹25,000!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Book ₹25,000 1-Year FD (7.75%)'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF107559), foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Active Certificates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),
        ...deposits.map((d) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.savings)),
              title: Text(d.certificateNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${d.type} • Maturity: ${d.maturityDate}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${d.principal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Mat: ₹${d.maturityAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontSize: 11)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // TAB 4: CARD
  // ==========================================
  Widget _buildCardTab(CustomerAccountModel? primaryAccount) {
    if (primaryAccount == null || primaryAccount.debitCard == null) {
      return const Center(child: Text('No debit card issued for this account.'));
    }

    final card = primaryAccount.debitCard!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Virtual Card UI
          Container(
            height: 200,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: card.isLocked
                    ? [Colors.grey.shade800, Colors.black87]
                    : [const Color(0xFF0F3D2E), const Color(0xFF107559), const Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('SFMS BHARAT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    Text(card.isLocked ? 'FROZEN' : 'RuPay PLATINUM', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                Text(
                  card.cardNumber,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'monospace', letterSpacing: 2),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CARD HOLDER', style: TextStyle(color: Colors.white60, fontSize: 8)),
                        Text(primaryAccount.accountName.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('VALID THRU', style: TextStyle(color: Colors.white60, fontSize: 8)),
                        Text(card.expiry, style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Controls
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Lock / Freeze Card', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Instantly block all card transactions'),
                  value: card.isLocked,
                  onChanged: (val) {
                    _service.toggleCardLock(primaryAccount.id);
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Online E-Commerce', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Enable online web & app payments'),
                  value: card.onlineTxnEnabled,
                  onChanged: (val) {
                    setState(() => card.onlineTxnEnabled = val);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
