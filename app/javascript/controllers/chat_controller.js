import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages", "input", "submit", "form", "typingIndicator"]
  static values = { conversationId: String }

  connect() {
    this.scrollToBottom()
    this.observer = new MutationObserver(() => this.scrollToBottom())
    if (this.hasMessagesTarget) {
      this.observer.observe(this.messagesTarget, { childList: true, subtree: true, characterData: true })
    }
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  scrollToBottom() {
    if (this.hasMessagesTarget) {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    }
  }

  submit(event) {
    if (this.hasInputTarget && this.inputTarget.value.trim() === "") {
      event.preventDefault()
      return
    }
    this.showTypingIndicator()
    this.disableForm()
  }

  showTypingIndicator() {
    if (this.hasTypingIndicatorTarget) {
      this.typingIndicatorTarget.classList.remove("hidden")
    }
  }

  hideTypingIndicator() {
    if (this.hasTypingIndicatorTarget) {
      this.typingIndicatorTarget.classList.add("hidden")
    }
  }

  disableForm() {
    if (this.hasInputTarget) {
      this.inputTarget.disabled = true
    }
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = true
    }
  }
}
