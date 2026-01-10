# Android Build Setup

## Prerequisites
- Flutter SDK installed
- Android SDK and tools configured

## Keystore Setup

1. **Copy the template file:**
   ```bash
   cp android/key.properties.template android/key.properties
   ```

2. **Fill in your keystore credentials:**
   - `storePassword`: Your keystore password
   - `keyPassword`: Your key password
   - `keyAlias`: Your key alias
   - `storeFile`: Path to your keystore file

3. **Place your keystore file:**
   - Put your `.jks` keystore file in the root directory
   - Update the `storeFile` path in `key.properties` accordingly

## Building

### Debug Build
```bash
flutter build apk --debug
```

### Release Build
```bash
flutter build appbundle --release
```

## Security Note
- Never commit `key.properties` or `.jks` files to version control
- Keep your keystore credentials secure and backed up separately
- The actual `key.properties` file is ignored by git for security
