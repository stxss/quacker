import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="autogrow"
export default class extends Controller {
    initialize() {
        this.autogrow = this.autogrow.bind(this);
    }

    connect() {
        this.element.style.overflow = "hidden";
        this.autogrow();
        this.element.addEventListener("input", this.autogrow);
        window.addEventListener("resize", this.autogrow);
    }

    disconnect() {
        window.removeEventListener("resize", this.autogrow);
    }

    autogrow() {
        if (this.element.scrollHeight < this.vh(90)) {
            this.element.style.overflowY = "hidden";
            this.element.style.height = "auto";
            this.element.style.height = `${this.element.scrollHeight}px`;
        } else {
            this.element.style.overflowY = "scroll";
        }
    }

    // https://stackoverflow.com/questions/1248081/how-to-get-the-browser-viewport-dimensions/8876069#8876069
    vh(percent) {
        var h = Math.max(document.documentElement.clientHeight,window.innerHeight || 0);
        return (percent * h) / 100;
    }
}

// https://blog.corsego.com/stimulus-textarea-autogrow
