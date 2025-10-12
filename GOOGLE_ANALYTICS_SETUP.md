# Google Analytics Setup Guide

Your app now includes **Google Analytics 4** tracking! 📊

## ✅ What's Been Implemented

### Tracking Features:
- ✅ **Page Views** - Automatic tracking
- ✅ **User Signups** - Tracked when users create accounts
- ✅ **User Logins** - Tracked when users sign in
- ✅ **File Uploads** - Tracked with file size and type
- ✅ **Premium Upgrades** - Tracked when users click upgrade button
- ✅ **Checkout Events** - Tracked when checkout is initiated
- ✅ **Purchase Events** - Tracked on successful payment
- ✅ **Errors** - Upload errors, checkout errors, auth errors

---

## 🔧 Environment Variable Setup

### For Render Deployment:

Add this environment variable in your Render dashboard:

| Variable | Value |
|----------|-------|
| `GA_TRACKING_ID` | `G-0BQH3K548R` |

**How to add:**
1. Go to your Render service
2. Click **Environment** tab
3. Click **Add Environment Variable**
4. Key: `GA_TRACKING_ID`
5. Value: `G-0BQH3K548R`
6. Click **Save Changes**

Render will automatically redeploy with the new variable.

### For Local Development:

Create `client/.env` file:
```env
GA_TRACKING_ID=G-0BQH3K548R
```

---

## 📊 Events Being Tracked

### User Authentication Events:

| Event Name | When It's Triggered | Data Collected |
|------------|-------------------|----------------|
| `sign_up` | User creates account | method: 'email' |
| `login` | User signs in | method: 'email' |
| `sign_up_error` | Signup fails | error message |
| `login_error` | Login fails | error message |

### File Upload Events:

| Event Name | When It's Triggered | Data Collected |
|------------|-------------------|----------------|
| `file_upload` | File uploaded successfully | file_size, file_type |
| `file_upload_error` | Upload fails | error message |

### Payment Events:

| Event Name | When It's Triggered | Data Collected |
|------------|-------------------|----------------|
| `upgrade_button_clicked` | User clicks upgrade button | - |
| `checkout_initiated` | Checkout session created | session_id |
| `checkout_error` | Checkout fails | error message |
| `purchase` | Payment successful | currency, transaction_id |

---

## 🎯 How It Works

### Dynamic Script Loading:

Instead of hardcoding the Google Tag in HTML, the app:
1. Reads `GA_TRACKING_ID` from environment variables
2. Dynamically loads the gtag.js script
3. Initializes Google Analytics
4. Tracks events throughout the user journey

### Code Location:

- **Main Analytics File**: `client/src/analytics.js`
- **Tracking in Components**:
  - `App.jsx` - File uploads, premium upgrades
  - `Auth.jsx` - Signups, logins
  - `PaymentSuccess.jsx` - Purchase completions

---

## 📈 View Your Analytics

### Google Analytics Dashboard:

1. Go to [Google Analytics](https://analytics.google.com/)
2. Select your property with ID: `G-0BQH3K548R`
3. Navigate to:
   - **Reports** → **Realtime** - See live users
   - **Reports** → **Engagement** → **Events** - See all tracked events
   - **Reports** → **Monetization** → **Ecommerce purchases** - See payments

### Real-Time Testing:

1. Deploy your app to Render
2. Visit your app and perform actions
3. Go to Google Analytics → **Realtime**
4. You should see your activity in real-time!

---

## 🧪 Testing Events

### Test Each Event:

1. **Page View** - Just visit the app
2. **Sign Up** - Create a new account
3. **Login** - Sign in with existing account
4. **File Upload** - Upload a file
5. **Upgrade Click** - Click "Upgrade to Premium"
6. **Checkout** - Complete the checkout flow
7. **Purchase** - Complete a payment (use test mode)

### View Events in Google Analytics:

1. Go to **Realtime** → **Event count by Event name**
2. Perform an action in your app
3. See the event appear within ~30 seconds

---

## 🔍 Advanced Tracking (Optional)

### Track Custom Events:

In any component, import and use:

```javascript
import { trackEvent } from './analytics'

// Track a custom event
trackEvent('button_clicked', {
  button_name: 'download_file',
  file_type: 'pdf'
})
```

### Track Page Views:

```javascript
import { trackPageView } from './analytics'

trackPageView('/premium-features')
```

### User Properties:

Track user characteristics:

```javascript
if (window.gtag) {
  window.gtag('set', 'user_properties', {
    premium_user: true,
    signup_date: '2025-10-12'
  })
}
```

---

## 🎨 Customization

### Change Tracking ID:

Update in Render environment variables:
```
GA_TRACKING_ID = G-YOUR-NEW-ID
```

### Disable Analytics for Development:

In `client/.env.local`:
```env
GA_TRACKING_ID=
```

Leave it empty, and analytics won't load.

### Add More Events:

Edit components and add:

```javascript
trackEvent('your_event_name', {
  param1: 'value1',
  param2: 'value2'
})
```

---

## 🔒 Privacy & GDPR Compliance

### Current Implementation:

- ✅ No PII (Personally Identifiable Information) is sent
- ✅ Only anonymous user IDs from Google Analytics
- ✅ Event data is aggregated and anonymized

### For GDPR Compliance (Optional):

Add a cookie consent banner and:

```javascript
// Only initialize if user consents
if (userHasConsented) {
  window.gtag('consent', 'update', {
    'analytics_storage': 'granted'
  })
}
```

---

## 📊 Key Metrics to Monitor

### User Engagement:
- Daily active users
- Session duration
- Pages per session

### Conversion Funnel:
1. Sign up
2. File upload
3. Upgrade button click
4. Checkout initiated
5. Purchase completed

### File Upload Analytics:
- Total uploads
- Most common file types
- Average file sizes
- Upload success rate

### Revenue Tracking:
- Premium conversions
- Revenue from purchases
- Conversion rate

---

## 🆘 Troubleshooting

### Events Not Showing Up:

**Check:**
1. ✅ `GA_TRACKING_ID` is set in Render
2. ✅ App was redeployed after adding variable
3. ✅ Browser console shows: "✅ Google Analytics initialized"
4. ✅ No ad blockers interfering
5. ✅ Wait 24-48 hours for data to appear in reports (Realtime is instant)

### "Google Analytics not initialized":

**Cause:** Environment variable not set

**Fix:** Add `GA_TRACKING_ID=G-0BQH3K548R` to Render and redeploy

### Seeing Test Traffic:

**Solution:** Set up a **Filter** in Google Analytics to exclude your own IP

---

## 📚 Resources

- [Google Analytics Documentation](https://developers.google.com/analytics)
- [GA4 Events Reference](https://developers.google.com/analytics/devguides/collection/ga4/events)
- [GA4 Ecommerce Guide](https://developers.google.com/analytics/devguides/collection/ga4/ecommerce)

---

## ✅ Setup Summary

To enable Google Analytics:

1. **Add environment variable in Render:**
   - Key: `GA_TRACKING_ID`
   - Value: `G-0BQH3K548R`

2. **Redeploy your app** (automatic after saving env var)

3. **Analytics will load automatically:**
   - ✅ `analytics.js` - Loads dynamically
   - ✅ All components - Track relevant events
   - ✅ Build passes variable to frontend

That's it! Your analytics will work automatically. 📊🎉

