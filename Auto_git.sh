#!/bin/bash

# Ensure the script is running in a Git repository
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Not a Git repository. Exiting..."
    exit 1
fi

while true; do
    # Check for unstaged changes
    if [[ -n $(git status --porcelain) ]]; then
        echo "Changes detected. Pulling, committing, and pushing..."
        
        # Handle pull safely
        git pull --rebase || { echo "Git pull failed. Resolve conflicts manually."; exit 1; }
        
        git add -A
        git commit -m "Auto-commit: $(date +'%Y-%m-%d %H:%M:%S')"
        git push
        echo "Changes committed and pushed."
    fi

    sleep 5
done
