# Tradesperson Example - Eleventy Site

## Build & Development Commands
- Build: `bin/build` (cleans _site, compiles SASS, runs eleventy)
- Serve: `bin/serve` (runs eleventy --serve with SASS watch)
- HTML Tidy: `bin/tidy_html` (formats HTML output)
- Single file SASS: `sass src/_scss/file.scss _site/css/file.css --style compressed`

## Code Style Guidelines
- **HTML**: Use 2-space indentation, max line length 80 chars
- **Layouts**: Follow BEM-like naming in templates and CSS
- **Includes**: Modular, reusable components in `_includes/`
- **JS**: Minimal JS, keep in `assets/js/` directory
- **Data**: Site-wide config in `_data/site.json`
- **Images**: Store in `images/` directory, use descriptive filenames
- **URLs**: Use absolute URLs with canonical structure
- **Markdown**: Use for content files with frontmatter
- **Error handling**: Use 11ty built-in error reporting
- **Collections**: Define in 11tydata.js files