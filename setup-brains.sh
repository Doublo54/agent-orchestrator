#!/usr/bin/env bash
# ============================================================
# DeFiZoo — Brain Repo Setup
# ============================================================
# Clones all brain repos into brains/ for volume mounting.
# Run once after cloning the orchestrator repo.
#
# Usage: ./setup-brains.sh
#
# Each brain is its own git repo. Agents read/write to their
# brain and can commit+push changes back to GitHub.
# ============================================================

set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[ok]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!!]${NC} $*"; }
fail()  { echo -e "${RED}[xx]${NC} $*"; }
step()  { echo -e "\n${BOLD}--- $* ---${NC}"; }

# ============================================================
# CONFIGURE THESE — set your GitHub org/user and repo names
# ============================================================
GITHUB_ORG="DeFiZooKeeper"

declare -A BRAIN_REPOS=(
  [frontend]="${GITHUB_ORG}/frontend-brain"
  [backend]="${GITHUB_ORG}/backend-brain"
  [solidity]="${GITHUB_ORG}/solidity-brain"
  [hr]="${GITHUB_ORG}/hr-brain"
)
# ============================================================

echo ""
echo -e "${BOLD}DeFiZoo Brain Setup${NC}"
echo -e "Cloning brain repos into brains/"
echo ""

mkdir -p brains

for brain in frontend backend solidity hr; do
    repo="${BRAIN_REPOS[$brain]}"
    step "$brain brain → $repo"

    if [ -d "brains/$brain/.git" ]; then
        warn "Already cloned. Pulling latest..."
        (cd "brains/$brain" && git pull)
        info "$brain brain updated"
    else
        # Clean out any placeholder files
        rm -rf "brains/$brain"

        if git clone "https://github.com/${repo}.git" "brains/$brain" 2>/dev/null; then
            info "$brain brain cloned"
        else
            warn "Could not clone https://github.com/${repo}.git"
            warn "Repo may not exist yet. Creating empty brain directory..."
            mkdir -p "brains/$brain"
            echo "# Clone manually: git clone https://github.com/${repo}.git brains/$brain" > "brains/$brain/README.md"
        fi
    fi
done

# --- Summary ---
step "Brain status"

for brain in frontend backend solidity hr; do
    if [ -d "brains/$brain/.git" ]; then
        info "$brain: git repo ✓"
    elif [ -d "brains/$brain" ]; then
        warn "$brain: directory exists but not a git repo (create the GitHub repo first)"
    else
        fail "$brain: missing"
    fi
done

echo ""
echo -e "${BOLD}How it connects:${NC}"
echo ""
echo "  brains/frontend/  →  mounted as workspace for Frontend Elephant (🐘)"
echo "  brains/backend/  →  mounted as workspace for API Octopus (🐙)"
echo "  brains/solidity/ →  mounted as workspace for Solidity Monkey (🐒)"
echo "  brains/hr/  →  mounted as workspace for HR Parrot (🦜)"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo ""
echo "  1. Replace REPLACE_* placeholders in state/openclaw.json with Discord IDs"
echo "  2. Make sure .env has your tokens"
echo "  3. docker compose up -d && docker compose logs -f"
echo ""
