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
        ".thread"
        );

        if (el.classList.contains("hidden")) {
            el.classList.replace("hidden","block")
            this.element.parentElement.classList.remove("items-center");
            this.element.firstElementChild.classList.add("hidden")

        } else {
            el.classList.add("hidden")
            this.element.parentElement.classList.add("items-center");
            this.element.firstElementChild.classList.remove("hidden")
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
        if (document.getSelection().rangeCount === 1) {
            let selection = document.getSelection().getRangeAt(0);
            let selectionLength = selection.endOffset - selection.startOffset
            if (selectionLength === 0 && document.getSelection().anchorNode.nodeName === "#text") {
                this.element.querySelector("a.hidden").click()
                document.getSelection().removeAllRanges()
            }
        } else {
        }
    }

    removeFlash() {
        setTimeout(() => {
            this.element.classList.remove("animate-jump")
            this.element.classList.add("animate-jump-out")

            setTimeout(() => {
                this.element.parentElement.innerHTML = ""
            }, 500)
        }, 3000);
    }
}
