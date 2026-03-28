import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea"]
  static values = { newConversationUrl: String }

  connect() {
    this.handleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.handleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
  }

  handleKeydown(event) {
    if ((event.metaKey || event.ctrlKey) && event.key === "k") {
      event.preventDefault()
      if (this.newConversationUrlValue) {
        window.location.href = this.newConversationUrlValue
      }
      return
    }
  }

  textareaKeydown(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.element.requestSubmit()
    }
  }
}
