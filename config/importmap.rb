# Pin npm packages by running ./bin/importmap

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: '@hotwired--stimulus.js' # @3.2.2
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin '@stimulus-components/rails-nested-form', to: '@stimulus-components--rails-nested-form.js' # @5.0.0
pin '@stimulus-components/password-visibility', to: '@stimulus-components--password-visibility.js' # @3.0.0
pin '@stimulus-components/clipboard', to: '@stimulus-components--clipboard.js' # @5.0.0
