# SFMS - Small Finance Management System (Web Application Suite)

A production-ready dual-application suite for Small Finance Banks, Microfinance Institutions (MFIs), and Cooperative Credit Societies:
1. **Banking Operations Application (Core Banker / Staff Portal)**
2. **Customer Banking Portal (Responsive Mobile & Desktop NetBanking)**
3. **Live Dual-View Studio (Interactive Split-Screen Simulation Hub)**

---

## 🚀 Quick Start (Instant Browser Preview)

No compilation or build step is required! You can open the applications immediately:

### Option A: Open directly in your browser
Simply double-click or open any of the HTML files in Chrome, Edge, Safari, or Firefox:
- **Dual-View Studio (Side-by-side Live Simulator)**: `sfms/web/index.html`
- **Banking Operations Application**: `sfms/web/ops/index.html`
- **Customer Banking Application**: `sfms/web/customer/index.html`

### Option B: Local HTTP Server (Node.js)
```bash
cd sfms/web
node server.js
```
Then visit:
- **Dual Studio**: [http://localhost:3000](http://localhost:3000)
- **Banking Operations**: [http://localhost:3000/ops/](http://localhost:3000/ops/)
- **Customer Portal**: [http://localhost:3000/customer/](http://localhost:3000/customer/)

---

## 🏛️ Application 1: Banking Operations Portal (`/ops`)

Tailored for branch staff, tellers, loan officers, and branch managers:

- **Executive & Operational Dashboard**:
  - Live Treasury tracking: Vault Balance vs Cashier Drawer Till Balance.
  - Core Financial KPIs: Total Member Deposits, Active Loans Book, Total KYC Members, Pending Approvals.
  - Operational Ledger with live credit/debit transaction entries and printable thermal slips.
- **Member & KYC Onboarding**:
  - Comprehensive registration form (Aadhaar, Voter ID, PAN, contact, location).
  - Member 360° Profile view showing linked accounts, active loans, and relationship value.
- **Account Management (CASA & Term Deposits)**:
  - Open new Savings, Current, and Term accounts with custom interest rates and opening deposit.
  - Real-time balance ledger.
- **Teller / Cashier Desk**:
  - **Cash Deposit**: Account selector with real-time balance, Denomination Matrix calculator (₹2000, ₹500, ₹200, ₹100, ₹50, ₹20, ₹10), and instant customer acknowledgement receipt.
  - **Cash Withdrawal**: Balance checks, minimum balance safeguards, cash disbursement slip.
  - **Account Transfer**: Inter-account internal bank transfers.
- **Loan Underwriting & Servicing**:
  - Originate microfinance and MSME business loans.
  - Credit review and 1-click Approval workflow.
  - Loan Capital Disbursement into borrower savings account or cash.
  - EMI Collection counter.
- **Day Book & Reconciliation**:
  - Daily opening cash, receipts (inflows), disbursements (outflows), and physical till count balancing.
- **Audit & Compliance**:
  - Chronological audit trail with export to CSV.

---

## 📱 Application 2: Customer Banking Portal (`/customer`)

Designed with a modern Neobank mobile-first aesthetic:

- **Device Mode Toggle**:
  - View as an iPhone/Android app inside a sleek device mockup shell OR toggle to widescreen Desktop NetBanking!
- **Customer Switcher**:
  - Instantly switch between demo profiles: Priya Sharma (Merchant), Rajesh Kumar (Farmer), Amit Patel (Logistics), Sunita Devi (SHG Leader).
- **Accounts & Net Worth**:
  - Total Net Worth breakdown (Savings + FDs - Loans).
  - Primary Savings card with masked account number and IFSC.
- **Digital Passbook & Statements**:
  - Real-time transaction history with Credit/Debit/Transfer filters.
  - Detailed transaction receipt modal with printable voucher.
  - Download Statement as CSV.
- **Instant Transfers & Pay**:
  - Quick Pay to any SFMS account with 4-digit PIN verification (`1234`).
- **Term Deposits (Fixed & Recurring Deposits)**:
  - Interactive tenure & amount slider calculator with projected interest and maturity value.
  - 1-Click creation of FD certificates.
- **Loan Center & Micro-Credit**:
  - Active loan breakdown with remaining principal and due date.
  - 1-Click Pay EMI: instantly deducts EMI from savings account and updates branch ledger!
  - Apply for new micro-credit or business loans.
- **Virtual Debit Card**:
  - 3D interactive flipping card (reveals CVV, expiry, magnetic strip).
  - One-tap Freeze / Lock toggle.
  - Online transactions enable/disable and ATM withdrawal limit slider.

---

## ⚡ Real-Time Synchronization Engine

Both applications communicate via a reactive event bus and cross-tab `BroadcastChannel`:
- When a Teller deposits money in the **Banking Operations App**, the **Customer App** immediately updates its balance and adds the transaction to the passbook without page reload!
- When a Customer pays an EMI or applies for a loan, the **Banking Operations App** updates its daybook and loans queue in real-time.
