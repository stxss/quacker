import { Controller } from "@hotwired/stimulus";

// Connects to the media tagging setting
export default class extends Controller {
    copyLink() {
        navigator.clipboard
            .writeText(this.element.dataset.url)
            .then(function () {
                document.querySelector(
                    ".flash"
                ).innerHTML = `<div class="flash__message" id="notice">Link copied!</div>`;
            });
    }

    toggleReplies() {
        let el = this.element.parentElement.querySelector(
            ".tweet > .tweet-info"
        );
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

    // used mute words save button toggling
    prepare(e) {
        let field = this.element.querySelector("input#muted_word_body");

        if (this.onlyWhitespace(field.value)) {
            e.preventDefault();
            field.value = "";
            let saveButton = this.element.querySelector(".save-wrapper");
            saveButton.innerHTML = `<div id="fake-save-muted-word">Save</div>`;
        } else {
            let saveButton = document.querySelector(".save-wrapper");
            saveButton.innerHTML = `<input type="submit" name="commit" value="Save" id="real-submit-muted-word" data-disable-with="Saving...">`;
        }
    }

    onlyWhitespace(data) {
        return /^\s*$/.test(data);
    }

    postClick() {
        let selection = window.getSelection().getRangeAt(0)
        let selectionLength = selection.endOffset - selection.startOffset
        if (selectionLength === 0) { this.element.querySelector("a.hidden").click() }
    }
}
