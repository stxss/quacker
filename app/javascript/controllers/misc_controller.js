import { Controller } from "@hotwired/stimulus";

// Connects to the media tagging setting
export default class extends Controller {

    copyLink() {
        navigator.clipboard.writeText(this.element.dataset.url).then(function () {

            document.querySelector(".notice").innerHTML = "Link copied!";
        });
    }

    toggleReplies() {
        let el = this.element.parentElement.querySelector(".tweet > .tweet-info")
        if (el.style.display === "none") {
            el.style.display = "block";
            this.element.textContent = "";
            this.element.parentElement.classList.remove("hidden");
        } else {
            el.style.display = "none";
            this.element.parentElement.classList.add("hidden");
            this.element.innerHTML = `<svg class="icon-expand" xmlns="http://www.w3.org/2000/svg"  viewBox="0 -960 960 960" width="24"><path d="M120-120v-240h80v104l124-124 56 56-124 124h104v80H120Zm516-460-56-56 124-124H600v-80h240v240h-80v-104L636-580Z"/></svg>`;
        }
    }

    get prevPage() {
        return this.element.dataset.url;
    }
}
