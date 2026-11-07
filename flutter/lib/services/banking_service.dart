import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/banking_models.dart';

class BankingService extends ChangeNotifier {
  static final BankingService _instance = BankingService._internal();
  factory BankingService() => _instance;
  BankingService._internal() {
    _seedInitialData();
  }

  // Repository State
  final List<MemberModel> _members = [];
  final List<CustomerAccountModel> _accounts = [];
  final List<TransactionModel> _transactions = [];
  final List<LoanModel> _loans = [];
  final List<TermDepositModel> _termDeposits = [];

  double vaultCash = 2450000.00;
  double tellerDrawerCash = 350000.00;

  // Getters
  List<MemberModel> get members => List.unmodifiable(_members);
  List<CustomerAccountModel> get accounts => List.unmodifiable(_accounts);
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<LoanModel> get loans => List.unmodifiable(_loans);
  List<TermDepositModel> get termDeposits => List.unmodifiable(_termDeposits);

  MemberModel? getMemberById(String id) {
    try {
      return _members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  CustomerAccountModel? getAccountById(String id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  CustomerAccountModel? getAccountByNumber(String num) {
    try {
      return _accounts.firstWhere((a) => a.accountNumber == num.trim());
    } catch (_) {
      return null;
    }
  }

  List<CustomerAccountModel> getAccountsForMember(String memberId) {
    return _accounts.where((a) => a.memberId == memberId).toList();
  }

  List<LoanModel> getLoansForMember(String memberId) {
    return _loans.where((l) => l.memberId == memberId).toList();
  }

  List<TermDepositModel> getTermDepositsForMember(String memberId) {
    return _termDeposits.where((td) => td.memberId == memberId).toList();
  }

  List<TransactionModel> getTransactionsForAccount(String accountId) {
    return _transactions.where((t) => t.accountId == accountId).toList();
  }

  void _seedInitialData() {
    _members.addAll([
      MemberModel(
        id: 'MEM001',
        memberNumber: 'MEM-10001',
        fullName: 'Rajesh Kumar',
        mobile: '9876543210',
        dob: '1984-06-15',
        gender: 'Male',
        occupation: 'Progressive Farmer',
        street: 'Village Rampur',
        district: 'Alwar',
        state: 'Rajasthan',
        pincode: '301001',
        idType: 'Aadhaar Card',
        idNumber: 'XXXX-XXXX-8921',
        kycStatus: 'VERIFIED',
        status: 'ACTIVE',
        joinedAt: '2026-01-10',
      ),
      MemberModel(
        id: 'MEM002',
        memberNumber: 'MEM-10002',
        fullName: 'Priya Sharma',
        mobile: '9811223344',
        email: 'priya.sharma@example.com',
        dob: '1991-09-22',
        gender: 'Female',
        occupation: 'Retail Merchant',
        street: 'Shop 14, Main Market Road',
        district: 'Jaipur',
        state: 'Rajasthan',
        pincode: '302001',
        idType: 'Aadhaar Card',
        idNumber: 'XXXX-XXXX-4512',
        pan: 'BRGPS5678K',
        kycStatus: 'VERIFIED',
        status: 'ACTIVE',
        joinedAt: '2026-01-15',
      ),
      MemberModel(
        id: 'MEM003',
        memberNumber: 'MEM-10003',
        fullName: 'Amit Patel',
        mobile: '9822334455',
        dob: '1988-12-05',
        gender: 'Male',
        occupation: 'Logistics Fleet Driver',
        street: 'Flat 204, Shanti Heights',
        district: 'Jaipur',
        state: 'Rajasthan',
        pincode: '302004',
        idType: 'Voter ID',
        idNumber: 'VTR889212',
        kycStatus: 'VERIFIED',
        status: 'ACTIVE',
        joinedAt: '2026-02-01',
      ),
      MemberModel(
        id: 'MEM004',
        memberNumber: 'MEM-10004',
        fullName: 'Sunita Devi',
        mobile: '9833445566',
        dob: '1985-03-18',
        gender: 'Female',
        occupation: 'SHG Leader - Handloom',
        street: 'Ward 3, Near Primary School',
        district: 'Dausa',
        state: 'Rajasthan',
        pincode: '303303',
        idType: 'Aadhaar Card',
        idNumber: 'XXXX-XXXX-7711',
        kycStatus: 'VERIFIED',
        status: 'ACTIVE',
        joinedAt: '2026-02-12',
      ),
    ]);

    _accounts.addAll([
      CustomerAccountModel(
        id: 'ACC1001',
        accountNumber: '1001002341',
        memberId: 'MEM001',
        accountName: 'Rajesh Kumar',
        accountType: 'SAVINGS',
        productName: 'Kisan Samriddhi Savings',
        interestRate: 4.5,
        balance: 54250.00,
        availableBalance: 54250.00,
        minBalance: 500.00,
        status: 'ACTIVE',
        openedAt: '2026-01-10',
        debitCard: DebitCardModel(
          cardNumber: '4218 8901 2345 6789',
          expiry: '09/29',
          cvv: '542',
          isLocked: false,
          onlineTxnEnabled: true,
          atmLimit: 25000,
          pin: '1234',
        ),
      ),
      CustomerAccountModel(
        id: 'ACC1002',
        accountNumber: '1001004562',
        memberId: 'MEM002',
        accountName: 'Priya Sharma (M/s Sharma Traders)',
        accountType: 'CURRENT',
        productName: 'Smart Merchant Current',
        interestRate: 0.0,
        balance: 185400.00,
        availableBalance: 185400.00,
        minBalance: 2000.00,
        status: 'ACTIVE',
        openedAt: '2026-01-15',
        debitCard: DebitCardModel(
          cardNumber: '4218 9912 3456 7810',
          expiry: '11/30',
          cvv: '819',
          isLocked: false,
          onlineTxnEnabled: true,
          atmLimit: 50000,
          pin: '4321',
        ),
      ),
      CustomerAccountModel(
        id: 'ACC1003',
        accountNumber: '1001007893',
        memberId: 'MEM003',
        accountName: 'Amit Patel',
        accountType: 'SAVINGS',
        productName: 'Standard Savings Plus',
        interestRate: 4.0,
        balance: 14800.00,
        availableBalance: 14800.00,
        minBalance: 500.00,
        status: 'ACTIVE',
        openedAt: '2026-02-01',
      ),
      CustomerAccountModel(
        id: 'ACC1004',
        accountNumber: '1001008904',
        memberId: 'MEM004',
        accountName: 'Sunita Devi',
        accountType: 'SAVINGS',
        productName: 'Mahila Utkarsh Savings',
        interestRate: 5.0,
        balance: 38900.00,
        availableBalance: 38900.00,
        minBalance: 200.00,
        status: 'ACTIVE',
        openedAt: '2026-02-12',
      ),
    ]);

    _loans.addAll([
      LoanModel(
        id: 'LN5001',
        loanNumber: 'LN-2026-0081',
        memberId: 'MEM002',
        borrowerName: 'Priya Sharma',
        linkedAccountId: 'ACC1002',
        loanType: 'MSME Business Expansion',
        principalAmount: 200000.00,
        outstandingPrincipal: 145000.00,
        interestRate: 11.5,
        termMonths: 24,
        repaidMonths: 6,
        emiAmount: 9370.00,
        nextDueDate: '2026-11-05',
        status: 'ACTIVE',
        appliedAt: '2026-01-18',
        approvedAt: '2026-01-20',
        disbursedAt: '2026-01-21',
      ),
      LoanModel(
        id: 'LN5002',
        loanNumber: 'LN-2026-0094',
        memberId: 'MEM004',
        borrowerName: 'Sunita Devi',
        linkedAccountId: 'ACC1004',
        loanType: 'Microfinance SHG Group Loan',
        principalAmount: 50000.00,
        outstandingPrincipal: 22000.00,
        interestRate: 10.0,
        termMonths: 12,
        repaidMonths: 7,
        emiAmount: 4395.00,
        nextDueDate: '2026-11-10',
        status: 'ACTIVE',
        appliedAt: '2026-02-15',
        approvedAt: '2026-02-16',
        disbursedAt: '2026-02-17',
      ),
      LoanModel(
        id: 'LN5003',
        loanNumber: 'LN-2026-0105',
        memberId: 'MEM001',
        borrowerName: 'Rajesh Kumar',
        linkedAccountId: 'ACC1001',
        loanType: 'Agri Equipment & Solar Pump',
        principalAmount: 150000.00,
        outstandingPrincipal: 150000.00,
        interestRate: 9.25,
        termMonths: 36,
        repaidMonths: 0,
        emiAmount: 4785.00,
        nextDueDate: '2026-11-15',
        status: 'PENDING_APPROVAL',
        appliedAt: '2026-10-20',
      ),
    ]);

    _termDeposits.addAll([
      TermDepositModel(
        id: 'FD2001',
        certificateNumber: 'FD-2026-001',
        memberId: 'MEM002',
        linkedAccountId: 'ACC1002',
        type: 'FIXED_DEPOSIT',
        principal: 100000.00,
        interestRate: 7.75,
        termMonths: 12,
        maturityAmount: 107750.00,
        startDate: '2026-01-20',
        maturityDate: '2027-01-20',
        status: 'ACTIVE',
      ),
      TermDepositModel(
        id: 'RD3001',
        certificateNumber: 'RD-2026-002',
        memberId: 'MEM001',
        linkedAccountId: 'ACC1001',
        type: 'RECURRING_DEPOSIT',
        principal: 6000.00,
        interestRate: 7.25,
        termMonths: 12,
        maturityAmount: 24960.00,
        startDate: '2026-01-15',
        maturityDate: '2027-01-15',
        status: 'ACTIVE',
      ),
    ]);

    _transactions.addAll([
      TransactionModel(
        id: 'TXN88201',
        txnNumber: 'TXN-20261024-001',
        accountId: 'ACC1001',
        accountNumber: '1001002341',
        memberId: 'MEM001',
        type: 'CREDIT',
        category: 'DEPOSIT',
        channel: 'TELLER_CASH',
        amount: 15000.00,
        balanceAfter: 54250.00,
        reference: 'DEP-CASH-8812',
        narration: 'Cash deposit at Teller counter',
        initiatedBy: 'TELLER',
        timestamp: '2026-10-24 10:15:30',
      ),
      TransactionModel(
        id: 'TXN88202',
        txnNumber: 'TXN-20261024-002',
        accountId: 'ACC1002',
        accountNumber: '1001004562',
        memberId: 'MEM002',
        type: 'CREDIT',
        category: 'UPI_INWARD',
        channel: 'DIGITAL',
        amount: 24500.00,
        balanceAfter: 185400.00,
        reference: 'UPI/2948291039',
        narration: 'Customer payment received via QR',
        initiatedBy: 'CUSTOMER',
        timestamp: '2026-10-24 11:20:00',
      ),
      TransactionModel(
        id: 'TXN88203',
        txnNumber: 'TXN-20261023-014',
        accountId: 'ACC1002',
        accountNumber: '1001004562',
        memberId: 'MEM002',
        type: 'DEBIT',
        category: 'LOAN_EMI',
        channel: 'AUTO_DEBIT',
        amount: 9370.00,
        balanceAfter: 160900.00,
        reference: 'EMI-LN5001-M06',
        narration: 'Auto-debit EMI for Loan LN-2026-0081',
        initiatedBy: 'SYSTEM',
        timestamp: '2026-10-23 05:00:10',
      ),
    ]);
  }

  // ==========================================
  // BANKING OPERATIONS
  // ==========================================

  MemberModel addMember({
    required String fullName,
    required String mobile,
    String? email,
    required String dob,
    required String gender,
    required String occupation,
    required String street,
    required String district,
    required String state,
    required String pincode,
    required String idType,
    required String idNumber,
    String? pan,
  }) {
    final nextSeq = _members.length + 1;
    final member = MemberModel(
      id: 'MEM${nextSeq.toString().padLeft(3, '0')}',
      memberNumber: 'MEM-${10000 + nextSeq}',
      fullName: fullName,
      mobile: mobile,
      email: email,
      dob: dob,
      gender: gender,
      occupation: occupation,
      street: street,
      district: district,
      state: state,
      pincode: pincode,
      idType: idType,
      idNumber: idNumber,
      pan: pan,
      kycStatus: 'VERIFIED',
      status: 'ACTIVE',
      joinedAt: DateTime.now().toString().split(' ')[0],
    );

    _members.insert(0, member);
    notifyListeners();
    return member;
  }

  CustomerAccountModel openAccount({
    required String memberId,
    required String accountType,
    required String productName,
    required double interestRate,
    required double openingDeposit,
  }) {
    final member = getMemberById(memberId);
    if (member == null) throw Exception('Member not found');

    final nextSeq = _accounts.length + 1;
    final acc = CustomerAccountModel(
      id: 'ACC${1000 + nextSeq}',
      accountNumber: '100100${5000 + nextSeq}',
      memberId: member.id,
      accountName: member.fullName,
      accountType: accountType,
      productName: productName,
      interestRate: interestRate,
      balance: openingDeposit,
      availableBalance: openingDeposit,
      minBalance: accountType == 'CURRENT' ? 2000.0 : 500.0,
      status: 'ACTIVE',
      openedAt: DateTime.now().toString().split(' ')[0],
      debitCard: DebitCardModel(
        cardNumber: '4218 ${Random().nextInt(9000) + 1000} ${Random().nextInt(9000) + 1000} ${Random().nextInt(9000) + 1000}',
        expiry: '12/31',
        cvv: '${Random().nextInt(900) + 100}',
        isLocked: false,
        onlineTxnEnabled: true,
        atmLimit: 25000,
        pin: '1234',
      ),
    );

    _accounts.insert(0, acc);

    if (openingDeposit > 0) {
      final txn = TransactionModel(
        id: 'TXN${Random().nextInt(90000) + 10000}',
        txnNumber: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        accountId: acc.id,
        accountNumber: acc.accountNumber,
        memberId: member.id,
        type: 'CREDIT',
        category: 'OPENING_DEPOSIT',
        channel: 'TELLER_CASH',
        amount: openingDeposit,
        balanceAfter: openingDeposit,
        reference: 'OPEN-${acc.accountNumber}',
        narration: 'Opening Cash Deposit',
        initiatedBy: 'TELLER',
        timestamp: DateTime.now().toString().split('.')[0],
      );
      _transactions.insert(0, txn);
      tellerDrawerCash += openingDeposit;
    }

    notifyListeners();
    return acc;
  }

  TransactionModel depositCash({
    required String accountId,
    required double amount,
    Map<int, int>? denominations,
    String? reference,
    String? narration,
    String tellerId = 'TELLER',
  }) {
    if (amount <= 0) throw Exception('Amount must be positive');
    final account = getAccountById(accountId);
    if (account == null) throw Exception('Account not found');

    account.balance += amount;
    account.availableBalance += amount;
    tellerDrawerCash += amount;

    final txn = TransactionModel(
      id: 'TXN${Random().nextInt(90000) + 10000}',
      txnNumber: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      accountId: account.id,
      accountNumber: account.accountNumber,
      memberId: account.memberId,
      type: 'CREDIT',
      category: 'DEPOSIT',
      channel: 'TELLER_CASH',
      amount: amount,
      balanceAfter: account.balance,
      reference: reference?.isNotEmpty == true ? reference! : 'DEP-${Random().nextInt(900000) + 100000}',
      narration: narration?.isNotEmpty == true ? narration! : 'Cash deposit at Teller desk',
      initiatedBy: tellerId,
      timestamp: DateTime.now().toString().split('.')[0],
      denominations: denominations,
    );

    _transactions.insert(0, txn);
    notifyListeners();
    return txn;
  }

  TransactionModel withdrawCash({
    required String accountId,
    required double amount,
    String? reference,
    String? narration,
    String tellerId = 'TELLER',
  }) {
    if (amount <= 0) throw Exception('Amount must be positive');
    final account = getAccountById(accountId);
    if (account == null) throw Exception('Account not found');

    if (account.availableBalance < amount) {
      throw Exception('Insufficient funds. Available: ₹${account.availableBalance.toStringAsFixed(2)}');
    }

    account.balance -= amount;
    account.availableBalance -= amount;
    tellerDrawerCash -= amount;

    final txn = TransactionModel(
      id: 'TXN${Random().nextInt(90000) + 10000}',
      txnNumber: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      accountId: account.id,
      accountNumber: account.accountNumber,
      memberId: account.memberId,
      type: 'DEBIT',
      category: 'WITHDRAWAL',
      channel: 'TELLER_CASH',
      amount: amount,
      balanceAfter: account.balance,
      reference: reference?.isNotEmpty == true ? reference! : 'WDL-${Random().nextInt(900000) + 100000}',
      narration: narration?.isNotEmpty == true ? narration! : 'Cash withdrawal at Teller desk',
      initiatedBy: tellerId,
      timestamp: DateTime.now().toString().split('.')[0],
    );

    _transactions.insert(0, txn);
    notifyListeners();
    return txn;
  }

  void transferFunds({
    required String fromAccountId,
    required String toAccountNumber,
    required double amount,
    String? narration,
    String initiatedBy = 'CUSTOMER',
  }) {
    if (amount <= 0) throw Exception('Amount must be positive');
    final from = getAccountById(fromAccountId);
    if (from == null) throw Exception('Source account not found');
    if (from.availableBalance < amount) throw Exception('Insufficient funds');

    final to = getAccountByNumber(toAccountNumber);
    if (to == null) throw Exception('Recipient account $toAccountNumber not found');
    if (from.id == to.id) throw Exception('Cannot transfer to same account');

    from.balance -= amount;
    from.availableBalance -= amount;

    to.balance += amount;
    to.availableBalance += amount;

    final ref = 'TRF-${Random().nextInt(900000) + 100000}';
    final now = DateTime.now().toString().split('.')[0];

    final debitTxn = TransactionModel(
      id: 'TXN${Random().nextInt(90000) + 10000}',
      txnNumber: 'TXN-${DateTime.now().millisecondsSinceEpoch}-D',
      accountId: from.id,
      accountNumber: from.accountNumber,
      memberId: from.memberId,
      type: 'DEBIT',
      category: 'TRANSFER',
      channel: 'DIGITAL',
      amount: amount,
      balanceAfter: from.balance,
      reference: ref,
      narration: narration?.isNotEmpty == true ? narration! : 'Transfer to A/C ${to.accountNumber} (${to.accountName})',
      initiatedBy: initiatedBy,
      timestamp: now,
    );

    final creditTxn = TransactionModel(
      id: 'TXN${Random().nextInt(90000) + 10000}',
      txnNumber: 'TXN-${DateTime.now().millisecondsSinceEpoch}-C',
      accountId: to.id,
      accountNumber: to.accountNumber,
      memberId: to.memberId,
      type: 'CREDIT',
      category: 'TRANSFER',
      channel: 'DIGITAL',
      amount: amount,
      balanceAfter: to.balance,
      reference: ref,
      narration: narration?.isNotEmpty == true ? narration! : 'Received from A/C ${from.accountNumber} (${from.accountName})',
      initiatedBy: initiatedBy,
      timestamp: now,
    );

    _transactions.insert(0, debitTxn);
    _transactions.insert(0, creditTxn);
    notifyListeners();
  }

  void approveLoan(String loanId) {
    final loan = _loans.firstWhere((l) => l.id == loanId);
    loan.status = 'APPROVED';
    loan.approvedAt = DateTime.now().toString().split(' ')[0];
    notifyListeners();
  }

  void disburseLoan(String loanId) {
    final loan = _loans.firstWhere((l) => l.id == loanId);
    final account = getAccountById(loan.linkedAccountId);
    if (account == null) throw Exception('Linked account not found');

    loan.status = 'ACTIVE';
    loan.disbursedAt = DateTime.now().toString().split(' ')[0];

    account.balance += loan.principalAmount;
    account.availableBalance += loan.principalAmount;
    vaultCash -= loan.principalAmount;

    final txn = TransactionModel(
      id: 'TXN${Random().nextInt(90000) + 10000}',
      txnNumber: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      accountId: account.id,
      accountNumber: account.accountNumber,
      memberId: loan.memberId,
      type: 'CREDIT',
      category: 'LOAN_DISBURSEMENT',
      channel: 'SYSTEM',
      amount: loan.principalAmount,
      balanceAfter: account.balance,
      reference: 'DISB-${loan.loanNumber}',
      narration: 'Disbursement of ${loan.loanType}',
      initiatedBy: 'MANAGER',
      timestamp: DateTime.now().toString().split('.')[0],
    );

    _transactions.insert(0, txn);
    notifyListeners();
  }

  void repayLoanEMI({
    required String loanId,
    required double amount,
    String? accountId,
    String initiatedBy = 'CUSTOMER',
  }) {
    final loan = _loans.firstWhere((l) => l.id == loanId);
    final account = accountId != null ? getAccountById(accountId) : getAccountById(loan.linkedAccountId);
    if (account == null) throw Exception('Account not found');
    if (account.availableBalance < amount) throw Exception('Insufficient balance');

    account.balance -= amount;
    account.availableBalance -= amount;

    loan.repaidMonths += 1;
    final principalPaid = min(loan.outstandingPrincipal, amount * 0.72);
    loan.outstandingPrincipal = max(0.0, loan.outstandingPrincipal - principalPaid);

    if (loan.outstandingPrincipal <= 0) {
      loan.status = 'CLOSED';
    }

    final txn = TransactionModel(
      id: 'TXN${Random().nextInt(90000) + 10000}',
      txnNumber: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      accountId: account.id,
      accountNumber: account.accountNumber,
      memberId: loan.memberId,
      type: 'DEBIT',
      category: 'LOAN_EMI',
      channel: 'DIGITAL',
      amount: amount,
      balanceAfter: account.balance,
      reference: 'EMI-${loan.loanNumber}-M${loan.repaidMonths}',
      narration: 'EMI Payment for Loan ${loan.loanNumber}',
      initiatedBy: initiatedBy,
      timestamp: DateTime.now().toString().split('.')[0],
    );

    _transactions.insert(0, txn);
    notifyListeners();
  }

  void createTermDeposit({
    required String memberId,
    required String linkedAccountId,
    required String type,
    required double principal,
    required int termMonths,
    required double interestRate,
  }) {
    final account = getAccountById(linkedAccountId);
    if (account == null) throw Exception('Savings account not found');
    if (account.availableBalance < principal) throw Exception('Insufficient balance');

    account.balance -= principal;
    account.availableBalance -= principal;

    final nextSeq = _termDeposits.length + 1;
    final certNum = '${type == 'FIXED_DEPOSIT' ? 'FD' : 'RD'}-2026-${nextSeq.toString().padLeft(3, '0')}';
    final maturity = principal + (principal * (interestRate / 100) * (termMonths / 12));

    final td = TermDepositModel(
      id: 'TD${2000 + nextSeq}',
      certificateNumber: certNum,
      memberId: memberId,
      linkedAccountId: account.id,
      type: type,
      principal: principal,
      interestRate: interestRate,
      termMonths: termMonths,
      maturityAmount: maturity,
      startDate: DateTime.now().toString().split(' ')[0],
      maturityDate: DateTime.now().add(Duration(days: termMonths * 30)).toString().split(' ')[0],
      status: 'ACTIVE',
    );

    _termDeposits.insert(0, td);

    final txn = TransactionModel(
      id: 'TXN${Random().nextInt(90000) + 10000}',
      txnNumber: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      accountId: account.id,
      accountNumber: account.accountNumber,
      memberId: memberId,
      type: 'DEBIT',
      category: type,
      channel: 'DIGITAL',
      amount: principal,
      balanceAfter: account.balance,
      reference: certNum,
      narration: 'Created $type Certificate $certNum',
      initiatedBy: 'CUSTOMER',
      timestamp: DateTime.now().toString().split('.')[0],
    );

    _transactions.insert(0, txn);
    notifyListeners();
  }

  void toggleCardLock(String accountId) {
    final acc = getAccountById(accountId);
    if (acc != null && acc.debitCard != null) {
      acc.debitCard!.isLocked = !acc.debitCard!.isLocked;
      notifyListeners();
    }
  }
}
