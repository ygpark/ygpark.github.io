# Makefile for Hugo project with pnpm-friendly commands

# Default values
PORT ?= 1313
BIND ?= 127.0.0.1
HUGO ?= hugo
PNPM ?= pnpm

.PHONY: help dev serve build install clean ci-build lint link

help:
	@echo "Makefile targets:"
	@echo "  make dev              - start dev server (uses pnpm to run any local scripts then hugo server -D)"
	@echo "  make serve            - start prod-like server (hugo server --bind $(BIND) --port $(PORT))"
	@echo "  make build            - build site into ./public"
	@echo "  make install          - install node deps with pnpm"
	@echo "  make clean            - remove public/ and resources/_gen/"
	@echo "  make ci-build         - clean and build (for CI)"
	@echo "  make lint             - run markdown/html lint if configured"
	@echo "  make link             - add Google Analytics links to posts"
	@echo "  make install-daemon   - set up launchd daemon for blog generation(deprecated)"
	@echo "  make uninstall-daemon - uninstall launchd daemon for blog generation(deprecated)"
	@echo "  make newpost          - create a new blog post"

# Start development server. If you have pnpm scripts (like tailwind/watch), run them first in background.
dev:
	@echo "Running pnpm install if needed..."
	@if [ -f package.json ]; then $(PNPM) install --frozen-lockfile || $(PNPM) install; fi
	@echo "Starting dev server (hugo server -D)"
	$(HUGO) server -D --bind $(BIND) --port $(PORT)

serve:
	$(HUGO) server --bind $(BIND) --port $(PORT)

build:
	$(HUGO) --minify

install:
	@if [ -f package.json ]; then $(PNPM) install; else echo "No package.json found, skipping pnpm install."; fi

clean:
	rm -rf public resources/_gen .hugo_build.lock

ci-build: clean
	$(HUGO) --minify

lint:
	@echo "No linter configured. Add lint commands to the Makefile or create a pnpm script called 'lint' in package.json."
	@if [ -f package.json ]; then $(PNPM) run lint || true; fi

link:
	python3 ./script/add_google_links.py ./content/posts/$$(date +"%Y-%m-%d")-economy.md

install-daemon:
	@echo "Setting up launchd daemon for blog generation..."
	@echo "Copying plist file to ~/Library/LaunchAgents/"
	cp ./script/com.ghostyak.blog.plist ~/Library/LaunchAgents/com.ghostyak.blog.plist

	@echo "Unloading any existing daemon..."
	launchctl unload ~/Library/LaunchAgents/com.ghostyak.blog.plist || true

	@echo "Loading the new daemon..."
	launchctl load ~/Library/LaunchAgents/com.ghostyak.blog.plist

	@echo "Daemon setup complete. You can check its status with:"
	@echo "  launchctl list | grep com.ghostyak.blog"
	@echo "Logs will be available at /tmp/com.ghostyak.blog.log and /tmp/com.ghostyak.blog.err"

uninstall-daemon:
	@echo "Unloading and removing launchd daemon..."
	launchctl unload ~/Library/LaunchAgents/com.ghostyak.blog.plist || true
	rm -f ~/Library/LaunchAgents/com.ghostyak.blog.plist
	@echo "Daemon uninstalled."

newpost:
	@echo "Creating a new blog post..."
	./script/newpost.sh