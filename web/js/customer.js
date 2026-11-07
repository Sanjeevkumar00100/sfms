/**
 * SFMS Customer Banking Application Controller
 */

let currentCustomerId = 'MEM002'; // Default: Priya Sharma
let customerActiveTab = 'home';
let isCardFlipped = false;

document.addEventListener('DOMContentLoaded', () => {
  initCustomerApp();
  sfmsStore.subscribe(() => {
    renderCustomerApp();
  });
});

function initCustomerApp() {
  setupCustomerSelector();
  setupCustomerNavigation();
  renderCustomerApp();
}

function showCustomerToast(message, type = 'success') {
  let container = document.getElementById('toast-container');
  if (!container) {
    container = document.createElement('div');
    container.id = 'toast-container';
    document.body.appendChild(container);
  }
  const toast = document.createElement('div');
  toast.className = `toast ${type}`;
  toast.innerHTML = `<span>${type === 'success' ? '✅' : type === 'error' ? '❌' : 'ℹ️'}</span> <div>${message}</div>`;
  container.appendChild(toast);
  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateY(10px)';
    setTimeout(() => toast.remove(), 250);
  }, 3500);
}

function setupCustomerSelector() {
  const sel = document.getElementById('customer-profile-selector');
  if (sel) {
    const members = sfmsStore.getMembers();
    sel.innerHTML = members.map(m => `
      <option value="${m.id}" ${m.id === currentCustomerId ? 'selected' : ''}>
        ${m.fullName} (${m.occupation})
      </option>
    `).join('');

    sel.addEventListener('change', (e) => {
      currentCustomerId = e.target.value;
      const member = sfmsStore.getMemberById(currentCustomerId);
      showCustomerToast(`Logged in as: ${member.fullName}`, 'info');
      renderCustomerApp();
    });
  }
}

function setupCustomerNavigation() {
  const tabs = document.querySelectorAll('[data-cust-tab]');
  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      const target = tab.getAttribute('data-cust-tab');
      switchCustomerTab(target);
    });
  });
}

function switchCustomerTab(tabName) {
  customerActiveTab = tabName;
  document.querySelectorAll('[data-cust-tab]').forEach(tab => {
    if (tab.getAttribute('data-cust-tab') === tabName) {
      tab.classList.add('active-cust-nav');
    } else {
      tab.classList.remove('active-cust-nav');
    }
  });

  document.querySelectorAll('.cust-section').forEach(sec => {
    sec.style.display = 'none';
  });

  const activeSec = document.getElementById(`cust-section-${tabName}`);
  if (activeSec) {
    activeSec.style.display = 'block';
  }

  renderCustomerApp();
}

function renderCustomerApp() {
  const member = sfmsStore.getMemberById(currentCustomerId);
  if (!member) return;

  const accounts = sfmsStore.getAccountsByMemberId(member.id);
  const primaryAccount = accounts[0] || null;
  const loans = sfmsStore.getLoansByMemberId(member.id);
  const termDeposits = sfmsStore.getTermDepositsByMemberId(member.id);

  // Update customer name & avatar
  const nameEls = document.querySelectorAll('.cust-name-display');
  nameEls.forEach(el => el.innerText = member.fullName.split(' ')[0]);

  const fullNameEls = document.querySelectorAll('.cust-fullname-display');
  fullNameEls.forEach(el => el.innerText = member.fullName);

  const occEls = document.querySelectorAll('.cust-occupation-display');
  occEls.forEach(el => el.innerText = member.occupation);

  // Render Tab
  switch (customerActiveTab) {
    case 'home':
      renderCustomerHome(member, accounts, loans, termDeposits);
      break;
    case 'passbook':
      renderCustomerPassbook(member, accounts);
      break;
    case 'transfer':
      renderCustomerTransfer(member, accounts);
      break;
    case 'deposits':
      renderCustomerDeposits(member, accounts, termDeposits);
      break;
    case 'loans':
      renderCustomerLoans(member, accounts, loans);
      break;
    case 'card':
      renderCustomerCard(primaryAccount);
      break;
    case 'profile':
      renderCustomerProfile(member, accounts);
      break;
  }
}

