import { Controller } from "@hotwired/stimulus";

// Connects to the repost pop up and button
export default class extends Controller {
    static targets = ["menu"];

    connect() {}

    dropMenu(e) {
        if (!this.hasMenuTarget) {
            return
        }

        if (this.menuTarget.style.display === "none") {
            this.menuTarget.style.display = "flex"
        }
        if (e.target.id === "backdrop") {
            this.hideBackdrop(e.target)
            this.hideMenu()
            return
        }
        document.addEventListener("click", (event) => {
            let withinBoundaries = event.composedPath().includes(this.element);

            if (!withinBoundaries) {
                this.hideMenu()
            }
        });

        this.element.addEventListener("keydown", (event) => {
            if (event.code === "Escape") {
                this.hideMenu()
                this.hideBackdrop(this.menuTarget.parentElement.querySelector("#backdrop"))
            }
        });
        this.showMenu(this.menuTarget)
        this.showBackdrop(this.menuTarget.parentElement.querySelector("#backdrop"), false)
        this.trapFocus(this.element);

    }

    trapFocus(element) {
        // https://hidde.blog/using-javascript-to-trap-focus-in-an-element/

        let focusableEls = element.querySelectorAll(
            'a[href]:not([disabled]), button:not([disabled]), textarea:not([disabled]), input[type="text"]:not([disabled]), input[type="radio"]:not([disabled]), input[type="checkbox"]:not([disabled]), select:not([disabled])'
        );
        let firstFocusableEl = focusableEls[0];
        let lastFocusableEl = focusableEls[focusableEls.length - 1];
        let KEYCODE_TAB = 9;

        element.addEventListener("keydown", function (e) {
            let isTabPressed = e.key === "Tab" || e.keyCode === KEYCODE_TAB;

            if (!isTabPressed) {
                return;
            }

            if (e.shiftKey) {
                /* shift + tab */ if (
                    document.activeElement === firstFocusableEl
                ) {
                    lastFocusableEl.focus();
                    e.preventDefault();
                }
            } /* tab */ else {
                if (document.activeElement === lastFocusableEl) {
                    firstFocusableEl.focus();
                    e.preventDefault();
                }
            }
        });
    }

    hideMenu(el) {
        this.menuTarget.classList.add("hidden")
    }

    showMenu(el) {
        el.classList.remove("hidden");
        el.classList.add("flex", "flex-col");
        el.closest("article").classList.add("z-10")
    }

    hideBackdrop(el) {
        el.classList.remove(...this.backdropClasses)
        el.classList.add("hidden")
    }

    showBackdrop(el, addClasses) {
        el.classList.remove("hidden")
        if (addClasses) {
            el.classList.add(...this.backdropClasses)
        }
    }

    get backdropClasses() {
        return ["bg-background", "opacity-60", "brightness-0", "transition", "duration-500"]
    }
}
