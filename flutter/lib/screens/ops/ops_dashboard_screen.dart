import 'package:flutter/material.dart';
import '../../services/banking_service.dart';
import '../common/receipt_dialog.dart';

class OpsDashboardScreen extends StatefulWidget {
  const OpsDashboardScreen({super.key});

  @override
  State<OpsDashboardScreen> createState() => _OpsDashboardScreenState();
}

class _OpsDashboardScreenState extends State<OpsDashboardScreen> {
  final BankingService _service = BankingService();
  int _currentTabIndex = 0;
  String _selectedRole = 'BRANCH MANAGER';

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
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SFMS Core Banking Operations',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Role: $_selectedRole • Branch BR001',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F3D2E),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Switch Staff Role',
            icon: const Icon(Icons.badge_outlined),
            onSelected: (role) {
              setState(() => _selectedRole = role);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Switched active role to $role')),
              );
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'BRANCH MANAGER', child: Text('Branch Manager')),
              const PopupMenuItem(value: 'CASHIER / TELLER', child: Text('Cashier / Teller')),
              const PopupMenuItem(value: 'LOAN OFFICER', child: Text('Loan Officer')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: _buildCurrentTab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (idx) => setState(() => _currentTabIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Members'),
          NavigationDestination(icon: Icon(Icons.account_balance_outlined), selectedIcon: Icon(Icons.account_balance), label: 'Accounts'),
          NavigationDestination(icon: Icon(Icons.point_of_sale_outlined), selectedIcon: Icon(Icons.point_of_sale), label: 'Teller'),
          NavigationDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description), label: 'Loans'),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildMembersTab();
      case 2:
        return _buildAccountsTab();
      case 3:
        return _buildTellerTab();
      case 4:
        return _buildLoansTab();
      default:
        return _buildOverviewTab();
    }
  }

  // ==========================================
  // TAB 0: OVERVIEW
  // ==========================================
  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cash Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F3D2E), Color(0xFF1E6B52)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BRANCH TREASURY & VAULT',
                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Vault Cash', style: TextStyle(color: Colors.white60, fontSize: 11)),
                        Text(
                          _formatCurrency(_service.vaultCash),
                          style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Teller Drawer', style: TextStyle(color: Colors.white60, fontSize: 11)),
                        Text(
                          _formatCurrency(_service.tellerDrawerCash),
                          style: const TextStyle(color: Color(0xFF6EE7B7), fontSize: 19, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Financial & Operational Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF107559).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Live Branch Data',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF107559)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 9 Summary Cards in Responsive Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 700 ? 3 : 2;
              final itemWidth = (constraints.maxWidth - ((crossAxisCount - 1) * 12)) / crossAxisCount;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _summaryCard(
                    width: itemWidth,
                    title: 'Total Customers',
                    value: '${_service.totalCustomers}',
                    subtitle: 'Registered Members',
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFF2563EB),
                    badge: 'Active',
                  ),
                  _summaryCard(
                    width: itemWidth,
                    title: 'Active Accounts',
                    value: '${_service.activeAccountsCount}',
                    subtitle: 'Savings & Current',
                    icon: Icons.account_balance_wallet_rounded,
                    color: const Color(0xFF0D9488),
                    badge: 'CASA',
                  ),
                  _summaryCard(
                    width: itemWidth,
                    title: 'Total Deposits',
                    value: _formatCurrency(_service.totalDeposits),
                    subtitle: 'CASA + Term Deposits',
                    icon: Icons.savings_rounded,
                    color: const Color(0xFF107559),
                  ),
                  _summaryCard(
                    width: itemWidth,
                    title: 'Total Loan Portfolio',
                    value: _formatCurrency(_service.totalLoanPortfolio),
                    subtitle: 'Principal Outstanding',
                    icon: Icons.account_balance_rounded,
                    color: const Color(0xFF4F46E5),
                  ),
                  _summaryCard(
                    width: itemWidth,
                    title: 'Today’s Deposits',
                    value: _formatCurrency(_service.todayDeposits),
                    subtitle: 'Cash & Inward Transfers',
                    icon: Icons.arrow_downward_rounded,
                    color: const Color(0xFF16A34A),
                  ),
                  _summaryCard(
                    width: itemWidth,
                    title: 'Today’s Withdrawals',
                    value: _formatCurrency(_service.todayWithdrawals),
                    subtitle: 'Cash Desk & Payouts',
                    icon: Icons.arrow_upward_rounded,
                    color: const Color(0xFFEA580C),
                  ),
                  _summaryCard(
                    width: itemWidth,
                    title: 'Today’s Loan Collections',
                    value: _formatCurrency(_service.todayLoanCollections),
                    subtitle: 'EMI & Principle Repaid',
                    icon: Icons.payments_rounded,
                    color: const Color(0xFF0891B2),
                  ),
                  _summaryCard(
                    width: itemWidth,
                    title: 'Pending Approvals',
                    value: '${_service.pendingApprovalsCount}',
                    subtitle: 'Loan Underwriting',
                    icon: Icons.pending_actions_rounded,
                    color: const Color(0xFFD97706),
                    badge: _service.pendingApprovalsCount > 0 ? 'Action Req' : null,
                    badgeColor: Colors.amber.shade900,
                  ),
                  _summaryCard(
                    width: itemWidth,
                    title: 'Overdue Loans',
                    value: '${_service.overdueLoansCount}',
                    subtitle: 'Past Scheduled Due',
                    icon: Icons.warning_amber_rounded,
                    color: const Color(0xFFDC2626),
                    badge: _service.overdueLoansCount > 0 ? 'Attention' : null,
                    badgeColor: const Color(0xFFDC2626),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Quick Action Launcher
          const Text(
            'Quick Operations',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openAddMemberDialog(),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Member'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF107559),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openOpenAccountDialog(),
                  icon: const Icon(Icons.account_balance_wallet),
                  label: const Text('Open A/C'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _currentTabIndex = 3),
                  icon: const Icon(Icons.paid),
                  label: const Text('Cash Desk'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Branch Activity
          const Text(
            "Today's Activity Feed",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ..._service.transactions.take(8).map((t) {
            final isCredit = t.type == 'CREDIT';
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isCredit ? Colors.green.shade50 : Colors.red.shade50,
                  child: Icon(
                    isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isCredit ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ),
                title: Text(
                  t.narration.isNotEmpty ? t.narration : t.category,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                subtitle: Text(
                  'A/C ${t.accountNumber} • ${t.timestamp}',
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isCredit ? '+' : '-'}₹${t.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    InkWell(
                      onTap: () => ReceiptDialog.show(context, t),
                      child: const Text('Slip', style: TextStyle(color: Colors.blue, fontSize: 11, decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    String result = '';
    int len = integerPart.length;
    if (len <= 3) {
      result = integerPart;
    } else {
      result = integerPart.substring(len - 3);
      int remaining = len - 3;
      while (remaining > 0) {
        if (remaining >= 2) {
          result = '${integerPart.substring(remaining - 2, remaining)},$result';
          remaining -= 2;
        } else {
          result = '${integerPart.substring(0, remaining)},$result';
          remaining = 0;
        }
      }
    }
    return '₹$result.$decimalPart';
  }

  Widget _summaryCard({
    required double width,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    String? badge,
    Color? badgeColor,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? color).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: badgeColor ?? color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: MEMBERS & KYC
  // ==========================================
  Widget _buildMembersTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddMemberDialog,
        backgroundColor: const Color(0xFF107559),
        icon: const Icon(Icons.person_add),
        label: const Text('New Member'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _service.members.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final m = _service.members[index];
          final accounts = _service.getAccountsForMember(m.id);
          final loans = _service.getLoansForMember(m.id);

          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('${m.memberNumber} • ${m.occupation}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          m.kycStatus,
                          style: TextStyle(color: Colors.green.shade800, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(m.mobile, style: const TextStyle(fontSize: 12)),
                      const Spacer(),
                      Text(
                        '${accounts.length} Accounts • ${loans.length} Loans',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // TAB 2: ACCOUNTS
  // ==========================================
  Widget _buildAccountsTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openOpenAccountDialog,
        backgroundColor: const Color(0xFF107559),
        icon: const Icon(Icons.add),
        label: const Text('Open Account'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _service.accounts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final a = _service.accounts[index];
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: a.accountType == 'SAVINGS' ? const Color(0xFFECFDF5) : Colors.indigo.shade50,
                child: Icon(
                  Icons.account_balance,
                  color: a.accountType == 'SAVINGS' ? const Color(0xFF107559) : Colors.indigo.shade800,
                ),
              ),
              title: Text(a.accountName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text('${a.accountNumber} • ${a.productName}', style: const TextStyle(fontSize: 12)),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${a.balance.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF107559)),
                  ),
                  Text(
                    'Avail: ₹${a.availableBalance.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // TAB 3: TELLER COUNTER
  // ==========================================
  Widget _buildTellerTab() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.grey.shade100,
            child: const TabBar(
              labelColor: Color(0xFF107559),
              indicatorColor: Color(0xFF107559),
              tabs: [
                Tab(icon: Icon(Icons.download, size: 18), text: 'Cash Deposit'),
                Tab(icon: Icon(Icons.upload, size: 18), text: 'Cash Withdrawal'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildTellerDepositForm(),
            _buildTellerWithdrawForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildTellerDepositForm() {
    String? selectedAccId = _service.accounts.isNotEmpty ? _service.accounts.first.id : null;
    final amountController = TextEditingController();
    final narrationController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setSubState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: selectedAccId,
                decoration: const InputDecoration(labelText: 'Customer Account', border: OutlineInputBorder()),
                items: _service.accounts.map((a) {
                  return DropdownMenuItem(
                    value: a.id,
                    child: Text('${a.accountNumber} - ${a.accountName}'),
                  );
                }).toList(),
                onChanged: (val) => setSubState(() => selectedAccId = val),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Deposit Amount (₹)',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: narrationController,
                decoration: const InputDecoration(
                  labelText: 'Remarks / Narration',
                  hintText: 'Counter cash deposit',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final amt = double.tryParse(amountController.text.trim()) ?? 0;
                    if (amt <= 0 || selectedAccId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid deposit amount')),
                      );
                      return;
                    }
                    try {
                      final txn = _service.depositCash(
                        accountId: selectedAccId!,
                        amount: amt,
                        narration: narrationController.text.trim(),
                        tellerId: _selectedRole,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Deposit of ₹$amt completed successfully!')),
                      );
                      ReceiptDialog.show(context, txn);
                      amountController.clear();
                      narrationController.clear();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Process Cash Deposit & Print Slip'),
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

  Widget _buildTellerWithdrawForm() {
    String? selectedAccId = _service.accounts.isNotEmpty ? _service.accounts.first.id : null;
    final amountController = TextEditingController();
    final narrationController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setSubState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: selectedAccId,
                decoration: const InputDecoration(labelText: 'Source Customer Account', border: OutlineInputBorder()),
                items: _service.accounts.map((a) {
                  return DropdownMenuItem(
                    value: a.id,
                    child: Text('${a.accountNumber} - ${a.accountName} (₹${a.availableBalance})'),
                  );
                }).toList(),
                onChanged: (val) => setSubState(() => selectedAccId = val),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Withdrawal Amount (₹)',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: narrationController,
                decoration: const InputDecoration(
                  labelText: 'Narration / Voucher #',
                  hintText: 'Cash withdrawal voucher',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final amt = double.tryParse(amountController.text.trim()) ?? 0;
                    if (amt <= 0 || selectedAccId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid amount')),
                      );
                      return;
                    }
                    try {
                      final txn = _service.withdrawCash(
                        accountId: selectedAccId!,
                        amount: amt,
                        narration: narrationController.text.trim(),
                        tellerId: _selectedRole,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Dispensed ₹$amt successfully!')),
                      );
                      ReceiptDialog.show(context, txn);
                      amountController.clear();
                      narrationController.clear();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  icon: const Icon(Icons.payments),
                  label: const Text('Authorize & Dispense Cash'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
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
  // TAB 4: LOANS
  // ==========================================
  Widget _buildLoansTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _service.loans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final loan = _service.loans[index];
        final isPending = loan.status == 'PENDING_APPROVAL';
        final isApproved = loan.status == 'APPROVED';

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loan.loanNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace')),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPending ? Colors.amber.shade50 : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isPending ? Colors.amber : Colors.green),
                      ),
                      child: Text(
                        loan.status,
                        style: TextStyle(
                          color: isPending ? Colors.amber.shade900 : Colors.green.shade900,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(loan.borrowerName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text(loan.loanType, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Principal: ₹${loan.principalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
                    Text('EMI: ₹${loan.emiAmount.toStringAsFixed(0)} / mo', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (isPending) ...[
                  const Divider(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _service.approveLoan(loan.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Loan ${loan.loanNumber} Approved!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF107559), foregroundColor: Colors.white),
                      child: const Text('Approve Loan Application'),
                    ),
                  ),
                ] else if (isApproved) ...[
                  const Divider(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        try {
                          _service.disburseLoan(loan.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Disbursed ₹${loan.principalAmount} to borrower!')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
                      child: const Text('Disburse Capital into Account'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // DIALOGS
  // ==========================================
  void _openAddMemberDialog() {
    final nameCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final occCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Onboard New Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name *')),
              TextField(controller: mobileCtrl, decoration: const InputDecoration(labelText: 'Mobile Number *')),
              TextField(controller: occCtrl, decoration: const InputDecoration(labelText: 'Occupation')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty || mobileCtrl.text.isEmpty) return;
              _service.addMember(
                fullName: nameCtrl.text.trim(),
                mobile: mobileCtrl.text.trim(),
                dob: '1992-05-15',
                gender: 'Not Specified',
                occupation: occCtrl.text.trim().isNotEmpty ? occCtrl.text.trim() : 'Self Employed',
                street: 'Main Road',
                district: 'Jaipur',
                state: 'Rajasthan',
                pincode: '302001',
                idType: 'Aadhaar Card',
                idNumber: 'XXXX-XXXX-9912',
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Member added successfully!')),
              );
            },
            child: const Text('Save Member'),
          ),
        ],
      ),
    );
  }

  void _openOpenAccountDialog() {
    if (_service.members.isEmpty) return;
    String memberId = _service.members.first.id;
    String accType = 'SAVINGS';
    final depositCtrl = TextEditingController(text: '1000');

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('Open Customer Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: memberId,
                decoration: const InputDecoration(labelText: 'Select Member'),
                items: _service.members.map((m) => DropdownMenuItem(value: m.id, child: Text(m.fullName))).toList(),
                onChanged: (v) => setDlgState(() => memberId = v!),
              ),
              DropdownButtonFormField<String>(
                value: accType,
                decoration: const InputDecoration(labelText: 'Account Type'),
                items: const [
                  DropdownMenuItem(value: 'SAVINGS', child: Text('Savings Account (4.0% p.a.)')),
                  DropdownMenuItem(value: 'CURRENT', child: Text('Current Account (0.0%)')),
                ],
                onChanged: (v) => setDlgState(() => accType = v!),
              ),
              TextField(
                controller: depositCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Opening Deposit (₹)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final dep = double.tryParse(depositCtrl.text) ?? 0.0;
                _service.openAccount(
                  memberId: memberId,
                  accountType: accType,
                  productName: accType == 'SAVINGS' ? 'Standard Savings Plus' : 'Smart Merchant Current',
                  interestRate: accType == 'SAVINGS' ? 4.0 : 0.0,
                  openingDeposit: dep,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account opened successfully!')),
                );
              },
              child: const Text('Open Account'),
            ),
          ],
        ),
      ),
    );
  }
}
