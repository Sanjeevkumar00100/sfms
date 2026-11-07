# SFMS - Small Finance Management System

SFMS is a full-featured banking and microfinance management solution comprising:
1. **Banking Operations Application (Staff & Core Banker Console)**
2. **Customer Banking Application (Digital NetBanking & Mobile App)**

The system is delivered in two complementary implementations:
- **Interactive Web Suite (`sfms/web/`)**: Zero-install, instant browser preview with live side-by-side Dual-View Studio.
- **Cross-Platform Flutter App (`sfms/flutter/`)**: Production Android APK/AAB and Windows builds with Supabase integration and offline demo support.

---

## 🌐 1. Web Application Suite (Instant Run)

Open in any web browser without any installation:
- **Dual-View Studio (Both Apps Side-by-Side)**: Open `sfms/web/index.html`
- **Banking Operations Portal**: Open `sfms/web/ops/index.html`
- **Customer Banking Portal**: Open `sfms/web/customer/index.html`

To run locally with Node:
```bash
cd sfms/web
node server.js
```
Visit `http://localhost:3000` to interact with both apps in real-time.

---

## 📱 2. Flutter Mobile & Desktop Apps (`sfms/flutter/`)

The Flutter codebase provides both applications within a unified app with role-based routing:

- **Direct Launchers on Login Screen**:
  - `[Banking Ops]`: Opens `OpsDashboardScreen` (Manager, Teller, KYC, Loans).
  - `[Customer App]`: Opens `CustomerPortalScreen` (Passbook, Transfers, Deposits, Loans, Card).
- **Supabase Authentication**:
  - Login with Supabase credentials to automatically route users according to their configured database role (`ADMIN`, `MANAGER`, `TELLER`, `CUSTOMER`).

### Cloud build with GitHub Actions (no local Flutter needed)

`.github/workflows/build.yml` builds on GitHub's servers: an Android **APK**, an Android **AAB**, and a **Windows** app zip.

1. Push changes to GitHub:
   ```bash
   git add .
   git commit -m "SFMS complete Banking Operations and Customer apps"
   git push origin main
   ```
2. Actions tab → "Build SFMS" → Run workflow.
3. Download `sfms-apk`, `sfms-aab`, and `sfms-windows` artifacts.
