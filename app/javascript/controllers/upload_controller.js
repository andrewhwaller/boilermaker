import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

// Stimulus controller for drag-and-drop file uploads with progress
//
// Usage in HTML:
//   data-controller="upload"
//   data-upload-multiple-value="true"
//   data-upload-accept-value="image/*"
//
export default class extends Controller {
  static targets = ["dropzone", "input", "fileList", "progress", "progressBar", "progressText", "progressPercent"]
  static values = { multiple: Boolean, accept: String }

  connect() {
    this.files = []
  }

  // Drag and drop handlers
  dragover(event) {
    event.preventDefault()
    event.stopPropagation()
  }

  dragenter(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dropzoneTarget.dataset.dragging = true
  }

  dragleave(event) {
    event.preventDefault()
    event.stopPropagation()
    delete this.dropzoneTarget.dataset.dragging
  }

  drop(event) {
    event.preventDefault()
    event.stopPropagation()
    delete this.dropzoneTarget.dataset.dragging

    const files = event.dataTransfer.files
    this.handleFiles(files)
  }

  // Click to select files
  click() {
    this.inputTarget.click()
  }

  // File input change handler
  fileSelected(event) {
    const files = event.target.files
    this.handleFiles(files)
  }

  // Process selected files
  handleFiles(fileList) {
    const files = Array.from(fileList)

    // Validate file types if accept is specified
    if (this.acceptValue) {
      const validFiles = files.filter(file => this.isValidType(file))
      if (validFiles.length !== files.length) {
        alert(`Some files were skipped because they don't match: ${this.acceptValue}`)
      }
      this.files = validFiles
    } else {
      this.files = files
    }

    if (this.files.length === 0) return

    this.showFileList()

    // Check if direct upload URL is set
    const directUploadUrl = this.inputTarget.dataset.directUploadUrl
    if (directUploadUrl) {
      this.uploadFiles(directUploadUrl)
    }
  }

  // Check if file type matches accept attribute
  isValidType(file) {
    if (!this.acceptValue) return true

    const accepts = this.acceptValue.split(",").map(t => t.trim())
    return accepts.some(accept => {
      if (accept.startsWith(".")) {
        return file.name.toLowerCase().endsWith(accept.toLowerCase())
      }
      if (accept.endsWith("/*")) {
        const type = accept.replace("/*", "")
        return file.type.startsWith(type)
      }
      return file.type === accept
    })
  }

  // Display selected files
  showFileList() {
    this.fileListTarget.classList.remove("hidden")
    this.fileListTarget.innerHTML = ""

    this.files.forEach((file, index) => {
      const item = document.createElement("div")
      item.className = "flex items-center justify-between p-2 bg-surface-alt rounded text-sm"
      item.innerHTML = `
        <span class="truncate">${file.name}</span>
        <span class="text-muted">${this.formatSize(file.size)}</span>
      `
      this.fileListTarget.appendChild(item)
    })
  }

  // Upload files using ActiveStorage direct upload
  uploadFiles(url) {
    this.showProgress()

    const totalFiles = this.files.length
    let completedFiles = 0
    let totalProgress = 0

    this.files.forEach((file, index) => {
      const upload = new DirectUpload(file, url, {
        directUploadWillStoreFileWithXHR: (request) => {
          request.upload.addEventListener("progress", (event) => {
            if (event.lengthComputable) {
              const fileProgress = (event.loaded / event.total) * 100
              this.updateProgress((completedFiles * 100 + fileProgress) / totalFiles)
            }
          })
        }
      })

      upload.create((error, blob) => {
        completedFiles++

        if (error) {
          console.error("Upload error:", error)
          this.showError(file.name, error)
        } else {
          // Create hidden input with signed blob ID
          this.addHiddenInput(blob)
        }

        if (completedFiles === totalFiles) {
          this.uploadComplete()
        }
      })
    })
  }

  // Add hidden input with blob signed ID
  addHiddenInput(blob) {
    const input = document.createElement("input")
    input.type = "hidden"
    input.name = this.inputTarget.name
    input.value = blob.signed_id
    this.element.appendChild(input)
  }

  // Progress display
  showProgress() {
    if (this.hasProgressTarget) {
      this.progressTarget.classList.remove("hidden")
    }
  }

  updateProgress(percent) {
    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.width = `${percent}%`
    }
    if (this.hasProgressPercentTarget) {
      this.progressPercentTarget.textContent = `${Math.round(percent)}%`
    }
  }

  uploadComplete() {
    if (this.hasProgressTextTarget) {
      this.progressTextTarget.textContent = "Upload complete!"
    }
    if (this.hasProgressBarTarget) {
      this.progressBarTarget.classList.add("bg-success")
    }
  }

  showError(filename, error) {
    const errorDiv = document.createElement("div")
    errorDiv.className = "text-sm text-destructive mt-2"
    errorDiv.textContent = `Failed to upload ${filename}: ${error}`
    this.element.appendChild(errorDiv)
  }

  // Format file size
  formatSize(bytes) {
    if (bytes < 1024) return `${bytes} B`
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
  }
}
