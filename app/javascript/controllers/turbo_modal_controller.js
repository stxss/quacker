import { Controller } from "@hotwired/stimulus";

// Connects to general modals - edit profile and so on
export default class extends Controller {

    connect() {
        this.urlChange()
        this.clickOutsideHandler = (e) => this.clickOutside(e);
        document.addEventListener("keyup", this.clickOutsideHandler)
        document.addEventListener("click", this.clickOutsideHandler)
    }

    disconnect() {
        document.removeEventListener("click", this.clickOutsideHandler)
        document.removeEventListener("keyup", this.clickOutsideHandler)
    urlChange(e) {
        let modal = this.element.closest("#modal")
        let modalUrl = modal.querySelector("form").dataset.modalUrl
        history.pushState(null, '', modalUrl);
    }
    }

    clickOutside(e) {
        if (e.type === "click") {
            let withinBoundaries = e.composedPath().includes(this.element);

            if (!withinBoundaries) {
                this.close(e);
            }
        } else if (e.type === "keyup") {
            if (e.code === "Escape") {
                this.close(e);
            }
        }
    }

    close(e) {
        e.preventDefault()
        let modal = this.element.closest("#modal")
        let docRef = this.element.querySelector("form").dataset.previousPageUrl

        modal.innerHTML = ""
        modal.removeAttribute("src")
        modal.removeAttribute("complete")

        history.pushState(null, '', docRef);
    }

    get prevPage() {
        return this.element.dataset.previousPageUrl;
    }

    get prevPageStr() {
        return this.prevPage.slice(this.prevPage.lastIndexOf("/") + 1);
    }

    get username() {
        return this.data.get("username");
    }
}