// ==========================================
// 1. CUSTOMER HOME
// ==========================================
function renderCustomerHome(member, accounts, loans, termDeposits) {
  const primaryAccount = accounts[0];
  const totalSavings = accounts.reduce((sum, a) => sum + a.balance, 0);
  const totalFD = termDeposits.reduce((sum, td) => sum + (td.principal || td.totalAccumulated || 0), 0);
  const totalLoanDue = loans
    .filter(l => l.status === 'ACTIVE')
    .reduce((sum, l) => sum + l.outstandingPrincipal, 0);

  const netWorth = (totalSavings + totalFD) - totalLoanDue;

  // Header net worth
  const elNetWorth = document.getElementById('cust-net-worth');
  if (elNetWorth) elNetWorth.innerText = formatINR(netWorth);

  const elPrimaryBal = document.getElementById('cust-primary-balance');
  if (elPrimaryBal) elPrimaryBal.innerText = primaryAccount ? formatINR(primaryAccount.balance) : '₹0.00';

  const elPrimaryAccNum = document.getElementById('cust-primary-accnum');
  if (elPrimaryAccNum && primaryAccount) {
    elPrimaryAccNum.innerText = `A/C •••• ${primaryAccount.accountNumber.slice(-4)}`;
  }

  // Linked accounts carousel/list
  const accList = document.getElementById('cust-accounts-list');
  if (accList) {
    accList.innerHTML = accounts.map(a => `
      <div class="p-3 border border-slate-200 rounded-xl bg-white shadow-xs flex justify-between items-center text-xs">
        <div>
          <div class="font-bold text-slate-800 font-mono">${a.accountNumber}</div>
          <div class="text-slate-500">${a.productName}</div>
        </div>
        <div class="text-right">
          <div class="font-bold text-emerald-600 text-sm">${formatINR(a.balance)}</div>
          <div class="text-[10px] text-slate-400">Avail: ${formatINR(a.availableBalance)}</div>
        </div>
      </div>
    `).join('');
  }

  // Recent transactions (last 5)
  const recentTxnsContainer = document.getElementById('cust-recent-txns-list');
  if (recentTxnsContainer) {
    const accIds = accounts.map(a => a.id);
    const memberTxns = sfmsStore.getAllTransactions()
      .filter(t => accIds.includes(t.accountId))
      .slice(0, 5);

    if (memberTxns.length === 0) {
      recentTxnsContainer.innerHTML = '<div class="text-xs text-center text-slate-400 py-4">No recent transactions</div>';
    } else {
      recentTxnsContainer.innerHTML = memberTxns.map(t => {
        const isCredit = t.type === 'CREDIT';
        let icon = isCredit ? '📥' : '📤';
        if (t.category === 'LOAN_EMI') icon = '📑';
        if (t.category === 'TRANSFER') icon = '🔁';

        return `
          <div class="flex items-center justify-between p-3 rounded-xl bg-white border border-slate-100 hover:bg-slate-50 transition cursor-pointer" onclick="viewTxnReceipt('${t.id}')">
            <div class="flex items-center gap-3">
              <div class="w-9 h-9 rounded-full ${isCredit ? 'bg-emerald-100 text-emerald-700' : 'bg-rose-100 text-rose-700'} flex items-center justify-center text-sm">
                ${icon}
              </div>
              <div>
                <div class="font-semibold text-xs text-slate-800">${t.narration || t.category}</div>
                <div class="text-[10px] text-slate-400 font-mono">${t.timestamp}</div>
              </div>
            </div>
            <div class="text-right">
              <div class="font-bold text-xs ${isCredit ? 'text-emerald-600' : 'text-rose-600'}">
                ${isCredit ? '+' : '-'}${formatINR(t.amount)}
              </div>
              <div class="text-[10px] text-slate-400 font-mono">${t.type}</div>
            </div>
          </div>
        `;
      }).join('');
    }
  }
}

// ==========================================
// 2. PASSBOOK & STATEMENTS
// ==========================================
let passbookFilter = 'ALL';

