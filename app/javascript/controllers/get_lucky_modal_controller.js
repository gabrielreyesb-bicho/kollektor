import { Controller } from "@hotwired/stimulus"

// Persists the Get Lucky suggestions modal across page reloads (e.g. when the
// user switches to another app on mobile and comes back, the browser may reload
// the page). The exact suggestions and the open state are kept in sessionStorage
// so the same albums reappear, and the modal only closes when the user taps the X.
const STORAGE_KEY = "getLuckyModalOpen"

export default class extends Controller {
  static targets = ["modal", "frame"]

  connect() {
    // Save the rendered suggestions once the frame finishes loading while open
    this.onFrameLoad = this.saveIfOpen.bind(this)
    this.frameTarget.addEventListener("turbo:frame-load", this.onFrameLoad)

    // Reopen the modal if it was open before a reload
    this.restore()
  }

  disconnect() {
    this.frameTarget.removeEventListener("turbo:frame-load", this.onFrameLoad)
  }

  open() {
    // Reset the frame src to force a fresh load each time
    this.frameTarget.src = this.frameTarget.dataset.src
    this.show()
    // State is saved on turbo:frame-load once the suggestions arrive
  }

  close() {
    this.modalTarget.classList.remove("show")
    document.body.style.overflow = ""
    // Clear the frame so next open fetches fresh results
    this.frameTarget.src = ""
    this.clearState()
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  stopPropagation(event) {
    event.stopPropagation()
  }

  // --- persistence helpers ---

  show() {
    this.modalTarget.classList.add("show")
    document.body.style.overflow = "hidden"
  }

  saveIfOpen() {
    if (!this.modalTarget.classList.contains("show")) return
    try {
      sessionStorage.setItem(STORAGE_KEY, this.frameTarget.innerHTML)
    } catch (e) {
      // sessionStorage may be unavailable (private mode); persistence is best-effort
    }
  }

  restore() {
    let html
    try {
      html = sessionStorage.getItem(STORAGE_KEY)
    } catch (e) {
      return
    }
    if (!html) return

    // Inject the saved suggestions without re-fetching (keeps the same albums)
    this.frameTarget.innerHTML = html
    this.show()
  }

  clearState() {
    try {
      sessionStorage.removeItem(STORAGE_KEY)
    } catch (e) {
      // ignore
    }
  }
}
