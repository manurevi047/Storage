import { useEffect } from 'react'
import './PaymentSuccess.css'

export default function PaymentSuccess() {
  useEffect(() => {
    // Auto-redirect to home after 5 seconds
    const timer = setTimeout(() => {
      window.location.href = '/'
    }, 5000)

    return () => clearTimeout(timer)
  }, [])

  return (
    <div className="payment-success">
      <div className="success-card">
        <div className="success-icon">
          <svg width="80" height="80" viewBox="0 0 80 80" fill="none" xmlns="http://www.w3.org/2000/svg">
            <circle cx="40" cy="40" r="40" fill="#10b981"/>
            <path d="M25 40L35 50L55 30" stroke="white" strokeWidth="4" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </div>
        
        <h1>Payment Successful! 🎉</h1>
        <p className="success-message">
          Thank you for upgrading to Premium!
        </p>
        
        <div className="success-details">
          <p>Your premium features are now active.</p>
          <p>You'll be redirected to the app in 5 seconds...</p>
        </div>

        <button 
          onClick={() => window.location.href = '/'} 
          className="return-button"
        >
          Return to App
        </button>
      </div>
    </div>
  )
}

