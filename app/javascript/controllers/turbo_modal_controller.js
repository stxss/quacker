import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="turbo-modal"
export default class extends Controller {
    hideModal() {
      this.element.parentElement.removeAttribute("src");
      this.element.remove();
    }

    next(event) {
      if (event.detail.success) {
        const fetchResponse = event.detail.fetchResponse;
        const username = fetchResponse.response.username;

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
        this.hideModal()
      }
    }
}
