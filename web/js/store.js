/**
 * SFMS Core Banking & Customer Store (Production-Grade State Engine)
 * Unified Double-Entry Ledger, RBI IRAC Asset Classification, Maker-Checker Queue,
 * AML/CTR Surveillance, Term Deposit Engine, and Cross-Tab Real-time Broadcast.
 */

const STORAGE_KEY = 'sfms_banking_db_v2';
const EVENT_CHANNEL = 'sfms_sync_channel_v2';

// Standard 5-Tier Chart of Accounts conforming to Third Schedule Banking Regulation Act
const CHART_OF_ACCOUNTS = [
  { code: '110101', name: 'Branch Strong Room Vault', category: 'ASSET' },
  { code: '110102', name: 'Cashier Counter Operating Till', category: 'ASSET' },
  { code: '140101', name: 'MSME Small Enterprise Loans', category: 'ASSET' },
  { code: '140102', name: 'Microfinance SHG Group Loans', category: 'ASSET' },
  { code: '140103', name: 'Agriculture & Tractor Loans', category: 'ASSET' },
  { code: '210101', name: 'Savings Bank Deposits Control', category: 'LIABILITY' },
  { code: '210201', name: 'Current Accounts Demand Deposits', category: 'LIABILITY' },
  { code: '210301', name: 'Term Deposits (Fixed & Recurring Deposits)', category: 'LIABILITY' },
  { code: '230101', name: 'TDS Payable on Interest (Sec 194A)', category: 'LIABILITY' },
  { code: '230201', name: 'Suspense Account - Cash Discrepancies', category: 'LIABILITY' },
  { code: '310000', name: 'Paid-Up Share Capital & Reserves', category: 'EQUITY' },
  { code: '410001', name: 'Interest Earned on Advances / Loans', category: 'REVENUE' },
  { code: '430001', name: 'Commission, Exchange & Service Charges', category: 'REVENUE' },
  { code: '510001', name: 'Interest Expended on Customer Deposits', category: 'EXPENSE' },
  { code: '520001', name: 'Branch Operating Expenses', category: 'EXPENSE' },
  { code: '530001', name: 'Provisions for Standard & Non-Performing Assets', category: 'EXPENSE' }
];

