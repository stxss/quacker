import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autogrow"
export default class extends Controller {
  initialize() {
    this.autogrow = this.autogrow.bind(this);
  }

  connect() {
    this.element.style.overflow = 'hidden';
    this.autogrow();
    this.element.addEventListener('input', this.autogrow);
    window.addEventListener('resize', this.autogrow);
  }

  disconnect() {
    window.removeEventListener('resize', this.autogrow);
  }

  autogrow() {
    this.element.style.height = 'auto';
    this.element.style.height = `${this.element.scrollHeight}px`;
  }
}

// https://blog.corsego.com/stimulus-textarea-autogrow
