# Workflow: worktrees via worktrunk

Every repo is a bare clone under `~/Doctolib/<repo>/.git` or `~/Perso/<repo>/.git`, with worktrees as sibling folders (`~/Doctolib/<repo>/<branch>`).

Before starting work on any new topic/task in a git repo, always create a dedicated worktree with `wt switch --create <branch>` (worktrunk) instead of working directly in an existing checkout. Never work on an unrelated topic inside someone else's or the main worktree.

- New repo: `wt-clone <url> ~/Doctolib/<repo>/.git` (or `~/Perso/<repo>/.git` for personal repos; `wt-clone` is a `git clone --bare` alias), then `wt switch <default-branch>` (main or master, whichever the repo uses) to get a working checkout.
- New task in an existing repo: `wt switch --create <branch-name>`.
- Done: `wt remove` after the branch is merged, or `wt prune` to bulk-clean everything already merged.
