import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle"]
  static values = {
    lightName: { type: String, default: "work-station" },
    darkName: { type: String, default: "command-center" }
  }

  toggleTargetConnected() {
    this.syncToggleState()
  }

  toggle() {
    const currentTheme = document.documentElement.getAttribute("data-theme")
    const isDark = currentTheme === this.darkNameValue
    const newTheme = isDark ? this.lightNameValue : this.darkNameValue
    const newMode = isDark ? "light" : "dark"

    document.documentElement.setAttribute("data-theme", newTheme)
    localStorage.setItem("theme-preference", newMode)
    document.cookie = `theme_name=${encodeURIComponent(newTheme)}; path=/; max-age=31536000; samesite=lax`

    this.syncToggleState()
  }

  syncToggleState() {
    const currentTheme = document.documentElement.getAttribute("data-theme")
    const isDark = currentTheme === this.darkNameValue

    this.toggleTargets.forEach(toggle => {
      toggle.setAttribute("aria-pressed", isDark ? "true" : "false")
      toggle.dataset.dark = isDark

      const textSpan = toggle.querySelector("span")
      if (textSpan) {
        textSpan.textContent = isDark ? "NEGATIVE" : "POSITIVE"
      }
    })
  }
}