import { Controller } from "@hotwired/stimulus"
import { marked } from "marked"
import DOMPurify from "dompurify"

export default class extends Controller {
  static targets = ["output"]
  static values = { raw: String }

  connect() {
    this.renderMarkdown()
    this.observer = new MutationObserver(() => this.renderMarkdown())
    this.observer.observe(this.element, { attributes: true, attributeFilter: ["data-markdown-raw-value"] })
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  rawValueChanged() {
    this.renderMarkdown()
  }

  renderMarkdown() {
    if (!this.hasOutputTarget || !this.rawValue) return

    const raw = this.rawValue
    const parsed = marked.parse(raw)
    const sanitized = DOMPurify.sanitize(parsed, {
      FORBID_TAGS: ["script", "iframe", "object", "embed"],
      FORBID_ATTR: ["onerror", "onload", "onclick", "onmouseover"]
    })
    this.outputTarget.innerHTML = sanitized
  }
}
