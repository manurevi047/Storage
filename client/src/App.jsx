import { useState, useRef, useEffect } from 'react'
import { useAuth } from './contexts/AuthContext'
import { supabase } from './lib/supabase'
import Auth from './components/Auth'
import PaymentSuccess from './PaymentSuccess'
import { trackEvent } from './analytics'
import './App.css'

function App() {
  const { user, loading: authLoading, signOut } = useAuth()
  const [selectedFile, setSelectedFile] = useState(null)
  const [uploading, setUploading] = useState(false)
  const [uploadedFiles, setUploadedFiles] = useState([])
  const [allUserFiles, setAllUserFiles] = useState([])
  const [loadingFiles, setLoadingFiles] = useState(false)
  const [error, setError] = useState(null)
  const [success, setSuccess] = useState(null)
  const [showPaymentSuccess, setShowPaymentSuccess] = useState(false)
  const [previewFile, setPreviewFile] = useState(null)
  const fileInputRef = useRef(null)

  // Check if returning from payment
  useEffect(() => {
    const path = window.location.pathname
    if (path === '/payment-success') {
      setShowPaymentSuccess(true)
    }
  }, [])

  // Fetch all user files when component mounts
  useEffect(() => {
    if (user) {
      fetchAllUserFiles()
    }
  }, [user])

  const fetchAllUserFiles = async () => {
    try {
      setLoadingFiles(true)
      setError(null)
      
      // Get the user's session token
      const { data: { session } } = await supabase.auth.getSession()
      
      if (!session) {
        throw new Error('Not authenticated')
      }

      const response = await fetch('/api/files', {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${session.access_token}`
        }
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || 'Failed to fetch files')
      }

      setAllUserFiles(data.files || [])
    } catch (err) {
      console.error('Error fetching files:', err)
      setError(err.message || 'Failed to fetch files')
    } finally {
      setLoadingFiles(false)
    }
  }

  // Show auth screen if not authenticated
  if (authLoading) {
    return (
      <div className="app loading-screen">
        <div className="loading-spinner">Loading...</div>
      </div>
    )
  }

  if (!user) {
    return <Auth />
  }

  // Show payment success page
  if (showPaymentSuccess) {
    return <PaymentSuccess />
  }

  const handleFileSelect = (event) => {
    const file = event.target.files[0]
    if (file) {
      setSelectedFile(file)
      setError(null)
      setSuccess(null)
    }
  }

  const handleUploadClick = () => {
    fileInputRef.current?.click()
  }

  const handleUpload = async () => {
    if (!selectedFile) {
      setError('Please select a file first')
      return
    }

    setUploading(true)
    setError(null)
    setSuccess(null)

    const formData = new FormData()
    formData.append('file', selectedFile)

    try {
      // Get the user's session token
      const { data: { session } } = await supabase.auth.getSession()
      
      if (!session) {
        throw new Error('Not authenticated')
      }

      const response = await fetch('/api/upload', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${session.access_token}`
        },
        body: formData,
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || 'Upload failed')
      }

      // Track successful upload
      trackEvent('file_upload', {
        file_size: selectedFile.size,
        file_type: selectedFile.type
      })

      setSuccess(`File "${selectedFile.name}" uploaded successfully!`)
      setUploadedFiles([data.file, ...uploadedFiles])
      setSelectedFile(null)
      if (fileInputRef.current) {
        fileInputRef.current.value = ''
      }
      
      // Refresh the complete file list
      await fetchAllUserFiles()
    } catch (err) {
      setError(err.message || 'Failed to upload file')
      
      // Track upload error
      trackEvent('file_upload_error', {
        error: err.message
      })
    } finally {
      setUploading(false)
    }
  }

  const handleSignOut = async () => {
    await signOut()
  }

  const handleUpgradeToPremium = async () => {
    try {
      setError(null)
      
      // Track upgrade button click
      trackEvent('upgrade_button_clicked')
      
      // Get the user's session token
      const { data: { session } } = await supabase.auth.getSession()
      
      if (!session) {
        setError('Not authenticated')
        return
      }

      const response = await fetch('/api/create-checkout', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${session.access_token}`,
          'Content-Type': 'application/json'
        }
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || 'Failed to create checkout')
      }

      // Track checkout initiation
      trackEvent('checkout_initiated', {
        session_id: data.session_id
      })

      // Redirect to Dodo Payments checkout
      console.log('Redirecting to checkout:', data.checkout_url)
      window.location.href = data.checkout_url

    } catch (err) {
      console.error('Checkout error:', err)
      setError(err.message || 'Failed to initiate payment')
      
      // Track checkout error
      trackEvent('checkout_error', {
        error: err.message
      })
    }
  }

  const formatFileSize = (bytes) => {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
  }

  const getFileIcon = (type) => {
    // Handle MIME types (from uploaded files)
    if (type?.startsWith('image/')) return '🖼️'
    if (type?.startsWith('video/')) return '🎥'
    if (type?.startsWith('audio/')) return '🎵'
    if (type?.includes('pdf')) return '📄'
    if (type?.includes('text')) return '📝'
    if (type?.includes('zip') || type?.includes('rar')) return '📦'
    
    // Handle file type strings (from filename detection)
    if (type === 'image') return '🖼️'
    if (type === 'video') return '🎥'
    if (type === 'audio') return '🎵'
    if (type === 'pdf') return '📄'
    if (type === 'text') return '📝'
    if (type === 'archive') return '📦'
    if (type === 'document') return '📄'
    if (type === 'code') return '💻'
    
    return '📎'
  }

  const extractOriginalFileName = (storedPath) => {
    // Extract original filename from stored path like "userId/timestamp-originalname.ext"
    const parts = storedPath.split('/')
    if (parts.length > 1) {
      const fileName = parts[parts.length - 1]
      // Remove timestamp prefix (format: timestamp-filename)
      const timestampMatch = fileName.match(/^\d+-(.+)$/)
      return timestampMatch ? timestampMatch[1] : fileName
    }
    return storedPath
  }

  const getFileTypeFromName = (fileName) => {
    const ext = fileName.toLowerCase().split('.').pop()
    
    // Image files
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg', 'ico', 'tiff', 'tif'].includes(ext)) return 'image'
    
    // Video files
    if (['mp4', 'mov', 'avi', 'mkv', 'wmv', 'flv', 'webm', 'm4v', '3gp', 'ogv'].includes(ext)) return 'video'
    
    // Audio files
    if (['mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a', 'wma', 'opus', 'aiff'].includes(ext)) return 'audio'
    
    // PDF files
    if (ext === 'pdf') return 'pdf'
    
    // Text files
    if (['txt', 'md', 'rtf', 'log', 'csv', 'json', 'xml', 'yaml', 'yml'].includes(ext)) return 'text'
    
    // Archive files
    if (['zip', 'rar', '7z', 'tar', 'gz', 'bz2', 'xz', 'tar.gz', 'tar.bz2'].includes(ext)) return 'archive'
    
    // Document files
    if (['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'odt', 'ods', 'odp'].includes(ext)) return 'document'
    
    // Code files
    if (['js', 'ts', 'jsx', 'tsx', 'html', 'css', 'scss', 'sass', 'less', 'py', 'java', 'cpp', 'c', 'php', 'rb', 'go', 'rs', 'swift', 'kt'].includes(ext)) return 'code'
    
    return 'document'
  }

  const handleFilePreview = (file) => {
    const originalName = extractOriginalFileName(file.name)
    const fileType = getFileTypeFromName(originalName)
    
    // Only show preview for images and videos
    if (fileType === 'image' || fileType === 'video') {
      setPreviewFile({
        url: file.url,
        name: originalName,
        type: fileType
      })
    } else {
      // For other file types, open in new tab
      window.open(file.url, '_blank', 'noopener,noreferrer')
    }
  }

  const closePreview = () => {
    setPreviewFile(null)
  }

  return (
    <div className="app">
      <div className="container">
        <header className="header">
          <div className="logo">
            <svg width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">
              <rect width="40" height="40" rx="8" fill="url(#gradient)"/>
              <path d="M20 10L20 25M20 25L25 20M20 25L15 20" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/>
              <path d="M12 28H28" stroke="white" strokeWidth="2.5" strokeLinecap="round"/>
              <defs>
                <linearGradient id="gradient" x1="0" y1="0" x2="40" y2="40" gradientUnits="userSpaceOnUse">
                  <stop stopColor="#6366f1"/>
                  <stop offset="1" stopColor="#8b5cf6"/>
                </linearGradient>
              </defs>
            </svg>
            <h1>File Upload</h1>
          </div>
          <p className="subtitle">Upload any file to secure cloud storage</p>
          
          <div className="user-info">
            <span className="user-email">👤 {user.email}</span>
            <button onClick={handleUpgradeToPremium} className="premium-button">
              ⭐ Upgrade to Premium
            </button>
            <button onClick={handleSignOut} className="sign-out-button">
              Sign Out
            </button>
          </div>
        </header>

        <div className="upload-section">
          <input
            ref={fileInputRef}
            type="file"
            onChange={handleFileSelect}
            style={{ display: 'none' }}
            id="file-input"
          />
          
          <div className="upload-card">
            <div className="upload-icon">
              <svg width="64" height="64" viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
                <circle cx="32" cy="32" r="32" fill="#f0f0ff"/>
                <path d="M32 20V38M32 20L26 26M32 20L38 26" stroke="#6366f1" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"/>
                <path d="M22 42H42" stroke="#6366f1" strokeWidth="3" strokeLinecap="round"/>
              </svg>
            </div>
            
            <button className="upload-button" onClick={handleUploadClick}>
              <svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M10 4V14M10 4L6 8M10 4L14 8" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                <path d="M4 16H16" stroke="white" strokeWidth="2" strokeLinecap="round"/>
              </svg>
              Choose File
            </button>
            
            {selectedFile && (
              <div className="file-info">
                <div className="file-details">
                  <span className="file-icon">{getFileIcon(selectedFile.type)}</span>
                  <div>
                    <div className="file-name">{selectedFile.name}</div>
                    <div className="file-size">{formatFileSize(selectedFile.size)}</div>
                  </div>
                </div>
                <button 
                  className="confirm-upload-button"
                  onClick={handleUpload}
                  disabled={uploading}
                >
                  {uploading ? 'Uploading...' : 'Upload'}
                </button>
              </div>
            )}

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
          </div>
        </div>

        {uploadedFiles.length > 0 && (
          <div className="files-section">
            <h2>Recently Uploaded Files</h2>
            <div className="files-list">
              {uploadedFiles.map((file, index) => (
                <div key={index} className="file-item">
                  <span className="file-icon">{getFileIcon(file.type)}</span>
                  <div className="file-item-info">
                    <div className="file-item-name">{file.name}</div>
                    <div className="file-item-size">{formatFileSize(file.size)}</div>
                  </div>
                  <a 
                    href={file.url} 
                    target="_blank" 
                    rel="noopener noreferrer"
                    className="view-link"
                  >
                    View
                  </a>
                </div>
              ))}
            </div>
          </div>
        )}

        <div className="files-section">
          <div className="section-header">
            <h2>All Your Files</h2>
            <button 
              onClick={fetchAllUserFiles} 
              className="refresh-button"
              disabled={loadingFiles}
            >
              {loadingFiles ? '🔄' : '🔄'} Refresh
            </button>
          </div>
          
          {loadingFiles ? (
            <div className="loading-files">
              <div className="loading-spinner">Loading files...</div>
            </div>
          ) : allUserFiles.length > 0 ? (
            <div className="files-list">
              {allUserFiles.map((file, index) => {
                const originalName = extractOriginalFileName(file.name)
                const fileType = getFileTypeFromName(originalName)
                return (
                  <div key={index} className="file-item">
                    <span className="file-icon">{getFileIcon(fileType)}</span>
                    <div className="file-item-info">
                      <div className="file-item-name">{originalName}</div>
                      <div className="file-item-details">
                        {file.size && (
                          <span className="file-item-size">{formatFileSize(file.size)}</span>
                        )}
                        {file.createdAt && (
                          <span className="file-item-date">
                            {new Date(file.createdAt).toLocaleDateString()}
                          </span>
                        )}
                      </div>
                    </div>
                    <button 
                      onClick={() => handleFilePreview(file)}
                      className="view-link"
                    >
                      View
                    </button>
                  </div>
                )
              })}
            </div>
          ) : (
            <div className="no-files">
              <div className="no-files-icon">📁</div>
              <p>No files uploaded yet</p>
              <p className="no-files-subtitle">Upload your first file using the button above</p>
            </div>
          )}
        </div>

        {/* File Preview Modal */}
        {previewFile && (
          <div className="preview-modal" onClick={closePreview}>
            <div className="preview-content" onClick={(e) => e.stopPropagation()}>
              <div className="preview-header">
                <h3>{previewFile.name}</h3>
                <button onClick={closePreview} className="close-button">×</button>
              </div>
              <div className="preview-body">
                {previewFile.type === 'image' ? (
                  <img 
                    src={previewFile.url} 
                    alt={previewFile.name}
                    className="preview-image"
                  />
                ) : previewFile.type === 'video' ? (
                  <video 
                    src={previewFile.url} 
                    controls
                    className="preview-video"
                  >
                    Your browser does not support video playback.
                  </video>
                ) : null}
              </div>
              <div className="preview-footer">
                <a 
                  href={previewFile.url} 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="download-link"
                >
                  Open in New Tab
                </a>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

export default App

