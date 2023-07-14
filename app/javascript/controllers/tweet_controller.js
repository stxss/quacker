import { Controller } from "@hotwired/stimulus";

// Connects to the media tagging setting
export default class extends Controller {
    static targets = [ "area", "counter", "circle", "submit" ];

    connect() {
    }

  //   verifyLength() {
  //     let area = this.areaTarget
  //     let content = area.querySelector("textarea").value
  //     let length = content.length

  //     if (content.match(/^\s*$/)) {length = 0}

  //     let circleContainer = this.circleTarget
  //     this.showCount(length)

  //     if (length === 0 && circleContainer.childNodes.length > 0) {
  //         circleContainer.innerHTML = "";
  //       } else if (length !== 0 && circleContainer.childNodes.length === 0) {
  //         circleContainer.innerHTML = `
  //           <svg class="progress-ring" height="100%" width="100%" viewBox="0 0 20 20" style="transform: rotate(-90deg); overflow: visible">
  //             <circle class="progress-ring__circle-bg" stroke-width="1.6" fill="transparent" r="10" cx="50%" cy="50%" stroke-linecap="round"></circle>
  //             <circle class="progress-ring__circle" stroke-width="2" fill="transparent" r="10" cx="50%" cy="50%" stroke-linecap="round"></circle>
  //             <text class="progress-ring__text" x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" style="rotate: 90deg; transform-origin: center;"></text>
  //           </svg>
  //         `;
  //     }
  //     this.progressCircle(length);

  //     if (length < 1 || length > 280) {
  //       fetch(this.areaTarget.getAttribute('data-url'), {
  //         method: 'POST',
  //         headers: {
  //           'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
  //           'Content-Type': 'application/json'
  //         },
  //         credentials: 'same-origin',
  //         body: JSON.stringify({
  //          valid: false
  //         })
  //       }).then (response => response.text())
  //       .then(html => Turbo.renderStreamMessage(html));

  //     } else if (length >= 1 && length <= 280 && !this.submitTarget.querySelector("input")) {

  //       fetch(this.areaTarget.getAttribute('data-url'), {
  //         method: 'POST',
  //         headers: {
  //           'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
  //           'Content-Type': 'application/json'
  //         },
  //         credentials: 'same-origin',
  //         body: JSON.stringify({
  //          valid: true
  //         })
  //       }).then (response => response.text())
  //       .then(html => Turbo.renderStreamMessage(html));
  //     }
  // }


    verifyLength() {
        let area = this.areaTarget
        let content = area.querySelector("textarea").value
        let length = content.length

        if (content.match(/^\s*$/)) {length = 0}


        let circleContainer = this.circleTarget
        this.showCount(length)

        if (length === 0 && circleContainer.childNodes.length > 0) {
            circleContainer.innerHTML = "";
          } else if (length !== 0 && circleContainer.childNodes.length === 0) {
            circleContainer.innerHTML = `
              <svg class="progress-ring" height="100%" width="100%" viewBox="0 0 20 20" style="transform: rotate(-90deg); overflow: visible">
                <circle class="progress-ring__circle-bg" stroke-width="1.6" fill="transparent" r="10" cx="50%" cy="50%" stroke-linecap="round"></circle>
                <circle class="progress-ring__circle" stroke-width="2" fill="transparent" r="10" cx="50%" cy="50%" stroke-linecap="round"></circle>
                <text class="progress-ring__text" x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" style="rotate: 90deg; transform-origin: center;"></text>
              </svg>
            `;
        }
        this.progressCircle(length);

        if (length < 1 || length > 280) {
          if (!this.submitTarget.querySelector("#fake-submit-tweet")) {

            if (this.submitTarget.querySelector("#real-submit-tweet")) {
              this.submitTarget.querySelector("#real-submit-tweet").remove()
            }

            // let fakeButton = document.createElement("div")
            // let fakeText = document.createTextNode("Tweet")
            // fakeButton.appendChild(fakeText)
            // fakeButton.setAttribute("id", "fake-submit-tweet")
            // this.submitTarget.appendChild(fakeButton)

            this.submitTarget.innerHTML = `<div id="fake-submit-tweet">Tweet</div>`
          }
        } else {
          if (!this.submitTarget.querySelector("input")) {
            this.submitTarget.querySelector("#fake-submit-tweet").remove()

            // let submitButton = document.createElement("input")
            // submitButton.setAttribute("type", "submit")
            // submitButton.setAttribute("name", "commit")
            // submitButton.setAttribute("value", "Tweet")
            // submitButton.setAttribute("id", "real-submit-tweet")
            // submitButton.setAttribute("data-disable-with", "Tweet")
            // this.submitTarget.appendChild(submitButton);

            this.submitTarget.innerHTML = `<input type="submit" name="commit" value="Tweet" id="real-submit-tweet" data-disable-with="Tweet">`
          }
        }
    }

    showCount(length) {
        if (!document.querySelector(".progress-ring")) {
            return
        }

        let text = this.counterTarget.querySelector(".progress-ring__text");
        let progressRing = document.querySelector(".progress-ring");

        if (length < 260) {
            text.textContent = ""
            progressRing.style.transition = "width 0.2s, height 0.2s";
            progressRing.classList.remove("over-limit");
        } else {
            text.textContent = 280 - length
            text.fontSize = "13px"
            progressRing.classList.add("over-limit");
        }

        if (length >= 280) {
            text.style.fill = "red"
        } else {
            text.style.fill = ""
        }
    }

    progressCircle(length) {
        if (length === 0) {return}
        let circles = this.circleTarget.querySelectorAll("circle")
        let fgCircle = circles[1]
        let bgCircle = circles[0]
        let radius = fgCircle.r.baseVal.value;
        let circumference = radius * 2 * Math.PI;

        fgCircle.style.strokeDasharray = `${circumference} ${circumference}`;
        fgCircle.style.strokeDashoffset = `${circumference} `;

        function setProgress(length) {
          let offset = circumference - (length / 280) * circumference;
          if (offset <= 0) {
            fgCircle.style.stroke = "#F4212E"
            bgCircle.style.stroke = "#F4212E"
          } else if (0 < offset && offset <= 4.487989505128276) {
            fgCircle.style.stroke = "#FFD400"
            bgCircle.style.stroke = "#2F3336"
          } else {
            fgCircle.style.stroke = "#1D9BF0"
            bgCircle.style.stroke = "#2F3336"
          }
          fgCircle.style.strokeDashoffset = offset;
        }

        setProgress(length);
    }
}
