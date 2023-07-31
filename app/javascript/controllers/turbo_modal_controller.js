import { Controller } from "@hotwired/stimulus";

// Connects to general modals - edit profile and so on
export default class extends Controller {

    connect() {
        document.addEventListener("click", (event) => {
            let withinBoundaries = event.composedPath().includes(this.element);

            if (!withinBoundaries) {
                this.hideModal();
            }
        });

        document.addEventListener("keyup", (event) => {
            if (event.code === "Escape") {
                this.hideModal();
            }
        });
    }

    hideModal() {
        this.element.parentElement.removeAttribute("src");
        this.element.remove();

        if (this.prevPageStr === this.username) {
            window.location.href = `/${this.username}`;
        } else if (this.prevPageStr === "content_you_see") {
            window.location.href = `/settings/content_you_see`;
        } else {
            window.location.href = "/home";
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
