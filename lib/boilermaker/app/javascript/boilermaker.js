import { Application } from "@hotwired/stimulus"
import ServerStatusController from "boilermaker/controllers/server_status_controller"
import ClockController from "boilermaker/controllers/clock_controller"

const application = Application.start()
application.register("server-status", ServerStatusController)
application.register("clock", ClockController)
