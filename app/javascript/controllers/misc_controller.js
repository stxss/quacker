import { Controller } from "@hotwired/stimulus";

// Connects to the media tagging setting
export default class extends Controller {
    // static targets = ["radioButtons" ];

    copyLink() {
        navigator.clipboard.writeText(this.element.dataset.url).then(function () {

            document.querySelector(".notice").innerHTML = "Link copied!";
        });
    }

    get prevPage() {
        return this.element.dataset.url;
    }

}
