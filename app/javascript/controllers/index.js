// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import RailsNestedForm from "@stimulus-components/rails-nested-form"
import PasswordVisibility from "@stimulus-components/password-visibility"
import Clipboard from '@stimulus-components/clipboard'
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

application.register("nested-form", RailsNestedForm)
application.register("password-visibility", PasswordVisibility)
application.register('clipboard', Clipboard)