import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  showImage(event) {
    const input = event.target
    // Look for preview element nearby or fallback to coverPreview/imagePreview
    let preview = input.closest('form').querySelector('#coverPreview') || 
                  input.closest('form').querySelector('#imagePreview')
    
    if (!preview) {
      // Fallback to any img tag in the same container
      preview = input.closest('.col-md-4, .mb-4')?.querySelector('img')
    }
    
    if (!preview) return
    
    if (input.files && input.files[0]) {
      const reader = new FileReader()
      
      reader.onload = function(e) {
        preview.src = e.target.result
        preview.style.display = 'block'
      }
      
      reader.readAsDataURL(input.files[0])
    } else {
      preview.src = ''
      preview.style.display = 'none'
    }
  }
} 