import { Controller } from "@hotwired/stimulus";

// Connects to the tweet form
export default class Tweet extends Controller {
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
            if (this.notTweet()) { e.preventDefault();}
        });

        this.update();
    }

    update() {
        this.verifyLength(this.length);
    }

    verifyLength(length) {
        if (this.notTweet()) {
            this.submitTarget.querySelector("input[type=submit]").setAttribute("disabled", "")
        } else {
            this.submitTarget.querySelector("input[type=submit]").removeAttribute("disabled")
            }

        this.showCount(length)
    }

    showCount(length) {
        if (length > 0) {
            this.counterTarget.textContent = `${length} / ${this.MAXLENGTH}`
        } else {
            this.counterTarget.textContent = ""
        }

        if (length >= 10000) {
            this.counterTarget.classList.remove("text-text")
            this.counterTarget.classList.add("text-red-600")
        } else {
            this.counterTarget.classList.remove("text-red-600")
            this.counterTarget.classList.add("text-text")
        }
    }

    clear(e) {
        if (this.areaTarget.value != "") {
            this.areaTarget.value = "";
        }
        window.removeEventListener("popstate", this.popStateHandler);
        this.update();
    }

    notTweet() {
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
        let activeBorder = ["border-l", "border-r", "border-t", "border-accent2"]
        let transparentBorder = "border-transparent"
        let pixelStabilization = ["relative","top-[-0.5px]"]


        //  Target styling, changing the color, opacity and text brightness/color
        target.classList.remove(brightness)
        target.classList.add(primaryColor)

        //  Add the border to target
        target.classList.remove(transparentBorder)
        target.classList.add(...activeBorder)

        //  Maintain the text in the same place
        target.firstElementChild.classList.add(...pixelStabilization)

        //  Other button styling, changing the color and opacity and text brightness/color
        other.classList.remove(primaryColor)
        other.classList.add(brightness)

        //  Remove border from other
        other.classList.remove(...activeBorder)
        other.classList.add(transparentBorder)

        //  Maintain the text in the same place
        other.firstElementChild.classList.remove(...pixelStabilization)

    }


    get content() {
        return this.areaTarget.value;
    }

    get length() {
        return this.content.length;
    }
}
