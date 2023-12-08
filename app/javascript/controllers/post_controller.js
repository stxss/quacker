import { Controller } from "@hotwired/stimulus";

// Connects to the post form
export default class Post extends Controller {
    static targets = ["area", "counter",  "submit", "modal", "write", "preview"];

    MAXLENGTH = 10_000

    initialize() {
        this.update();
    }

    connect() {
        this.popStateHandler = (e) => this.clear(e);
        if (this.hasModalTarget) {
            window.addEventListener("popstate", this.popStateHandler);
        }

        document.getElementById("post-compose").addEventListener("submit", (e) => {
            if (this.notPost()) { e.preventDefault();}
        });

        this.update();
    }

    update() {
        this.verifyLength(this.length);
    }

    verifyLength(length) {
        if (this.notPost()) {
            this.submitTarget.querySelector("input[type=submit]").setAttribute("disabled", "")
        } else {
            this.submitTarget.querySelector("input[type=submit]").removeAttribute("disabled")
            }

        this.showCount(length)
    }

    showCount(length) {
        if (length > 0) {
            this.counterTarget.classList.remove("hidden")
            this.counterTarget.textContent = `${length} / ${this.MAXLENGTH}`
        } else {
            this.counterTarget.textContent = ""
            this.counterTarget.classList.add("hidden")
        }
        if (length >= 10000) {
            this.counterTarget.classList.replace("text-text", "text-red-600")
        } else {
            this.counterTarget.classList.replace("text-red-600", "text-text")
        }
    }

    clear(e) {
        if (this.areaTarget.value != "") {
            this.areaTarget.value = "";
        }
        window.removeEventListener("popstate", this.popStateHandler);
        this.update();
    }

    notPost() {
        return (/^\s*$/.test(this.content) || this.length < 1 || this.length > 10000);
    }


    changeToWrite() {
        this.changeButtonStyle(this.writeTarget, this.previewTarget)
    }

    changeToPreview() {
        this.changeButtonStyle(this.previewTarget, this.writeTarget)
    }

    changeButtonStyle(target, other) {
        let primaryColor = "bg-primary"
        let brightness = "brightness-50"
        let textColor = "text-text"
        let textDimmed = "text-text-dimmed"
        let activeBorder = ["border-l", "border-r", "border-t", "border-accent2"]
        let transparentBorder = "border-transparent"

        //  Target styling, changing the color, opacity and text brightness/color
        target.classList.remove(brightness, textDimmed)
        target.classList.add(primaryColor, textColor)

        //  Add the border to target
        target.classList.remove(transparentBorder)
        target.classList.add(...activeBorder)

        //  Other button styling, changing the color and opacity and text brightness/color
        other.classList.remove(primaryColor, textColor)
        other.classList.add(brightness, textDimmed)

        //  Remove border from other
        other.classList.remove(...activeBorder)
        other.classList.add(transparentBorder)
    }

    get content() {
        return this.areaTarget.value;
    }

    get length() {
        return this.content.length;
    }
}
