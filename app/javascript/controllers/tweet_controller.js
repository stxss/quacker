import { Controller } from "@hotwired/stimulus";

// Connects to the media tagging setting
export default class extends Controller {
    static targets = [ "area" ];

    connect() {
        this.verifyLength()
    }

    verifyLength() {
        let area = this.areaTarget
        let length = area.querySelector("textarea").value.length
        let button = document.querySelector("#submit-tweet")

        button.disabled = length < 1 || length > 280

    }
}
