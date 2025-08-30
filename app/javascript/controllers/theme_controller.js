import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme"
export default class extends Controller {
  static targets = []
  static values = {
    storageKey: { type: String, default: "theme-preference" },
    defaultTheme: { type: String, default: "light" }
  }
  
  // Theme constants
  static get THEME_LIGHT() { return "light" }
  static get THEME_DARK() { return "dark" }
  static get THEME_SYSTEM() { return "system" }

  connect() {
    this.initializeTheme()
    this.setupSystemPreferenceListener()
    this.updateDebugInfo()
    this.setupThemeChangeListener()
  }

  disconnect() {
    this.cleanupSystemPreferenceListener()
  }

  // Initialize theme on connect - prevents FOUC
  initializeTheme() {
    const currentTheme = this.getCurrentTheme()
    this.applyTheme(currentTheme)
  }

  // Get current effective theme based on priority: user choice > system > default
  getCurrentTheme() {
    try {
      const storedPreference = this.getStoredThemePreference()
      
      if (storedPreference && this.isValidTheme(storedPreference)) {
        if (storedPreference === this.constructor.THEME_SYSTEM) {
          return this.getSystemPreference()
        }
        return storedPreference
      }
      
      // No stored preference, use system preference or default
      return this.getSystemPreference()
    } catch (error) {
      this.handleError("Failed to get current theme", error)
      return this.defaultThemeValue
    }
  }

  // Get system preference from prefers-color-scheme
  getSystemPreference() {
    try {
      if (window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches) {
        return this.constructor.THEME_DARK
      }
      return this.constructor.THEME_LIGHT
    } catch (error) {
      this.handleError("Failed to detect system preference", error)
      return this.defaultThemeValue
    }
  }

  // Get stored theme preference from localStorage
  getStoredThemePreference() {
    try {
      return localStorage.getItem(this.storageKeyValue)
    } catch (error) {
      this.handleError("Failed to access localStorage", error)
      return null
    }
  }

  // Store theme preference in localStorage
  setStoredThemePreference(theme) {
    try {
      if (theme === null || theme === undefined) {
        localStorage.removeItem(this.storageKeyValue)
      } else {
        localStorage.setItem(this.storageKeyValue, theme)
      }
      return true
    } catch (error) {
      this.handleError("Failed to store theme preference", error)
      return false
    }
  }

  // Validate theme value
  isValidTheme(theme) {
    return [
      this.constructor.THEME_LIGHT,
      this.constructor.THEME_DARK,
      this.constructor.THEME_SYSTEM
    ].includes(theme)
  }

  // Apply theme to HTML element
  applyTheme(theme) {
    try {
      const htmlElement = document.documentElement
      
      // Remove existing theme classes
      htmlElement.classList.remove(this.constructor.THEME_LIGHT, this.constructor.THEME_DARK)
      
      // Apply theme class (system preference doesn't need a class)
      if (theme === this.constructor.THEME_DARK) {
        htmlElement.classList.add(this.constructor.THEME_DARK)
      } else if (theme === this.constructor.THEME_LIGHT) {
        htmlElement.classList.add(this.constructor.THEME_LIGHT)
      }
      
      // Dispatch theme change event
      this.dispatchThemeChangeEvent(theme)
    } catch (error) {
      this.handleError("Failed to apply theme", error)
    }
  }

  // Public API methods for theme management

  // Set theme and persist preference
  setTheme(theme) {
    if (!this.isValidTheme(theme)) {
      this.handleError(`Invalid theme: ${theme}`)
      return false
    }

    try {
      // Store preference
      this.setStoredThemePreference(theme)
      
      // Apply theme immediately
      const effectiveTheme = theme === this.constructor.THEME_SYSTEM 
        ? this.getSystemPreference() 
        : theme
      
      this.applyTheme(effectiveTheme)
      return true
    } catch (error) {
      this.handleError("Failed to set theme", error)
      return false
    }
  }

  // Toggle between light and dark (ignores system preference)
  toggleTheme() {
    try {
      const currentTheme = this.getCurrentTheme()
      const newTheme = currentTheme === this.constructor.THEME_DARK 
        ? this.constructor.THEME_LIGHT 
        : this.constructor.THEME_DARK
      
      return this.setTheme(newTheme)
    } catch (error) {
      this.handleError("Failed to toggle theme", error)
      return false
    }
  }

  // Get current effective theme (what's actually displayed)
  getTheme() {
    return this.getCurrentTheme()
  }

  // Get stored user preference (may be different from effective theme)
  getThemePreference() {
    return this.getStoredThemePreference() || this.constructor.THEME_SYSTEM
  }

