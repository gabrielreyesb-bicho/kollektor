import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay"]
  
  connect() {
    this.handleKeydown = this.handleKeydown.bind(this)
  }
  
  toggle() {
    this.overlayTarget.classList.toggle("show")
    // Prevent body scroll when menu is open
    if (this.overlayTarget.classList.contains("show")) {
      document.body.style.overflow = "hidden"
      document.addEventListener("keydown", this.handleKeydown)
    } else {
      document.body.style.overflow = ""
      document.removeEventListener("keydown", this.handleKeydown)
    }
  }
  
  close() {
    this.overlayTarget.classList.remove("show")
    document.body.style.overflow = ""
    document.removeEventListener("keydown", this.handleKeydown)
  }
  
  stopPropagation(event) {
    event.stopPropagation()
  }
  
  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
  
  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
    document.body.style.overflow = ""
  }
}
