import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme"
export default class extends Controller {
  static targets = ["button", "indicator"]
  static values = {
    storageKey: { type: String, default: "theme-preference" },
    lightName:  { type: String, default: "platinum" },
    darkName:   { type: String, default: "graphite" }
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
    const mode = this.getCurrentMode()
    this.applyMode(mode)
  }

  // Get current effective mode ("light" | "dark") or system-derived
  getCurrentMode() {
    const stored = this.getStoredMode()
    if (stored && stored !== "system") {
      return stored // "light" | "dark"
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

  // Get stored mode preference from localStorage (supports back-compat names)
  getStoredMode() {
    try {
      const v = localStorage.getItem(this.storageKeyValue)
      if (!v) return null
      // Back-compat: map historical theme names to modes
      if (["default", "platinum", "corporate"].includes(v)) return "light"
      if (["forest", "graphite", "business"].includes(v)) return "dark"
      if (["light", "dark", "system"].includes(v)) return v
      return null
    } catch {
      return null
    }
  }

  // Store mode preference in localStorage
  setStoredMode(mode) {
    try {
      if (mode === "system") {
        localStorage.removeItem(this.storageKeyValue)
      } else {
        localStorage.setItem(this.storageKeyValue, mode)
      }
    } catch {
      // localStorage not available, theme will default to system
    }
  }

  // Apply mode by setting DaisyUI data-theme to configured light/dark names
  applyMode(mode) {
    // Add temporary class to enable smooth transitions
    try { this.element.classList.add('theme-transition') } catch {}
    // Set DaisyUI data-theme attribute on the element this controller is attached to
    if (mode === "dark" || mode === "light") {
      const themeName = mode === "dark" ? this.darkNameValue : this.lightNameValue
      this.element.setAttribute("data-theme", themeName)
    } else {
      // Remove data-theme to use system default
      this.element.removeAttribute("data-theme")
    }
    
    // Update toggle UI state
    this.updateToggleState(mode)
    
    // Dispatch theme change event for other controllers
    const appliedTheme = this.element.getAttribute('data-theme') || null
    this.dispatch("change", { detail: { mode, theme: appliedTheme } })

    // Remove transition class after animation completes
    try {
      clearTimeout(this._transitionTimeout)
      this._transitionTimeout = setTimeout(() => {
        this.element.classList.remove('theme-transition')
      }, 300)
    } catch {}
  }

  // Set mode ("light" | "dark" | "system") and persist preference
  setMode(mode) {
    // Back-compat mapping from theme names to modes
    if (["platinum", "default", "corporate"].includes(mode)) mode = "light"
    if (["graphite", "forest", "business"].includes(mode)) mode = "dark"
    if (!["light", "dark", "system"].includes(mode)) return false

    this.setStoredMode(mode)
    const effective = mode === "system" ? this.getSystemPreference() : mode
    this.applyMode(effective)
    return true
  }

  // Toggle between light and dark modes
  toggleTheme() {
    const current = this.getCurrentMode()
    const next = current === "dark" ? "light" : "dark"
    return this.setMode(next)
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
    const stored = this.getStoredMode()
    
    // Only react to system changes if user hasn't set explicit preference
    if (!stored || stored === "system") {
      const mode = event.matches ? "dark" : "light"
      this.applyMode(mode)
    }
  }

  // Stimulus action methods (can be used with data-action)
  // Backward-compat method names used by existing buttons
  corporate() { return this.setMode("light") }
  business() { return this.setMode("dark") }

  // New explicit methods for modes
  light() { return this.setMode("light") }
  dark() { return this.setMode("dark") }
  // Back-compat for any old actions
  platinum() { return this.setMode("light") }
  graphite() { return this.setMode("dark") }
  default() { return this.setMode("light") }
  forest() { return this.setMode("dark") }

  system() { return this.setMode("system") }

  toggle() {
    // Route keyboard-driven toggle through the same animation path
    this.animateToggle()
    return true
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
  updateToggleState(mode = null) {
    // Only update if we have toggle targets
    if (!this.hasButtonTarget) return
    
    // Determine current mode if not provided
    let isDark
    if (mode) {
      isDark = mode === 'dark'
    } else {
      const currentName = this.element.getAttribute('data-theme')
      isDark = currentName === this.darkNameValue
    }

    // Update button ARIA state
    this.buttonTarget.setAttribute('aria-pressed', isDark.toString())

    // Position knob without animation for current mode
    if (this.hasIndicatorTarget) {
      try {
        const pad = 2
        const track = this.buttonTarget.clientWidth
        const knob = this.indicatorTarget.offsetWidth
        const travel = Math.max(0, track - pad * 2 - knob)
        const target = isDark ? travel : 0
        const prev = this.indicatorTarget.style.transition
        this.indicatorTarget.style.transition = 'none'
        this.indicatorTarget.style.transform = `translateX(${target}px)`
        // force reflow to apply immediately
        void this.indicatorTarget.offsetWidth
        this.indicatorTarget.style.transition = prev || ''
      } catch {}
    }
  }

  // Animate first, then apply mode so theme changes after the motion
  animateToggle() {
    const current = this.getCurrentMode()
    const targetMode = current === 'dark' ? 'light' : 'dark'
    // Update visual pressed state immediately for a11y
    const targetIsDark = targetMode === 'dark'
    this.buttonTarget.setAttribute('aria-pressed', targetIsDark.toString())

    if (!this.hasIndicatorTarget) return this.setMode(targetMode)

    try {
      // Measure travel
      const pad = 2
      const track = this.buttonTarget.clientWidth
      const knob = this.indicatorTarget.offsetWidth
      const travel = Math.max(0, track - pad * 2 - knob)
      const startX = current === 'dark' ? travel : 0
      const endX = targetIsDark ? travel : 0
      // set starting position explicitly to avoid jumps
      const prev = this.indicatorTarget.style.transition
      this.indicatorTarget.style.transition = 'none'
      this.indicatorTarget.style.transform = `translateX(${startX}px)`
      void this.indicatorTarget.offsetWidth
      this.indicatorTarget.style.transition = prev || ''

      // Set transition and animate (slower start, quicker finish)
      this.indicatorTarget.style.transition = 'transform 320ms cubic-bezier(0.6, 0, 1, 1)'
      this.indicatorTarget.style.transform = `translateX(${endX}px)`

      // On complete, apply the mode (updates data-theme and persists)
      const onDone = (ev) => {
        if (ev.propertyName !== 'transform') return
        this.indicatorTarget.removeEventListener('transitionend', onDone)
        this.setMode(targetMode)
      }
      this.indicatorTarget.addEventListener('transitionend', onDone)
    } catch {
      // Fallback: just set the mode
      this.setMode(targetMode)
    }
  }
}
