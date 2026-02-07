# RevenueCat Setup Guide

This guide explains how to configure RevenueCat for in-app purchases in the Tiny Steps app.

## Overview

The app uses RevenueCat to manage subscriptions. Two subscription tiers are offered:
- **Monthly**: `tiny_steps_premium_monthly`
- **Yearly**: `tiny_steps_premium_yearly`

## Step 1: Create RevenueCat Account

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Create an account or sign in
3. Create a new project named "Tiny Steps"

## Step 2: Configure Products

### Product IDs to Configure

| Product ID | Type | Description |
|------------|------|-------------|
| `tiny_steps_premium_monthly` | Auto-Renewable Subscription | Monthly premium access |
| `tiny_steps_premium_yearly` | Auto-Renewable Subscription | Yearly premium access |

### Create Entitlement

1. In RevenueCat, go to **Entitlements**
2. Create an entitlement called `premium`
3. Attach both products to this entitlement

### Create Offering

1. Go to **Offerings**
2. Create a default offering
3. Add both products to the offering:
   - Set monthly as `PackageType.monthly`
   - Set yearly as `PackageType.annual`

## Step 3: iOS Setup

### App Store Connect

1. Create your app in [App Store Connect](https://appstoreconnect.apple.com)
2. Go to **Features > Subscriptions**
3. Create a subscription group (e.g., "Tiny Steps Premium")
4. Add both products:
   - Monthly subscription with ID `tiny_steps_premium_monthly`
   - Yearly subscription with ID `tiny_steps_premium_yearly`
5. Configure pricing for each product
6. Fill in subscription details (description, display name)

### RevenueCat iOS Configuration

1. In RevenueCat Dashboard, go to **Apps**
2. Add an iOS app
3. Enter your **App Bundle ID** (e.g., `com.yourcompany.tinysteps`)
4. Add your **App-Specific Shared Secret**:
   - In App Store Connect, go to your app
   - Navigate to **App Information > App-Specific Shared Secret**
   - Generate and copy the secret
   - Paste in RevenueCat

5. Copy the **Public SDK Key** (starts with `appl_`)

### Update Code

Replace the placeholder in `lib/data/services/purchase_service.dart`:

```dart
static const String _iosApiKey = 'appl_YOUR_IOS_KEY_HERE';
```

## Step 4: Android Setup

### Google Play Console

1. Create your app in [Google Play Console](https://play.google.com/console)
2. Go to **Monetize > Products > Subscriptions**
3. Create both products:
   - `tiny_steps_premium_monthly` - Monthly subscription
   - `tiny_steps_premium_yearly` - Yearly subscription
4. Configure pricing, billing period, and grace period

### RevenueCat Android Configuration

1. In RevenueCat Dashboard, go to **Apps**
2. Add an Android app
3. Enter your **Package Name** (e.g., `com.yourcompany.tinysteps`)
4. Add your **Service Account JSON**:
   - In Google Play Console, go to **Setup > API Access**
   - Create or link a service account
   - Grant "View financial data" and "Manage orders" permissions
   - Download the JSON key file
   - Upload to RevenueCat

5. Copy the **Public SDK Key** (starts with `goog_`)

### Update Code

Replace the placeholder in `lib/data/services/purchase_service.dart`:

```dart
static const String _androidApiKey = 'goog_YOUR_ANDROID_KEY_HERE';
```

## Step 5: Testing

### Test Users

#### iOS (Sandbox)
1. In App Store Connect, go to **Users and Access > Sandbox**
2. Create sandbox test accounts
3. On device: Settings > App Store > sign out, then use sandbox account in-app

#### Android
1. In Google Play Console, go to **Setup > License testing**
2. Add tester email addresses
3. Upload an APK/AAB to internal testing track
4. Testers must opt-in via the test link

### RevenueCat Debug Mode

The app enables debug logging in debug builds:
```dart
if (kDebugMode) {
  await Purchases.setLogLevel(LogLevel.debug);
}
```

Check the device logs for RevenueCat output.

### Test Scenarios

1. **First purchase** - Complete monthly/yearly purchase flow
2. **Restore purchases** - Test on fresh install with existing subscription
3. **Cancellation** - Cancel in device settings, verify entitlement expires
4. **Upgrade/Downgrade** - Switch between monthly and yearly

## Step 6: Go Live Checklist

### iOS
- [ ] Submit subscriptions for review in App Store Connect
- [ ] Ensure "Cleared for Sale" is enabled
- [ ] Test purchase flow with sandbox account
- [ ] Replace sandbox API key with production (same key works for both)

### Android
- [ ] Publish app to internal/closed testing
- [ ] Verify products appear correctly
- [ ] Test purchase flow with license tester
- [ ] Ensure Google Play billing library version matches

### RevenueCat
- [ ] Verify webhooks are configured (optional but recommended)
- [ ] Set up revenue tracking / analytics integration
- [ ] Configure email notifications for events

## Troubleshooting

### "No current offering available"
- Verify products are created in RevenueCat
- Check that products are active in App Store Connect / Play Console
- Ensure offerings are set up with packages

### "Product not available"
- iOS: Check subscription is "Cleared for Sale"
- Android: Ensure app is published to a track and products are active
- Wait 24-48 hours for products to propagate

### "User cancelled" errors
- This is normal when user dismisses the purchase dialog
- App handles this gracefully (no error shown)

### Testing Renewals (iOS)
Sandbox subscriptions renew faster:
| Duration | Sandbox Renewal |
|----------|-----------------|
| 1 week   | 3 minutes       |
| 1 month  | 5 minutes       |
| 1 year   | 1 hour          |

## Security Notes

- API keys are public SDK keys - safe to include in client code
- Never expose your RevenueCat secret API key
- Verify entitlements server-side for sensitive features (optional)

## Support

- [RevenueCat Docs](https://docs.revenuecat.com/)
- [RevenueCat Community](https://community.revenuecat.com/)
- [Flutter SDK Reference](https://docs.revenuecat.com/docs/flutter)
