# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "auth_fetch", to: "auth_fetch.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "tom-select", to: "https://ga.jspm.io/npm:tom-select@2.3.1/dist/js/tom-select.complete.js"

# Explicitly pin your controllers
pin "controllers/application", to: "controllers/application.js"
pin "controllers/alert_controller", to: "controllers/alert_controller.js"
pin "controllers/filter_controller", to: "controllers/filter_controller.js"
pin "controllers/sidebar_controller", to: "controllers/sidebar_controller.js"
pin "controllers/display_controller", to: "controllers/display_controller.js"
pin "controllers/genre_filter_controller", to: "controllers/genre_filter_controller.js"

# Pin all from controllers directory
pin_all_from "app/javascript/controllers", under: "controllers"
