import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle"]
  static values = {
    defaultPolarity: { type: String, default: "light" }
  }

  connect() {
    this.syncPolarity()
  }

  toggle() {
    const currentPolarity = document.documentElement.getAttribute("data-polarity") || this.defaultPolarityValue
    const newPolarity = currentPolarity === "dark" ? "light" : "dark"

    this.setPolarity(newPolarity)
  }

  setPolarity(polarity) {
    document.documentElement.setAttribute("data-polarity", polarity)
    localStorage.setItem("polarity", polarity)
    document.cookie = `polarity=${polarity};path=/;max-age=31536000;SameSite=Lax`

    this.syncToggleState()
  }

  syncPolarity() {
    const storedPolarity = localStorage.getItem("polarity")

    if (storedPolarity) {
      document.documentElement.setAttribute("data-polarity", storedPolarity)
    } else {
      const prefersDark = window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches
      const polarity = prefersDark ? "dark" : this.defaultPolarityValue
      document.documentElement.setAttribute("data-polarity", polarity)
    }

    this.syncToggleState()
  }

  syncToggleState() {
    const isDark = document.documentElement.getAttribute("data-polarity") === "dark"

    this.toggleTargets.forEach(toggle => {
      toggle.setAttribute("aria-pressed", isDark ? "true" : "false")
      toggle.dataset.dark = isDark

      const textSpan = toggle.querySelector("span")
      if (textSpan) {
        textSpan.textContent = isDark ? "DARK" : "LIGHT"
      }
    })
  }
}
