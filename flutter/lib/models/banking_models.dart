// SFMS Core Banking & Customer Domain Models

class MemberModel {
  final String id;
  final String memberNumber;
  final String fullName;
  final String mobile;
  final String? email;
  final String dob;
  final String gender;
  final String occupation;
  final String street;
  final String district;
  final String state;
  final String pincode;
  final String idType;
  final String idNumber;
  final String? pan;
  final String kycStatus;
  final String status;
  final String joinedAt;

  MemberModel({
    required this.id,
    required this.memberNumber,
    required this.fullName,
    required this.mobile,
    this.email,
    required this.dob,
    required this.gender,
    required this.occupation,
    required this.street,
    required this.district,
    required this.state,
    required this.pincode,
    required this.idType,
    required this.idNumber,
    this.pan,
    required this.kycStatus,
    required this.status,
    required this.joinedAt,
  });

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      id: map['id']?.toString() ?? '',
      memberNumber: map['member_number']?.toString() ?? map['memberNumber']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? map['fullName']?.toString() ?? '',
      mobile: map['mobile']?.toString() ?? '',
      email: map['email']?.toString(),
      dob: map['dob']?.toString() ?? map['date_of_birth']?.toString() ?? '1990-01-01',
      gender: map['gender']?.toString() ?? 'Not Specified',
      occupation: map['occupation']?.toString() ?? 'Self Employed',
      street: map['street']?.toString() ?? map['address']?.toString() ?? '',
      district: map['district']?.toString() ?? 'Jaipur',
      state: map['state']?.toString() ?? 'Rajasthan',
      pincode: map['pincode']?.toString() ?? '302001',
      idType: map['id_type']?.toString() ?? map['idType']?.toString() ?? 'Aadhaar Card',
      idNumber: map['id_number']?.toString() ?? map['idNumber']?.toString() ?? 'XXXX-XXXX-1234',
      pan: map['pan']?.toString(),
      kycStatus: map['kyc_status']?.toString() ?? map['kycStatus']?.toString() ?? 'VERIFIED',
      status: map['status']?.toString() ?? map['member_status']?.toString() ?? 'ACTIVE',
      joinedAt: map['joined_at']?.toString() ?? map['created_at']?.toString() ?? '2026-01-01',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'member_number': memberNumber,
      'full_name': fullName,
      'mobile': mobile,
      'email': email,
      'date_of_birth': dob,
      'gender': gender,
      'occupation': occupation,
      'address': street,
      'district': district,
      'state': state,
      'pincode': pincode,
      'id_type': idType,
      'id_number': idNumber,
      'pan': pan,
      'kyc_status': kycStatus,
      'status': status,
      'created_at': joinedAt,
    };
  }
}

class CustomerAccountModel {
  final String id;
  final String accountNumber;
  final String memberId;
  final String accountName;
  final String accountType; // SAVINGS | CURRENT
  final String productName;
  final double interestRate;
  double balance;
  double availableBalance;
  final double minBalance;
  final String status;
  final String openedAt;
  final DebitCardModel? debitCard;

  CustomerAccountModel({
    required this.id,
    required this.accountNumber,
    required this.memberId,
    required this.accountName,
    required this.accountType,
    required this.productName,
    required this.interestRate,
    required this.balance,
    required this.availableBalance,
    required this.minBalance,
    required this.status,
    required this.openedAt,
    this.debitCard,
  });

  factory CustomerAccountModel.fromMap(Map<String, dynamic> map) {
    return CustomerAccountModel(
      id: map['id']?.toString() ?? '',
      accountNumber: map['account_number']?.toString() ?? map['accountNumber']?.toString() ?? '',
      memberId: map['member_id']?.toString() ?? map['memberId']?.toString() ?? '',
      accountName: map['account_name']?.toString() ?? map['accountName']?.toString() ?? '',
      accountType: map['account_type']?.toString() ?? map['accountType']?.toString() ?? 'SAVINGS',
      productName: map['product_name']?.toString() ?? map['productName']?.toString() ?? 'Standard Savings Plus',
      interestRate: (map['interest_rate'] ?? map['interestRate'] ?? 4.0).toDouble(),
      balance: (map['balance'] ?? map['current_balance'] ?? 0.0).toDouble(),
      availableBalance: (map['available_balance'] ?? map['balance'] ?? 0.0).toDouble(),
      minBalance: (map['min_balance'] ?? 500.0).toDouble(),
      status: map['status']?.toString() ?? 'ACTIVE',
      openedAt: map['opened_at']?.toString() ?? map['created_at']?.toString() ?? '2026-01-01',
      debitCard: map['debitCard'] != null ? DebitCardModel.fromMap(map['debitCard']) : null,
    );
  }
}

