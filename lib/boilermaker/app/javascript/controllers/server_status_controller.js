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
      this.submitButtonTarget.textContent = 'SAVING...'
    }

    if (this.hasMessageTarget) {
      this.messageTarget.textContent = 'SAVING CONFIGURATION AND RESTARTING SERVER...'
    }

    setTimeout(() => {
      this.startRestartMonitoring()
    }, 1000)
  }

  startRestartMonitoring() {
    if (this.hasMessageTarget) {
      this.messageTarget.innerHTML = '<span style="animation: blink 1s step-end infinite">▌</span> SERVER IS RESTARTING... PLEASE WAIT.'
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
        this.messageTarget.innerHTML = '● SERVER RESTARTED SUCCESSFULLY. YOU MAY RETURN TO THE APP.'
        this.messageTarget.style.color = 'var(--text, #33ff33)'

        if (this.hasSubmitButtonTarget) {
          this.submitButtonTarget.disabled = false
          this.submitButtonTarget.textContent = 'SAVE CHANGES'
        }
      } else {
        this.messageTarget.innerHTML = '○ SERVER IS TAKING LONGER THAN EXPECTED. PLEASE REFRESH MANUALLY.'
        this.messageTarget.style.color = 'var(--accent, #ffb000)'

        if (this.hasSubmitButtonTarget) {
          this.submitButtonTarget.disabled = false
          this.submitButtonTarget.textContent = 'SAVE CHANGES'
        }
      }
    }
  }

  disconnect() {
    this.stopMonitoring(false)
  }
}
