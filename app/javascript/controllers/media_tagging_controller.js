import { Controller } from "@hotwired/stimulus";

// Connects to the media tagging setting
export default class extends Controller {
    static targets = ["radioButtons" ];

    toggleRadioButtons() {
        let el = this.radioButtonsTarget

        if (el) {
            el.parentNode.removeChild(el);
        }
    }

    submit() {
        let form = this.element.querySelector("form");
        form.requestSubmit();
    }
}
