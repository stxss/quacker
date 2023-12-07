import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme"
export default class extends Controller {
  connect() {
    this.element.addEventListener("click", (e) => {
      this.themeSwitch()
    })
  }

  themeSwitch() {
    document.documentElement.classList.remove("preload")
    if (!this.element.classList.contains("before:duration-500")) {
      this.element.classList.add("before:duration-500")
    }
    if (document.documentElement.classList.contains("dark")) {
      document.documentElement.classList.remove("dark")
      localStorage.setItem("theme", "light")
    } else {
      document.documentElement.classList.add("dark")
      localStorage.setItem("theme", "dark")
    }
    document.getSelection().removeAllRanges()

  }
}
