import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submitButton", "message"]
  static values = {
    restartUrl: String
  }

  connect() {
    const form = document.getElementById('settings_form')
    if (form) {
      form.addEventListener('submit', this.handleSubmit.bind(this))
    }
  }

  handleSubmit(event) {
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.textContent = 'Saving...'
    }

    if (this.hasMessageTarget) {
      this.messageTarget.textContent = 'Saving configuration and restarting server...'
    }

    setTimeout(() => {
      this.startRestartMonitoring()
    }, 1000)
  }

  startRestartMonitoring() {
    if (this.hasMessageTarget) {
      this.messageTarget.innerHTML = '<span class="inline-flex items-center gap-2"><span class="loading loading-spinner loading-xs"></span> Server is restarting... Please wait.</span>'
    }

    this.pollInterval = setInterval(() => {
      this.checkServerHealth()
    }, 2000)

    this.pollTimeout = setTimeout(() => {
      this.stopMonitoring(false)
    }, 30000)
  }

  async checkServerHealth() {
    try {
      const response = await fetch(this.restartUrlValue, {
        method: 'GET',
        cache: 'no-cache'
      })

      if (response.ok) {
        this.stopMonitoring(true)
      }
    } catch (error) {
      // Server is still restarting
    }
  }

  stopMonitoring(success) {
    if (this.pollInterval) {
      clearInterval(this.pollInterval)
      this.pollInterval = null
    }

    if (this.pollTimeout) {
      clearTimeout(this.pollTimeout)
      this.pollTimeout = null
    }

    if (this.hasMessageTarget) {
      if (success) {
        this.messageTarget.innerHTML = '<span class="text-success font-medium">✓ Server restarted successfully! You can now return to the app.</span>'

        if (this.hasSubmitButtonTarget) {
          this.submitButtonTarget.disabled = false
          this.submitButtonTarget.textContent = 'Save Changes'
        }
      } else {
        this.messageTarget.innerHTML = '<span class="text-warning">Server is taking longer than expected to restart. Please refresh the page manually.</span>'

        if (this.hasSubmitButtonTarget) {
          this.submitButtonTarget.disabled = false
          this.submitButtonTarget.textContent = 'Save Changes'
        }
      }
    }
  }

  disconnect() {
    this.stopMonitoring(false)
  }
}
