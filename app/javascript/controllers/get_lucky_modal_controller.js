import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "frame"]

  open() {
    // Reset the frame src to force a fresh load each time
    this.frameTarget.src = this.frameTarget.dataset.src
    this.modalTarget.classList.add("show")
    document.body.style.overflow = "hidden"
  }

  close() {
    this.modalTarget.classList.remove("show")
    document.body.style.overflow = ""
    // Clear the frame so next open fetches fresh results
    this.frameTarget.src = ""
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  stopPropagation(event) {
    event.stopPropagation()
  }
}
