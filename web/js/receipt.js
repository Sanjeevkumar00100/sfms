/**
 * SFMS Receipt Generator & Thermal Slip Renderer
 */

function generateReceiptHTML(txn, bankInfo, additionalInfo = {}) {
  const isCredit = txn.type === 'CREDIT';
  const typeLabel = txn.category.replace(/_/g, ' ');

  let denominationHTML = '';
  if (txn.denominations && Object.keys(txn.denominations).length > 0) {
    denominationHTML = `
      <div class="receipt-divider"></div>
      <div style="font-size:11px; font-weight:bold; margin-bottom:4px;">CASH DENOMINATIONS:</div>
      ${Object.entries(txn.denominations)
        .filter(([_, count]) => count > 0)
        .map(([note, count]) => `
          <div class="receipt-row" style="font-size:11px;">
            <span>₹${note} × ${count}</span>
            <span>₹${Number(note) * count}</span>
          </div>
        `).join('')}
    `;
  }

  return `
    <div class="thermal-receipt" id="printable-receipt">
      <div class="receipt-header">
        <div style="font-size: 15px; font-weight: bold; text-transform: uppercase;">${bankInfo.orgName}</div>
        <div style="font-size: 11px; color: #475569;">${bankInfo.branchName} • IFSC: ${bankInfo.ifsc}</div>
        <div style="margin-top: 6px; font-weight: bold; background: #000; color: #fff; padding: 2px 4px; display: inline-block;">
          CUSTOMER ACKNOWLEDGEMENT SLIP
        </div>
      </div>

      <div class="receipt-row">
        <span>TXN NO:</span>
        <span style="font-weight: bold;">${txn.txnNumber}</span>
      </div>
      <div class="receipt-row">
        <span>DATE & TIME:</span>
        <span>${txn.timestamp}</span>
      </div>
      <div class="receipt-row">
        <span>CHANNEL:</span>
        <span>${txn.channel}</span>
      </div>

      <div class="receipt-divider"></div>

      <div class="receipt-row">
        <span>ACCOUNT NO:</span>
        <span style="font-weight: bold;">${txn.accountNumber}</span>
      </div>
      ${additionalInfo.accountName ? `
      <div class="receipt-row">
        <span>A/C HOLDER:</span>
        <span>${additionalInfo.accountName}</span>
      </div>` : ''}
      <div class="receipt-row">
        <span>TXN TYPE:</span>
        <span style="font-weight: bold; color: ${isCredit ? '#15803d' : '#b91c1c'};">${txn.type} (${typeLabel})</span>
      </div>
      <div class="receipt-row">
        <span>REFERENCE:</span>
        <span>${txn.reference || 'N/A'}</span>
      </div>
      <div class="receipt-row">
        <span>NARRATION:</span>
        <span style="max-width: 170px; text-align: right; word-break: break-word;">${txn.narration || '-'}</span>
      </div>

      ${denominationHTML}

      <div class="receipt-total">
        <span>AMOUNT:</span>
        <span>${bankInfo.currencySymbol}${Number(txn.amount).toLocaleString('en-IN', { minimumFractionDigits: 2 })}</span>
      </div>

      <div class="receipt-row" style="font-size:12px;">
        <span>AVAIL BALANCE:</span>
        <span style="font-weight:bold;">${bankInfo.currencySymbol}${Number(txn.balanceAfter).toLocaleString('en-IN', { minimumFractionDigits: 2 })}</span>
      </div>

      <div class="receipt-divider"></div>

      <div style="margin-top: 14px; display: flex; justify-content: space-between; font-size: 10px;">
        <div style="text-align: center; width: 120px;">
          <div style="border-bottom: 1px solid #000; height: 26px;"></div>
          <div style="margin-top: 4px;">CUSTOMER SIGN</div>
        </div>
        <div style="text-align: center; width: 120px;">
          <div style="border-bottom: 1px solid #000; height: 26px; line-height: 28px; font-weight: bold;">
            ${txn.initiatedBy || 'AUTHORIZED'}
          </div>
          <div style="margin-top: 4px;">OFFICER SEAL / SIGN</div>
        </div>
      </div>

      <div class="receipt-footer">
        <p>*** Thank You for Banking with SFMS ***</p>
        <p>Toll Free Helpline: 1800-200-SFMS (7367)</p>
        <p style="margin-top: 4px; font-size: 9px; color: #64748b;">Computer generated voucher. No physical signature required for electronic transfers.</p>
      </div>
    </div>
  `;
}

function showReceiptModal(txn, bankInfo, additionalInfo = {}) {
  const modalHTML = `
    <div class="sfms-modal-backdrop" id="receipt-modal-backdrop">
      <div class="sfms-modal-content" style="max-width: 400px; padding: 20px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
          <h3 style="font-size: 1.1rem; font-weight: 700;">Transaction Receipt</h3>
          <button class="btn btn-outline btn-sm" onclick="closeReceiptModal()">✕</button>
        </div>
        
        ${generateReceiptHTML(txn, bankInfo, additionalInfo)}

        <div style="display: flex; gap: 10px; margin-top: 20px;">
          <button class="btn btn-primary" style="flex: 1;" onclick="window.print()">
            🖨️ Print Receipt
          </button>
          <button class="btn btn-secondary" onclick="closeReceiptModal()">
            Done
          </button>
        </div>
      </div>
    </div>
  `;

  // Remove existing
  closeReceiptModal();
  document.body.insertAdjacentHTML('beforeend', modalHTML);
}

function closeReceiptModal() {
  const existing = document.getElementById('receipt-modal-backdrop');
  if (existing) existing.remove();
}

window.showReceiptModal = showReceiptModal;
window.closeReceiptModal = closeReceiptModal;
window.generateReceiptHTML = generateReceiptHTML;
