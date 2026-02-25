set dotenv-load
set positional-arguments

CI := env("CI", "false")
GIT_REMOTE := env("GIT_REMOTE", "origin")
default_branch := "main"

# ── Development ──────────────────────────────────────────────────────

# Run all quality checks
check: lint format-check

# Lint with shellcheck
lint:
    shellcheck -x ae tests/unit tests/integration install

# Check formatting (shfmt, diff mode)
format-check:
    shfmt -d -i 4 -ci ae install

# Auto-format
format:
    shfmt -w -i 4 -ci ae install

# ── Testing ──────────────────────────────────────────────────────────

# Run all tests
test: test-unit test-integration

# Unit tests (pure functions, no deps)
test-unit:
    bash tests/unit

# Integration tests (requires tmux, git)
test-integration:
    bash tests/integration

# ── Version ──────────────────────────────────────────────────────────

# Show current version
version:
    @grep -m1 '^AE_VERSION=' ae | cut -d'"' -f2

# Bump version: just bump patch|minor|major
bump PART="patch":
    #!/usr/bin/env bash
    set -euo pipefail
    CURRENT=$(grep -m1 '^AE_VERSION=' ae | cut -d'"' -f2)
    IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"
    case "{{PART}}" in
        major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
        minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
        patch) PATCH=$((PATCH + 1)) ;;
        *) echo "Usage: just bump patch|minor|major" >&2; exit 1 ;;
    esac
    echo "${MAJOR}.${MINOR}.${PATCH}"

# ── Changelog ────────────────────────────────────────────────────────

# Generate full CHANGELOG.md from git history
changelog:
    git-cliff -o CHANGELOG.md

# ── Release ──────────────────────────────────────────────────────────

# Full release pipeline: check → test → version → changelog → tag → gh release
# Usage: just release patch  (or minor, major)
release PART="patch":
    #!/usr/bin/env bash
    set -euo pipefail

    # Pre-flight: clean working tree (staged, unstaged, AND untracked)
    if ! git diff --quiet HEAD || [ -n "$(git ls-files --others --exclude-standard)" ]; then
        echo "Error: uncommitted or untracked changes" >&2; exit 1
    fi
    git fetch {{GIT_REMOTE}} --tags
    git pull {{GIT_REMOTE}} {{default_branch}} --rebase

    # Gate 1: Quality
    just check

    # Gate 2: Tests
    just test

    # Version
    VERSION=$(just bump {{PART}})
    echo "Releasing v$VERSION"

    # Update version in script
    sed -i "s/^AE_VERSION=\".*\"/AE_VERSION=\"$VERSION\"/" ae

    # Update version badge in README
    sed -i "s/release-[0-9]*\.[0-9]*\.[0-9]*/release-$VERSION/" README.md 2>/dev/null || true

    # Generate changelog
    TAG="v$VERSION"
    git-cliff --tag "$TAG" -o CHANGELOG.md
    RELEASE_BODY=$(git-cliff --tag "$TAG" --unreleased --strip header)
    RELEASE_BODY="${RELEASE_BODY:-Release $TAG}"

    # Commit
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    if [ "$BRANCH" != "{{default_branch}}" ]; then
        echo "Error: releases must be from {{default_branch}} (currently on $BRANCH)" >&2; exit 1
    fi

    git add CHANGELOG.md
    git add -u
    git diff --cached --quiet || git commit -m "chore(release): $TAG"

    # Tag + push
    git tag "$TAG"
    git push {{GIT_REMOTE}} "$TAG"
    git push {{GIT_REMOTE}} {{default_branch}}

    # GitHub release (best-effort, requires gh CLI with repo access)
    if command -v gh &>/dev/null; then
        REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)
        if [[ -n "$REPO" ]]; then
            gh api "repos/$REPO/releases" \
                -f tag_name="$TAG" -f target_commitish={{default_branch}} -f name="$TAG" \
                -f body="$RELEASE_BODY" -f make_latest=true > /dev/null 2>&1 \
                && echo "GitHub release created" \
                || echo "Warning: GitHub release failed (tag pushed, create release manually)" >&2
        fi
    fi

    echo "Released $TAG"

# ── Install ──────────────────────────────────────────────────────────

# Install ae (symlink to ~/.local/bin)
install:
    ./install

# ── Quick Reference ──────────────────────────────────────────────────

# Show available recipes
help:
    @just --list