class DebitCardModel {
  final String cardNumber;
  final String expiry;
  final String cvv;
  bool isLocked;
  bool onlineTxnEnabled;
  int atmLimit;
  String pin;

  DebitCardModel({
    required this.cardNumber,
    required this.expiry,
    required this.cvv,
    required this.isLocked,
    required this.onlineTxnEnabled,
    required this.atmLimit,
    required this.pin,
  });

  factory DebitCardModel.fromMap(Map<String, dynamic> map) {
    return DebitCardModel(
      cardNumber: map['cardNumber']?.toString() ?? '4218 8901 2345 6789',
      expiry: map['expiry']?.toString() ?? '11/30',
      cvv: map['cvv']?.toString() ?? '819',
      isLocked: map['isLocked'] == true,
      onlineTxnEnabled: map['onlineTxnEnabled'] != false,
      atmLimit: (map['atmLimit'] ?? 25000) as int,
      pin: map['pin']?.toString() ?? '1234',
    );
  }
}

class TransactionModel {
  final String id;
  final String txnNumber;
  final String accountId;
  final String accountNumber;
  final String memberId;
  final String type; // CREDIT | DEBIT
  final String category; // DEPOSIT | WITHDRAWAL | TRANSFER | LOAN_EMI
  final String channel;
  final double amount;
  final double balanceAfter;
  final String reference;
  final String narration;
  final String initiatedBy;
  final String timestamp;
  final Map<int, int>? denominations;

  TransactionModel({
    required this.id,
    required this.txnNumber,
    required this.accountId,
    required this.accountNumber,
    required this.memberId,
    required this.type,
    required this.category,
    required this.channel,
    required this.amount,
    required this.balanceAfter,
    required this.reference,
    required this.narration,
    required this.initiatedBy,
    required this.timestamp,
    this.denominations,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id']?.toString() ?? '',
      txnNumber: map['txn_number']?.toString() ?? map['txnNumber']?.toString() ?? '',
      accountId: map['account_id']?.toString() ?? map['accountId']?.toString() ?? '',
      accountNumber: map['account_number']?.toString() ?? map['accountNumber']?.toString() ?? '',
      memberId: map['member_id']?.toString() ?? map['memberId']?.toString() ?? '',
      type: map['type']?.toString() ?? 'CREDIT',
      category: map['category']?.toString() ?? 'DEPOSIT',
      channel: map['channel']?.toString() ?? 'TELLER_CASH',
      amount: (map['amount'] ?? 0.0).toDouble(),
      balanceAfter: (map['balance_after'] ?? map['balanceAfter'] ?? 0.0).toDouble(),
      reference: map['reference']?.toString() ?? '',
      narration: map['narration']?.toString() ?? '',
      initiatedBy: map['initiated_by']?.toString() ?? map['initiatedBy']?.toString() ?? 'SYSTEM',
      timestamp: map['timestamp']?.toString() ?? map['created_at']?.toString() ?? DateTime.now().toString(),
    );
  }
}

class LoanModel {
  final String id;
  final String loanNumber;
  final String memberId;
  final String borrowerName;
  final String linkedAccountId;
  final String loanType;
  final double principalAmount;
  double outstandingPrincipal;
  final double interestRate;
  final int termMonths;
  int repaidMonths;
  final double emiAmount;
  String nextDueDate;
  String status; // PENDING_APPROVAL | APPROVED | ACTIVE | CLOSED
  final String appliedAt;
  String? approvedAt;
  String? disbursedAt;

