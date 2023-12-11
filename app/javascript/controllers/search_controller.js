import { Controller } from "@hotwired/stimulus"
import debounce from "debounce"

// Connects to data-controller="search"
export default class extends Controller {
  initialize() {
    this.submit = debounce(this.submit.bind(this), 300);
  }

  submit(e) {
    if (this.onlyWhitespace(e.data)) {
      e.preventDefault();
    } else {
      this.element.requestSubmit();
    }
  }

  prepare(e) {
    let field = this.element.querySelector("input")
    if(this.onlyWhitespace(field.value)) {
      e.preventDefault();
      field.value = "";
      let resultsField = document.querySelector("#search-results")
      resultsField.innerHTML = `<div class="align-middle self-center">Search for messages</div>`;
    }
  }

  onlyWhitespace(data) {
    return /^\s*$/.test(data)
  }
}
