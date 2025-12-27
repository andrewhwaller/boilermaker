import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  handleKeydown(event) {
    // Only handle F-keys
    if (!event.key.startsWith("F")) return

    const keyNumber = parseInt(event.key.substring(1), 10)
    if (isNaN(keyNumber)) return

    // Prevent default browser behavior for these F-keys
    const handledKeys = [1, 2, 3, 5, 10]
    if (handledKeys.includes(keyNumber)) {
      event.preventDefault()
      this.executeAction(this.getActionForKey(keyNumber))
    }
  }

  execute(event) {
    const action = event.params.action
    if (action) {
      this.executeAction(action)
    }
  }

  getActionForKey(keyNumber) {
    const keyMap = {
      1: "help",
      2: "new",
      3: "edit",
      5: "refresh",
      10: "logout"
    }
    return keyMap[keyNumber]
  }

  executeAction(action) {
    switch (action) {
      case "help":
        this.showHelp()
        break
      case "new":
        this.triggerNew()
        break
      case "edit":
        this.triggerEdit()
        break
      case "refresh":
        this.refresh()
        break
      case "logout":
        this.logout()
        break
    }
  }

  showHelp() {
    const helpText = `
Function Keys:
  F1  - Show this help
  F2  - Create new item (context-dependent)
  F3  - Edit current item (if applicable)
  F5  - Refresh page
  F10 - Log out
    `.trim()

    alert(helpText)
  }

  triggerNew() {
    // Look for a "new" or "create" link on the page
    const newLink = document.querySelector('a[href*="/new"]')
    if (newLink) {
      newLink.click()
    } else {
      // Dispatch custom event for pages to handle
      this.dispatch("new", { bubbles: true })
    }
  }

  triggerEdit() {
    // Look for an "edit" link on the page
    const editLink = document.querySelector('a[href*="/edit"]')
    if (editLink) {
      editLink.click()
    } else {
      // Dispatch custom event for pages to handle
      this.dispatch("edit", { bubbles: true })
    }
  }

  refresh() {
    // Use Turbo to refresh the page
    if (window.Turbo) {
      window.Turbo.visit(window.location.href, { action: "replace" })
    } else {
      window.location.reload()
    }
  }

  logout() {
    const logoutLink = document.querySelector('a[href*="session"][data-turbo-method="delete"]')
    if (logoutLink) {
      logoutLink.click()
    } else {
      // Fallback: navigate to session destroy
      window.location.href = "/session"
    }
  }
}
