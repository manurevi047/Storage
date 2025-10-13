// Google Tag Manager Integration
const GA_TRACKING_ID = import.meta.env.VITE_GA_TRACKING_ID || import.meta.env.GA_TRACKING_ID || 'G-Q7TB2EYX0F'

// Only load Google Tag Manager if tracking ID is provided
if (GA_TRACKING_ID) {
  // Load gtag.js script
  const script = document.createElement('script')
  script.async = true
  script.src = `https://www.googletagmanager.com/gtag/js?id=${GA_TRACKING_ID}`
  document.head.appendChild(script)

  // Initialize dataLayer and gtag function
  window.dataLayer = window.dataLayer || []
  function gtag() {
    window.dataLayer.push(arguments)
  }
  window.gtag = gtag

  gtag('js', new Date())
  gtag('config', GA_TRACKING_ID)

  console.log('✅ Google Tag Manager initialized with ID:', GA_TRACKING_ID)
} else {
  console.log('ℹ️ Google Tag Manager not initialized (no tracking ID provided)')
}

// Helper function to track custom events
export const trackEvent = (eventName, eventParams = {}) => {
  if (window.gtag) {
    window.gtag('event', eventName, eventParams)
  }
}

// Helper function to track page views
export const trackPageView = (pagePath) => {
  if (window.gtag && GA_TRACKING_ID) {
    window.gtag('config', GA_TRACKING_ID, {
      page_path: pagePath
    })
  }
}

// Export for use in components
export default { trackEvent, trackPageView }

