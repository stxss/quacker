import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="message"
export default class extends Controller {
    static targets = ["area", "list", "submit"];

    initialize() {
        this.update();
    }

    connect() {
        this.popStateHandler = (e) => this.clear(e);
        window.addEventListener("popstate", this.popStateHandler);
        document.documentElement.classList.add("overflow-hidden")
        this.update();
    }

    disconnect() {
        document.documentElement.classList.remove("overflow-hidden")
    }

    update() {
        this.verifyLength(this.length);
    }

    verifyLength(length) {
        if (this.notMessage()) {
            if (!this.submitTarget.disabled) {
                this.submitTarget.disabled = true
            }
        } else {
            this.submitTarget.disabled = false
        }
    }

    // for when sharing a post via dm
    calculateChecked() {
        let boxes = this.element.querySelectorAll("input[type='checkbox']");
        let checked = 0;

        boxes.forEach((box) => {
            if (box.checked) {
                checked++;
            }
        });

        return checked;
    }

    toggleSubmitButton() {
        this.submitTarget.disabled = this.calculateChecked() <= 0
    }

    submit(e) {
        if (this.notMessage()) {
            e.preventDefault();
        }
    }

    notMessage() {
        return /^\s*$/.test(this.content) || this.length < 1 ;
    }

    clear() {
      if (this.areaTarget.value != "") {
          this.areaTarget.value = "";
      }
      window.removeEventListener("popstate", this.popStateHandler);
      this.update();
  }

    get content() {
        return this.areaTarget.value;
    }

    get length() {
        return this.content.length;
    }
}
