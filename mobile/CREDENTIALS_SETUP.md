# Android Local Credentials Setup

EAS is configured to use **local credentials** for Android builds. This avoids the "Entity not authorized: AndroidKeystoreEntity" permission error when your Expo account cannot create keystores on EAS servers.

## One-time setup

### 1. Generate an Android keystore

From the `mobile` directory, run (requires Java/javac):

```powershell
keytool -genkey -v -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 ^
  -alias my-key-alias ^
  -keystore keystores/release.keystore ^
  -dname "CN=Stay Admin, OU=, O=, L=, S=, C=US"
```

You'll be prompted for a keystore password and key password — remember these.

### 2. Create credentials.json

Copy the example and fill in your values:

```powershell
copy credentials.json.example credentials.json
```

Edit `credentials.json` and set:

- `keystorePath`: `./keystores/release.keystore` (or your keystore path)
- `keystorePassword`: keystore password
- `keyAlias`: `my-key-alias` (or the alias you used)
- `keyPassword`: key password

**Important:** `credentials.json` is gitignored. Never commit it.

### 3. Build

```powershell
cd mobile
eas build --platform android --profile production
```
