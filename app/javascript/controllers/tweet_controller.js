import { Controller } from "@hotwired/stimulus";

// Connects to the media tagging setting
export default class extends Controller {
    static targets = [ "area", "counter" ];

    connect() {
        this.verifyLength()
    }

    verifyLength() {
        let area = this.areaTarget
        let content = area.querySelector("textarea").value
        let length = content.length
        let button = document.querySelector("#submit-tweet")

        button.disabled = length < 1 || length > 280

        this.showCount(length)
    }

    showCount(length) {
        console.log(length)
        if (length < 260) {
            this.counterTarget.textContent = ""
        } else {
            this.counterTarget.textContent = 280 - length
        }

        if (length >= 280) {
            this.counterTarget.style = "color: red"
        } else {
            this.counterTarget.style = "color: black"
        }
    }
}
