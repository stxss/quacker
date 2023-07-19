// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Modal confirmation windows
Turbo.setConfirmMethod(() => {
    let dialog = document.getElementById("turbo-confirm")
    dialog.showModal()
    document.documentElement.style.overflow = "hidden"

    // Specifically for the checkbox when setting the protected tweets setting on
    let diagCheckBox = document.getElementById("account_private_visibility")
    if (diagCheckBox) {
        diagCheckBox.checked = false
    }

    dialog.addEventListener("click", (event) => {
        if (event.target === dialog) {
            dialog.close()
        }
    });

    return new Promise((resolve, reject) => {
        dialog.addEventListener("close", () => {
            resolve(dialog.returnValue == "confirm")
            document.documentElement.removeAttribute("style");
        }, { once: true })
    })
})
