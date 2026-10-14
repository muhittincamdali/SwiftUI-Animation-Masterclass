#!/usr/bin/env bash
# Renders the animated README images (docs/images/*.gif) from the package's own code.
#
# Tests/SwiftUIAnimationMasterclassTests/MediaRenderTests.swift steps ParticleSystem, the change
# effects and the physics models frame by frame, draws each frame with ImageRenderer and writes
# the frames as GIFs, in light and dark. The suite only runs when SCREENSHOT_DIR is set.
#
# Usage: scripts/render-readme-media.sh
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
output_dir="$repo_root/docs/images"
mkdir -p "$output_dir"

cd "$repo_root"
SCREENSHOT_DIR="$output_dir" swift test --filter MediaRenderTests
ls -1 "$output_dir"/*.gif
