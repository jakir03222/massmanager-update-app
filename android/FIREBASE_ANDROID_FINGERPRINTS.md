# Add certificate fingerprints to Firebase (Android)

Use these **debug** keystore fingerprints in the Firebase Console so Auth (e.g. Google Sign-In) works on Android.

## Your debug keystore fingerprints

| Type   | Fingerprint |
|--------|-------------|
| **SHA-1**   | `D3:5E:AC:A8:A8:C4:CB:C9:0C:09:FE:C7:AF:B2:61:B4:46:22:32:EE` |
| **SHA-256** | `62:35:2C:EF:58:D3:CB:7A:67:AB:27:94:CE:54:1F:32:B7:AD:54:5B:3A:A9:7A:6E:4E:73:F1:C5:BA:6C:CB:14` |

## Steps in Firebase Console

1. Open **[Firebase Console](https://console.firebase.google.com)** and select your project (e.g. **masemanager-44c9b**).
2. Go to **Project settings** (gear icon) → **Your apps**.
3. Under **Android apps**, select your app (`com.example.text_app`) or add it if missing:
   - **Android package name:** `com.example.text_app`
   - Download `google-services.json` and place it in `android/app/`.
4. In the same Android app card, click **Add fingerprint**.
5. Paste **SHA-1**:  
   `D3:5E:AC:A8:A8:C4:CB:C9:0C:09:FE:C7:AF:B2:61:B4:46:22:32:EE`  
   → Save.
6. Click **Add fingerprint** again and paste **SHA-256**:  
   `62:35:2C:EF:58:D3:CB:7A:67:AB:27:94:CE:54:1F:32:B7:AD:54:5B:3A:A9:7A:6E:4E:73:F1:C5:BA:6C:CB:14`  
   → Save.

## Release build (when you publish)

For release builds you must add the fingerprints of your **release** keystore:

```bash
keytool -list -v -keystore /path/to/your/release.keystore -alias your-alias
```

Then add those SHA-1 and SHA-256 values to the same Android app in Firebase.

## Re-get fingerprints (debug)

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Look for the lines starting with `SHA1:` and `SHA256:`.
