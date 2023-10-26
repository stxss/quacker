import { Controller } from "@hotwired/stimulus";

// Connects to general modals - edit profile and so on
export default class extends Controller {

    connect() {
        this.clickOutsideHandler = (e) => this.clickOutside(e);
        document.addEventListener("keyup", this.clickOutsideHandler)
        document.addEventListener("click", this.clickOutsideHandler)
    }

    disconnect() {
        document.removeEventListener("click", this.clickOutsideHandler)
        document.removeEventListener("keyup", this.clickOutsideHandler)
    }

    clickOutside(e) {
        if (e.type === "click") {
            let withinBoundaries = e.composedPath().includes(this.element);
            if (!withinBoundaries) {
                this.close(e)
            }
        } else if (e.type === "keyup") {
            if (e.code === "Escape") {
                this.close(e)
            }
        }
    }

    close(e) {
        if (this.username) {
            Turbo.visit(`/${this.username}`, { action: "advance" })
        } else if (history.length > 3) {
            history.back()
        } else {
            Turbo.visit("/home", { action: "advance" })
        }
    }

    get username() {
        return this.data.get("username");
    }
}
