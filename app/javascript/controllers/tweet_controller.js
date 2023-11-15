import { Controller } from "@hotwired/stimulus";

// Connects to the tweet form
export default class Tweet extends Controller {
    static targets = ["area", "counter", "circle", "submit", "modal"];

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

        let circleContainer = this.circleTarget

        if (length === 0 && circleContainer.childNodes.length > 0) {
            circleContainer.innerHTML = "";
            } else if (length !== 0 && circleContainer.childNodes.length === 0) {
            circleContainer.innerHTML = `
                <svg class="progress-ring" height="100%" width="100%" viewBox="0 0 20 20" style="transform: rotate(-90deg); overflow: visible">
                <circle class="progress-ring__circle-bg" stroke-width="1.6" fill="transparent" r="10" cx="50%" cy="50%" stroke-linecap="round"></circle>
                <circle class="progress-ring__circle" stroke-width="2" fill="transparent" r="10" cx="50%" cy="50%" stroke-linecap="round"></circle>
                <text class="progress-ring__text" x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" style="rotate: 90deg; transform-origin: center;"></text>
                </svg>
            `;
        }
        this.showCount(length)
        this.progressCircle(length);
    }

    showCount(length) {
        this.verifyLength;
        if (!document.querySelector(".progress-ring")) {
            return;
        }

        let text = this.counterTarget.querySelector(".progress-ring__text");
        if (!text) {return;}
        let progressRing = document.querySelector(".progress-ring");

        if (length < 260) {
            text.textContent = "";
            progressRing.style.transition = "width 0.2s, height 0.2s";
            progressRing.classList.remove("over-limit");
        } else {
            text.textContent = 7000 - length;
            text.fontSize = "13px";
            progressRing.classList.add("over-limit");
        }

        if (length >= 7000) {
            text.style.fill = "red";
        } else {
            text.style.fill = "";
        }
    }

    progressCircle(length) {
        if (length === 0) {
            return;
        }
        let circles = this.circleTarget.querySelectorAll("circle");
        let fgCircle = circles[1];
        let bgCircle = circles[0];
        let radius = fgCircle.r.baseVal.value;
        let circumference = radius * 2 * Math.PI;

        fgCircle.style.strokeDasharray = `${circumference} ${circumference}`;
        fgCircle.style.strokeDashoffset = `${circumference} `;

        function setProgress(length) {
            let offset = circumference - (length / 7000) * circumference;
            if (offset <= 0) {
                offset = 0;
                fgCircle.style.stroke = "#F4212E";
                bgCircle.style.stroke = "#F4212E";
            } else if (0 < offset && offset <= 4.487989505128276) {
                fgCircle.style.stroke = "#FFD400";
                bgCircle.style.stroke = "#2F3336";
            } else {
                fgCircle.style.stroke = "#1D9BF0";
                bgCircle.style.stroke = "#2F3336";
            }
            fgCircle.style.strokeDashoffset = offset;
        }

        setProgress(length);
    }
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
