import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme-toggle"
export default class extends Controller {
  static targets = ["button", "indicator", "sunIcon", "moonIcon"]
  
  connect() {
    this.updateToggleState()
    this.setupThemeChangeListener()
  }

  disconnect() {
    if (this.boundThemeChangeHandler) {
      document.removeEventListener("theme:change", this.boundThemeChangeHandler)
    }
  }

  toggle() {
    // Dispatch action to theme controller using Stimulus event system
    this.dispatch("toggle", { prefix: "theme" })
  }

  handleKeyboard(event) {
    // Check for Cmd/Ctrl + Shift + L
    if ((event.metaKey || event.ctrlKey) && event.shiftKey && event.key === 'L') {
      event.preventDefault()
      this.toggle()
    }
  }

  setupThemeChangeListener() {
    this.boundThemeChangeHandler = this.handleThemeChange.bind(this)
    document.addEventListener("theme:change", this.boundThemeChangeHandler)
  }

  handleThemeChange(event) {
    this.updateToggleState(event.detail.theme)
  }

  updateToggleState(theme = null) {
    // Determine current theme from DOM if not provided
    const currentTheme = theme || (document.documentElement.classList.contains('dark') ? 'dark' : 'light')
    const isDark = currentTheme === 'dark'

    // Update button ARIA state
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute('aria-pressed', isDark.toString())
    }

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