---
name: mobile-ship
description: Mobile trigger: commit + push + PR without confirmations
---

Run /ship --auto on the current working directory. Commit all pending changes with an appropriate conventional commit message, push to remote, and create a PR. Do not ask for confirmation — proceed with safe defaults. Tests must still pass before pushing. Report the PR URL when done. Write results to sessions/mobile-output.md.