# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

pin "boilermaker", to: "boilermaker.js", preload: true
pin_all_from "lib/boilermaker/app/javascript/controllers", under: "boilermaker/controllers", preload: true

pin "marked", to: "https://ga.jspm.io/npm:marked@15.0.7/lib/marked.esm.js"
pin "dompurify", to: "https://ga.jspm.io/npm:dompurify@3.2.6/dist/purify.es.mjs"