function renderCustomerPassbook(member, accounts) {
  const accIds = accounts.map(a => a.id);
  let txns = sfmsStore.getAllTransactions().filter(t => accIds.includes(t.accountId));

  if (passbookFilter === 'CREDIT') {
    txns = txns.filter(t => t.type === 'CREDIT');
  } else if (passbookFilter === 'DEBIT') {
    txns = txns.filter(t => t.type === 'DEBIT');
  } else if (passbookFilter === 'TRANSFER') {
    txns = txns.filter(t => t.category === 'TRANSFER');
  }

  const container = document.getElementById('cust-passbook-entries');
  if (!container) return;

  if (txns.length === 0) {
    container.innerHTML = '<div class="text-center py-8 text-slate-400 text-xs">No records found for this filter.</div>';
    return;
  }

  container.innerHTML = txns.map(t => {
    const isCredit = t.type === 'CREDIT';
    return `
      <div class="p-3 bg-white border border-slate-100 rounded-xl hover:shadow-xs transition cursor-pointer mb-2" onclick="viewTxnReceipt('${t.id}')">
        <div class="flex justify-between items-start mb-1">
          <div class="font-semibold text-xs text-slate-900">${t.narration || t.category.replace(/_/g, ' ')}</div>
          <div class="font-bold text-xs ${isCredit ? 'text-emerald-600' : 'text-rose-600'}">
            ${isCredit ? '+' : '-'}${formatINR(t.amount)}
          </div>
        </div>
        <div class="flex justify-between items-center text-[10px] text-slate-400 font-mono">
          <div>Ref: ${t.reference || t.txnNumber}</div>
          <div>Bal: ${formatINR(t.balanceAfter)}</div>
        </div>
        <div class="text-[10px] text-slate-400 mt-1">${t.timestamp} • Channel: ${t.channel}</div>
      </div>
    `;
  }).join('');
}

function setPassbookFilter(filter) {
  passbookFilter = filter;
  document.querySelectorAll('[data-passbook-filter]').forEach(b => {
    if (b.getAttribute('data-passbook-filter') === filter) {
      b.className = 'btn btn-primary btn-sm text-xs py-1 px-3';
    } else {
      b.className = 'btn btn-outline btn-sm text-xs py-1 px-3';
    }
  });
  const member = sfmsStore.getMemberById(currentCustomerId);
  const accounts = sfmsStore.getAccountsByMemberId(currentCustomerId);
  renderCustomerPassbook(member, accounts);
}

