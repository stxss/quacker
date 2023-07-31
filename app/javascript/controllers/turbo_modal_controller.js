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
        let prev_page = this.element.dataset.previousPageUrl;
        let username = this.data.get("username");
        let prev_page_str = prev_page.slice(prev_page.lastIndexOf("/") + 1);

        this.element.parentElement.removeAttribute("src");
        this.element.remove();

        if (prev_page_str === username) {
            window.location.href = `/${username}`;
        } else if (prev_page_str === "privacy_and_safety" || prev_page_str === "search" ) {
            window.location.href = `/settings/content_you_see`;
        } else {
            window.location.href = "/home";
        }

    }

    next(event) {
        if (event.detail.success) {
            let fetchResponse = event.detail.fetchResponse;
            let username = fetchResponse.response.username;

            history.pushState(
                { turbo_frame_history: true },
                "",
                `/${username}`
            );

            Turbo.visit(fetchResponse.response.url);
        }
    }

    close(e) {
        if (e.detail.success) {
            this.hideModal();
        }
    }
}
