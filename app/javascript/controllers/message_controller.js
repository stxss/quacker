import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="message"
export default class extends Controller {
  static targets = ["area"]
  connect() {
  }

  clear() {
    if (this.areaTarget.value != "") {
      this.areaTarget.value = "";
    }
  }
}
