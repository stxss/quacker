import { Controller } from "@hotwired/stimulus";

// Connects to general modals - edit profile and so on
export default class extends Controller {

    connect() {
        this.clickOutsideHandler = (e) => this.clickOutside(e);
        document.addEventListener("keyup", this.clickOutsideHandler)
        document.addEventListener("click", this.clickOutsideHandler)
        this.showBackdrop(this.element.parentElement.firstElementChild, true)
    }

    disconnect() {
        document.removeEventListener("click", this.clickOutsideHandler)
        document.removeEventListener("keyup", this.clickOutsideHandler)
    }

    clickOutside(e) {
        let withinBoundaries = e.composedPath().includes(this.element);

        if ((e.type === "click" && !withinBoundaries) || (e.type === "keyup" && e.code === "Escape")) {
            this.close(e)
            let bdList = document.querySelectorAll("#backdrop:not(.hidden)")
            bdList.forEach((el) => {
                el.classList.add("hidden")
                el.classList.remove(...this.backdropClasses)
            })
            console.log(document.getElementById("flash"))
        } else if (e.type === "keyup" && e.code !== "Escape") {
        }
    }

    close(e) {
        if (this.username) {
            Turbo.visit(`/${this.username}`, { action: "advance" })
        } else if (this.postShare) {
            this.element.parentElement.removeAttribute('src')
            this.element.parentElement.removeAttribute('complete')
            this.element.parentElement.innerHTML = ""
        } else if (history.length > 3) {
            document.getSelection().removeAllRanges()
            history.back()
        } else {
            Turbo.visit("/home", { action: "advance" })
        }
    }

    get username() {
        return this.data.get("username");
    }

    get postShare() {
        return this.data.get("postShare");
    }

    showBackdrop(el, addClasses) {
        el.classList.remove("hidden")
        if (addClasses) {
            el.classList.add(...this.backdropClasses)
        }
    }

    get backdropClasses() {
        return ["bg-background", "opacity-60", "brightness-0", "transition", "duration-500"]
    }
}
