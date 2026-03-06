#!/usr/bin/env bash
set -euo pipefail

# Creates, approves, and merges a PR from dev -> main using GitHub CLI.
# Keeps both branches by never requesting branch deletion on merge.

BASE_BRANCH="main"
HEAD_BRANCH="dev"
MERGE_METHOD="merge" # merge | squash | rebase
PR_TITLE=""
PR_BODY=""
REPO_ARG=""

usage() {
  cat <<'EOF'
Usage: ./pr_dev_to_main.sh [options]

Options:
  --repo OWNER/REPO     GitHub repo override (defaults to current repo)
  --title "..."          PR title (optional)
  --body "..."           PR body (optional)
  --merge-method METHOD  merge | squash | rebase (default: merge)
  -h, --help            Show this help

Requirements:
  - git configured for this repository
  - gh CLI installed and authenticated (gh auth status)

Behavior:
  - Creates or reuses an open PR from dev -> main
  - Approves the PR
  - Merges the PR without deleting branches
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO_ARG="$2"
      shift 2
      ;;
    --title)
      PR_TITLE="$2"
      shift 2
      ;;
    --body)
      PR_BODY="$2"
      shift 2
      ;;
    --merge-method)
      MERGE_METHOD="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ "$MERGE_METHOD" != "merge" && "$MERGE_METHOD" != "squash" && "$MERGE_METHOD" != "rebase" ]]; then
  echo "Invalid --merge-method: $MERGE_METHOD" >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git is required but not installed." >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI is required but not installed." >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "gh is not authenticated. Run: gh auth login" >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Run this script from inside a git repository." >&2
  exit 1
fi

REPO_FLAGS=()
if [[ -n "$REPO_ARG" ]]; then
  REPO_FLAGS=(--repo "$REPO_ARG")
fi

echo "Fetching latest refs..."
git fetch origin "$BASE_BRANCH" "$HEAD_BRANCH"

if ! git show-ref --verify --quiet "refs/remotes/origin/$BASE_BRANCH"; then
  echo "Remote branch origin/$BASE_BRANCH does not exist." >&2
  exit 1
fi

if ! git show-ref --verify --quiet "refs/remotes/origin/$HEAD_BRANCH"; then
  echo "Remote branch origin/$HEAD_BRANCH does not exist." >&2
  exit 1
fi

if [[ -z "$PR_TITLE" ]]; then
  PR_TITLE="Merge $HEAD_BRANCH into $BASE_BRANCH"
fi

if [[ -z "$PR_BODY" ]]; then
  PR_BODY="Automated PR created by script: $HEAD_BRANCH -> $BASE_BRANCH"
fi

echo "Looking for an existing open PR ($HEAD_BRANCH -> $BASE_BRANCH)..."
PR_NUMBER="$(gh pr list "${REPO_FLAGS[@]}" --state open --base "$BASE_BRANCH" --head "$HEAD_BRANCH" --json number --jq '.[0].number')"

if [[ -z "$PR_NUMBER" || "$PR_NUMBER" == "null" ]]; then
  echo "No open PR found. Creating one..."
  PR_URL="$(gh pr create "${REPO_FLAGS[@]}" --base "$BASE_BRANCH" --head "$HEAD_BRANCH" --title "$PR_TITLE" --body "$PR_BODY")"
  echo "Created PR: $PR_URL"
  PR_NUMBER="$(gh pr view "${REPO_FLAGS[@]}" "$PR_URL" --json number --jq '.number')"
else
  echo "Using existing PR #$PR_NUMBER"
fi

echo "Approving PR #$PR_NUMBER..."
# Approval can fail if your account cannot approve this PR (e.g. self-approval blocked).
if ! gh pr review "${REPO_FLAGS[@]}" "$PR_NUMBER" --approve; then
  echo "Approval step failed. Continuing to merge attempt." >&2
fi

echo "Merging PR #$PR_NUMBER with method '$MERGE_METHOD'..."
MERGE_FLAG="--merge"
if [[ "$MERGE_METHOD" == "squash" ]]; then
  MERGE_FLAG="--squash"
elif [[ "$MERGE_METHOD" == "rebase" ]]; then
  MERGE_FLAG="--rebase"
fi

gh pr merge "${REPO_FLAGS[@]}" "$PR_NUMBER" "$MERGE_FLAG"

echo "Done. PR #$PR_NUMBER merged. Branches '$HEAD_BRANCH' and '$BASE_BRANCH' were not deleted by this script."