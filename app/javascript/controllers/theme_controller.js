import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle"]
  static values = {
    lightName: { type: String, default: "work-station" },
    darkName: { type: String, default: "command-center" }
  }

  connect() {
    this.syncToggleState()
  }

  toggle() {
    const currentTheme = document.documentElement.getAttribute("data-theme")
    const isDark = currentTheme === this.darkNameValue
    const newTheme = isDark ? this.lightNameValue : this.darkNameValue
    const newMode = isDark ? "light" : "dark"

    // Update DOM
    document.documentElement.setAttribute("data-theme", newTheme)

    // Update storage
    try {
      localStorage.setItem("theme-preference", newMode)
    } catch {}

    // Update cookie
    try {
      document.cookie = `theme_name=${encodeURIComponent(newTheme)}; path=/; max-age=31536000; samesite=lax`
    } catch {}

    // Update UI
    this.syncToggleState()
  }

  syncToggleState() {
    const currentTheme = document.documentElement.getAttribute("data-theme")
    const isDark = currentTheme === this.darkNameValue

    this.toggleTargets.forEach(toggle => {
      toggle.setAttribute("aria-pressed", isDark ? "true" : "false")
      toggle.classList.toggle("theme-toggle-dark", isDark)
    })
  }
}