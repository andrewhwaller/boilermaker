import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme"
export default class extends Controller {
  static values = {
    storageKey: { type: String, default: "theme-preference" }
  }

  connect() {
    this.initializeTheme()
    this.setupSystemPreferenceListener()
    this.setupToggleListener()
  }

  disconnect() {
    this.cleanupSystemPreferenceListener()
    this.cleanupToggleListener()
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
      return "dark"
    }
    return "light"
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

  // Apply theme to HTML element
  applyTheme(theme) {
    const htmlElement = document.documentElement
    
    // Remove existing theme classes
    htmlElement.classList.remove("light", "dark")
    
    // Apply theme class
    if (theme === "dark" || theme === "light") {
      htmlElement.classList.add(theme)
    }
    
    // Dispatch theme change event for other controllers
    this.dispatch("change", { detail: { theme } })
  }

  // Set theme and persist preference
  setTheme(theme) {
    if (!["light", "dark", "system"].includes(theme)) {
      return false
    }

    this.setStoredTheme(theme)
    
    const effectiveTheme = theme === "system" ? this.getSystemPreference() : theme
    this.applyTheme(effectiveTheme)
    
    return true
  }

  // Toggle between light and dark
  toggleTheme() {
    const currentTheme = this.getCurrentTheme()
    const newTheme = currentTheme === "dark" ? "light" : "dark"
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
      const newTheme = event.matches ? "dark" : "light"
      this.applyTheme(newTheme)
    }
  }

  // Stimulus action methods (can be used with data-action)
  light() {
    return this.setTheme("light")
  }

  dark() {
    return this.setTheme("dark")
  }

  system() {
    return this.setTheme("system")
  }

  toggle() {
    return this.toggleTheme()
  }

  // Listen for toggle events from theme-toggle controllers
  setupToggleListener() {
    this.boundToggleHandler = this.handleToggleEvent.bind(this)
    document.addEventListener("theme:toggle", this.boundToggleHandler)
  }

  cleanupToggleListener() {
    if (this.boundToggleHandler) {
      document.removeEventListener("theme:toggle", this.boundToggleHandler)
    }
  }

  handleToggleEvent(event) {
    this.toggleTheme()
  }
}