import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="scroller"
export default class extends Controller {
  connect() {
    this.element.scrollIntoView()
  }
}