  // System preference change handling
  setupSystemPreferenceListener() {
    try {
      if (window.matchMedia) {
        this.systemMediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
        this.systemChangeHandler = this.handleSystemPreferenceChange.bind(this)
        
        // Modern browsers
        if (this.systemMediaQuery.addEventListener) {
          this.systemMediaQuery.addEventListener("change", this.systemChangeHandler)
        } 
        // Fallback for older browsers
        else if (this.systemMediaQuery.addListener) {
          this.systemMediaQuery.addListener(this.systemChangeHandler)
        }
      }
    } catch (error) {
      this.handleError("Failed to setup system preference listener", error)
    }
  }

  cleanupSystemPreferenceListener() {
    try {
      if (this.systemMediaQuery && this.systemChangeHandler) {
        // Modern browsers
        if (this.systemMediaQuery.removeEventListener) {
          this.systemMediaQuery.removeEventListener("change", this.systemChangeHandler)
        }
        // Fallback for older browsers
        else if (this.systemMediaQuery.removeListener) {
          this.systemMediaQuery.removeListener(this.systemChangeHandler)
        }
      }
    } catch (error) {
      this.handleError("Failed to cleanup system preference listener", error)
    }
  }

  handleSystemPreferenceChange(event) {
    try {
      const storedPreference = this.getStoredThemePreference()
      
      // Only react to system changes if user hasn't set explicit preference or prefers system
      if (!storedPreference || storedPreference === this.constructor.THEME_SYSTEM) {
        const newTheme = event.matches ? this.constructor.THEME_DARK : this.constructor.THEME_LIGHT
        this.applyTheme(newTheme)
      }
    } catch (error) {
      this.handleError("Failed to handle system preference change", error)
    }
  }

  // Event system
  dispatchThemeChangeEvent(theme) {
    try {
      const event = new CustomEvent("theme:change", {
        detail: { 
          theme,
          preference: this.getThemePreference(),
          timestamp: new Date().toISOString()
        },
        bubbles: true
      })
      
      this.element.dispatchEvent(event)
      
      // Also dispatch on document for global listeners
      document.dispatchEvent(new CustomEvent("theme:change", {
        detail: event.detail
      }))
    } catch (error) {
      this.handleError("Failed to dispatch theme change event", error)
    }
  }

  // Stimulus action methods (can be used with data-action)
  light() {
    return this.setTheme(this.constructor.THEME_LIGHT)
  }

  dark() {
    return this.setTheme(this.constructor.THEME_DARK)
  }

  system() {
    return this.setTheme(this.constructor.THEME_SYSTEM)
  }

  toggle() {
    return this.toggleTheme()
  }

  // Error handling
  handleError(message, error = null) {
    const errorMessage = `ThemeController: ${message}`
    
    if (error) {
      console.error(errorMessage, error)
    } else {
      console.error(errorMessage)
    }

    // Dispatch error event for application error handling
    try {
      const errorEvent = new CustomEvent("theme:error", {
        detail: { message: errorMessage, error, timestamp: new Date().toISOString() },
        bubbles: true
      })
      this.element.dispatchEvent(errorEvent)
    } catch (dispatchError) {
      // Fallback if event dispatch fails
      console.error("Failed to dispatch theme error event", dispatchError)
    }
  }

  // Debug info and display methods
  setupThemeChangeListener() {
    // Listen for theme change events to update debug info
    document.addEventListener("theme:change", (event) => {
      this.updateDebugInfo()
    })
  }

  updateDebugInfo() {
    try {
      const debugElement = document.getElementById("theme-debug")
      if (debugElement) {
        const debugInfo = this.debug()
        debugElement.innerHTML = `
          <strong>Theme Debug Info:</strong><br/>
          Current Theme: ${debugInfo.currentTheme}<br/>
          Stored Preference: ${debugInfo.storedPreference || 'null'}<br/>
          System Preference: ${debugInfo.systemPreference}<br/>
          Effective Preference: ${debugInfo.effectivePreference}<br/>
          HTML Classes: ${debugInfo.htmlClasses.join(', ') || 'none'}<br/>
          Storage Available: ${debugInfo.storageAvailable ? 'yes' : 'no'}
        `
      }
    } catch (error) {
      this.handleError("Failed to update debug info", error)
    }
  }

  // Utility method for debugging
  debug() {
    return {
      currentTheme: this.getCurrentTheme(),
      storedPreference: this.getStoredThemePreference(),
      systemPreference: this.getSystemPreference(),
      effectivePreference: this.getThemePreference(),
      htmlClasses: Array.from(document.documentElement.classList),
      storageAvailable: this.isLocalStorageAvailable()
    }
  }

  // Check if localStorage is available
  isLocalStorageAvailable() {
    try {
      const test = '__theme_storage_test__'
      localStorage.setItem(test, test)
      localStorage.removeItem(test)
      return true
    } catch (error) {
      return false
    }
  }
}