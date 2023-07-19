import { Controller } from "@hotwired/stimulus";

// Connects to the retweet pop up and button
export default class extends Controller {
    static targets = ["dropdown", "menu", "menuButton"];

    connect() {
        document.addEventListener("click", (event) => {
            let withinBoundaries = event.composedPath().includes(this.element);

            if (!withinBoundaries) {
                this.menuTarget.classList.remove("show");
            }
        });

        this.element.addEventListener("keydown", (event) => {
            if (event.code === "Escape") {
                this.menuTarget.classList.remove("show");
            }
        });
    }

    dropMenu() {
        this.trapFocus(this.element)
        this.menuTarget.classList.toggle("show");
    }


    trapFocus(element) {
        // https://hidde.blog/using-javascript-to-trap-focus-in-an-element/

        let focusableEls = element.querySelectorAll('a[href]:not([disabled]), button:not([disabled]), textarea:not([disabled]), input[type="text"]:not([disabled]), input[type="radio"]:not([disabled]), input[type="checkbox"]:not([disabled]), select:not([disabled])');
        let firstFocusableEl = focusableEls[0];
        let lastFocusableEl = focusableEls[focusableEls.length - 1];
        let KEYCODE_TAB = 9;

        // document.addEventListener("click", (event) => {
        //     let withinBoundaries = event.composedPath().includes(this.element);

        //     if (!withinBoundaries) {
        //         console.log(focusableEls)
        //         let isEqual = Array.from(focusableEls).some(node => node === event.target)
        //         console.log(isEqual)
        //         if (!isEqual) {
        //             event.preventDefault()
        //         }
        //         this.menuTarget.classList.remove("show");
        //     }
        // });

        element.addEventListener('keydown', function(e) {
          let isTabPressed = (e.key === 'Tab' || e.keyCode === KEYCODE_TAB);

          if (!isTabPressed) {
            return;
          }

          if ( e.shiftKey ) /* shift + tab */ {
            if (document.activeElement === firstFocusableEl) {
              lastFocusableEl.focus();
                e.preventDefault();
              }
            } else /* tab */ {
            if (document.activeElement === lastFocusableEl) {
              firstFocusableEl.focus();
                e.preventDefault();
              }
            }
        });
    }
}
