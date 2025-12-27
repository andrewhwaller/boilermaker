import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    keys: String,
    action: String
  }

  connect() {
    this.boundHandler = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundHandler)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandler)
  }

  handleKeydown(event) {
    if (this.matchesKeys(event)) {
      event.preventDefault()
      this.executeAction()
    }
  }

  matchesKeys(event) {
    const requiredKeys = this.keysValue.toLowerCase().split("+")
    const pressedKeys = []

    if (event.metaKey) pressedKeys.push("meta", "cmd", "command")
    if (event.ctrlKey) pressedKeys.push("ctrl", "control")
    if (event.altKey) pressedKeys.push("alt", "option")
    if (event.shiftKey) pressedKeys.push("shift")

    const keyName = event.key.toLowerCase()
    pressedKeys.push(keyName)

    // Check if all required keys are pressed
    return requiredKeys.every(key => pressedKeys.includes(key))
  }

  executeAction() {
    const action = this.actionValue

    // Try to find a matching element to click
    const element = document.querySelector(`[data-keyboard-action="${action}"]`)
    if (element) {
      element.click()
      return
    }

    // Dispatch custom event
    const customEvent = new CustomEvent("keyboard-hint:execute", {
      detail: { action },
      bubbles: true
    })
    this.element.dispatchEvent(customEvent)
  }
}
