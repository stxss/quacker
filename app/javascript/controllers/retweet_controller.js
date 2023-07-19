import { Controller } from "@hotwired/stimulus";

// Connects to the retweet pop up and button
export default class extends Controller {
    static targets = ["dropdown", "menu", "menuButton"];

    connect() {
        document.addEventListener("click", (event) => {
            let withinBoundaries = event.composedPath().includes(this.element);

            if (!withinBoundaries) {
                this.menuTarget.classList.remove("show");
            }
        });

        this.element.addEventListener("keydown", (event) => {
            if (event.code === "Escape") {
                this.menuTarget.classList.remove("show");
            }
        });
    }

    dropMenu() {
        this.menuTarget.classList.toggle("show");
    }
}
