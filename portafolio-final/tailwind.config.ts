import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: "#1E90FF",
        accent: "#FFD700",
        brown: "#8B4513",
        indigoDark: "#1D1B4E",
        bgDark: "#071724",
        panel: "#0b2332",
      },
      boxShadow: {
        pixel: "0 6px 0 #000",
      },
    },
  },
  plugins: [],
};

export default config;
