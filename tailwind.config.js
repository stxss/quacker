module.exports = {
    mode: "jit",
    content: [
        "./app/views/**/*.html.erb",
        "./app/helpers/**/*.rb",
        "./app/assets/stylesheets/**/*.css",
        "./app/javascript/**/*.js",
    ],
    plugins: [
        // ...
        require("@tailwindcss/line-clamp"),
    ],
    darkMode: "class",
    theme: {
        extend: {
            colors: {
                text: "var(--text)",
                background: "var(--background)",
                primary: "var(--primary)",
                secondary: "var(--secondary)",
                accent: "var(--accent)",
                accent2: "var(--accent2)",
                comment: "var(--comment)",
                retweeted: "var(--retweeted)",
                liked: "var(--liked)",
                bookmarked: "var(--bookmarked)"
            },
            transitionTimingFunction: {
                DEFAULT: "cubic-bezier(0.25, 0.1, 0.25, 1)",
            },
            transitionDuration: {
                DEFAULT: "200ms",
            },
            boxShadow: {
                centered: "0px 0px 75px -40px",
                toolbar: "0px 0px 50px -15px"
            },
            translate: {
                switch: ("var(--theme-switch-pos)")
            }
        },
    },
};
