// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "./controllers"

// Modal confirmation windows
Turbo.setConfirmMethod((message, element) => {
    let dialog = document.getElementById("turbo-confirm")
    dialog.querySelector("h3").textContent = element.dataset.header
    dialog.querySelector("p").textContent = message
    dialog.querySelector("button[value='confirm']").textContent = element.dataset.confirm
    dialog.querySelector("button[value='cancel']").textContent = element.dataset.cancel
    dialog.showModal()
    document.documentElement.style.overflow = "hidden"

    // Specifically for the checkbox when setting the protected posts setting on
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


//  Theme settings

const themeToggleIcon = document.querySelector(".theme-toggle")
const userTheme = localStorage.getItem("theme")
const systemTheme = window.matchMedia("(prefers-color-scheme: dark)").matches

let clickHandler = (e) => themeSwitch(e);
themeToggleIcon.addEventListener("click", clickHandler);

const initialThemeCheck = () => {
    if (userTheme === "dark" || (!userTheme && systemTheme)) {
        document.documentElement.classList.add("dark")

    }
}

const themeSwitch = () => {
    document.documentElement.classList.remove("preload")
    if (document.documentElement.classList.contains("dark")) {
        document.documentElement.classList.remove("dark")
        localStorage.setItem("theme", "light")
    } else {
        document.documentElement.classList.add("dark")
        localStorage.setItem("theme", "dark")
    }

    themeToggleIcon.classList.add(
        "before:transition",
        "before:duration-500",
        "before:ease-out"
        )

    // Create an empty "constructed" stylesheet
    const sheet = new CSSStyleSheet();
    // Apply a rule to the sheet
    sheet.replaceSync(`
    * {
        transition-delay: 0s;
        transition: color 0.5s, background-color 0.5s;
    }
    `)
    // Apply the stylesheet to a document
    document.adoptedStyleSheets = [...document.adoptedStyleSheets, sheet];
}

initialThemeCheck();

//  Prevent the transitions from being fired on page load
setTimeout(() => { document.documentElement.classList.remove("preload") }, 200)
