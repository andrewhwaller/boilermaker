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

      // Update button text
      const textSpan = toggle.querySelector("span")
      if (textSpan) {
        textSpan.textContent = isDark ? "NEGATIVE" : "POSITIVE"
      }

      // Update button state classes
      if (isDark) {
        // Pressed state - dark/negative polarity
        toggle.classList.remove("border-base-content/20", "bg-base-100")
        toggle.classList.add("border-base-content/30", "bg-base-300")

        // Update text glow
        if (textSpan) {
          textSpan.className = "text-base-content/80 drop-shadow-[0_0_2px_rgba(255,255,255,0.3)] tracking-wider"
        }
      } else {
        // Raised state - light/positive polarity
        toggle.classList.remove("border-base-content/30", "bg-base-300")
        toggle.classList.add("border-base-content/20", "bg-base-100")

        // Update text glow
        if (textSpan) {
          textSpan.className = "text-base-content drop-shadow-[0_0_3px_rgba(0,0,0,0.2)] tracking-wider"
        }
      }
    })
  }
}