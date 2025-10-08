import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    format: { type: String, default: "%H:%M:%S UTC" },
    interval: { type: Number, default: 1000 }
  }

  connect() {
    this.tick()
    this.timer = setInterval(() => this.tick(), this.intervalValue)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  tick() {
    const now = new Date()
    const options = { hour: "2-digit", minute: "2-digit", second: "2-digit", hour12: false, timeZone: "UTC" }
    const formatted = now.toLocaleTimeString("en-GB", options)
    this.element.textContent = `${formatted} UTC`
  }
}
