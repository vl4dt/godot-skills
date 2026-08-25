# CLI Export Pipeline (Android / iOS / Desktop)

Export from CI or an agent shell with zero editor interaction, once presets exist.

## One-Time Setup Per Machine

1. Export templates matching the engine version must be installed — per host:
   - Windows: `%APPDATA%\Godot\export_templates\<version>\`
   - Linux: `~/.local/share/godot/export_templates/<version>/`
   - macOS: `~/Library/Application Support/Godot/export_templates/<version>/`
   Install via any editor's Manage Export Templates UI once, or copy manually.
2. Android toolchain (per build host): JDK 17, Android SDK with build-tools/platform-tools,
   debug keystore. Typical `ANDROID_HOME`: `%LOCALAPPDATA%\Android\Sdk` (Windows),
   `~/Android/Sdk` (Linux).
3. iOS builds always finish on macOS/Xcode — see iOS section. Generating the Xcode project
   folder itself works fine from Windows or Linux.

## Presets (`export_presets.cfg`)

Create presets once (editor UI is fine) or write entries by hand. Minimal skeletons:

```ini
[preset.0]
name="Windows Desktop"
platform="Windows Desktop"
export_path="builds/win/game.exe"

[preset.1]
name="Android"
platform="Android"
export_path="builds/android/game.aab"
gradle_build/use_gradle_build=true        # REQUIRED for native plugins (RevenueCat etc.)
package/unique_name="com.yourstudio.game"

[preset.2]
name="iOS"
platform="iOS"
export_path="builds/ios/game.xcodeproj"
```

After hand-editing presets, validate with a real export — typos fail at export time.

## Commands

```bash
# Debug build (faster, includes debugger; use for device testing during dev)
godot --headless --path . --export-debug "Android" builds/android/debug.apk

# Release build (store submission)
godot --headless --path . --export-release "Windows Desktop" builds/win/game.exe
godot --headless --path . --export-release "Android" builds/android/game.aab    # AAB = Play Store
godot --headless --path . --export-release "Android" builds/android/game.apk    # APK = sideload/Galaxy Store
godot --headless --path . --export-release "iOS" builds/ios/                     # Xcode project folder
```

Exit code 0 + file exists = success. On failure read the FULL log — export errors cascade
(missing template → missing SDK → signing failure).

## Android Signing

Debug keystore is automatic. For release:

```bash
keytool -genkeypair -v -keystore release.keystore -alias game -keyalg RSA -validity 10000

export GODOT_ANDROID_KEYSTORE_PATH=/abs/path/release.keystore
export GODOT_ANDROID_KEYSTORE_USER=game
export GODOT_ANDROID_KEYSTORE_PASSWORD=secret
godot --headless --path . --export-release "Android" builds/android/game.aab
```

Guard the keystore like a password — losing it means losing app-signing continuity on Play.
Keep one shared release keystore in sync between your Windows and Linux machines (password
manager / secure transfer); signing with different keystores breaks update compatibility.

## Gradle Build Notes

Native Android plugins (RevenueCat, ads, Firebase…) require **Gradle Build enabled** in the
preset. First gradle build downloads dependencies (slow); subsequent builds cache. If gradle
fails, check: JDK version (17), `ANDROID_HOME`, and that plugin versions are mutually compatible.

## iOS Pipeline

The export produces an **Xcode project folder** (not an IPA):

```bash
godot --headless --path . --export-release "iOS" builds/ios/
# → builds/ios/ contains .xcodeproj — open on macOS, set team/signing, Product → Archive
```

No Mac? Options: GitHub Actions `macos-*` runner, Codemagic, or borrow a Mac for a single
archive session. Set `bundle identifier`, version, and signing before archiving.

## Store Submission Checklist (Shipaton-relevant)

- [ ] Icon 1024×1024 PNG exported from the icon preset
- [ ] Screenshot 1179×2556 px **frameless** (Devpost requirement) — capture from emulator/device, not editor viewport
- [ ] `version/code` bumped every Play upload; iOS `CFBundleVersion` too
- [ ] Privacy policy URL + data-safety forms (purchases ⇒ declare IAP)
- [ ] IAP products created in store consoles BEFORE RevenueCat mirrors them
- [ ] Internal testing track first: verify purchase + restore flow on real device
- [ ] Submit days before deadline — review queues stretch unpredictably

## Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `No export template found` | Version mismatch | Install templates matching exact engine version |
| Gradle: `SDK location not found` | Env | Set `ANDROID_HOME`, accept licenses |
| Plugin listed but "not enabled" | Preset toggle | Enable plugin checkbox per preset (both platforms!) |
| AAB rejected: versionCode lower | Increment | Bump `version/code` in preset |
| iOS archive fails: signing | Team/capabilities | Set development team in exported Xcode project |
