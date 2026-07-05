/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/renderer/index.html', './src/renderer/src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        panel: '#1e1e1e',
        border: '#2d2d2d',
        muted: '#9ca3af',
        accent: '#6366f1'
      }
    }
  },
  plugins: []
}
