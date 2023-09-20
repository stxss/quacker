import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="conversation"
export default class extends Controller {
    static targets = ["form"];

    connect() {
        console.log("wiii");
    }

    toggleName() {
        let boxes = this.element.querySelectorAll("input[type='checkbox']");
        let checked = 0;
        console.log(boxes);
        boxes.forEach((box) => {
            if (box.checked) {
                checked++;
            }
        });

        console.log(checked);

        if (checked >= 2) {
            console.log(this.formTarget);
            let nameDiv = document.createElement("div");

            nameDiv.innerHTML = `<div>
                <label for="conversation_name">Group Name</label>
                <input required='required' type="text" name="conversation[name]" id="conversation_name" autocomplete="off">
            </div>`;
            this.formTarget.prepend(nameDiv);
        } else {
            let nameDiv = this.formTarget.querySelector("div");
            if (nameDiv) {
                nameDiv.remove();
            }
        }
    }
}