  LoanModel({
    required this.id,
    required this.loanNumber,
    required this.memberId,
    required this.borrowerName,
    required this.linkedAccountId,
    required this.loanType,
    required this.principalAmount,
    required this.outstandingPrincipal,
    required this.interestRate,
    required this.termMonths,
    required this.repaidMonths,
    required this.emiAmount,
    required this.nextDueDate,
    required this.status,
    required this.appliedAt,
    this.approvedAt,
    this.disbursedAt,
  });

  factory LoanModel.fromMap(Map<String, dynamic> map) {
    return LoanModel(
      id: map['id']?.toString() ?? '',
      loanNumber: map['loan_number']?.toString() ?? map['loanNumber']?.toString() ?? '',
      memberId: map['member_id']?.toString() ?? map['memberId']?.toString() ?? '',
      borrowerName: map['borrower_name']?.toString() ?? map['borrowerName']?.toString() ?? '',
      linkedAccountId: map['linked_account_id']?.toString() ?? map['linkedAccountId']?.toString() ?? '',
      loanType: map['loan_type']?.toString() ?? map['loanType']?.toString() ?? 'MSME Business Loan',
      principalAmount: (map['principal_amount'] ?? map['principalAmount'] ?? 0.0).toDouble(),
      outstandingPrincipal: (map['outstanding_principal'] ?? map['outstandingPrincipal'] ?? 0.0).toDouble(),
      interestRate: (map['interest_rate'] ?? map['interestRate'] ?? 11.5).toDouble(),
      termMonths: (map['term_months'] ?? map['termMonths'] ?? 12) as int,
      repaidMonths: (map['repaid_months'] ?? map['repaidMonths'] ?? 0) as int,
      emiAmount: (map['emi_amount'] ?? map['emiAmount'] ?? 0.0).toDouble(),
      nextDueDate: map['next_due_date']?.toString() ?? map['nextDueDate']?.toString() ?? '2026-11-05',
      status: map['status']?.toString() ?? 'ACTIVE',
      appliedAt: map['applied_at']?.toString() ?? map['appliedAt']?.toString() ?? '2026-01-01',
      approvedAt: map['approved_at']?.toString() ?? map['approvedAt']?.toString(),
      disbursedAt: map['disbursed_at']?.toString() ?? map['disbursedAt']?.toString(),
    );
  }
}

class TermDepositModel {
  final String id;
  final String certificateNumber;
  final String memberId;
  final String linkedAccountId;
  final String type; // FIXED_DEPOSIT | RECURRING_DEPOSIT
  final double principal;
  final double interestRate;
  final int termMonths;
  final double maturityAmount;
  final String startDate;
  final String maturityDate;
  final String status;

  TermDepositModel({
    required this.id,
    required this.certificateNumber,
    required this.memberId,
    required this.linkedAccountId,
    required this.type,
    required this.principal,
    required this.interestRate,
    required this.termMonths,
    required this.maturityAmount,
    required this.startDate,
    required this.maturityDate,
    required this.status,
  });

  factory TermDepositModel.fromMap(Map<String, dynamic> map) {
    return TermDepositModel(
      id: map['id']?.toString() ?? '',
      certificateNumber: map['certificate_number']?.toString() ?? map['certificateNumber']?.toString() ?? '',
      memberId: map['member_id']?.toString() ?? map['memberId']?.toString() ?? '',
      linkedAccountId: map['linked_account_id']?.toString() ?? map['linkedAccountId']?.toString() ?? '',
      type: map['type']?.toString() ?? 'FIXED_DEPOSIT',
      principal: (map['principal'] ?? 0.0).toDouble(),
      interestRate: (map['interest_rate'] ?? map['interestRate'] ?? 7.5).toDouble(),
      termMonths: (map['term_months'] ?? map['termMonths'] ?? 12) as int,
      maturityAmount: (map['maturity_amount'] ?? map['maturityAmount'] ?? 0.0).toDouble(),
      startDate: map['start_date']?.toString() ?? map['startDate']?.toString() ?? '2026-01-01',
      maturityDate: map['maturity_date']?.toString() ?? map['maturityDate']?.toString() ?? '2027-01-01',
      status: map['status']?.toString() ?? 'ACTIVE',
    );
  }
}
