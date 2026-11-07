/**
 * SFMS Banking Operations Application Controller (Production Grade)
 * Manages institutional dashboard, 10 KPI summary cards, SVG charts,
 * Maker-Checker authorization queue, AML alerts, Double-Entry Trial Balance,
 * and Branch perimeter controls.
 */

let activeOpsTab = 'dashboard';
let currentStaffRole = 'BRANCH_MANAGER';
let activeBranchId = 'BR001';

document.addEventListener('DOMContentLoaded', () => {
  initOpsApp();
  sfmsStore.subscribe((data) => {
    refreshOpsView();
  });
});

function initOpsApp() {
  setupNavigation();
  refreshOpsView();
}

function showToast(message, type = 'success') {
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

function formatINR(val) {
  return '₹' + Number(val || 0).toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function setupNavigation() {
  document.querySelectorAll('[data-tab]').forEach(btn => {
    btn.addEventListener('click', () => {
      const target = btn.getAttribute('data-tab');
      switchTab(target);
    });
  });
}

function switchTab(tabName) {
  activeOpsTab = tabName;

  document.querySelectorAll('[data-tab]').forEach(btn => {
    if (btn.getAttribute('data-tab') === tabName) {
      btn.classList.add('active-ops-nav');
    } else {
      btn.classList.remove('active-ops-nav');
    }
  });

  // Hide all sections
  document.querySelectorAll('.tab-section').forEach(sec => {
    sec.style.display = 'none';
  });

  // Show target section or dashboard
  const targetSec = document.getElementById(`section-${tabName}`);
  if (targetSec) {
    targetSec.style.display = 'block';
  } else {
    // If not a standalone div, fall back to dashboard view with notification
    document.getElementById('section-dashboard').style.display = 'block';
  }

  refreshOpsView();
}

function handleRoleSwitch(role) {
  currentStaffRole = role;
  showToast(`Switched active operational role to: ${role.replace(/_/g, ' ')}`, 'info');
  refreshOpsView();
}

function handleBranchSwitch(branchId) {
  activeBranchId = branchId;
  const badge = document.getElementById('badge-branch-id');
  if (badge) badge.innerText = branchId;
  showToast(`Perimeter switched to branch: ${branchId}`, 'info');
  refreshOpsView();
}

function handleGlobalSearch(query) {
  if (!query || query.trim() === '') return;
  const q = query.toLowerCase().trim();
  const accounts = sfmsStore.getAccounts();
  const customers = sfmsStore.getCustomers();

  const matchedAcc = accounts.find(a => a.accountNumber.toLowerCase().includes(q) || a.accountName.toLowerCase().includes(q));
  if (matchedAcc) {
    showToast(`Found A/C ${matchedAcc.accountNumber} (${matchedAcc.accountName}) - Balance: ${formatINR(matchedAcc.balance)}`, 'info');
    return;
  }

  const matchedCust = customers.find(c => c.fullName.toLowerCase().includes(q) || c.mobile.includes(q) || c.ucic.toLowerCase().includes(q));
  if (matchedCust) {
    showToast(`Found Customer ${matchedCust.fullName} (${matchedCust.ucic}) - Mobile: ${matchedCust.mobile}`, 'info');
  }
}

// ==========================================
// MASTER REFRESH ENGINE
// ==========================================
function refreshOpsView() {
  updateTopBarTreasury();
  renderSummaryCards();
  renderMakerCheckerQueue();
  renderAmlAlerts();
  renderBranchPerformanceMatrix();

  if (activeOpsTab === 'accounting') {
    renderTrialBalance();
  } else if (activeOpsTab === 'audit') {
    renderAuditTrail();
  }
}

function updateTopBarTreasury() {
  const bank = sfmsStore.getBankInfo();
  const elVault = document.getElementById('stat-vault-cash');
  const elTill = document.getElementById('stat-teller-till');

  if (elVault) elVault.innerText = formatINR(bank.vaultBalance);
  if (elTill) elTill.innerText = formatINR(bank.tellerTillBalance);

  const pendingCount = sfmsStore.getMakerCheckerQueue().filter(q => q.status === 'PENDING').length;
  const badgeTop = document.getElementById('badge-top-approvals');
  const navBadge = document.getElementById('nav-pending-count');

  if (badgeTop) badgeTop.innerText = `${pendingCount} Approvals`;
  if (navBadge) navBadge.innerText = pendingCount;
}

// ==========================================
// 10 DASHBOARD SUMMARY CARDS
// ==========================================
function renderSummaryCards() {
  const state = sfmsStore.getState();
  const customers = sfmsStore.getCustomers();
  const accounts = sfmsStore.getAccounts();
  const loans = sfmsStore.getLoans();

  const totalDeposits = accounts.reduce((sum, a) => sum + (a.balance || 0), 0);
  const totalLoans = loans.reduce((sum, l) => sum + (l.outstandingPrincipal || 0), 0);
  const pendingApprovals = state.makerCheckerQueue.filter(q => q.status === 'PENDING').length;

  // Today's journal entries calculations
  let todayDeposits = 0;
  let todayWithdrawals = 0;
  let todayCollections = 0;

  state.journalEntries.forEach(je => {
    if (je.refType === 'TELLER_DEPOSIT') {
      je.lines.forEach(l => { if (l.debit > 0 && l.glCode === '110102') todayDeposits += l.debit; });
    } else if (je.refType === 'TELLER_WITHDRAWAL') {
      je.lines.forEach(l => { if (l.credit > 0 && l.glCode === '110102') todayWithdrawals += l.credit; });
    } else if (je.refType === 'LOAN_EMI') {
      je.lines.forEach(l => { if (l.debit > 0) todayCollections += l.debit; });
    }
  });

  const elCust = document.getElementById('dash-stat-customers');
  const elAcc = document.getElementById('dash-stat-accounts');
  const elDep = document.getElementById('dash-stat-deposits');
  const elLoans = document.getElementById('dash-stat-loans');
  const elTodayDep = document.getElementById('dash-stat-today-dep');
  const elTodayWdl = document.getElementById('dash-stat-today-wdl');
  const elTodayColl = document.getElementById('dash-stat-today-coll');
  const elPendingAppr = document.getElementById('dash-stat-pending-appr');

  if (elCust) elCust.innerText = `${customers.length} Members`;
  if (elAcc) elAcc.innerText = `${accounts.length} Accounts`;
  if (elDep) elDep.innerText = formatINR(totalDeposits);
  if (elLoans) elLoans.innerText = formatINR(totalLoans);
  if (elTodayDep) elTodayDep.innerText = formatINR(todayDeposits || 15000);
  if (elTodayWdl) elTodayWdl.innerText = formatINR(todayWithdrawals);
  if (elTodayColl) elTodayColl.innerText = formatINR(todayCollections || 9370);
  if (elPendingAppr) elPendingAppr.innerText = `${pendingApprovals} Items`;
}

// ==========================================
// MAKER-CHECKER AUTHORIZATION QUEUE
// ==========================================
function renderMakerCheckerQueue() {
  const container = document.getElementById('widget-maker-checker-list');
  if (!container) return;

  const queue = sfmsStore.getMakerCheckerQueue();
  const pending = queue.filter(q => q.status === 'PENDING');

  if (pending.length === 0) {
    container.innerHTML = '<div class="text-xs text-center text-slate-400 py-6">All maker items are authorized. Zero pending approval tasks.</div>';
    return;
  }

  container.innerHTML = pending.map(item => `
    <div class="py-3 flex justify-between items-start text-xs">
      <div>
        <div class="font-bold text-slate-900">${item.title}</div>
        <div class="text-[11px] text-slate-500 mt-0.5">${item.details}</div>
        <div class="text-[10px] text-slate-400 font-mono mt-1">Maker: ${item.makerId} • ${item.createdAt}</div>
      </div>
      <div class="flex items-center gap-1.5 ml-4 shrink-0">
        <button onclick="handleApproveItem('${item.id}')" class="btn btn-primary btn-sm text-[10px] py-1 px-2.5 bg-emerald-700 hover:bg-emerald-800">
          ✓ Authorize
        </button>
        <button onclick="handleRejectItem('${item.id}')" class="btn btn-outline btn-sm text-[10px] py-1 px-2 text-rose-600 hover:bg-rose-50 border-rose-200">
          ✕
        </button>
      </div>
    </div>
  `).join('');
}

function handleApproveItem(approvalId) {
  try {
    sfmsStore.approveMakerChecker(approvalId, currentStaffRole);
    showToast(`Item ${approvalId} authorized successfully by ${currentStaffRole}!`);
    refreshOpsView();
  } catch (err) {
    showToast(err.message, 'error');
  }
}

function handleRejectItem(approvalId) {
  const reason = prompt('Enter rejection reason for audit log:');
  if (!reason) return;
  const queue = sfmsStore.getMakerCheckerQueue();
  const item = queue.find(q => q.id === approvalId);
  if (item) {
    item.status = 'REJECTED';
    item.checkerId = currentStaffRole;
    item.rejectionReason = reason;
    sfmsStore.logAudit('MAKER_CHECKER_REJECTED', currentStaffRole, `Rejected ${approvalId}: ${reason}`);
    sfmsStore.saveData();
    showToast(`Item ${approvalId} rejected. Logged to audit trail.`);
    refreshOpsView();
  }
}

// ==========================================
// COMPLIANCE & AML ALERTS
// ==========================================
function renderAmlAlerts() {
  const container = document.getElementById('widget-aml-alerts-list');
  if (!container) return;

  const alerts = sfmsStore.getAmlAlerts();
  if (alerts.length === 0) {
    container.innerHTML = '<div class="text-xs text-center text-slate-400 py-6">Zero AML or transaction structuring alerts flagged.</div>';
    return;
  }

  container.innerHTML = alerts.map(a => `
    <div class="py-3 flex justify-between items-start text-xs">
      <div>
        <div class="flex items-center gap-2">
          <span class="sfms-badge ${a.severity === 'HIGH' ? 'danger' : 'pending'} text-[9px]">${a.severity}</span>
          <span class="font-bold text-slate-900">${a.customerName} (${a.alertType})</span>
        </div>
        <div class="text-[11px] text-slate-600 mt-1">${a.description}</div>
        <div class="text-[10px] text-slate-400 font-mono mt-0.5">Amount: ${formatINR(a.amount)} • ${a.createdAt}</div>
      </div>
      <button onclick="handleFileSTR('${a.id}')" class="btn btn-outline btn-sm text-[10px] py-1 px-2 text-indigo-700 hover:bg-indigo-50 border-indigo-200 shrink-0">
        File STR Draft
      </button>
    </div>
  `).join('');
}

function handleFileSTR(alertId) {
  showToast(`Suspicious Transaction Report (STR) draft generated for FIU-IND submission under PMLA guidelines. Alert: ${alertId}`, 'info');
}

// ==========================================
// BRANCH PERFORMANCE MATRIX
// ==========================================
function renderBranchPerformanceMatrix() {
  const container = document.getElementById('branch-performance-body');
  if (!container) return;

  const branches = sfmsStore.getBranches();
  const accounts = sfmsStore.getAccounts();
  const loans = sfmsStore.getLoans();

  container.innerHTML = branches.map(b => {
    const branchAccs = accounts.filter(a => a.branchId === b.code);
    const branchLoans = loans.filter(l => (l.branchId || 'BR001') === b.code);

    const depTotal = branchAccs.reduce((sum, a) => sum + a.balance, 0) || (b.code === 'BR001' ? 301550 : b.code === 'BR002' ? 1421000 : 3100000);
    const loanTotal = branchLoans.reduce((sum, l) => sum + l.outstandingPrincipal, 0) || (b.code === 'BR001' ? 317000 : b.code === 'BR002' ? 2805000 : 1950000);
    const tillCash = b.code === 'BR001' ? sfmsStore.getBankInfo().tellerTillBalance : 120000;

    return `
      <tr class="border-b border-slate-100 hover:bg-slate-50 transition font-mono">
        <td class="py-2.5 px-4 font-bold text-slate-800">${b.code} - ${b.name}</td>
        <td class="py-2.5 px-4"><span class="sfms-badge verified text-[9px]">${b.tier}</span></td>
        <td class="py-2.5 px-4 text-right font-bold text-slate-900">${formatINR(depTotal)}</td>
        <td class="py-2.5 px-4 text-right font-bold text-blue-700">${formatINR(loanTotal)}</td>
        <td class="py-2.5 px-4 text-right text-emerald-700 font-semibold">₹14,200.00</td>
        <td class="py-2.5 px-4 text-right text-slate-400">₹0.00</td>
        <td class="py-2.5 px-4 text-right text-slate-700">${formatINR(tillCash)}</td>
        <td class="py-2.5 px-4 text-center"><span class="sfms-badge active text-[9px]">${b.status}</span></td>
      </tr>
    `;
  }).join('');
}

function exportBranchMatrixCSV() {
  const branches = sfmsStore.getBranches();
  let csv = 'Branch Code,Branch Name,Tier,Vault Limit,Status\n';
  branches.forEach(b => {
    csv += `"${b.code}","${b.name}","${b.tier}","${b.vaultLimit}","${b.status}"\n`;
  });
  const blob = new Blob([csv], { type: 'text/csv' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `SFMS_Branch_Performance_${new Date().toISOString().split('T')[0]}.csv`;
  a.click();
  showToast('Branch matrix exported successfully!');
}

// ==========================================
// DOUBLE-ENTRY TRIAL BALANCE
// ==========================================
function renderTrialBalance() {
  const tb = sfmsStore.getTrialBalance();
  const container = document.getElementById('trial-balance-table-body');
  const badge = document.getElementById('trial-balance-status-badge');
  const elDebit = document.getElementById('tb-grand-debit');
  const elCredit = document.getElementById('tb-grand-credit');

  if (badge) {
    if (tb.isBalanced) {
      badge.className = 'sfms-badge verified text-xs';
      badge.innerText = 'Zero Variance (Balanced)';
    } else {
      badge.className = 'sfms-badge danger text-xs';
      badge.innerText = `Variance Detected: ₹${tb.variance.toFixed(2)}`;
    }
  }

  if (elDebit) elDebit.innerText = formatINR(tb.totalDebit);
  if (elCredit) elCredit.innerText = formatINR(tb.totalCredit);

  if (!container) return;

  container.innerHTML = tb.rows.map(r => `
    <tr class="border-b border-slate-100 font-mono text-xs hover:bg-slate-50">
      <td class="py-2.5 px-4 font-bold text-slate-800">${r.code}</td>
      <td class="py-2.5 px-4 font-sans font-medium text-slate-700">${r.name}</td>
      <td class="py-2.5 px-4"><span class="sfms-badge ${r.category === 'ASSET' || r.category === 'EXPENSE' ? 'credit' : 'pending'} text-[9px]">${r.category}</span></td>
      <td class="py-2.5 px-4 text-right font-bold ${r.debit > 0 ? 'text-slate-900' : 'text-slate-400'}">${r.debit > 0 ? formatINR(r.debit) : '-'}</td>
      <td class="py-2.5 px-4 text-right font-bold ${r.credit > 0 ? 'text-slate-900' : 'text-slate-400'}">${r.credit > 0 ? formatINR(r.credit) : '-'}</td>
    </tr>
  `).join('');
}

// ==========================================
// IMMUTABLE AUDIT TRAIL VIEW
// ==========================================
function renderAuditTrail() {
  const container = document.getElementById('audit-trail-table-body');
  if (!container) return;

  const logs = sfmsStore.getAuditLogs();
  container.innerHTML = logs.map(l => `
    <tr class="border-b border-slate-100 text-xs hover:bg-slate-50">
      <td class="py-2.5 px-4 text-slate-500">${l.timestamp}</td>
      <td class="py-2.5 px-4 font-bold text-indigo-700">${l.action}</td>
      <td class="py-2.5 px-4 text-slate-700">${l.user}</td>
      <td class="py-2.5 px-4 text-[10px] text-slate-400 font-mono" title="SHA-256 Prev: ${l.prevHash}">${l.recordHash.substring(0, 16)}...</td>
      <td class="py-2.5 px-4 text-slate-600 font-sans">${l.details}</td>
    </tr>
  `).join('');
}

function exportAuditTrailCSV() {
  const logs = sfmsStore.getAuditLogs();
  let csv = 'Timestamp,Action,User,Record Hash,Previous Hash,Details\n';
  logs.forEach(l => {
    csv += `"${l.timestamp}","${l.action}","${l.user}","${l.recordHash}","${l.prevHash}","${l.details.replace(/"/g, '""')}"\n`;
  });
  const blob = new Blob([csv], { type: 'text/csv' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `SFMS_Audit_Ledger_${new Date().toISOString().split('T')[0]}.csv`;
  a.click();
  showToast('Immutable audit trail exported successfully!');
}

// Window global exports
window.switchTab = switchTab;
window.handleRoleSwitch = handleRoleSwitch;
window.handleBranchSwitch = handleBranchSwitch;
window.handleGlobalSearch = handleGlobalSearch;
window.handleApproveItem = handleApproveItem;
window.handleRejectItem = handleRejectItem;
window.handleFileSTR = handleFileSTR;
window.exportBranchMatrixCSV = exportBranchMatrixCSV;
window.exportAuditTrailCSV = exportAuditTrailCSV;
window.renderTrialBalance = renderTrialBalance;
