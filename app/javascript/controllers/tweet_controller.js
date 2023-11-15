import { Controller } from "@hotwired/stimulus";

// Connects to the tweet form
export default class Tweet extends Controller {
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

    get content() {
        return this.areaTarget.value;
    }

    get length() {
        return this.content.length;
    }
}
