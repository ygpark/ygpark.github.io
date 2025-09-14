# Makefile for Hugo project with pnpm-friendly commands

# Default values
PORT ?= 1313
BIND ?= 127.0.0.1
HUGO ?= hugo
PNPM ?= pnpm

.PHONY: help dev serve build install clean ci-build lint

help:
	@echo "Makefile targets:"
	@echo "  make dev        - start dev server (uses pnpm to run any local scripts then hugo server -D)"
	@echo "  make serve      - start prod-like server (hugo server --bind $(BIND) --port $(PORT))"
	@echo "  make build      - build site into ./public"
	@echo "  make install    - install node deps with pnpm"
	@echo "  make clean      - remove public/ and resources/_gen/"
	@echo "  make ci-build   - clean and build (for CI)"
	@echo "  make lint       - run markdown/html lint if configured"

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