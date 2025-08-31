import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme-toggle"
export default class extends Controller {
  static targets = ["button", "indicator", "sunIcon", "moonIcon"]
  
  connect() {
    this.updateToggleState()
    this.setupThemeChangeListener()
  }

  disconnect() {
    // Clean up event listeners
    document.removeEventListener("theme:change", this.boundThemeChangeHandler)
  }

  toggle() {
    console.log('ThemeToggle: Toggle clicked')
    const themeController = this.getThemeController()
    console.log('ThemeToggle: Theme controller found:', !!themeController)
    
    if (themeController) {
      console.log('ThemeToggle: Calling toggleTheme()')
      const result = themeController.toggleTheme()
      console.log('ThemeToggle: Toggle result:', result)
    } else {
      console.error('ThemeToggle: No theme controller available')
    }
  }

  handleKeyboard(event) {
    // Check for Cmd/Ctrl + Shift + L
    if ((event.metaKey || event.ctrlKey) && event.shiftKey && event.key === 'L') {
      event.preventDefault()
      this.toggle()
    }
  }

  setupThemeChangeListener() {
    this.boundThemeChangeHandler = this.handleThemeChange.bind(this)
    document.addEventListener("theme:change", this.boundThemeChangeHandler)
  }

  handleThemeChange(event) {
    this.updateToggleState()
  }

  updateToggleState() {
    const themeController = this.getThemeController()
    if (!themeController) return

    const currentTheme = themeController.getCurrentTheme()
    const isDark = currentTheme === 'dark'

    // Update button ARIA state
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute('aria-pressed', isDark.toString())
    }

    // Update indicator position
    if (this.hasIndicatorTarget) {
      if (isDark) {
        this.indicatorTarget.classList.add('translate-x-7')
      } else {
        this.indicatorTarget.classList.remove('translate-x-7')
      }
    }

    // Update icon visibility
    if (this.hasSunIconTarget && this.hasMoonIconTarget) {
      if (isDark) {
        this.sunIconTarget.classList.remove('opacity-100')
        this.sunIconTarget.classList.add('opacity-0')
        this.moonIconTarget.classList.remove('opacity-0') 
        this.moonIconTarget.classList.add('opacity-100')
      } else {
        this.sunIconTarget.classList.remove('opacity-0')
        this.sunIconTarget.classList.add('opacity-100')
        this.moonIconTarget.classList.remove('opacity-100')
        this.moonIconTarget.classList.add('opacity-0')
      }
    }
  }

  getThemeController() {
    // Look for the theme controller on the html element
    const themeElement = document.querySelector('html[data-controller*="theme"]')
    if (!themeElement) {
      console.warn('ThemeToggle: No theme controller found on html element')
      return null
    }

    // Get the theme controller instance
    const controllers = this.application.controllers.filter(controller => 
      controller.identifier === 'theme' && controller.element === themeElement
    )
    
    if (controllers.length === 0) {
      console.warn('ThemeToggle: Theme controller not initialized')
      return null
    }

    return controllers[0]
  }
}