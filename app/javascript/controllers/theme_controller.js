import { Controller } from "@hotwired/stimulus"

// Minimal, no-flash theme controller
export default class extends Controller {
  static targets = ["button", "indicator"]
  static values = {
    storageKey: { type: String, default: "theme-preference" },
    lightName: { type: String, default: "work-station" },
    darkName:  { type: String, default: "command-center" }
  }

  connect() {
    this.applyStoredPreference()
    this.syncAria()
    this.syncIndicators()
  }

  // Actions
  toggle() { this.set(this.isDarkActive() ? "light" : "dark") }
  light()  { this.set("light") }
  dark()   { this.set("dark") }

  // Core
  set(mode) {
    if (!["light", "dark"].includes(mode)) return
    try { localStorage.setItem(this.storageKeyValue, mode) } catch {}
    const name = mode === "dark" ? this.darkNameValue : this.lightNameValue
    document.documentElement.setAttribute("data-theme", name)
    try { document.cookie = `theme_name=${encodeURIComponent(name)}; path=/; max-age=31536000; samesite=lax` } catch {}
    this.syncAria()
    this.syncIndicators()
  }

  applyStoredPreference() {
    try {
      const v = localStorage.getItem(this.storageKeyValue)
      if (v === "dark" || v === "light") this.set(v)
    } catch {}
  }

  syncAria() {
    const pressed = this.isDarkActive() ? "true" : "false"
    const btns = this.buttonTargets || []
    btns.forEach(btn => btn.setAttribute("aria-pressed", pressed))
  }

  syncIndicators() {
    const isDark = this.isDarkActive()
    const indicators = this.indicatorTargets || []
    indicators.forEach(el => {
      const cs = getComputedStyle(el)
      const raw = cs.getPropertyValue('--toggle-travel') || '0'
      const px = parseFloat(raw)
      const x = isDark ? (isNaN(px) ? 0 : px) : 0
      el.style.transition = 'transform 320ms cubic-bezier(0.6, 0, 1, 1)'
      el.style.transform = `translateX(${x}px)`
    })
  }

  isDarkActive() {
    const name = document.documentElement.getAttribute("data-theme")
    return name === this.darkNameValue || ["graphite", "forest", "business"].includes(name)
  }
}