function downloadCustomerStatementCSV() {
  const member = sfmsStore.getMemberById(currentCustomerId);
  const accounts = sfmsStore.getAccountsByMemberId(currentCustomerId);
  const accIds = accounts.map(a => a.id);
  const txns = sfmsStore.getAllTransactions().filter(t => accIds.includes(t.accountId));

  let csv = 'Date,Txn Number,Account,Type,Category,Reference,Amount,Balance After\n';
  txns.forEach(t => {
    csv += `"${t.timestamp}","${t.txnNumber}","${t.accountNumber}","${t.type}","${t.category}","${t.reference}","${t.amount}","${t.balanceAfter}"\n`;
  });

  const blob = new Blob([csv], { type: 'text/csv' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `SFMS_Statement_${member.fullName.replace(/\s+/g, '_')}.csv`;
  a.click();
  showCustomerToast('Statement downloaded successfully!');
}

// ==========================================
// 3. TRANSFERS & PAYMENTS
// ==========================================
function renderCustomerTransfer(member, accounts) {
  const fromSel = document.getElementById('cust-transfer-from-account');
  if (fromSel) {
    fromSel.innerHTML = accounts.map(a => `
      <option value="${a.id}">
        ${a.accountNumber} (${a.productName}) - Avail: ${formatINR(a.availableBalance)}
      </option>
    `).join('');
  }
}

function setQuickTransferAmount(amt) {
  const inp = document.getElementById('cust-transfer-amount');
  if (inp) inp.value = amt;
}

function handleCustomerTransferSubmit(e) {
  e.preventDefault();
  const form = e.target;
  const formData = new FormData(form);

  const pin = formData.get('securityPin');
  if (pin !== '1234') {
    showCustomerToast('Incorrect Security PIN. Demo default PIN is 1234', 'error');
    return;
  }

  try {
    const res = sfmsStore.transferFunds({
      fromAccountId: formData.get('fromAccountId'),
      toAccountNumber: formData.get('toAccountNumber'),
      amount: formData.get('amount'),
      narration: formData.get('narration'),
      initiatedBy: 'CUSTOMER'
    });

    showCustomerToast(`Transfer of ₹${formData.get('amount')} successful! Ref: ${res.reference}`);
    form.reset();
    switchCustomerTab('home');
    showReceiptModal(res.debitTxn, sfmsStore.getBankInfo());
  } catch (err) {
    showCustomerToast(err.message, 'error');
  }
}

// ==========================================
// 4. TERM DEPOSITS (FD / RD)
// ==========================================
function renderCustomerDeposits(member, accounts, termDeposits) {
  const accSel = document.getElementById('cust-deposit-account-select');
  if (accSel) {
    accSel.innerHTML = accounts.map(a => `
      <option value="${a.id}">
        ${a.accountNumber} (Balance: ${formatINR(a.balance)})
      </option>
    `).join('');
  }

  const container = document.getElementById('cust-active-deposits-list');
  if (container) {
    if (termDeposits.length === 0) {
      container.innerHTML = '<div class="text-xs text-slate-400 py-4 text-center">No active Fixed or Recurring Deposits.</div>';
    } else {
      container.innerHTML = termDeposits.map(td => `
        <div class="p-4 bg-white border border-slate-200 rounded-xl shadow-xs mb-3">
          <div class="flex justify-between items-start">
            <div>
              <span class="sfms-badge active text-[10px]">${td.type.replace(/_/g, ' ')}</span>
              <div class="font-bold text-slate-900 text-sm mt-1">${td.certificateNumber}</div>
              <div class="text-xs text-slate-500 font-mono">Rate: ${td.interestRate}% p.a. • ${td.termMonths} Months</div>
            </div>
            <div class="text-right">
              <div class="text-xs text-slate-400">Principal</div>
              <div class="font-bold text-slate-900 text-sm">${formatINR(td.principal || td.totalAccumulated)}</div>
            </div>
          </div>
          <div class="flex justify-between items-center mt-3 pt-2 border-t border-slate-100 text-xs">
            <span class="text-slate-500">Maturity: <strong class="text-slate-800">${td.maturityDate}</strong></span>
            <span class="text-emerald-700 font-bold">Maturity Value: ${formatINR(td.maturityAmount)}</span>
          </div>
        </div>
      `).join('');
    }
  }

  calculateDepositCalculator();
}

function calculateDepositCalculator() {
  const amtInp = document.getElementById('fd-calc-amount');
  const termInp = document.getElementById('fd-calc-term');
  const rateInp = document.getElementById('fd-calc-rate');

  if (!amtInp || !termInp) return;

  const principal = parseFloat(amtInp.value || 50000);
  const months = parseInt(termInp.value || 12, 10);
  let rate = 7.5;
  if (months < 6) rate = 6.25;
  else if (months >= 12 && months < 24) rate = 7.75;
  else if (months >= 24) rate = 8.10;

  if (rateInp) rateInp.value = rate + '%';

  const interest = principal * (rate / 100) * (months / 12);
  const maturity = principal + interest;

  const elInterest = document.getElementById('fd-calc-interest');
  const elMaturity = document.getElementById('fd-calc-maturity');

  if (elInterest) elInterest.innerText = formatINR(interest);
  if (elMaturity) elMaturity.innerText = formatINR(maturity);
}

function handleOpenDepositSubmit(e) {
  e.preventDefault();
  const form = e.target;
  const formData = new FormData(form);

  const amt = parseFloat(formData.get('amount'));
  const months = parseInt(formData.get('termMonths'), 10);
  let rate = 7.5;
  if (months < 6) rate = 6.25;
  else if (months >= 12 && months < 24) rate = 7.75;
  else if (months >= 24) rate = 8.10;

  try {
    const td = sfmsStore.createTermDeposit({
      memberId: currentCustomerId,
      linkedAccountId: formData.get('linkedAccountId'),
      type: formData.get('depositType'),
      amount: amt,
      termMonths: months,
      interestRate: rate,
      autoRenew: true,
      initiatedBy: 'CUSTOMER'
    });

    showCustomerToast(`${td.type.replace(/_/g, ' ')} Certificate ${td.certificateNumber} opened!`);
    form.reset();
    switchCustomerTab('home');
  } catch (err) {
    showCustomerToast(err.message, 'error');
  }
}

// ==========================================
// 5. LOANS & REPAYMENTS
// ==========================================
function renderCustomerLoans(member, accounts, loans) {
  const container = document.getElementById('cust-active-loans-list');
  if (container) {
    if (loans.length === 0) {
      container.innerHTML = '<div class="text-xs text-slate-400 py-6 text-center">No active loans or applications.</div>';
    } else {
      container.innerHTML = loans.map(l => {
        const isActive = l.status === 'ACTIVE';
        return `
          <div class="p-4 bg-white border border-slate-200 rounded-xl shadow-xs mb-3">
            <div class="flex justify-between items-start mb-2">
              <div>
                <span class="sfms-badge ${isActive ? 'active' : 'pending'} text-[10px]">${l.status}</span>
                <div class="font-bold text-slate-900 text-sm mt-1">${l.loanType}</div>
                <div class="text-xs text-slate-400 font-mono">${l.loanNumber} • ${l.interestRate}% p.a.</div>
              </div>
              <div class="text-right">
                <div class="text-xs text-slate-400">Balance Due</div>
                <div class="font-bold text-slate-900 text-sm">${formatINR(l.outstandingPrincipal)}</div>
              </div>
            </div>

            ${isActive ? `
              <div class="bg-emerald-50 p-3 rounded-lg flex justify-between items-center text-xs mt-3">
                <div>
                  <div class="text-emerald-800 font-semibold">Monthly EMI: ${formatINR(l.emiAmount)}</div>
                  <div class="text-[10px] text-emerald-600">Next due date: ${l.nextDueDate}</div>
                </div>
                <button class="btn btn-primary btn-sm text-xs py-1" onclick="handlePayEmiCustomer('${l.id}')">
                  1-Click Pay EMI
                </button>
              </div>
            ` : `
              <div class="bg-amber-50 p-2 rounded-lg text-xs text-amber-800 mt-2">
                Under credit review at branch. Expected approval in 24 hours.
              </div>
            `}
          </div>
        `;
      }).join('');
    }
  }
}

function handlePayEmiCustomer(loanId) {
  const member = sfmsStore.getMemberById(currentCustomerId);
  const accounts = sfmsStore.getAccountsByMemberId(member.id);
  const primaryAccount = accounts[0];

  if (!primaryAccount) {
    showCustomerToast('No savings account found to debit EMI from', 'error');
    return;
  }

  try {
    const res = sfmsStore.repayLoanEMI({
      loanId,
      accountId: primaryAccount.id,
      paymentMethod: 'ACCOUNT',
      initiatedBy: 'CUSTOMER'
    });

    showCustomerToast(`EMI Payment of ${formatINR(res.emiPaid)} successful!`);
    renderCustomerApp();
  } catch (err) {
    showCustomerToast(err.message, 'error');
  }
}

function handleCustomerApplyLoanSubmit(e) {
  e.preventDefault();
  const form = e.target;
  const formData = new FormData(form);

  try {
    const loan = sfmsStore.applyForLoan({
      memberId: currentCustomerId,
      loanType: formData.get('loanType'),
      amount: formData.get('amount'),
      termMonths: formData.get('termMonths'),
      interestRate: 11.5,
      purpose: formData.get('purpose'),
      initiatedBy: 'CUSTOMER'
    });

    showCustomerToast(`Loan application ${loan.loanNumber} submitted! Review in progress.`);
    form.reset();
    renderCustomerLoans(sfmsStore.getMemberById(currentCustomerId), sfmsStore.getAccountsByMemberId(currentCustomerId), sfmsStore.getLoansByMemberId(currentCustomerId));
  } catch (err) {
    showCustomerToast(err.message, 'error');
  }
}

// ==========================================
// 6. VIRTUAL DEBIT CARD
// ==========================================
function renderCustomerCard(account) {
  if (!account || !account.debitCard) {
    const container = document.getElementById('cust-card-container');
    if (container) container.innerHTML = '<div class="text-xs text-center text-slate-400 py-10">No debit card issued for this account.</div>';
    return;
  }

  const card = account.debitCard;
  const cardEl = document.getElementById('virtual-debit-card');
  const lockOverlay = document.getElementById('card-locked-overlay');
  const lockToggle = document.getElementById('card-lock-toggle');
  const onlineToggle = document.getElementById('card-online-toggle');
  const limitSlider = document.getElementById('card-limit-slider');
  const limitValue = document.getElementById('card-limit-value');

  if (cardEl) {
    document.getElementById('card-holder-name').innerText = account.accountName.toUpperCase();
    document.getElementById('card-num-display').innerText = card.cardNumber;
    document.getElementById('card-expiry-display').innerText = card.expiry;
    document.getElementById('card-cvv-display').innerText = card.cvv;
  }

  if (lockOverlay) {
    lockOverlay.style.display = card.isLocked ? 'flex' : 'none';
  }
  if (lockToggle) lockToggle.checked = card.isLocked;
  if (onlineToggle) onlineToggle.checked = card.onlineTxnEnabled;
  if (limitSlider) limitSlider.value = card.atmLimit;
  if (limitValue) limitValue.innerText = formatINR(card.atmLimit);
}

function toggleCardFlip() {
  const card = document.getElementById('virtual-debit-card');
  if (card) {
    isCardFlipped = !isCardFlipped;
    if (isCardFlipped) {
      card.classList.add('flipped');
    } else {
      card.classList.remove('flipped');
    }
  }
}

function handleCardLockChange(isLocked) {
  const accounts = sfmsStore.getAccountsByMemberId(currentCustomerId);
  if (accounts[0]) {
    sfmsStore.updateCardSettings({
      accountId: accounts[0].id,
      isLocked
    });
    showCustomerToast(isLocked ? 'Debit card FROZEN for security' : 'Debit card ACTIVE and ready for use');
  }
}

function handleCardOnlineChange(onlineTxnEnabled) {
  const accounts = sfmsStore.getAccountsByMemberId(currentCustomerId);
  if (accounts[0]) {
    sfmsStore.updateCardSettings({
      accountId: accounts[0].id,
      onlineTxnEnabled
    });
    showCustomerToast(`Online e-commerce transactions ${onlineTxnEnabled ? 'ENABLED' : 'DISABLED'}`);
  }
}

function handleCardLimitChange(limit) {
  const accounts = sfmsStore.getAccountsByMemberId(currentCustomerId);
  if (accounts[0]) {
    sfmsStore.updateCardSettings({
      accountId: accounts[0].id,
      atmLimit: limit
    });
    document.getElementById('card-limit-value').innerText = formatINR(limit);
  }
}

// ==========================================
// 7. PROFILE & SELF SERVICE
// ==========================================
function renderCustomerProfile(member, accounts) {
  const container = document.getElementById('cust-profile-details');
  if (!container) return;

  container.innerHTML = `
    <div class="space-y-4 text-xs">
      <div class="p-3 bg-slate-50 rounded-xl">
        <div class="text-slate-400">Member ID</div>
        <div class="font-bold text-slate-800 font-mono">${member.memberNumber}</div>
      </div>
      <div class="p-3 bg-slate-50 rounded-xl">
        <div class="text-slate-400">KYC Status</div>
        <div class="font-bold text-emerald-600">${member.kyc.status} (${member.kyc.idType} - ${member.kyc.idNumber})</div>
      </div>
      <div class="p-3 bg-slate-50 rounded-xl">
        <div class="text-slate-400">Mobile & Email</div>
        <div class="font-semibold text-slate-800">${member.mobile} • ${member.email || 'None'}</div>
      </div>
      <div class="p-3 bg-slate-50 rounded-xl">
        <div class="text-slate-400">Registered Address</div>
        <div class="font-semibold text-slate-800">${member.address.street}, ${member.address.district}, ${member.address.state} - ${member.address.pincode}</div>
      </div>
    </div>
  `;
}

function handleChequeBookRequest() {
  showCustomerToast('Cheque book request submitted! Dispatched via registered post in 3 business days.');
}

window.switchCustomerTab = switchCustomerTab;
window.setPassbookFilter = setPassbookFilter;
window.downloadCustomerStatementCSV = downloadCustomerStatementCSV;
window.setQuickTransferAmount = setQuickTransferAmount;
window.handleCustomerTransferSubmit = handleCustomerTransferSubmit;
window.calculateDepositCalculator = calculateDepositCalculator;
window.handleOpenDepositSubmit = handleOpenDepositSubmit;
window.handlePayEmiCustomer = handlePayEmiCustomer;
window.handleCustomerApplyLoanSubmit = handleCustomerApplyLoanSubmit;
window.toggleCardFlip = toggleCardFlip;
window.handleCardLockChange = handleCardLockChange;
window.handleCardOnlineChange = handleCardOnlineChange;
window.handleCardLimitChange = handleCardLimitChange;
window.handleChequeBookRequest = handleChequeBookRequest;
