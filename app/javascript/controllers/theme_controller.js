import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme"
export default class extends Controller {
  static targets = ["button", "indicator"]
  static values = {
    storageKey: { type: String, default: "theme-preference" },
    lightName: { type: String, default: "platinum" },
    darkName: { type: String, default: "graphite" }
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
    // If server-rendered markup already has a theme, respect it to avoid FOUC
    const currentAttr = this.element.getAttribute('data-theme')
    if (currentAttr) {
      // Sync toggle UI state without re-applying theme
      this.updateToggleState()
      return
    }
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
      if (["default", "platinum"].includes(v)) return "light"
      if (["forest", "graphite"].includes(v)) return "dark"
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
    this.element.classList.add('theme-transition')
    // Set DaisyUI data-theme attribute on the element this controller is attached to
    if (mode === "dark" || mode === "light") {
      const themeName = mode === "dark" ? this.darkNameValue : this.lightNameValue
      this.element.setAttribute("data-theme", themeName)
      this.setThemeCookie(themeName)
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
    clearTimeout(this._transitionTimeout)
    this._transitionTimeout = setTimeout(() => {
      this.element.classList.remove('theme-transition')
    }, 300)
  }

  // Persist chosen theme name so the server can render it on next request
  setThemeCookie(name) {
    try {
      const value = encodeURIComponent(name)
      document.cookie = `theme_name=${value}; path=/; max-age=31536000; samesite=lax`
    } catch { }
  }

  // Cookie handling removed: server sets initial data-theme from cookie

  // Helpers
  prefersReducedMotion() {
    return !!(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches)
  }

  computeTravel() {
    const pad = 2 // px, matches px-[2px]
    const track = this.buttonTarget?.clientWidth || 0
    const knob = this.indicatorTarget?.offsetWidth || 0
    return Math.max(0, track - pad * 2 - knob)
  }

  setKnobPosition(x, immediate = false) {
    if (!this.hasIndicatorTarget) return
    if (immediate) {
      const prev = this.indicatorTarget.style.transition
      this.indicatorTarget.style.transition = 'none'
      this.indicatorTarget.style.transform = `translateX(${x}px)`
      void this.indicatorTarget.offsetWidth
      this.indicatorTarget.style.transition = prev || ''
    } else {
      this.indicatorTarget.style.transform = `translateX(${x}px)`
    }
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

  // --

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
  light() { return this.setMode("light") }
  dark() { return this.setMode("dark") }

  system() { return this.setMode("system") }

  toggle() {
    // Route keyboard-driven toggle through the same animation path
    this.animateToggle()
    return true
  }

  // --

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
    const travel = this.computeTravel()
    const target = isDark ? travel : 0
    this.setKnobPosition(target, true)
  }

  // Animate first, then apply mode so theme changes after the motion
  animateToggle() {
    if (this._animating) return false
    const current = this.getCurrentMode()
    const targetMode = current === 'dark' ? 'light' : 'dark'
    // Update visual pressed state immediately for a11y
    const targetIsDark = targetMode === 'dark'
    this.buttonTarget.setAttribute('aria-pressed', targetIsDark.toString())

    if (!this.hasIndicatorTarget) return this.setMode(targetMode)

    // Respect reduced motion: skip animation
    if (this.prefersReducedMotion()) return this.setMode(targetMode)

    this._animating = true
    // Measure travel
    const travel = this.computeTravel()
    const startX = current === 'dark' ? travel : 0
    const endX = targetIsDark ? travel : 0

    // If no movement is needed, apply immediately
    if (startX === endX) {
      this._animating = false
      return this.setMode(targetMode)
    }

    // set starting position explicitly to avoid jumps
    this.setKnobPosition(startX, true)

    // Set transition and animate (slower start, quicker finish)
    this.indicatorTarget.style.transition = 'transform 320ms cubic-bezier(0.6, 0, 1, 1)'
    this.setKnobPosition(endX)

    // On complete, apply the mode (updates data-theme and persists)
    const onDone = (ev) => {
      if (ev.propertyName !== 'transform') return
      this._animating = false
      this.setMode(targetMode)
    }
    this.indicatorTarget.addEventListener('transitionend', onDone, { once: true })
  }
}
