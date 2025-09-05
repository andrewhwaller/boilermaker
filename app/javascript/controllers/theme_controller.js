import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme"
export default class extends Controller {
  static targets = ["button", "indicator", "sunIcon", "moonIcon"]
  static values = {
    storageKey: { type: String, default: "theme-preference" }
  }

  connect() {
    this.initializeTheme()
    this.setupSystemPreferenceListener()
    this.updateToggleState()
  }

  disconnect() {
    this.cleanupSystemPreferenceListener()
  }

  // Initialize theme on connect - prevents FOUC
  initializeTheme() {
    const theme = this.getCurrentTheme()
    this.applyTheme(theme)
  }

  // Get current effective theme
  getCurrentTheme() {
    const stored = this.getStoredTheme()
    if (stored && stored !== "system") {
      return stored
    }
    return this.getSystemPreference()
  }

  // Get system preference from prefers-color-scheme
  getSystemPreference() {
    if (window.matchMedia?.("(prefers-color-scheme: dark)").matches) {
      return "business"
    }
    return "corporate"
  }

  // Get stored theme preference from localStorage
  getStoredTheme() {
    try {
      return localStorage.getItem(this.storageKeyValue)
    } catch {
      return null
    }
  }

  // Store theme preference in localStorage
  setStoredTheme(theme) {
    try {
      if (theme === "system") {
        localStorage.removeItem(this.storageKeyValue)
      } else {
        localStorage.setItem(this.storageKeyValue, theme)
      }
    } catch {
      // localStorage not available, theme will default to system
    }
  }

  // Apply theme using DaisyUI data-theme on the controller's element
  applyTheme(theme) {
    // Set DaisyUI data-theme attribute on the element this controller is attached to
    if (theme === "business" || theme === "corporate") {
      this.element.setAttribute("data-theme", theme)
    } else {
      // Remove data-theme to use system default
      this.element.removeAttribute("data-theme")
    }
    
    // Update toggle UI state
    this.updateToggleState(theme)
    
    // Dispatch theme change event for other controllers
    this.dispatch("change", { detail: { theme } })
  }

  // Set theme and persist preference
  setTheme(theme) {
    if (!["corporate", "business", "system"].includes(theme)) {
      return false
    }

    this.setStoredTheme(theme)
    
    const effectiveTheme = theme === "system" ? this.getSystemPreference() : theme
    this.applyTheme(effectiveTheme)
    
    return true
  }

  // Toggle between corporate and business themes
  toggleTheme() {
    const currentTheme = this.getCurrentTheme()
    const newTheme = currentTheme === "business" ? "corporate" : "business"
    return this.setTheme(newTheme)
  }

  // System preference change handling
  setupSystemPreferenceListener() {
    if (!window.matchMedia) return
    
    this.systemMediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
    this.systemChangeHandler = this.handleSystemPreferenceChange.bind(this)
    
    if (this.systemMediaQuery.addEventListener) {
      this.systemMediaQuery.addEventListener("change", this.systemChangeHandler)
    }
  }

  cleanupSystemPreferenceListener() {
    if (this.systemMediaQuery && this.systemChangeHandler) {
      if (this.systemMediaQuery.removeEventListener) {
        this.systemMediaQuery.removeEventListener("change", this.systemChangeHandler)
      }
    }
  }

  handleSystemPreferenceChange(event) {
    const storedTheme = this.getStoredTheme()
    
    // Only react to system changes if user hasn't set explicit preference
    if (!storedTheme || storedTheme === "system") {
      const newTheme = event.matches ? "business" : "corporate"
      this.applyTheme(newTheme)
    }
  }

  // Stimulus action methods (can be used with data-action)
  corporate() {
    return this.setTheme("corporate")
  }

  business() {
    return this.setTheme("business")
  }

  system() {
    return this.setTheme("system")
  }

  toggle() {
    return this.toggleTheme()
  }

  // Handle keyboard shortcuts
  handleKeyboard(event) {
    // Check for Cmd/Ctrl + Shift + L
    if ((event.metaKey || event.ctrlKey) && event.shiftKey && event.key === 'L') {
      event.preventDefault()
      this.toggle()
    }
  }

  // Update toggle button visual state
  updateToggleState(theme = null) {
    // Only update if we have toggle targets
    if (!this.hasButtonTarget) return
    
    // Determine current theme from DOM if not provided
    const currentTheme = theme || (this.element.getAttribute('data-theme') === 'business' ? 'business' : 'corporate')
    const isDark = currentTheme === 'business'

    // Update button ARIA state
    this.buttonTarget.setAttribute('aria-pressed', isDark.toString())

    // Update indicator position
    if (this.hasIndicatorTarget) {
      this.indicatorTarget.classList.toggle('translate-x-7', isDark)
    }

    // Update icon visibility
    if (this.hasSunIconTarget && this.hasMoonIconTarget) {
      this.sunIconTarget.classList.toggle('opacity-0', isDark)
      this.sunIconTarget.classList.toggle('opacity-100', !isDark)
      this.moonIconTarget.classList.toggle('opacity-0', !isDark)
      this.moonIconTarget.classList.toggle('opacity-100', isDark)
    }
  }
}