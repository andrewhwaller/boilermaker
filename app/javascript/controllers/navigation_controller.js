import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mobileMenu"]

  toggleMobileMenu() {
    this.mobileMenuTarget.classList.toggle("hidden")
  }
}