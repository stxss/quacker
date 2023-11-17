import { Controller } from "@hotwired/stimulus";

const themeToggleIcon = document.querySelector(".theme-toggle")

const userTheme = localStorage.getItem("theme")
const systemTheme = window.matchMedia("(prefers-color-scheme: dark)").matches

// Connects to data-controller="theme"
export default class extends Controller {
    initialize() {
      console.log("init")
      this.clickHandler = (e) => this.themeSwitch(e);
      themeToggleIcon.addEventListener("click", this.clickHandler);
      this.initialThemeCheck();

        // Create an empty "constructed" stylesheet
        const sheet = new CSSStyleSheet();
        // Apply a rule to the sheet
        sheet.replaceSync(`* {
          transition: 0.5s
        }`);

        // Apply the stylesheet to a document
        document.adoptedStyleSheets = [...document.adoptedStyleSheets, sheet];
    }

    connect() {

    }

    initialThemeCheck() {
      if (userTheme === "dark" || (!userTheme && systemTheme)) {
        document.documentElement.classList.add("dark")
      }
    }

    themeSwitch() {
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
    }
}
