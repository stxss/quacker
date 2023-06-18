import { Controller } from "@hotwired/stimulus";

// Connects to the media tagging setting
export default class extends Controller {
    static targets = ["dropdown", "menu", "menuButton"];

    dropMenu() {
        let rtMenu = this.menuTarget
        rtMenu.classList.toggle("show")
    }

    changeColor() {
        let btn = this.menuButtonTarget
        let rtCount = btn.closest(".retweets").querySelector("#retweet-count")

        if (btn.id === "menu-retweet") {
            btn.id = "menu-unretweet"
        } else if (btn.id === "menu-unretweet") {
            btn.id = "menu-retweet"
        }
    }
}
