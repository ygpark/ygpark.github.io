# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Hugo static site generator project configured for blog.ghostyak.com using the PaperMod theme. The site is in Korean (ko-kr) and includes blog posts, portfolio, and contact sections.

## Development Commands

### Core Commands
- `make dev` - Start development server with draft posts (port 1313)
- `make build` - Build production site with minification to ./public
- `make clean` - Remove build artifacts (public/, resources/_gen/, .hugo_build.lock)
- `make ci-build` - Clean build for CI/CD
- `make link` - Add Google search links to H3 headings in posts

### Development Workflow
```bash
# Start development
make dev

# Build for production
make build

# Clean and rebuild
make clean && make build
```

## Architecture

### Content Structure
- `/content/posts/` - Blog posts with date-based naming (YYYY-MM-DD.md)
- `/content/about/`, `/content/portfolio/`, `/content/contact/` - Static pages
- `/content/search/` - Search functionality page (JSON output enabled)

### Theme
- Uses PaperMod theme as a Git submodule in `/themes/PaperMod/`
- Search functionality is enabled with JSON output format

### Scripts
- `/script/add_google_links.py` - Converts H3 headings in posts to Google search links
  - Removes numbering from headings (e.g., "1. Title" becomes "Title")
  - Wraps headings in markdown links to Google search

### Configuration
- Main config: `hugo.toml`
- Base URL: https://blog.ghostyak.com/
- Menu items: Home, Posts, Categories, Tags, Portfolio, About, Archives, Search, Contact

## CI/CD
- GitHub Actions workflow exists at `.github/workflows/hugo.yml`
- Use `make ci-build` for clean builds in CI environment