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
        this.update();
    }

    update() {
        this.verifyLength(this.length);
    }

    verifyLength(length) {
        if (this.notMessage()) {
            if (!this.submitTarget.querySelector(".fake-submit-message")) {
                this.submitTarget.innerHTML = `<div class="fake-submit-message">Send</div>`;
            }
        } else {
            if (!this.submitTarget.querySelector("input")) {
                this.submitTarget.innerHTML = `<input type="submit" name="commit" value="Send" class="w-fit p-3" data-disable-with="Sending Message" data-action="click->message#submit"></input>
                `;
            }
        }
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
