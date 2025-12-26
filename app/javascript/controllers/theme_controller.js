import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle"]

  connect() {
    this.syncTheme()
  }

  toggle() {
    const isDark = document.documentElement.getAttribute("data-theme") === "dark"
    const newTheme = isDark ? "light" : "dark"

    document.documentElement.setAttribute("data-theme", newTheme)
    localStorage.setItem("theme", newTheme)

    this.syncToggleState()
  }

  syncTheme() {
    const theme = localStorage.getItem("theme")
    if (theme) {
      document.documentElement.setAttribute("data-theme", theme)
    } else {
      // If no theme is set, use the browser preference
      if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
        document.documentElement.setAttribute("data-theme", "dark")
      } else {
        document.documentElement.setAttribute("data-theme", "light")
      }
    }
    this.syncToggleState()
  }

  syncToggleState() {
    const isDark = document.documentElement.getAttribute("data-theme") === "dark"

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