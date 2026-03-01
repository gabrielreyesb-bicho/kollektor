import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "recommendationsContainer", "refreshButtonContainer"]

  connect() {
    this.modalTarget.addEventListener('show.bs.modal', () => {
      this.fetchRecommendations()
    })
  }

  async refreshSuggestions() {
    await this.fetchRecommendations()
  }

  async fetchRecommendations() {
    try {
      this.recommendationsContainerTarget.innerHTML = '<div class="text-center"><div class="spinner-border text-primary" role="status"></div><p class="mt-2">Finding great music for you...</p></div>'
      this.refreshButtonContainerTarget.style.display = 'none'

      const response = await fetch('/api/recommendations/by_genre/random')
      
      if (!response.ok) {
        throw new Error('Network response was not ok')
      }
      
      const html = await response.text()
      this.recommendationsContainerTarget.innerHTML = html
      this.refreshButtonContainerTarget.style.display = 'block'
    } catch (error) {
      this.recommendationsContainerTarget.innerHTML = `
        <div class="alert alert-danger">
          Error loading recommendations. Please try again.
          <br>
          <small class="text-muted">${error.message}</small>
        </div>
      `
      this.refreshButtonContainerTarget.style.display = 'block'
    }
  }
} 