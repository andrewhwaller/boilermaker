import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "prompt", "status"]

  connect() {
    this.history = []
    this.historyIndex = -1
    this.mode = "normal"
  }

  handleGlobalKeydown(event) {
    // Focus on "/" key press when not in an input
    if (event.key === "/" && !this.isInInput(event.target)) {
      event.preventDefault()
      this.inputTarget.focus()
      this.setMode("search")
    }

    // Escape clears and blurs
    if (event.key === "Escape" && document.activeElement === this.inputTarget) {
      this.clear()
      this.inputTarget.blur()
    }
  }

  handleKeydown(event) {
    switch (event.key) {
      case "Enter":
        this.execute()
        break
      case "ArrowUp":
        event.preventDefault()
        this.navigateHistory(-1)
        break
      case "ArrowDown":
        event.preventDefault()
        this.navigateHistory(1)
        break
      case "Escape":
        this.clear()
        this.inputTarget.blur()
        break
    }
  }

  handleInput() {
    const value = this.inputTarget.value

    if (value.startsWith(":")) {
      this.setMode("command")
    } else if (value.startsWith("/")) {
      this.setMode("search")
    } else if (value.length === 0) {
      this.setMode("normal")
    }
  }

  execute() {
    const value = this.inputTarget.value.trim()
    if (!value) return

    // Add to history
    this.history.push(value)
    this.historyIndex = this.history.length

    if (value.startsWith(":")) {
      this.executeCommand(value.substring(1))
    } else if (value.startsWith("/")) {
      this.executeSearch(value.substring(1))
    } else {
      this.executeSearch(value)
    }

    this.clear()
  }

  executeCommand(cmd) {
    const command = cmd.toLowerCase().trim()
    const args = command.split(/\s+/)
    const action = args[0]

    switch (action) {
      case "help":
      case "h":
        this.showHelp()
        break
      case "settings":
      case "set":
        window.Turbo.visit("/settings")
        break
      case "logout":
      case "quit":
      case "q":
        this.logout()
        break
      case "home":
        window.Turbo.visit("/")
        break
      case "theme":
        if (args[1]) {
          this.setThemePolarity(args[1])
        }
        break
      default:
        this.showError(`Unknown command: ${action}`)
    }
  }

  executeSearch(query) {
    if (!query) return

    // Dispatch custom event for search
    const event = new CustomEvent("command-bar:search", {
      detail: { query },
      bubbles: true
    })
    this.element.dispatchEvent(event)

    // Default: navigate to search page with query
    const searchUrl = `/search?q=${encodeURIComponent(query)}`
    window.Turbo.visit(searchUrl)
  }

  setThemePolarity(polarity) {
    if (polarity === "dark" || polarity === "light") {
      document.documentElement.setAttribute("data-polarity", polarity)
      localStorage.setItem("polarity", polarity)
      document.cookie = `polarity=${polarity};path=/;max-age=31536000;SameSite=Lax`
    }
  }

  showHelp() {
    const helpText = `
Commands:
  :help, :h        Show this help
  :settings, :set  Open settings
  :logout, :q      Log out
  :home            Go to home
  :theme <light|dark>  Switch theme polarity

Search:
  /query           Search for query
  Type and Enter   Quick search
    `.trim()

    console.log(helpText)
    alert(helpText)
  }

  showError(message) {
    console.error(`[CommandBar] ${message}`)
  }

  logout() {
    const logoutLink = document.querySelector('a[href*="session"][data-turbo-method="delete"]')
    if (logoutLink) {
      logoutLink.click()
    } else {
      window.location.href = "/session"
    }
  }

  navigateHistory(direction) {
    const newIndex = this.historyIndex + direction

    if (newIndex >= 0 && newIndex < this.history.length) {
      this.historyIndex = newIndex
      this.inputTarget.value = this.history[newIndex]
      this.handleInput()
    } else if (newIndex >= this.history.length) {
      this.historyIndex = this.history.length
      this.inputTarget.value = ""
      this.setMode("normal")
    }
  }

  setMode(mode) {
    this.mode = mode

    switch (mode) {
      case "command":
        this.promptTarget.textContent = ":"
        this.promptTarget.classList.add("text-accent")
        break
      case "search":
        this.promptTarget.textContent = "/"
        this.promptTarget.classList.add("text-accent")
        break
      default:
        this.promptTarget.textContent = ">"
        this.promptTarget.classList.remove("text-accent")
    }
  }

  clear() {
    this.inputTarget.value = ""
    this.setMode("normal")
    this.historyIndex = this.history.length
  }

  isInInput(element) {
    const tagName = element.tagName.toLowerCase()
    return tagName === "input" || tagName === "textarea" || element.isContentEditable
  }
}
