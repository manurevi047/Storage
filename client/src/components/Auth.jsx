import { useState } from 'react'
import { useAuth } from '../contexts/AuthContext'
import { trackEvent } from '../analytics'
import './Auth.css'

export default function Auth() {
  const [isSignUp, setIsSignUp] = useState(false)
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [username, setUsername] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [success, setSuccess] = useState(null)

  const { signIn, signUp } = useAuth()

  const handleSubmit = async (e) => {
    e.preventDefault()
    setLoading(true)
    setError(null)
    setSuccess(null)

    // Basic validation
    if (!email || !password) {
      setError('Please fill in all fields')
      setLoading(false)
      return
    }

    if (password.length < 6) {
      setError('Password must be at least 6 characters')
      setLoading(false)
      return
    }

    if (isSignUp && !username) {
      setError('Please enter a username')
      setLoading(false)
      return
    }

    try {
      if (isSignUp) {
        const { error } = await signUp(email, password, { username })
        if (error) throw error
        
        // Track signup
        trackEvent('sign_up', {
          method: 'email'
        })
        
        setSuccess('Account created! Please check your email to verify your account.')
        setEmail('')
        setPassword('')
        setUsername('')
      } else {
        const { error } = await signIn(email, password)
        if (error) throw error
        
        // Track login
        trackEvent('login', {
          method: 'email'
        })
        
        setSuccess('Signed in successfully!')
      }
    } catch (err) {
      setError(err.message || 'Authentication failed')
      
      // Track auth error
      trackEvent(isSignUp ? 'sign_up_error' : 'login_error', {
        error: err.message
      })
    } finally {
      setLoading(false)
    }
  }

  const toggleMode = () => {
    setIsSignUp(!isSignUp)
    setError(null)
    setSuccess(null)
  }

  return (
    <div className="auth-container">
      <div className="auth-card">
        <div className="auth-header">
          <div className="auth-icon">
            <svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
              <rect width="48" height="48" rx="12" fill="url(#authGradient)"/>
              <path d="M24 12C19.58 12 16 15.58 16 20C16 22.84 17.54 25.32 19.86 26.64C16.82 27.94 14.5 30.84 14.5 34.25V36H33.5V34.25C33.5 30.84 31.18 27.94 28.14 26.64C30.46 25.32 32 22.84 32 20C32 15.58 28.42 12 24 12Z" fill="white"/>
              <defs>
                <linearGradient id="authGradient" x1="0" y1="0" x2="48" y2="48" gradientUnits="userSpaceOnUse">
                  <stop stopColor="#6366f1"/>
                  <stop offset="1" stopColor="#8b5cf6"/>
                </linearGradient>
              </defs>
            </svg>
          </div>
          <h2>{isSignUp ? 'Create Account' : 'Welcome Back'}</h2>
          <p className="auth-subtitle">
            {isSignUp ? 'Sign up to start uploading files' : 'Sign in to your account'}
          </p>
        </div>

        <form onSubmit={handleSubmit} className="auth-form">
          {isSignUp && (
            <div className="form-group">
              <label htmlFor="username">Username</label>
              <input
                id="username"
                type="text"
                placeholder="Enter your username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                disabled={loading}
                required={isSignUp}
              />
            </div>
          )}

          <div className="form-group">
            <label htmlFor="email">Email</label>
            <input
              id="email"
              type="email"
              placeholder="Enter your email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              disabled={loading}
              required
            />
          </div>

          <div className="form-group">
            <label htmlFor="password">Password</label>
            <input
              id="password"
              type="password"
              placeholder="Enter your password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              disabled={loading}
              required
              minLength="6"
            />
            {isSignUp && (
              <span className="form-hint">Minimum 6 characters</span>
            )}
          </div>

          {error && (
            <div className="message error">
              <span className="message-icon">⚠️</span>
              {error}
            </div>
          )}

          {success && (
            <div className="message success">
              <span className="message-icon">✅</span>
              {success}
            </div>
          )}

          <button
            type="submit"
            className="auth-submit-button"
            disabled={loading}
          >
            {loading ? 'Loading...' : (isSignUp ? 'Sign Up' : 'Sign In')}
          </button>
        </form>

        <div className="auth-footer">
          <p>
            {isSignUp ? 'Already have an account?' : "Don't have an account?"}
            {' '}
            <button
              type="button"
              className="auth-toggle-button"
              onClick={toggleMode}
              disabled={loading}
            >
              {isSignUp ? 'Sign In' : 'Sign Up'}
            </button>
          </p>
        </div>
      </div>
    </div>
  )
}

