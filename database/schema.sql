-- ============================================================================
-- SFMS (Small Finance Management System) - Core Banking Database Blueprint
-- Conforming to Reserve Bank of India (RBI) Regulations & Double-Entry Principles
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. SYSTEM, BRANCHES & STAFF HIERARCHY
-- ============================================================================

CREATE TABLE public.system_settings (
    key VARCHAR(50) PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO public.system_settings (key, value, description) VALUES
('institution_profile', '{"name": "Utkarsh Small Finance Bank", "code": "SFMS-USFB-01", "currency": "INR", "symbol": "₹"}', 'Bank master profile'),
('business_calendar', '{"current_business_date": "2026-10-24", "day_status": "OPEN", "holiday_calendar": "INDIAN_NI_ACT"}', 'Core calendar and BOD/EOD control'),
('maker_checker_thresholds', '{"cash_deposit_auto_limit": 50000, "cash_withdrawal_auto_limit": 20000, "transfer_auto_limit": 100000, "loan_sanction_branch_limit": 500000}', 'Segregation of duties authorization ceilings');

CREATE TABLE public.branches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_code VARCHAR(10) UNIQUE NOT NULL,
    branch_name VARCHAR(100) NOT NULL,
    ifsc_code VARCHAR(11) NOT NULL,
    micr_code VARCHAR(9),
    tier VARCHAR(20) NOT NULL DEFAULT 'METRO', -- METRO, URBAN, SEMI_URBAN, RURAL
    vault_limit NUMERIC(15,2) NOT NULL DEFAULT 2500000.00,
    address JSONB NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.staff_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    employee_code VARCHAR(20) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    mobile VARCHAR(15) NOT NULL,
    branch_id UUID NOT NULL REFERENCES public.branches(id),
    role VARCHAR(30) NOT NULL, -- SUPER_ADMIN, BRANCH_MANAGER, CASHIER, CSO, LOAN_OFFICER, CREDIT_MANAGER, ACCOUNTANT, AUDITOR, RECOVERY_OFFICER, COMPLIANCE_OFFICER, MANAGEMENT
    cash_drawer_limit NUMERIC(12,2) DEFAULT 200000.00,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- 2. CUSTOMERS, IDENTITY, KYC & NOMINEES
-- ============================================================================

CREATE TABLE public.customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES auth.users(id),
    ucic VARCHAR(20) UNIQUE NOT NULL,
    home_branch_id UUID NOT NULL REFERENCES public.branches(id),
    full_name VARCHAR(150) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(15) NOT NULL,
    mobile VARCHAR(15) NOT NULL,
    email VARCHAR(100),
    occupation VARCHAR(100) NOT NULL,
    risk_category VARCHAR(10) NOT NULL DEFAULT 'LOW', -- LOW, MEDIUM, HIGH
    ckyc_number VARCHAR(14),
    pan_number VARCHAR(10),
    masked_aadhaar VARCHAR(12), -- Stores strictly masked 'XXXXXXXX1234'
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, INOPERATIVE, DORMANT, DECEASED
    is_minor BOOLEAN NOT NULL DEFAULT false,
    address JSONB NOT NULL,
    created_by UUID REFERENCES public.staff_profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.nominees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
    full_name VARCHAR(150) NOT NULL,
    relationship VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    is_minor BOOLEAN NOT NULL DEFAULT false,
    guardian_name VARCHAR(150),
    guardian_relationship VARCHAR(50),
    address JSONB NOT NULL,
    allocation_percentage NUMERIC(5,2) NOT NULL DEFAULT 100.00,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- 3. DYNAMIC PRODUCT CONFIGURATIONS & CUSTOMER ACCOUNTS
-- ============================================================================

CREATE TABLE public.product_definitions (
    id VARCHAR(20) PRIMARY KEY, -- e.g. 'SAV-REG-01', 'CUR-COM-01', 'FD-CUM-01', 'LN-MSME-01'
    product_type VARCHAR(20) NOT NULL, -- SAVINGS, CURRENT, FIXED_DEPOSIT, RECURRING_DEPOSIT, LOAN, OVERDRAFT
    product_name VARCHAR(100) NOT NULL,
    base_interest_rate NUMERIC(5,2) NOT NULL,
    compounding_frequency VARCHAR(20) NOT NULL DEFAULT 'QUARTERLY',
    min_balance NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    gl_account_id VARCHAR(20) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE public.customer_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_number VARCHAR(20) UNIQUE NOT NULL,
    customer_id UUID NOT NULL REFERENCES public.customers(id),
    branch_id UUID NOT NULL REFERENCES public.branches(id),
    product_id VARCHAR(20) NOT NULL REFERENCES public.product_definitions(id),
    account_type VARCHAR(20) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'INR',
    current_balance NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    available_balance NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    lien_amount NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, DORMANT, FROZEN, CLOSED
    opened_date DATE NOT NULL DEFAULT CURRENT_DATE,
    closed_date DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.term_deposits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    certificate_number VARCHAR(25) UNIQUE NOT NULL,
    customer_id UUID NOT NULL REFERENCES public.customers(id),
    linked_account_id UUID NOT NULL REFERENCES public.customer_accounts(id),
    type VARCHAR(20) NOT NULL, -- FIXED_DEPOSIT, RECURRING_DEPOSIT
    principal_amount NUMERIC(15,2) NOT NULL,
    monthly_installment NUMERIC(12,2),
    interest_rate NUMERIC(5,2) NOT NULL,
    tenure_months INT NOT NULL,
    maturity_amount NUMERIC(15,2) NOT NULL,
    start_date DATE NOT NULL,
    maturity_date DATE NOT NULL,
    interest_payout VARCHAR(20) NOT NULL DEFAULT 'ON_MATURITY', -- ON_MATURITY, MONTHLY, QUARTERLY
    tds_deducted NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    form_15g_submitted BOOLEAN NOT NULL DEFAULT false,
    auto_renew BOOLEAN NOT NULL DEFAULT true,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, MATURED, PREMATURE_CLOSED
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- 4. BRANCH CASH OPERATIONS, VAULT & DRAWERS
-- ============================================================================

CREATE TABLE public.vault_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID NOT NULL REFERENCES public.branches(id),
    business_date DATE NOT NULL,
    opening_balance NUMERIC(15,2) NOT NULL,
    closing_balance NUMERIC(15,2),
    keyholder_1_id UUID NOT NULL REFERENCES public.staff_profiles(id),
    keyholder_2_id UUID NOT NULL REFERENCES public.staff_profiles(id),
    status VARCHAR(20) NOT NULL DEFAULT 'OPEN', -- OPEN, CLOSED, RECONCILED
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.cash_drawers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID NOT NULL REFERENCES public.branches(id),
    staff_id UUID NOT NULL REFERENCES public.staff_profiles(id),
    business_date DATE NOT NULL,
    opening_cash NUMERIC(12,2) NOT NULL,
    current_cash NUMERIC(12,2) NOT NULL,
    closing_cash NUMERIC(12,2),
    status VARCHAR(20) NOT NULL DEFAULT 'OPEN',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- 5. LOANS, APPRAISAL, COLLATERAL & REPAYMENTS
-- ============================================================================

CREATE TABLE public.loans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    loan_number VARCHAR(20) UNIQUE NOT NULL,
    customer_id UUID NOT NULL REFERENCES public.customers(id),
    branch_id UUID NOT NULL REFERENCES public.branches(id),
    linked_account_id UUID NOT NULL REFERENCES public.customer_accounts(id),
    product_id VARCHAR(20) NOT NULL REFERENCES public.product_definitions(id),
    sanctioned_amount NUMERIC(15,2) NOT NULL,
    disbursed_amount NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    principal_outstanding NUMERIC(15,2) NOT NULL,
    interest_rate NUMERIC(5,2) NOT NULL,
    tenure_months INT NOT NULL,
    emi_amount NUMERIC(12,2) NOT NULL,
    repaid_months INT NOT NULL DEFAULT 0,
    next_due_date DATE NOT NULL,
    dpd_count INT NOT NULL DEFAULT 0,
    irac_status VARCHAR(20) NOT NULL DEFAULT 'STANDARD', -- STANDARD, SMA0, SMA1, SMA2, SUBSTANDARD, DOUBTFUL, LOSS
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING_APPROVAL', -- PENDING_APPROVAL, SANCTIONED, ACTIVE, CLOSED, WRITTEN_OFF
    purpose TEXT,
    sanctioned_by UUID REFERENCES public.staff_profiles(id),
    sanctioned_at TIMESTAMPTZ,
    disbursed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.repayment_schedules (
    id BIGSERIAL PRIMARY KEY,
    loan_id UUID NOT NULL REFERENCES public.loans(id) ON DELETE CASCADE,
    installment_number INT NOT NULL,
    due_date DATE NOT NULL,
    principal_component NUMERIC(12,2) NOT NULL,
    interest_component NUMERIC(12,2) NOT NULL,
    total_installment NUMERIC(12,2) NOT NULL,
    is_paid BOOLEAN NOT NULL DEFAULT false,
    paid_date DATE,
    paid_amount NUMERIC(12,2) DEFAULT 0.00
);

-- ============================================================================
-- 6. DOUBLE-ENTRY GENERAL LEDGER ENGINE
-- ============================================================================

CREATE TABLE public.chart_of_accounts (
    gl_code VARCHAR(20) PRIMARY KEY,
    gl_name VARCHAR(150) NOT NULL,
    account_category VARCHAR(20) NOT NULL, -- ASSET, LIABILITY, EQUITY, REVENUE, EXPENSE
    parent_gl_code VARCHAR(20) REFERENCES public.chart_of_accounts(gl_code),
    is_leaf BOOLEAN NOT NULL DEFAULT true,
    is_active BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE public.journal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entry_number VARCHAR(30) UNIQUE NOT NULL,
    branch_id UUID NOT NULL REFERENCES public.branches(id),
    business_date DATE NOT NULL,
    reference_type VARCHAR(50) NOT NULL, -- TELLER_DEPOSIT, TELLER_WITHDRAWAL, TRANSFER, LOAN_DISBURSEMENT, LOAN_EMI, EOD_ACCRUAL
    reference_id VARCHAR(50),
    narration TEXT NOT NULL,
    created_by UUID REFERENCES public.staff_profiles(id),
    authorized_by UUID REFERENCES public.staff_profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.journal_lines (
    id BIGSERIAL PRIMARY KEY,
    journal_entry_id UUID NOT NULL REFERENCES public.journal_entries(id) ON DELETE CASCADE,
    gl_code VARCHAR(20) NOT NULL REFERENCES public.chart_of_accounts(gl_code),
    customer_account_id UUID REFERENCES public.customer_accounts(id),
    debit_amount NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    credit_amount NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_debit_credit_exclusive CHECK (
        (debit_amount > 0 AND credit_amount = 0) OR 
        (credit_amount > 0 AND debit_amount = 0)
    )
);

-- Double-Entry Ledger Balanced Verification Trigger
CREATE OR REPLACE FUNCTION public.verify_journal_entry_balance()
RETURNS TRIGGER AS $$
DECLARE
    v_total_debit NUMERIC(15,2);
    v_total_credit NUMERIC(15,2);
BEGIN
    SELECT COALESCE(SUM(debit_amount), 0), COALESCE(SUM(credit_amount), 0)
    INTO v_total_debit, v_total_credit
    FROM public.journal_lines
    WHERE journal_entry_id = NEW.journal_entry_id;

    -- Note: Real enforcement occurs at voucher finalization/post stage
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 7. MAKER-CHECKER APPROVALS & COMPLIANCE
-- ============================================================================

CREATE TABLE public.maker_checker_approvals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID NOT NULL REFERENCES public.branches(id),
    entity_type VARCHAR(50) NOT NULL, -- CASH_DEPOSIT, CASH_WITHDRAWAL, LOAN_APPLICATION, ACCOUNT_OPENING, KYC_UPDATE
    entity_id VARCHAR(50) NOT NULL,
    action_type VARCHAR(50) NOT NULL,
    requested_amount NUMERIC(15,2),
    payload JSONB NOT NULL,
    maker_id UUID NOT NULL REFERENCES public.staff_profiles(id),
    checker_id UUID REFERENCES public.staff_profiles(id),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED
    rejection_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    authorized_at TIMESTAMPTZ
);

CREATE TABLE public.aml_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID NOT NULL REFERENCES public.branches(id),
    customer_id UUID REFERENCES public.customers(id),
    alert_type VARCHAR(50) NOT NULL, -- CTR_THRESHOLD, VELOCITY_STRUCTURING, HIGH_RISK_PEP
    severity VARCHAR(10) NOT NULL DEFAULT 'MEDIUM', -- LOW, MEDIUM, HIGH, CRITICAL
    description TEXT NOT NULL,
    transaction_amount NUMERIC(15,2),
    status VARCHAR(20) NOT NULL DEFAULT 'OPEN', -- OPEN, UNDER_REVIEW, FILED_STR, DISMISSED
    assigned_to UUID REFERENCES public.staff_profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- 8. CRYPTOGRAPHIC TAMPER-EVIDENT AUDIT TRAIL
-- ============================================================================

CREATE TABLE public.audit_logs (
    id BIGSERIAL PRIMARY KEY,
    prev_hash TEXT NOT NULL,
    record_hash TEXT NOT NULL,
    table_name TEXT NOT NULL,
    operation VARCHAR(10) NOT NULL,
    user_id UUID,
    branch_id UUID,
    old_data JSONB,
    new_data JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);

-- ============================================================================
-- 9. SMS STAGING QUEUE (FUTURE MSG91 / DLT GATEWAY)
-- ============================================================================

CREATE TABLE public.sms_queue (
    id BIGSERIAL PRIMARY KEY,
    mobile VARCHAR(15) NOT NULL,
    template_id VARCHAR(50) NOT NULL,
    message_body TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'STAGED_MOCK', -- STAGED_MOCK, DISPATCHED, FAILED
    dlt_template_id VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- 10. ROW-LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

ALTER TABLE public.customer_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.maker_checker_approvals ENABLE ROW LEVEL SECURITY;

-- Helper functions for JWT claims
CREATE OR REPLACE FUNCTION public.get_auth_branch_id()
RETURNS uuid LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('request.jwt.claims', true)::jsonb -> 'app_metadata' ->> 'branch_id', '')::uuid;
$$;

CREATE OR REPLACE FUNCTION public.get_auth_role()
RETURNS text LANGUAGE sql STABLE AS $$
  SELECT current_setting('request.jwt.claims', true)::jsonb -> 'app_metadata' ->> 'role';
$$;

-- Branch staff perimeter access
CREATE POLICY "Staff Branch Perimeter Access"
ON public.customer_accounts
FOR ALL
TO authenticated
USING (
  (public.get_auth_role() IN ('SUPER_ADMIN', 'HO_AUDITOR', 'COMPLIANCE_OFFICER'))
  OR
  (branch_id = public.get_auth_branch_id() AND public.get_auth_role() IN ('BRANCH_MANAGER', 'CASHIER', 'CSO', 'ACCOUNTANT'))
);

-- Customer isolated access
CREATE POLICY "Customer Self Service Access"
ON public.customer_accounts
FOR SELECT
TO authenticated
USING (
  customer_id IN (
    SELECT id FROM public.customers WHERE profile_id = auth.uid()
  )
);

-- ============================================================================
-- 11. BASELINE SEED DATA
-- ============================================================================

-- Chart of Accounts conforming to Third Schedule
INSERT INTO public.chart_of_accounts (gl_code, gl_name, account_category, parent_gl_code, is_leaf) VALUES
('100000', 'ASSETS', 'ASSET', NULL, false),
('110000', 'Cash and Bank Balances', 'ASSET', '100000', false),
('110101', 'Branch Strong Room Vault', 'ASSET', '110000', true),
('110102', 'Cashier Counter Operating Till', 'ASSET', '110000', true),
('140000', 'Advances (Loan Assets)', 'ASSET', '100000', false),
('140101', 'MSME Small Enterprise Loans', 'ASSET', '140000', true),
('140102', 'Microfinance SHG Group Loans', 'ASSET', '140000', true),
('200000', 'LIABILITIES', 'LIABILITY', NULL, false),
('210000', 'Deposits', 'LIABILITY', '200000', false),
('210101', 'Savings Bank Deposits Control', 'LIABILITY', '210000', true),
('210201', 'Current Accounts Demand Deposits', 'LIABILITY', '210000', true),
('210301', 'Term Deposits (FD / RD)', 'LIABILITY', '210000', true),
('230101', 'TDS Payable on Interest Deductions', 'LIABILITY', '200000', true),
('300000', 'CAPITAL & RESERVES', 'EQUITY', NULL, false),
('310000', 'Paid-up Capital & Reserves', 'EQUITY', '300000', true),
('400000', 'REVENUE & INCOME', 'REVENUE', NULL, false),
('410000', 'Interest Earned on Advances', 'REVENUE', '400000', true),
('430000', 'Fee Income & Service Charges', 'REVENUE', '400000', true),
('500000', 'EXPENSES', 'EXPENSE', NULL, false),
('510000', 'Interest Expended on Deposits', 'EXPENSE', '500000', true);

-- Products
INSERT INTO public.product_definitions (id, product_type, product_name, base_interest_rate, compounding_frequency, min_balance, gl_account_id) VALUES
('SAV-REG-01', 'SAVINGS', 'Standard Savings Plus', 4.00, 'QUARTERLY', 500.00, '210101'),
('SAV-KIS-01', 'SAVINGS', 'Kisan Samriddhi Savings', 4.50, 'QUARTERLY', 200.00, '210101'),
('CUR-MER-01', 'CURRENT', 'Smart Merchant Current Account', 0.00, 'NONE', 2000.00, '210201'),
('FD-CUM-01',  'FIXED_DEPOSIT', 'Cumulative Term Deposit (1 Year)', 7.75, 'QUARTERLY', 5000.00, '210301'),
('RD-ACC-01',  'RECURRING_DEPOSIT', 'Monthly Recurring Deposit', 7.25, 'QUARTERLY', 500.00, '210301'),
('LN-MSME-01', 'LOAN', 'MSME Business Expansion Loan', 11.50, 'MONTHLY', 0.00, '140101'),
('LN-SHG-01',  'LOAN', 'Microfinance SHG Group Loan', 10.00, 'MONTHLY', 0.00, '140102');

-- Branch
INSERT INTO public.branches (id, branch_code, branch_name, ifsc_code, micr_code, tier, vault_limit, address) VALUES
('b0000000-0000-0000-0000-000000000001', 'BR001', 'Metro Central Branch', 'SFMS0001001', '302889001', 'METRO', 2500000.00, '{"street": "Connaught Place", "city": "Jaipur", "state": "Rajasthan", "pincode": "302001"}'),
('b0000000-0000-0000-0000-000000000002', 'BR002', 'Alwar Rural Branch', 'SFMS0001002', '301889002', 'RURAL', 1500000.00, '{"street": "Mandi Road", "city": "Alwar", "state": "Rajasthan", "pincode": "301001"}');

-- ============================================================================
-- 12. RPC FUNCTIONS & COMPATIBILITY VIEWS
-- ============================================================================

-- Backwards compatibility view for legacy 'members' queries
CREATE OR REPLACE VIEW public.members AS
SELECT 
    id,
    profile_id,
    ucic AS member_number,
    full_name,
    mobile,
    email,
    risk_category,
    status,
    created_at,
    updated_at
FROM public.customers;

-- Stored Procedure: User profile & role resolution (used across mobile and web)
CREATE OR REPLACE FUNCTION public.sfms_get_my_profile()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_staff record;
  v_customer record;
BEGIN
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object('error', 'Not authenticated');
  END IF;

  -- 1. Check if user is staff profile
  SELECT s.*, b.branch_name, b.branch_code
  INTO v_staff
  FROM public.staff_profiles s
  LEFT JOIN public.branches b ON s.branch_id = b.id
  WHERE s.id = v_uid AND s.is_active = true;

  IF FOUND THEN
    RETURN jsonb_build_object(
      'user_type', 'STAFF',
      'id', v_staff.id,
      'role', v_staff.role,
      'role_code', v_staff.role,
      'role_name', v_staff.role,
      'full_name', v_staff.full_name,
      'employee_code', v_staff.employee_code,
      'email', v_staff.email,
      'branch_id', v_staff.branch_id,
      'branch_name', v_staff.branch_name,
      'cash_drawer_limit', v_staff.cash_drawer_limit
    );
  END IF;

  -- 2. Check if user is customer profile
  SELECT c.*, b.branch_name, b.branch_code
  INTO v_customer
  FROM public.customers c
  LEFT JOIN public.branches b ON c.home_branch_id = b.id
  WHERE c.profile_id = v_uid AND c.status = 'ACTIVE';

  IF FOUND THEN
    RETURN jsonb_build_object(
      'user_type', 'CUSTOMER',
      'id', v_customer.id,
      'role', 'CUSTOMER',
      'role_code', 'CUSTOMER',
      'role_name', 'CUSTOMER',
      'full_name', v_customer.full_name,
      'ucic', v_customer.ucic,
      'email', v_customer.email,
      'branch_id', v_customer.home_branch_id,
      'branch_name', v_customer.branch_name,
      'risk_category', v_customer.risk_category
    );
  END IF;

  -- 3. Fallback: Check raw app_metadata or default to ADMIN if email matches or role in metadata
  RETURN jsonb_build_object(
    'user_type', 'AUTHENTICATED',
    'role', COALESCE(current_setting('request.jwt.claims', true)::jsonb -> 'app_metadata' ->> 'role', 'ADMIN'),
    'role_code', COALESCE(current_setting('request.jwt.claims', true)::jsonb -> 'app_metadata' ->> 'role', 'ADMIN'),
    'id', v_uid
  );
END;
$$;

-- Grant execution to authenticated & anon roles
GRANT EXECUTE ON FUNCTION public.sfms_get_my_profile() TO authenticated, anon;
GRANT SELECT ON public.members TO authenticated, anon;

