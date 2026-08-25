# RevenueCat Plugin Integration Playbook (Godot Mobile Games)

For hackathon/game-jam mobile games that must monetize via RevenueCat. Based on research of
the **Godotx RevenueCat** plugin (MIT, community-maintained) — verified August 2026.

## Versions (pin these)

| Component | Version | Note |
|---|---|---|
| Godot | 4.7-stable | plugin is built against this |
| Godotx RevenueCat plugin | v2.2.x | github.com/FunkyMuse/godot-revenuecat (also on official Asset Library, id 4493) |
| Bundled RC iOS SDK | 5.79.0 | min iOS 15.0 |
| Bundled RC Android SDK | 10.10.0 | min Android SDK 24 |

## Why this plugin

It wraps the **official** native RevenueCat SDKs and ships them as `.xcframework` (iOS) +
`.aar` (Android), managed through Godot's export-plugin pipeline — no C++/Java/Obj-C work
for us. It's thin glue: if it breaks, fork and patch it rather than replacing it.

⚠️ **No first-party RevenueCat SDK exists for Godot.** This community plugin is the
pragmatic path; budget a spike to validate it BEFORE building game systems on top.

## Install

1. AssetLib in-editor → "Godotx RevenueCat" → Install & Enable
   (or download release ZIP → copy `addons/`, `ios/plugins/`, `android/plugins/` into project root)
2. Commit all three folders
3. Run `godot --headless --path . --import` to regenerate cache

## Configure Export Presets

Both platforms need their plugin enabled — per preset:

- **Android preset**: enable the RevenueCat plugin AND `Gradle Build` (native plugins require gradle)
- **iOS preset**: enable the RevenueCat plugin

Verify with an actual headless export after setup (see `exporting.md`).

## Store Setup Order (do it in this sequence)

1. Create app in Google Play Console + App Store Connect
2. Create IAP products there (e.g., `premium_unlock`, `hints_10`)
3. Create matching products + entitlement (`premium`) + offering (`default`) in the
   RevenueCat dashboard; note each platform's **public** API key
4. Sandbox-test purchases with internal testers before writing more game code

## Runtime Integration Skeleton

Read the addon's bundled README/API reference for exact method names — verify against the
installed version, don't guess (see SKILL.md failure modes). The flow is always:

```gdscript
# autoload IapManager — adapt names to the installed plugin API
extends Node

const IOS_API_KEY := "appl_xxx"
const ANDROID_API_KEY := "goog_xxx"

signal entitlements_changed(is_premium: bool)

func _ready() -> void:
	var key := IOS_API_KEY if OS.get_name() == "iOS" else ANDROID_API_KEY
	_configure(key)                 # plugin configure/init call
	check_entitlements()

func _configure(key: String) -> void:
	pass                            # TODO: plugin init — see addons/godotx_revenue_cat README

func buy(product_id: String) -> void:
	pass                            # TODO: purchase call → await result → check_entitlements()

func restore() -> void:
	pass                            # TODO: restore purchases (App Store requires a restore button!)

func check_entitlements() -> void:
	pass                            # TODO: fetch customer info → emit entitlements_changed

func show_paywall() -> void:
	pass                            # TODO: present_paywall (plugin ships native paywall UI)
```

Wire `entitlements_changed` into game systems (unlock levels, remove ads, etc.).

## Hackathon-Specific Requirements

- Judges must get **a free trial OR a promo unlock** for premium features:
  - Simplest: make the paywall offer a trial; or add a hidden "promo code" input redeeming
    entitlement locally / via your own backend
- Demo video must show the real purchase flow on device (sandbox OK)
- Grand Prize judging uses RevenueCat-reported revenue → integrate early so revenue accrues
- Consider RevenueCat Ads tracking (AdMob ILRD → AdTracker) as an extra category entry

## Failure Playbook

| Problem | Action |
|---|---|
| Plugin init fails on export | Check plugin enabled in BOTH presets; Android needs Gradle Build ON |
| Products not loading | Store products not yet approved/available to tester account; check dashboard mirroring |
| Purchase succeeds, entitlement stale | Call customer-info refresh after purchase; don't cache entitlements across sessions without refresh |
| iOS build missing plugin symbols | Re-export; confirm `.xcframework` copied by export plugin |
| Plugin abandoned/broken | Fork repo, patch (thin native glue), or pin last-good release tag |

## Sources

- Plugin: github.com/FunkyMuse/godot-revenuecat · godot-x/revenuecat · Asset Library #4493
- Official SDKs: github.com/RevenueCat/purchases-ios · purchases-android · docs.revenuecat.com
- Engine ranking context: ship-a-ton-2026/docs/engine-research.md
