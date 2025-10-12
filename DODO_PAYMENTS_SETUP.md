# Dodo Payments Integration Guide

Your app now includes **Dodo Payments** for premium upgrades! 💳

## 🎯 Features

- ✅ **Upgrade to Premium Button** - One-click upgrade
- ✅ **Secure Checkout** - Hosted by Dodo Payments
- ✅ **User Pre-fill** - Email and name auto-filled
- ✅ **Success Page** - Beautiful payment confirmation
- ✅ **Protected** - Only authenticated users can checkout

---

## 🔧 Setup Requirements

### 1. Get Dodo Payments Credentials

1. Go to [Dodo Payments Dashboard](https://test.dodopayments.com/)
2. Sign up / Log in
3. Navigate to **Settings** → **API Keys**
4. Copy your **API Key** (starts with `dodo_test_...` or `dodo_live_...`)

### 2. Create a Product

1. In Dodo Payments Dashboard, go to **Products**
2. Click **"Create Product"**
3. Fill in product details:
   - **Name**: Premium Subscription
   - **Price**: Your pricing
   - **Type**: One-time or Recurring
4. Click **"Save"**
5. Copy the **Product ID** (e.g., `prod_abc123xyz`)

---

## 📋 Environment Variables for Render

Add these **3 new variables** to your existing ones in Render:

| Variable | Value | Example |
|----------|-------|---------|
| `DODO_PAYMENTS_API_KEY` | Your Dodo API key | `dodo_test_abc123...` |
| `DODO_PRODUCT_ID` | Your product ID | `prod_abc123xyz` |
| `APP_URL` | Your Render app URL | `https://your-app.onrender.com` |

### Complete Environment Variables List:

```
SUPABASE_URL = https://kylvaxbcvovxjeutrcds.supabase.co
SUPABASE_SERVICE_KEY = your_service_role_key
SUPABASE_ANON_KEY = your_anon_key
SUPABASE_BUCKET = uploads
DODO_PAYMENTS_API_KEY = dodo_test_abc123...
DODO_PRODUCT_ID = prod_abc123xyz
APP_URL = https://your-app.onrender.com
```

---

## 🎨 How It Works

### User Flow:

1. **User logs in** to your app
2. **Clicks "⭐ Upgrade to Premium"** button in header
3. **Backend creates checkout session** with Dodo Payments API
4. **User redirected to Dodo Payments** checkout page
5. **User completes payment** (card details, etc.)
6. **Redirected back to your app** at `/payment-success`
7. **Success page shown** with confirmation

### Technical Flow:

```
┌─────────────┐   Click Button   ┌──────────────┐
│   Browser   │─────────────────▶│ Frontend     │
│  (React)    │                   │ App.jsx      │
└─────────────┘                   └──────────────┘
                                         │
                                         │ POST /api/create-checkout
                                         ▼
                                  ┌──────────────┐
                                  │ Express API  │
                                  │ server/      │
                                  └──────────────┘
                                         │
                                         │ POST /checkouts
                                         ▼
                                  ┌──────────────┐
                                  │ Dodo         │
                                  │ Payments API │
                                  └──────────────┘
                                         │
                                         │ Returns checkout_url
                                         ▼
┌─────────────┐   Redirect        ┌──────────────┐
│   Browser   │◀──────────────────│ Backend      │
│             │                   │              │
└─────────────┘                   └──────────────┘
       │
       │ User completes payment
       ▼
┌─────────────┐
│ Dodo        │
│ Payments    │
│ Checkout    │
└─────────────┘
       │
       │ Redirect to return_url
       ▼
┌─────────────┐
│ Your App    │
│ /payment-   │
│  success    │
└─────────────┘
```

---

## 🔒 Security Features

✅ **Protected Endpoint** - Only authenticated users can create checkout  
✅ **JWT Verification** - Token checked before creating session  
✅ **Server-Side API Call** - API key never exposed to browser  
✅ **User Metadata** - User ID tracked in payment metadata  
✅ **Error Handling** - Graceful error messages  

---

## 🎯 API Endpoint

### POST `/api/create-checkout`

**Protected:** Requires JWT token

**Request Headers:**
```
Authorization: Bearer <user_jwt_token>
Content-Type: application/json
```

**Response:**
```json
{
  "success": true,
  "checkout_url": "https://test.dodopayments.com/checkout/session_abc123",
  "session_id": "session_abc123"
}
```

**What it does:**
1. Verifies user is authenticated
2. Reads Dodo API key and product ID from environment
3. Creates checkout session with Dodo Payments API
4. Pre-fills customer email and name
5. Sets return URL to `/payment-success`
6. Returns checkout URL to frontend
7. Frontend redirects user to Dodo checkout

---

## 🧪 Testing

### Test Mode (Default)

The app uses Dodo's **test environment**:
- API endpoint: `https://test.dodopayments.com/checkouts`
- Use test API keys (start with `dodo_test_`)
- Use test payment methods provided by Dodo

### Test Payment Flow:

1. **Local Testing:**
   ```bash
   cd ~/file-upload-app
   # Add to .env:
   echo "DODO_PAYMENTS_API_KEY=dodo_test_your_key" >> .env
   echo "DODO_PRODUCT_ID=prod_test_123" >> .env
   echo "APP_URL=http://localhost:3001" >> .env
   
   npm run dev
   ```

2. **Visit app, sign in, click "Upgrade to Premium"**

3. **Use Dodo's test payment methods** (check their docs)

### Production Mode:

1. Get production API key from Dodo (starts with `dodo_live_`)
2. Update environment variable in Render
3. Change API endpoint to: `https://dodopayments.com/checkouts`

---

## 🎨 Customization

### Change Button Text:

Edit `client/src/App.jsx`:
```jsx
<button onClick={handleUpgradeToPremium} className="premium-button">
  💎 Go Premium  // Change this
</button>
```

### Change Button Style:

Edit `client/src/App.css`:
```css
.premium-button {
  background: linear-gradient(135deg, #ffd700 0%, #ffed4e 100%);
  /* Change colors, size, etc. */
}
```

### Add Multiple Products:

Update `server/index.js`:
```javascript
product_cart: [
  {
    product_id: process.env.DODO_PRODUCT_ID_MONTHLY,
    quantity: 1
  },
  {
    product_id: process.env.DODO_PRODUCT_ID_YEARLY,
    quantity: 1
  }
]
```

### Add Billing Address:

Update `server/index.js` in the fetch body:
```javascript
billing_address: {
  street: req.body.street,
  city: req.body.city,
  state: req.body.state,
  country: req.body.country,
  zipcode: req.body.zipcode
}
```

---

## 🔄 Webhooks (Optional)

For production, you should set up **webhooks** to handle:
- Payment confirmation
- Update user's premium status in database
- Send confirmation email

### Webhook Setup:

1. In Dodo Dashboard → **Developers** → **Webhooks**
2. Add webhook URL: `https://your-app.onrender.com/api/webhook/dodo`
3. Select events: `checkout.completed`, `payment.succeeded`
4. Save webhook secret

Add endpoint in `server/index.js`:
```javascript
app.post('/api/webhook/dodo', async (req, res) => {
  // Verify webhook signature
  // Update user premium status in database
  // Send confirmation email
  res.json({ received: true })
})
```

---

## 📊 Payment Tracking

### View Payments in Dodo Dashboard:

1. Go to **Payments** tab
2. See all transactions
3. View customer details
4. Check payment status

### Metadata Included:

Each payment includes:
```json
{
  "user_id": "uuid-of-user",
  "user_email": "user@example.com",
  "timestamp": "2025-10-12T..."
}
```

This helps you track which user made which payment.

---

## 🆘 Troubleshooting

### "Payment system not configured"

**Cause:** Missing environment variables

**Fix:** Add `DODO_PAYMENTS_API_KEY` and `DODO_PRODUCT_ID` to Render

### "Failed to create checkout session"

**Cause:** Invalid API key or product ID

**Fix:** 
1. Verify API key in Dodo dashboard
2. Check product ID is correct
3. Ensure product is active/published

### Button doesn't redirect

**Cause:** API error or network issue

**Fix:**
1. Check browser console for errors
2. Check Render logs for backend errors
3. Verify APP_URL is set correctly

### Return URL not working

**Cause:** Wrong APP_URL or routing issue

**Fix:**
1. Update `APP_URL` environment variable
2. Ensure it matches your actual Render URL
3. Include `https://` prefix

---

## 📚 Resources

- [Dodo Payments Documentation](https://docs.dodopayments.com/)
- [Dodo Payments Dashboard](https://test.dodopayments.com/)
- [Dodo API Reference](https://docs.dodopayments.com/api)

---

Your premium upgrade system is ready! 🚀

