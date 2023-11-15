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
            if (!this.submitTarget.querySelector(".fake-submit-tweet")) {
                this.submitTarget.innerHTML = `<div class="fake-submit-tweet">Tweet</div>`
            }
            } else {
            if (!this.submitTarget.querySelector("input")) {
                this.submitTarget.innerHTML = `<input type="submit" name="commit" value="Tweet" id="real-submit-tweet" data-disable-with="Tweet" data-action="click->tweet#submit">`
            }
            }

        this.showCount(length)
    }

    showCount(length) {
        // this.verifyLength;

        console.log(this.counterTarget.parentElement)

        if (length > 0) {
            this.counterTarget.textContent = `${length} / ${this.MAXLENGTH}`
        } else {
            this.counterTarget.textContent = ""
        }
        if (length >= 10000) {
            this.counterTarget.style.color = "red";
        } else {
            this.counterTarget.style.color = "white";
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
        return (/^\s*$/.test(this.content) || this.length < 1 || this.length > 7000);
    }


    changeToWrite() {
        this.changeButtonStyle(this.writeTarget, this.previewTarget)
    }

    changeToPreview() {
        this.changeButtonStyle(this.previewTarget, this.writeTarget)
    }

    changeButtonStyle(target, other) {
        //  Also take care of not hardcoding the values, and instead using the light and dark variables

        //  Target styling
        //  Change the color, opacity and text brightness/color
        target.classList.remove("bg-slate-600", "bg-opacity-0", "text-gray-400")
        target.classList.add("bg-neutral-900", "bg-opacity-100", "text-stone-100")

        //  Add the border to target
        target.classList.add("border-l","border-r", "border-t" ,"border-zinc-500")

        other.firstElementChild.classList.remove("relative","top-[-0.5px]")
        target.firstElementChild.classList.add("relative","top-[-0.5px]")

        //  Other styling
        //  Change the color and opacity
        other.classList.remove("bg-neutral-900", "bg-opacity-100", "text-stone-100")
        other.classList.add("bg-slate-600", "bg-opacity-0", "text-gray-400")

        //  Remove border from other
        other.classList.remove("border-l","border-r", "border-t" ,"border-zinc-500")
    }


    get content() {
        return this.areaTarget.value;
    }

    get length() {
        return this.content.length;
    }
}
