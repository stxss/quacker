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
                this.hideModal(e);
            }
        } else if (e.type === "keyup") {
            if (e.code === "Escape") {
                this.hideModal(e);
            }
        }
    }

    hideModal(e) {
        e.preventDefault();
        this.element.parentElement.querySelector(".backdrop").remove();
        this.element.remove();

        if (this.prevPageStr === this.username) {
            history.pushState(null, '', `/${this.username}`);
        } else if (this.prevPageStr === "content_you_see" || this.prevPageStr === "search") {
            history.pushState(null, '', `/settings/content_you_see`);
        } else {
            history.pushState(null, '', "/home");
        }
    }

    close(e) {
        if (e.detail.success) {
            this.hideModal();
        }
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
