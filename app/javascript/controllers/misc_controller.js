import { Controller } from "@hotwired/stimulus";

// Connects to the media tagging setting
export default class extends Controller {
    copyLink() {
        navigator.clipboard
            .writeText(this.element.dataset.url)
            .then(function () {
                let wrapper = document.createElement("div")
                wrapper.classList.add("fixed", "z-20", "bottom-20", "start-1/2")
                let flash = document.createElement("div")
                flash.classList.add("z-40", "animate-jump", "animate-duration-200", "animation-ease-in-out", "bg-primary", "py-2", "px-4", "rounded-md", "text-center", "text-white", "duration-500")
                flash.dataset.controller = "misc"
                flash.dataset.action = "animationend->misc#removeFlash"
                flash.dataset.id = "notice"
                flash.textContent = "Link Copied!"
                document.documentElement.append(wrapper)
                wrapper.append(flash)
                setTimeout(() => {
                    wrapper.remove()
                }, 3001)
            });

        // For some reason, using `this.element.parentElement.classList.add("hidden")` doesn't work, but setting a timeout to 0 does.
        setTimeout(() => {
            this.element.parentElement.classList.add("hidden")
            this.element.closest(".dropdown").querySelector("#backdrop").classList.add("hidden")
        }, 0);
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

    postClick(e) {
        if (document.getSelection().rangeCount === 1) {
            let selection = document.getSelection().getRangeAt(0);
            let selectionLength = selection.endOffset - selection.startOffset
            let postLink
            if (selectionLength === 0 && document.getSelection().anchorNode.nodeName === "#text") {
                if (e.target.classList.contains("post-info")) {
                    postLink = e.target.querySelector("a.hidden")
                } else {
                    postLink = e.target.closest(`article`).querySelector("a.hidden")
                }
                postLink.click()
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