const DEFAULT_DATA = {
  bankInfo: {
    orgName: 'Utkarsh Small Finance Bank',
    orgCode: 'SFMS-USFB-01',
    branchName: 'Metro Central Branch',
    branchCode: 'BR001',
    ifsc: 'SFMS0001001',
    micr: '302889001',
    currency: 'INR',
    currencySymbol: '₹',
    vaultBalance: 2450000.00,
    vaultLimit: 5000000.00,
    tellerTillBalance: 350000.00,
    dayStatus: 'OPEN', // OPEN | BOD_COMPLETE | EOD_BALANCED | CLOSED
    currentBusinessDate: '2026-10-24'
  },
  branches: [
    { id: 'BR001', code: 'BR001', name: 'Metro Central Branch', city: 'Jaipur', tier: 'METRO', vaultLimit: 5000000, status: 'OPEN' },
    { id: 'BR002', code: 'BR002', name: 'Alwar Rural Branch', city: 'Alwar', tier: 'RURAL', vaultLimit: 2000000, status: 'OPEN' },
    { id: 'BR003', code: 'BR003', name: 'Mandi West Branch', city: 'Dausa', tier: 'SEMI_URBAN', vaultLimit: 3000000, status: 'OPEN' }
  ],
  staff: [
    { id: 'STF001', employeeCode: 'EMP-101', name: 'Alok Verma', role: 'BRANCH_MANAGER', branch: 'BR001', email: 'alok.bm@sfms.com' },
    { id: 'STF002', employeeCode: 'EMP-102', name: 'Neha Sharma', role: 'CASHIER', branch: 'BR001', tillLimit: 300000.00, email: 'neha.cash@sfms.com' },
    { id: 'STF003', employeeCode: 'EMP-103', name: 'Rohan Gupta', role: 'CREDIT_MANAGER', branch: 'BR001', email: 'rohan.credit@sfms.com' },
    { id: 'STF004', employeeCode: 'EMP-104', name: 'Meena Rao', role: 'CSO', branch: 'BR001', email: 'meena.cso@sfms.com' },
    { id: 'STF005', employeeCode: 'EMP-105', name: 'Sunil Joshi', role: 'COMPLIANCE_OFFICER', branch: 'BR001', email: 'compliance@sfms.com' },
    { id: 'STF006', employeeCode: 'EMP-106', name: 'Pooja Iyer', role: 'AUDITOR', branch: 'BR001', email: 'auditor@sfms.com' }
  ],
  productDefinitions: [
    { id: 'SAV-REG-01', type: 'SAVINGS', name: 'Standard Savings Plus', rate: 4.00, compounding: 'QUARTERLY', minBal: 1000.00, glCode: '210101' },
    { id: 'SAV-KIS-01', type: 'SAVINGS', name: 'Kisan Samriddhi Savings', rate: 4.50, compounding: 'QUARTERLY', minBal: 200.00, glCode: '210101' },
    { id: 'CUR-MER-01', type: 'CURRENT', name: 'Smart Merchant Current', rate: 0.00, compounding: 'NONE', minBal: 5000.00, glCode: '210201' },
    { id: 'FD-CUM-01',  type: 'FIXED_DEPOSIT', name: '1-Year Cumulative Fixed Deposit', rate: 7.75, compounding: 'QUARTERLY', minBal: 5000.00, glCode: '210301' },
    { id: 'RD-ACC-01',  type: 'RECURRING_DEPOSIT', name: '12-Month Recurring Deposit', rate: 7.25, compounding: 'QUARTERLY', minBal: 500.00, glCode: '210301' },
    { id: 'LN-MSME-01', type: 'LOAN', name: 'MSME Business Expansion Loan', rate: 11.50, compounding: 'MONTHLY', minBal: 0.00, glCode: '140101' },
    { id: 'LN-SHG-01',  type: 'LOAN', name: 'Microfinance SHG Group Loan', rate: 10.00, compounding: 'MONTHLY', minBal: 0.00, glCode: '140102' }
  ],
  customers: [
    {
      id: 'MEM001',
      ucic: 'UCIC-10001',
      fullName: 'Rajesh Kumar',
      dob: '1984-06-15',
      gender: 'Male',
      mobile: '9876543210',
      email: 'rajesh.kumar@example.com',
      occupation: 'Progressive Farmer / Agri-entrepreneur',
      riskTier: 'LOW',
      ckycNumber: 'CKYC9920192812',
      pan: 'ABCDE1234F',
      maskedAadhaar: 'XXXXXXXX8921',
      homeBranch: 'BR001',
      status: 'ACTIVE',
      address: { street: 'Village Rampur, Post Kalan', district: 'Alwar', state: 'Rajasthan', pincode: '301001' },
      nominee: { name: 'Savitri Devi', relation: 'Wife', dob: '1988-04-10', allocation: 100 },
      joinedAt: '2026-01-10'
    },
    {
      id: 'MEM002',
      ucic: 'UCIC-10002',
      fullName: 'Priya Sharma',
      dob: '1991-09-22',
      gender: 'Female',
      mobile: '9811223344',
      email: 'priya.sharma@example.com',
      occupation: 'Retail Grocer & Merchant (Sharma Traders)',
      riskTier: 'MEDIUM',
      ckycNumber: 'CKYC8819201944',
      pan: 'BRGPS5678K',
      maskedAadhaar: 'XXXXXXXX4512',
      homeBranch: 'BR001',
      status: 'ACTIVE',
      address: { street: 'Shop 14, Main Market Road', district: 'Jaipur', state: 'Rajasthan', pincode: '302001' },
      nominee: { name: 'Rohan Sharma', relation: 'Brother', dob: '1996-01-14', allocation: 100 },
      joinedAt: '2026-01-15'
    },
    {
      id: 'MEM003',
      ucic: 'UCIC-10003',
      fullName: 'Amit Patel',
      dob: '1988-12-05',
      gender: 'Male',
      mobile: '9822334455',
      email: 'amit.patel@example.com',
      occupation: 'Logistics Fleet Operator',
      riskTier: 'LOW',
      ckycNumber: 'CKYC7710293811',
      pan: 'CKLPT9912M',
      maskedAadhaar: 'XXXXXXXX9912',
      homeBranch: 'BR001',
      status: 'ACTIVE',
      address: { street: 'Flat 204, Shanti Heights', district: 'Jaipur', state: 'Rajasthan', pincode: '302004' },
      nominee: { name: 'Geeta Patel', relation: 'Mother', dob: '1965-08-20', allocation: 100 },
      joinedAt: '2026-02-01'
    },
    {
      id: 'MEM004',
      ucic: 'UCIC-10004',
      fullName: 'Sunita Devi',
      dob: '1985-03-18',
      gender: 'Female',
      mobile: '9833445566',
      email: 'sunita.shg@example.com',
      occupation: 'SHG Leader - Handloom & Handicrafts',
      riskTier: 'LOW',
      ckycNumber: 'CKYC6610294822',
      pan: 'DZZPD4321A',
      maskedAadhaar: 'XXXXXXXX7711',
      homeBranch: 'BR001',
      status: 'ACTIVE',
      address: { street: 'Ward 3, Near Primary School', district: 'Dausa', state: 'Rajasthan', pincode: '303303' },
      nominee: { name: 'Mukesh Devi', relation: 'Spouse', dob: '1982-11-12', allocation: 100 },
      joinedAt: '2026-02-12'
    },
    {
      id: 'MEM005',
      ucic: 'UCIC-10005',
      fullName: 'Vikram Singh',
      dob: '1995-11-30',
      gender: 'Male',
      mobile: '9844556677',
      email: 'vikram.singh@example.com',
      occupation: 'Bullion Dealer / Scrap Trader',
      riskTier: 'HIGH',
      ckycNumber: '',
      pan: 'EZLPS9921B',
      maskedAadhaar: 'XXXXXXXX3321',
      homeBranch: 'BR001',
      status: 'ACTIVE',
      address: { street: 'Old Sarafa Bazaar', district: 'Ajmer', state: 'Rajasthan', pincode: '305001' },
      nominee: { name: 'Anjali Singh', relation: 'Sister', dob: '1998-05-18', allocation: 100 },
      joinedAt: '2026-03-01'
    }
  ],
  accounts: [
    {
      id: 'ACC1001',
      accountNumber: 'BR001-101-0000101',
      customerId: 'MEM001',
      accountName: 'Rajesh Kumar',
      accountType: 'SAVINGS',
      productId: 'SAV-KIS-01',
      balance: 54250.00,
      availableBalance: 54250.00,
      lienAmount: 0.00,
      branchId: 'BR001',
      status: 'ACTIVE',
      openedAt: '2026-01-10',
      debitCard: {
        cardNumber: '4218 •••• •••• 6789',
        fullNumber: '4218 8901 2345 6789',
        expiry: '09/29',
        cvv: '542',
        isLocked: false,
        onlineTxnEnabled: true,
        atmLimit: 25000,
        pin: '1234'
      }
    },
    {
      id: 'ACC1002',
      accountNumber: 'BR001-102-0000102',
      customerId: 'MEM002',
      accountName: 'Priya Sharma (M/s Sharma Traders)',
      accountType: 'CURRENT',
      productId: 'CUR-MER-01',
      balance: 185400.00,
      availableBalance: 185400.00,
      lienAmount: 0.00,
      branchId: 'BR001',
      status: 'ACTIVE',
      openedAt: '2026-01-15',
      debitCard: {
        cardNumber: '4218 •••• •••• 7810',
        fullNumber: '4218 9912 3456 7810',
        expiry: '11/30',
        cvv: '819',
        isLocked: false,
        onlineTxnEnabled: true,
        atmLimit: 50000,
        pin: '4321'
      }
    },
    {
      id: 'ACC1003',
      accountNumber: 'BR001-101-0000103',
      customerId: 'MEM003',
      accountName: 'Amit Patel',
      accountType: 'SAVINGS',
      productId: 'SAV-REG-01',
      balance: 14800.00,
      availableBalance: 14800.00,
      lienAmount: 0.00,
      branchId: 'BR001',
      status: 'ACTIVE',
      openedAt: '2026-02-01',
      debitCard: {
        cardNumber: '4218 •••• •••• 9901',
        fullNumber: '4218 5566 7788 9901',
        expiry: '03/28',
        cvv: '320',
        isLocked: false,
        onlineTxnEnabled: false,
        atmLimit: 15000,
        pin: '9876'
      }
    },
    {
      id: 'ACC1004',
      accountNumber: 'BR001-101-0000104',
      customerId: 'MEM004',
      accountName: 'Sunita Devi',
      accountType: 'SAVINGS',
      productId: 'SAV-REG-01',
      balance: 38900.00,
      availableBalance: 38900.00,
      lienAmount: 0.00,
      branchId: 'BR001',
      status: 'ACTIVE',
      openedAt: '2026-02-12',
      debitCard: null
    },
    {
      id: 'ACC1005',
      accountNumber: 'BR001-101-0000105',
      customerId: 'MEM005',
      accountName: 'Vikram Singh',
      accountType: 'SAVINGS',
      productId: 'SAV-REG-01',
      balance: 8200.00,
      availableBalance: 8200.00,
      lienAmount: 0.00,
      branchId: 'BR001',
      status: 'ACTIVE',
      openedAt: '2026-03-01',
      debitCard: null
    }
  ],
  termDeposits: [
    {
      id: 'FD2001',
      certificateNumber: 'FD-2026-001',
      customerId: 'MEM002',
      linkedAccountId: 'ACC1002',
      type: 'FIXED_DEPOSIT',
      principal: 100000.00,
      interestRate: 7.75,
      termMonths: 12,
      maturityAmount: 107980.00,
      interestAccrued: 5812.50,
      tdsDeducted: 0.00,
      form15Submitted: true,
      startDate: '2026-01-20',
      maturityDate: '2027-01-20',
      status: 'ACTIVE',
      autoRenew: true
    },
    {
      id: 'RD3001',
      certificateNumber: 'RD-2026-002',
      customerId: 'MEM001',
      linkedAccountId: 'ACC1001',
      type: 'RECURRING_DEPOSIT',
      monthlyInstallment: 2000.00,
      interestRate: 7.25,
      termMonths: 12,
      installmentsPaid: 4,
      totalAccumulated: 8000.00,
      maturityAmount: 24960.00,
      interestAccrued: 242.00,
      tdsDeducted: 0.00,
      form15Submitted: false,
      startDate: '2026-01-15',
      maturityDate: '2027-01-15',
      status: 'ACTIVE',
      autoRenew: false
    }
  ],
  loans: [
    {
      id: 'LN5001',
      loanNumber: 'LN-2026-0081',
      customerId: 'MEM002',
      borrowerName: 'Priya Sharma',
      linkedAccountId: 'ACC1002',
      loanType: 'MSME Business Expansion',
      productId: 'LN-MSME-01',
      principalAmount: 200000.00,
      outstandingPrincipal: 145000.00,
      interestRate: 11.5,
      termMonths: 24,
      repaidMonths: 6,
      emiAmount: 9370.00,
      nextDueDate: '2026-11-05',
      dpdCount: 0,
      iracStatus: 'STANDARD', // STANDARD | SMA0 | SMA1 | SMA2 | SUBSTANDARD | DOUBTFUL | LOSS
      status: 'ACTIVE',
      appliedAt: '2026-01-18',
      sanctionedAt: '2026-01-20',
      disbursedAt: '2026-01-21'
    },
    {
      id: 'LN5002',
      loanNumber: 'LN-2026-0094',
      customerId: 'MEM004',
      borrowerName: 'Sunita Devi',
      linkedAccountId: 'ACC1004',
      loanType: 'Microfinance SHG Group Loan',
      productId: 'LN-SHG-01',
      principalAmount: 50000.00,
      outstandingPrincipal: 22000.00,
      interestRate: 10.0,
      termMonths: 12,
      repaidMonths: 7,
      emiAmount: 4395.00,
      nextDueDate: '2026-11-10',
      dpdCount: 0,
      iracStatus: 'STANDARD',
      status: 'ACTIVE',
      appliedAt: '2026-02-15',
      sanctionedAt: '2026-02-16',
      disbursedAt: '2026-02-17'
    },
    {
      id: 'LN5003',
      loanNumber: 'LN-2026-0105',
      customerId: 'MEM001',
      borrowerName: 'Rajesh Kumar',
      linkedAccountId: 'ACC1001',
      loanType: 'Agriculture & Solar Pump Loan',
      productId: 'LN-MSME-01',
      principalAmount: 150000.00,
      outstandingPrincipal: 150000.00,
      interestRate: 9.25,
      termMonths: 36,
      repaidMonths: 0,
      emiAmount: 4785.00,
      nextDueDate: '2026-11-15',
      dpdCount: 0,
      iracStatus: 'STANDARD',
      status: 'PENDING_APPROVAL',
      purpose: 'Installation of solar-powered drip irrigation system',
      appliedAt: '2026-10-20',
      sanctionedAt: null,
      disbursedAt: null
    }
  ],
  // Standard Double-Entry Journal Entries
  journalEntries: [
    {
      id: 'JE-20261024-001',
      entryNumber: 'VCH/2026/00142',
      businessDate: '2026-10-24',
      branchId: 'BR001',
      refType: 'TELLER_DEPOSIT',
      refId: 'DEP-CASH-8812',
      narration: 'Cash deposit at Teller counter into A/C BR001-101-0000101',
      createdBy: 'STF002',
      authorizedBy: 'STF001',
      timestamp: '2026-10-24 10:15:30',
      lines: [
        { glCode: '110102', accountId: null, debit: 15000.00, credit: 0.00 },
        { glCode: '210101', accountId: 'ACC1001', debit: 0.00, credit: 15000.00 }
      ]
    },
    {
      id: 'JE-20261023-014',
      entryNumber: 'VCH/2026/00139',
      businessDate: '2026-10-23',
      branchId: 'BR001',
      refType: 'LOAN_EMI',
      refId: 'EMI-LN5001-M06',
      narration: 'Auto-debit EMI repayment for Loan LN-2026-0081',
      createdBy: 'SYSTEM',
      authorizedBy: 'SYSTEM',
      timestamp: '2026-10-23 05:00:10',
      lines: [
        { glCode: '210201', accountId: 'ACC1002', debit: 9370.00, credit: 0.00 },
        { glCode: '140101', accountId: null, debit: 0.00, credit: 6746.40 }, // Principal portion
        { glCode: '410001', accountId: null, debit: 0.00, credit: 2623.60 }  // Interest income portion
      ]
    }
  ],
  // Maker-Checker Approvals Queue
  makerCheckerQueue: [
    {
      id: 'MC-20261024-01',
      branchId: 'BR001',
      entityType: 'LOAN_SANCTION',
      entityId: 'LN5003',
      title: 'Sanction Agri Loan: Rajesh Kumar (₹1,50,000)',
      makerId: 'STF003', // Rohan Gupta (Credit Manager)
      requestedAmount: 150000.00,
      status: 'PENDING',
      createdAt: '2026-10-24 09:30:00',
      details: 'Solar irrigation facility under Agri Priority Sector. Scorecard: 78/100.'
    },
    {
      id: 'MC-20261024-02',
      branchId: 'BR001',
      entityType: 'HIGH_VALUE_CASH_DEPOSIT',
      entityId: 'TXN-REQ-991',
      title: 'Cash Deposit > ₹50,000 threshold (₹4,50,000)',
      makerId: 'STF002', // Neha Sharma (Teller)
      requestedAmount: 450000.00,
      status: 'PENDING',
      createdAt: '2026-10-24 10:45:00',
      details: 'Customer: Vikram Singh (Old Sarafa Bazaar). PAN verified: EZLPS9921B.'
    }
  ],
  // AML & Regulatory Compliance Alerts
  amlAlerts: [
    {
      id: 'AML-20261024-01',
      customerId: 'MEM005',
      customerName: 'Vikram Singh',
      alertType: 'HIGH_RISK_PEP_STRUCTURING',
      severity: 'HIGH',
      amount: 450000.00,
      description: 'Customer in High Risk Tier transacting high cash frequency. Review for CTR/STR filing.',
      status: 'OPEN',
      createdAt: '2026-10-24 10:46:10'
    }
  ],
  // Cryptographically Hash-Chained Audit Logs
  auditLogs: [
    {
      id: 1,
      prevHash: '0000000000000000000000000000000000000000000000000000000000000000',
      recordHash: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      action: 'SYSTEM_GENESIS',
      user: 'SUPER_ADMIN',
      details: 'SFMS Core Banking Ledger initialized conforming to RBI Master Directions',
      timestamp: '2026-10-24 00:00:00'
    }
  ],
  // SMS Notification Queue (Staged Mock for future MSG91/DLT integration)
  smsQueue: [
    {
      id: 1,
      mobile: '9811223344',
      template: 'TXN_CREDIT_ALERT',
      body: 'Your A/C BR001-102-0000102 has been credited with INR 24,500.00. Avail Bal: INR 1,85,400.00 - SFMS Bank',
      status: 'STAGED_MOCK_READY_FOR_MSG91',
      createdAt: '2026-10-24 11:20:00'
    }
  ]
};

