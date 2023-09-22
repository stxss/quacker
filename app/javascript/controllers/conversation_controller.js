import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="conversation"
export default class extends Controller {
    static targets = ["form", "submit"];

    connect() {}

    calculateChecked() {
        let boxes = this.element.querySelectorAll("input[type='checkbox']");
        let checked = 0;

        boxes.forEach((box) => {
            if (box.checked) {
                checked++;
            }
        });

        return checked;
    }

    groupNamePresent() {
        let nameInput = this.formTarget.querySelector("input[type='text']");
        if (nameInput) {
            return nameInput.value.length > 0;
        } else {
            return false;
        }
    }


    toggleName() {
        let checked = this.calculateChecked();

        if (checked >= 2) {
            let nameDiv = document.createElement("div");

            nameDiv.innerHTML = `
                <label for="conversation_name">Group Name</label>
                <input class="required:border-red-500 valid:border-green-500 border" type="text" name="conversation[name]" id="conversation_name" autocomplete="off" required>`;
            this.formTarget.prepend(nameDiv);
            nameDiv.addEventListener("input", (e) => {
                this.toggleSubmitButton();
            })
        } else {
            let nameDiv = this.formTarget.querySelector("div");
            if (nameDiv) {
                nameDiv.remove();
            }
        }
    }

    toggleSubmitButton() {
        let checked = this.calculateChecked();

        console.log(this.submitTarget)
        let btn;

        // 1 checked -> able to start chat
        // 2 checked -> able to start group chat only if group name is present
        if (checked == 1) {
            btn = `<input type="submit" data-conversation-target="submit" name="commit" value="Start Chat" data-disable-with="Create Conversation"></input>`;
        } else if (checked >= 2) {
            if (this.groupNamePresent()) {
                btn = `<input type="submit" data-conversation-target="submit" name="commit" value="Start Group Chat" data-disable-with="Create Conversation"></input>`;
            } else {
                btn = `<input disabled class="disabled:opacity-75" type="submit" data-conversation-target="submit" name="commit" value="Start Group Chat" data-disable-with="Create Conversation"></input>`;
            }
        } else {
            btn = `<input class="disabled:opacity-75" type="submit" data-conversation-target="submit" name="commit" value="Start Chat" data-disable-with="Create Conversation" disabled></input>`;
        }

        this.submitTarget.outerHTML = btn;
    }
}
