import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["marker"]

  scrollTo(event) {
    event.preventDefault()

    const href = event.currentTarget.getAttribute("href")
    if (!href) return

    const targetId = href.substring(1)
    const target = document.getElementById(targetId)

    if (target) {
      target.scrollIntoView({
        behavior: "smooth",
        block: "start"
      })

      // Update URL hash without scrolling
      history.pushState(null, "", href)
    }
  }
}
