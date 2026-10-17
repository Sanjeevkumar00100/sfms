
## Cloud build with GitHub Actions (no local Flutter needed)

`.github/workflows/build.yml` builds on GitHub's servers: an Android
**APK**, an Android **AAB**, and a **Windows** app zip. It runs
`flutter create` itself, so the `android/` and `windows/` folders do
not need to be committed.

1. Create a **private** repo on github.com, then from the project root:
   `git init && git add . && git commit -m "SFMS" && git branch -M main`
   `git remote add origin https://github.com/YOUR_USER/sfms.git`
   `git push -u origin main`
2. Repo → Settings → Secrets and variables → Actions → add:
   `SUPABASE_URL`, `SUPABASE_ANON_KEY` (anon key only, never service-role).
3. Edit `APP_ORG` at the top of the workflow to your own id
   (e.g. `com.yourname`). The package id can't change after publishing.
4. Actions tab → "Build SFMS" → Run workflow. When it finishes, download
   `sfms-apk`, `sfms-aab-...` and `sfms-windows` from the run page.

For a Play-Store-ready AAB, also add secrets `KEYSTORE_BASE64`,
`KEYSTORE_PASSWORD`, `KEY_PASSWORD` (key alias must be `upload`). Without
them the AAB is produced but labelled UNSIGNED and Play will reject it.
