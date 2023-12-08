module.exports = {
    mode: "jit",
    content: [
        "./app/views/**/*.html.erb",
        "./app/helpers/**/*.rb",
        "./app/javascript/**/*.js",
        "./app/assets/images/svg/*.svg"
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
                "text-dimmed": "var(--text-dimmed)",
                background: "var(--background)",
                primary: "var(--primary)",
                secondary: "var(--secondary)",
                accent: "var(--accent)",
                accent2: "var(--accent2)",
                comment: "var(--comment)",
                reposted: "var(--reposted)",
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
                toolbar: "0px 0px 50px -15px",
                dialog: "0px 0px 200px -40px",
            },
            translate: {
                switch: ("var(--theme-switch-pos)")
            },
            keyframes: {
                jump: {
                    "0%": {
                        transform: 'scale(50%)',
                    },
                    '30%': {
                        transform: 'scale(120%)',
                    },
                    '60%': {
                        transform: 'scale(85%)',
                    },
                    "100%": {
                        transform: 'scale(100%)',
                    },
                },
                "jump-out": {
                    '0%': {
                        transform: 'scale(100%)',
                    },
                    '20%': {
                        transform: 'scale(120%)',
                    },
                    '70%, 100%': {
                        transform: 'scale(0%)',
                    },
                }
            },
            animation: {
                jump: "jump .5s both",
                "jump-out": "jump-out .5s both"
            },
            animationDuration: {
                200: "200ms"
            }
        },
    },
};