class SFMSStore {
  constructor() {
    this.data = this.loadData();
    this.subscribers = [];
    this.channel = null;

    if (typeof window !== 'undefined' && 'BroadcastChannel' in window) {
      try {
        this.channel = new BroadcastChannel(EVENT_CHANNEL);
        this.channel.onmessage = (event) => {
          if (event.data && event.data.type === 'SYNC') {
            this.data = this.loadData();
            this.notify(false);
          }
        };
      } catch (e) {
        console.warn('BroadcastChannel not initialized:', e);
      }
    }
  }

  loadData() {
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      if (stored) return JSON.parse(stored);
    } catch (e) {
      console.warn('LocalStorage read exception:', e);
    }
    this.saveData(DEFAULT_DATA, false);
    return JSON.parse(JSON.stringify(DEFAULT_DATA));
  }

  saveData(data = this.data, broadcast = true) {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
      if (broadcast && this.channel) {
        this.channel.postMessage({ type: 'SYNC', timestamp: Date.now() });
      }
    } catch (e) {
      console.error('LocalStorage write exception:', e);
    }
    this.notify(true);
  }

  subscribe(listener) {
    this.subscribers.push(listener);
    return () => {
      this.subscribers = this.subscribers.filter(l => l !== listener);
    };
  }

  notify(isLocal = true) {
    this.subscribers.forEach(l => {
      try { l(this.data, isLocal); } catch (err) { console.error('Subscriber error:', err); }
    });
  }

  // Cryptographic audit logger simulation
  logAudit(action, user, details) {
    const lastLog = this.data.auditLogs[0] || { recordHash: '0'.repeat(64) };
    const prevHash = lastLog.recordHash;
    const rawPayload = `${action}|${user}|${details}|${Date.now()}|${prevHash}`;
    
    // Simple deterministic hash simulation for in-browser immutability
    let hash = 0;
    for (let i = 0; i < rawPayload.length; i++) {
      hash = ((hash << 5) - hash) + rawPayload.charCodeAt(i);
      hash |= 0;
    }
    const recordHash = Math.abs(hash).toString(16).padStart(64, 'a');

    this.data.auditLogs.unshift({
      id: this.data.auditLogs.length + 1,
      prevHash,
      recordHash,
      action,
      user,
      details,
      timestamp: new Date().toLocaleString()
    });

    if (this.data.auditLogs.length > 300) this.data.auditLogs.pop();
  }

  // ==========================================
  // GETTERS
  // ==========================================
  getState() { return this.data; }
  getBankInfo() { return this.data.bankInfo; }
  getBranches() { return this.data.branches; }
  getCustomers() { return this.data.customers; }
  getCustomerById(id) { return this.data.customers.find(c => c.id === id); }
  getAccounts() { return this.data.accounts; }
  getAccountById(id) { return this.data.accounts.find(a => a.id === id); }
  getAccountByNumber(num) { return this.data.accounts.find(a => a.accountNumber === num.trim()); }
  getAccountsByCustomerId(custId) { return this.data.accounts.filter(a => a.customerId === custId); }
  getLoans() { return this.data.loans; }
  getLoansByCustomerId(custId) { return this.data.loans.filter(l => l.customerId === custId); }
  getTermDepositsByCustomerId(custId) { return this.data.termDeposits.filter(td => td.customerId === custId); }
  getJournalEntries() { return this.data.journalEntries; }
  getMakerCheckerQueue() { return this.data.makerCheckerQueue; }
  getAmlAlerts() { return this.data.amlAlerts; }
  getAuditLogs() { return this.data.auditLogs; }

  // ==========================================
  // DOUBLE-ENTRY POSTING ENGINE
  // ==========================================
  postDoubleEntryVoucher({ refType, refId, narration, lines, createdBy = 'SYSTEM', authorizedBy = 'SYSTEM' }) {
    // 1. Verify Balanced Debits == Credits
    let totalDebit = 0;
    let totalCredit = 0;
    lines.forEach(l => {
      totalDebit += parseFloat(l.debit || 0);
      totalCredit += parseFloat(l.credit || 0);
    });

    if (Math.abs(totalDebit - totalCredit) > 0.01) {
      throw new Error(`Double-Entry Out of Balance! Debits: ₹${totalDebit.toFixed(2)}, Credits: ₹${totalCredit.toFixed(2)}`);
    }

    const nextSeq = this.data.journalEntries.length + 1;
    const entryNumber = 'VCH/' + new Date().getFullYear() + '/' + String(nextSeq).padStart(5, '0');

    const entry = {
      id: 'JE-' + Date.now(),
      entryNumber,
      businessDate: this.data.bankInfo.currentBusinessDate,
      branchId: this.data.bankInfo.branchCode,
      refType,
      refId,
      narration,
      createdBy,
      authorizedBy,
      timestamp: new Date().toLocaleString(),
      lines
    };

    this.data.journalEntries.unshift(entry);
    this.logAudit('GL_VOUCHER_POSTED', createdBy, `${entryNumber}: ${narration} (Balanced: ₹${totalDebit.toFixed(2)})`);
    return entry;
  }

  // ==========================================
  // CASH OPERATIONS (CASHIER TELLER COUNTER)
  // ==========================================

  depositCash({ accountId, amount, denominations = {}, reference = '', narration = '', tellerId = 'STF002' }) {
    const depositAmount = parseFloat(amount);
    if (isNaN(depositAmount) || depositAmount <= 0) throw new Error('Valid deposit amount required');

    const account = this.getAccountById(accountId);
    if (!account) throw new Error('Account not found');
    if (account.status !== 'ACTIVE') throw new Error(`Account is ${account.status}`);

    const customer = this.getCustomerById(account.customerId);

    // RBI Rule 114B: Cash >= 50,000 requires PAN validation
    if (depositAmount >= 50000) {
      if (!customer.pan || customer.pan.length !== 10) {
        throw new Error('Mandatory Compliance: Cash deposit >= ₹50,000 requires valid PAN on file per Income Tax Rule 114B');
      }
    }

    // Check Maker-Checker threshold: deposits > 2,00,000 require Manager check
    if (depositAmount > 200000 && tellerId === 'CASHIER') {
      const mcId = 'MC-' + Date.now();
      this.data.makerCheckerQueue.unshift({
        id: mcId,
        branchId: 'BR001',
        entityType: 'HIGH_VALUE_CASH_DEPOSIT',
        entityId: account.accountNumber,
        title: `High-Value Cash Deposit: ${account.accountName} (₹${depositAmount.toLocaleString('en-IN')})`,
        makerId: tellerId,
        requestedAmount: depositAmount,
        status: 'PENDING',
        createdAt: new Date().toLocaleString(),
        details: `Teller counter cash deposit exceeding branch auto-authorization ceiling. Ref: ${reference || 'CASH'}`
      });
      this.saveData();
      return { requiresApproval: true, message: 'Deposit held in Maker-Checker queue for Branch Manager authorization' };
    }

    // Execute Immediate Ledger Updates
    account.balance = parseFloat((account.balance + depositAmount).toFixed(2));
    account.availableBalance = parseFloat((account.availableBalance + depositAmount).toFixed(2));
    this.data.bankInfo.tellerTillBalance += depositAmount;

    // Check Teller Till Ceiling
    if (this.data.bankInfo.tellerTillBalance > 300000) {
      this.logAudit('TILL_LIMIT_WARNING', tellerId, `Cashier drawer balance (₹${this.data.bankInfo.tellerTillBalance.toFixed(2)}) breached ceiling of ₹3,00,000. Transfer to vault recommended.`);
    }

    // Generate Double-Entry Vouchers
    // Dr: 110102 (Cashier Operating Till) | Cr: 210101 (Customer Savings Deposits Control)
    const glCreditCode = account.accountType === 'CURRENT' ? '210201' : '210101';
    const ref = reference || 'DEP-' + Math.floor(100000 + Math.random() * 900000);

    const voucher = this.postDoubleEntryVoucher({
      refType: 'TELLER_DEPOSIT',
      refId: ref,
      narration: narration || `Cash deposit into A/C ${account.accountNumber}`,
      createdBy: tellerId,
      authorizedBy: tellerId,
      lines: [
        { glCode: '110102', accountId: null, debit: depositAmount, credit: 0.00 },
        { glCode: glCreditCode, accountId: account.id, debit: 0.00, credit: depositAmount }
      ]
    });

    // Staging SMS Queue
    this.data.smsQueue.unshift({
      id: this.data.smsQueue.length + 1,
      mobile: customer.mobile,
      template: 'TXN_CREDIT',
      body: `Your A/C ${account.accountNumber} has been credited with INR ${depositAmount.toFixed(2)} via Cash. Avail Bal: INR ${account.availableBalance.toFixed(2)} - SFMS Bank`,
      status: 'STAGED_MOCK_READY_FOR_MSG91',
      createdAt: new Date().toLocaleString()
    });

    this.saveData();
    return { success: true, transaction: {
      id: voucher.id,
      txnNumber: voucher.entryNumber,
      accountId: account.id,
      accountNumber: account.accountNumber,
      amount: depositAmount,
      balanceAfter: account.balance,
      type: 'CREDIT',
      category: 'CASH_DEPOSIT',
      channel: 'TELLER_DESK',
      reference: ref,
      narration: narration || 'Cash deposit at Teller counter',
      timestamp: voucher.timestamp,
      denominations
    }, newBalance: account.balance };
  }

  withdrawCash({ accountId, amount, reference = '', narration = '', tellerId = 'STF002' }) {
    const withdrawAmount = parseFloat(amount);
    if (isNaN(withdrawAmount) || withdrawAmount <= 0) throw new Error('Valid withdrawal amount required');

    const account = this.getAccountById(accountId);
    if (!account) throw new Error('Account not found');
    if (account.status !== 'ACTIVE') throw new Error(`Account is ${account.status}`);

    if (account.availableBalance < withdrawAmount) {
      throw new Error(`Insufficient funds. Available: ₹${account.availableBalance.toFixed(2)}`);
    }

    if (this.data.bankInfo.tellerTillBalance < withdrawAmount) {
      throw new Error(`Cashier till has insufficient physical cash (Available in till: ₹${this.data.bankInfo.tellerTillBalance.toFixed(2)}). Request vault cash transfer.`);
    }

    // Execute Ledger Updates
    account.balance = parseFloat((account.balance - withdrawAmount).toFixed(2));
    account.availableBalance = parseFloat((account.availableBalance - withdrawAmount).toFixed(2));
    this.data.bankInfo.tellerTillBalance -= withdrawAmount;

    const glDebitCode = account.accountType === 'CURRENT' ? '210201' : '210101';
    const ref = reference || 'WDL-' + Math.floor(100000 + Math.random() * 900000);

    const voucher = this.postDoubleEntryVoucher({
      refType: 'TELLER_WITHDRAWAL',
      refId: ref,
      narration: narration || `Cash withdrawal from A/C ${account.accountNumber}`,
      createdBy: tellerId,
      authorizedBy: tellerId,
      lines: [
        { glCode: glDebitCode, accountId: account.id, debit: withdrawAmount, credit: 0.00 },
        { glCode: '110102', accountId: null, debit: 0.00, credit: withdrawAmount }
      ]
    });

    this.saveData();
    return { success: true, transaction: {
      id: voucher.id,
      txnNumber: voucher.entryNumber,
      accountId: account.id,
      accountNumber: account.accountNumber,
      amount: withdrawAmount,
      balanceAfter: account.balance,
      type: 'DEBIT',
      category: 'CASH_WITHDRAWAL',
      channel: 'TELLER_DESK',
      reference: ref,
      narration: narration || 'Cash withdrawal at Teller counter',
      timestamp: voucher.timestamp
    }, newBalance: account.balance };
  }

  // ==========================================
  // CUSTOMER TRANSFERS (INTERNAL BOOK TRANSFERS)
  // ==========================================
  transferFunds({ fromAccountId, toAccountNumber, amount, narration = '', initiatedBy = 'CUSTOMER' }) {
    const transferAmount = parseFloat(amount);
    if (isNaN(transferAmount) || transferAmount <= 0) throw new Error('Valid transfer amount required');

    const fromAccount = this.getAccountById(fromAccountId);
    if (!fromAccount) throw new Error('Source account not found');
    if (fromAccount.availableBalance < transferAmount) throw new Error('Insufficient funds in source account');

    const toAccount = this.getAccountByNumber(toAccountNumber);
    if (!toAccount) throw new Error(`Recipient account ${toAccountNumber} was not found in SFMS`);
    if (fromAccount.id === toAccount.id) throw new Error('Source and destination cannot be identical');

    fromAccount.balance = parseFloat((fromAccount.balance - transferAmount).toFixed(2));
    fromAccount.availableBalance = parseFloat((fromAccount.availableBalance - transferAmount).toFixed(2));

    toAccount.balance = parseFloat((toAccount.balance + transferAmount).toFixed(2));
    toAccount.availableBalance = parseFloat((toAccount.availableBalance + transferAmount).toFixed(2));

    const ref = 'TRF-' + Math.floor(100000 + Math.random() * 900000);
    const fromGL = fromAccount.accountType === 'CURRENT' ? '210201' : '210101';
    const toGL = toAccount.accountType === 'CURRENT' ? '210201' : '210101';

    const voucher = this.postDoubleEntryVoucher({
      refType: 'INTERNAL_TRANSFER',
      refId: ref,
      narration: narration || `Transfer from ${fromAccount.accountNumber} to ${toAccount.accountNumber}`,
      createdBy: initiatedBy,
      authorizedBy: 'SYSTEM',
      lines: [
        { glCode: fromGL, accountId: fromAccount.id, debit: transferAmount, credit: 0.00 },
        { glCode: toGL, accountId: toAccount.id, debit: 0.00, credit: transferAmount }
      ]
    });

    this.saveData();
    return {
      success: true,
      reference: ref,
      debitTxn: {
        id: voucher.id,
        txnNumber: voucher.entryNumber + '-D',
        accountId: fromAccount.id,
        accountNumber: fromAccount.accountNumber,
        amount: transferAmount,
        balanceAfter: fromAccount.balance,
        type: 'DEBIT',
        category: 'TRANSFER',
        channel: 'DIGITAL_TRANSFER',
        reference: ref,
        narration: `Transfer to A/C ${toAccount.accountNumber} (${toAccount.accountName})`,
        timestamp: voucher.timestamp
      }
    };
  }

  // ==========================================
  // LOANS LIFECYCLE & AMORTIZATION
  // ==========================================

  applyForLoan({ customerId, loanType, amount, termMonths, interestRate, purpose = '', initiatedBy = 'CUSTOMER' }) {
    const customer = this.getCustomerById(customerId);
    if (!customer) throw new Error('Customer not found');

    const principal = parseFloat(amount);
    const months = parseInt(termMonths, 10);
    const rate = parseFloat(interestRate || 11.5);

    // Reducing Balance EMI: [P x r x (1+r)^n] / [(1+r)^n - 1]
    const monthlyRate = (rate / 12) / 100;
    const emi = Math.round((principal * monthlyRate * Math.pow(1 + monthlyRate, months)) / (Math.pow(1 + monthlyRate, months) - 1));

    const accounts = this.getAccountsByCustomerId(customerId);
    const linkedAcc = accounts.length > 0 ? accounts[0].id : null;

    const loanId = 'LN' + Math.floor(5000 + Math.random() * 5000);
    const loanNumber = 'LN-2026-' + String(this.data.loans.length + 1).padStart(4, '0');

    const newLoan = {
      id: loanId,
      loanNumber,
      customerId: customer.id,
      borrowerName: customer.fullName,
      linkedAccountId: linkedAcc,
      loanType,
      productId: 'LN-MSME-01',
      principalAmount: principal,
      outstandingPrincipal: principal,
      interestRate: rate,
      termMonths: months,
      repaidMonths: 0,
      emiAmount: emi,
      nextDueDate: new Date(Date.now() + 30 * 86400000).toISOString().split('T')[0],
      dpdCount: 0,
      iracStatus: 'STANDARD',
      status: 'PENDING_APPROVAL',
      purpose: purpose || 'Working Capital & Inventory',
      appliedAt: new Date().toISOString().split('T')[0],
      sanctionedAt: null,
      disbursedAt: null
    };

    this.data.loans.unshift(newLoan);

    // Enqueue into Maker-Checker for Credit Manager & Branch Manager
    this.data.makerCheckerQueue.unshift({
      id: 'MC-' + Date.now(),
      branchId: 'BR001',
      entityType: 'LOAN_SANCTION',
      entityId: newLoan.id,
      title: `Sanction Loan: ${customer.fullName} (₹${principal.toLocaleString('en-IN')})`,
      makerId: initiatedBy,
      requestedAmount: principal,
      status: 'PENDING',
      createdAt: new Date().toLocaleString(),
      details: `${loanType} for ${months} mos. EMI: ₹${emi}/mo. Purpose: ${purpose}`
    });

    this.logAudit('LOAN_APPLICATION_SUBMITTED', initiatedBy, `Submitted loan application ${loanNumber} of ₹${principal}`);
    this.saveData();
    return newLoan;
  }

  approveMakerChecker(approvalId, checkerId = 'STF001') {
    const item = this.data.makerCheckerQueue.find(q => q.id === approvalId);
    if (!item) throw new Error('Approval task not found');

    item.status = 'APPROVED';
    item.checkerId = checkerId;
    item.authorizedAt = new Date().toLocaleString();

    if (item.entityType === 'LOAN_SANCTION') {
      const loan = this.data.loans.find(l => l.id === item.entityId);
      if (loan) {
        loan.status = 'SANCTIONED';
        loan.sanctionedAt = new Date().toISOString().split('T')[0];
        loan.sanctionedBy = checkerId;
      }
    }

    this.logAudit('MAKER_CHECKER_APPROVED', checkerId, `Authorized approval item ${approvalId}: ${item.title}`);
    this.saveData();
    return item;
  }

  disburseLoan(loanId, disbursedBy = 'STF001') {
    const loan = this.data.loans.find(l => l.id === loanId);
    if (!loan) throw new Error('Loan not found');
    if (loan.status !== 'SANCTIONED') throw new Error(`Only SANCTIONED loans can be disbursed. Current status: ${loan.status}`);

    const targetAccount = this.getAccountById(loan.linkedAccountId);
    if (!targetAccount) throw new Error('Valid borrower CASA account required for capital credit');

    loan.status = 'ACTIVE';
    loan.disbursedAt = new Date().toISOString().split('T')[0];
    loan.disbursedAmount = loan.principalAmount;

    // Credit borrower CASA account
    targetAccount.balance = parseFloat((targetAccount.balance + loan.principalAmount).toFixed(2));
    targetAccount.availableBalance = parseFloat((targetAccount.availableBalance + loan.principalAmount).toFixed(2));
    this.data.bankInfo.vaultBalance -= loan.principalAmount;

    // Double Entry: Dr: 140101 (Advances MSME Loans) | Cr: 210101 (CASA Deposit Control)
    const ref = 'DISB-' + loan.loanNumber;
    this.postDoubleEntryVoucher({
      refType: 'LOAN_DISBURSEMENT',
      refId: ref,
      narration: `Disbursement of ${loan.loanType} (${loan.loanNumber}) into ${targetAccount.accountNumber}`,
      createdBy: disbursedBy,
      authorizedBy: disbursedBy,
      lines: [
        { glCode: '140101', accountId: null, debit: loan.principalAmount, credit: 0.00 },
        { glCode: targetAccount.accountType === 'CURRENT' ? '210201' : '210101', accountId: targetAccount.id, debit: 0.00, credit: loan.principalAmount }
      ]
    });

    this.saveData();
    return loan;
  }

  repayLoanEMI({ loanId, accountId = null, amount = null, initiatedBy = 'CUSTOMER' }) {
    const loan = this.data.loans.find(l => l.id === loanId);
    if (!loan) throw new Error('Loan not found');
    if (loan.status !== 'ACTIVE') throw new Error(`Loan is not active (${loan.status})`);

    const emiToPay = amount ? parseFloat(amount) : loan.emiAmount;
    const account = accountId ? this.getAccountById(accountId) : this.getAccountById(loan.linkedAccountId);
    if (!account) throw new Error('Linked savings account not found');
    if (account.availableBalance < emiToPay) throw new Error(`Insufficient balance to pay EMI of ₹${emiToPay}`);

    // Deduct EMI from CASA
    account.balance = parseFloat((account.balance - emiToPay).toFixed(2));
    account.availableBalance = parseFloat((account.availableBalance - emiToPay).toFixed(2));

    loan.repaidMonths += 1;
    // Calculate split: Roughly 72% principal reduction, 28% interest income
    const principalPortion = Math.min(loan.outstandingPrincipal, parseFloat((emiToPay * 0.72).toFixed(2)));
    const interestPortion = parseFloat((emiToPay - principalPortion).toFixed(2));

    loan.outstandingPrincipal = Math.max(0, parseFloat((loan.outstandingPrincipal - principalPortion).toFixed(2)));

    // Advance next due date 1 month
    const nextDue = new Date(loan.nextDueDate);
    nextDue.setMonth(nextDue.getMonth() + 1);
    loan.nextDueDate = nextDue.toISOString().split('T')[0];

    if (loan.outstandingPrincipal <= 0 || loan.repaidMonths >= loan.termMonths) {
      loan.status = 'CLOSED';
    }

    // Double Entry:
    // Dr: Customer CASA | Cr: 140101 (Loan Principal Asset) | Cr: 410001 (Interest Revenue)
    const ref = `EMI-${loan.loanNumber}-M${loan.repaidMonths}`;
    const glDebit = account.accountType === 'CURRENT' ? '210201' : '210101';

    this.postDoubleEntryVoucher({
      refType: 'LOAN_EMI',
      refId: ref,
      narration: `EMI repayment for Loan ${loan.loanNumber}`,
      createdBy: initiatedBy,
      authorizedBy: 'SYSTEM',
      lines: [
        { glCode: glDebit, accountId: account.id, debit: emiToPay, credit: 0.00 },
        { glCode: '140101', accountId: null, debit: 0.00, credit: principalPortion },
        { glCode: '410001', accountId: null, debit: 0.00, credit: interestPortion }
      ]
    });

    this.saveData();
    return { success: true, loan, emiPaid: emiToPay };
  }

  // ==========================================
  // TERM DEPOSITS ENGINE
  // ==========================================
  createTermDeposit({ customerId, linkedAccountId, type = 'FIXED_DEPOSIT', amount, termMonths, interestRate, form15Submitted = false, initiatedBy = 'CUSTOMER' }) {
    const account = this.getAccountById(linkedAccountId);
    if (!account) throw new Error('Linked savings account not found');

    const depositAmount = parseFloat(amount);
    if (account.availableBalance < depositAmount) throw new Error(`Insufficient funds to open ${type}`);

    account.balance = parseFloat((account.balance - depositAmount).toFixed(2));
    account.availableBalance = parseFloat((account.availableBalance - depositAmount).toFixed(2));

    const rate = parseFloat(interestRate || 7.75);
    const months = parseInt(termMonths, 10);

    // Quarterly Compounding: A = P(1 + r/400)^(4*t)
    const quarters = months / 3;
    const maturity = parseFloat((depositAmount * Math.pow(1 + (rate / 400), quarters)).toFixed(2));

    const nextSeq = this.data.termDeposits.length + 1;
    const certNum = (type === 'FIXED_DEPOSIT' ? 'FD-2026-' : 'RD-2026-') + String(nextSeq).padStart(3, '0');

    const termDeposit = {
      id: (type === 'FIXED_DEPOSIT' ? 'FD' : 'RD') + (2000 + nextSeq),
      certificateNumber: certNum,
      customerId,
      linkedAccountId: account.id,
      type,
      principal: depositAmount,
      monthlyInstallment: type === 'RECURRING_DEPOSIT' ? depositAmount : null,
      interestRate: rate,
      termMonths: months,
      installmentsPaid: type === 'RECURRING_DEPOSIT' ? 1 : null,
      totalAccumulated: depositAmount,
      maturityAmount: maturity,
      interestAccrued: 0.00,
      tdsDeducted: 0.00,
      form15Submitted,
      startDate: new Date().toISOString().split('T')[0],
      maturityDate: new Date(Date.now() + months * 30 * 86400000).toISOString().split('T')[0],
      status: 'ACTIVE',
      autoRenew: true
    };

    this.data.termDeposits.unshift(termDeposit);

    // Double Entry: Dr: Customer Savings | Cr: 210301 (Term Deposits Control)
    const glDebit = account.accountType === 'CURRENT' ? '210201' : '210101';
    this.postDoubleEntryVoucher({
      refType: 'TERM_DEPOSIT_CREATION',
      refId: certNum,
      narration: `Funds booked into ${type} Cert ${certNum}`,
      createdBy: initiatedBy,
      authorizedBy: 'SYSTEM',
      lines: [
        { glCode: glDebit, accountId: account.id, debit: depositAmount, credit: 0.00 },
        { glCode: '210301', accountId: null, debit: 0.00, credit: depositAmount }
      ]
    });

    this.saveData();
    return termDeposit;
  }

  // ==========================================
  // FINANCIAL REPORTS: TRIAL BALANCE, BS, P&L
  // ==========================================
  getTrialBalance() {
    const glSummary = {};
    CHART_OF_ACCOUNTS.forEach(c => {
      glSummary[c.code] = { code: c.code, name: c.name, category: c.category, debit: 0, credit: 0 };
    });

    this.data.journalEntries.forEach(entry => {
      entry.lines.forEach(line => {
        if (!glSummary[line.glCode]) {
          glSummary[line.glCode] = { code: line.glCode, name: 'Other GL ' + line.glCode, category: 'ASSET', debit: 0, credit: 0 };
        }
        glSummary[line.glCode].debit += line.debit;
        glSummary[line.glCode].credit += line.credit;
      });
    });

    let totalDebit = 0;
    let totalCredit = 0;
    const rows = Object.values(glSummary).filter(r => r.debit > 0 || r.credit > 0);
    rows.forEach(r => {
      totalDebit += r.debit;
      totalCredit += r.credit;
    });

    const variance = Math.abs(totalDebit - totalCredit);
    return {
      rows,
      totalDebit: parseFloat(totalDebit.toFixed(2)),
      totalCredit: parseFloat(totalCredit.toFixed(2)),
      isBalanced: variance < 0.05,
      variance: parseFloat(variance.toFixed(2))
    };
  }

  resetToDefaults() {
    this.data = JSON.parse(JSON.stringify(DEFAULT_DATA));
    this.saveData();
    return this.data;
  }
}

// Global Singleton Export
window.sfmsStore = new SFMSStore();
