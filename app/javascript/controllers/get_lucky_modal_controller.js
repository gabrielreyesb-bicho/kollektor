import { Controller } from "@hotwired/stimulus"

// Modal de sugerencias "Get Lucky".
//
// Este modal NO se abre solo. Antes se guardaba su contenido en sessionStorage
// para reabrirlo tras una recarga, pero eso podía dejar la app inutilizable: si
// el modal se restauraba y algo fallaba después, no había forma de salir — la
// única navegación visible queda tapada por el overlay. Un modal que se abre
// solo tiene que poder cerrarse siempre, y no vale la pena arriesgar la app
// entera por conservar cuatro sugerencias entre recargas.
export default class extends Controller {
  static targets = ["modal", "frame", "suggestions", "emptyMessage"]

  connect() {
    this.onKeydown = this.closeOnEscape.bind(this)
    document.addEventListener("keydown", this.onKeydown)

    // Borrar o descartar un álbum llega por Turbo Stream, que no dispara
    // turbo:frame-load; sin esto el mensaje de "no quedan sugerencias" nunca
    // aparecería.
    this.onStreamRender = () => requestAnimationFrame(() => this.updateEmptyState())
    document.addEventListener("turbo:before-stream-render", this.onStreamRender)

    // Restos de la versión anterior: si quedó estado guardado de una sesión
    // previa, tirarlo para que nadie herede un modal atascado.
    this.clearLegacyState()
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeydown)
    document.removeEventListener("turbo:before-stream-render", this.onStreamRender)
    document.body.style.overflow = ""
  }

  open() {
    // Reset del src para forzar una tirada nueva en cada apertura
    this.frameTarget.src = this.frameTarget.dataset.src
    this.modalTarget.classList.add("show")
    document.body.style.overflow = "hidden"
  }

  close() {
    this.modalTarget.classList.remove("show")
    document.body.style.overflow = ""
    this.frameTarget.src = ""
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape" && this.modalTarget.classList.contains("show")) {
      this.close()
    }
  }

  stopPropagation(event) {
    event.stopPropagation()
  }

  // Quitar todas las sugerencias dejaría el modal en blanco
  updateEmptyState() {
    if (!this.hasEmptyMessageTarget || !this.hasSuggestionsTarget) return

    const empty = this.suggestionsTarget.querySelectorAll(".lucky-suggestion").length === 0
    this.emptyMessageTarget.classList.toggle("d-none", !empty)
  }

  clearLegacyState() {
    try {
      sessionStorage.removeItem("getLuckyModalOpen")
    } catch (e) {
      // sessionStorage puede no existir (modo privado); da igual
    }
  }
}
