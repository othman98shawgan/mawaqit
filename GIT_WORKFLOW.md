## Git Workflow Rules (Strict Agent Instructions)

### 1. Branch Rules
- **`main` is the only permanent branch.** Never create or use a `develop` branch.
- **Never commit code directly to `main`.** All work must happen on a temporary branch created from `main`:
  - `feat/<name>` for new features
  - `fix/<name>` for bug fixes
  - `chore/<name>` for package updates, Gradle/Kotlin upgrades, or refactoring
  - `hotfix/<vX.Y.Z>` for emergency live store fixes (branch off the release Git tag, not `main`)
- **NEVER merge or create PRs:** You (the agent) are strictly forbidden from running `git merge`, `gh pr create`, or `gh pr merge`. The user handles all Pull Requests and merges manually on GitHub Web.

---

### 2. Step-by-Step Workflow for Every Task

**Step 1: Start New Task**
Before writing any code for a new task, run:
```bash
git checkout main
git pull origin main
git checkout -b <type>/<branch-name>
```
*(If the user asks to start a new task while an older feature branch is still unmerged, STOP and remind the user to merge the current branch on GitHub first).*

**Step 2: Write Code & Commit**
- Commit changes to the current branch as you work.
- Always keep `pubspec.lock` tracked and committed so historical tags reproduce exact dependency versions.
- Never mix package/Gradle upgrades with feature code on the same branch.

**Step 3: Pre-PR Checks & Push**
When the task is finished:
1. Run `flutter analyze` and `flutter test`. Fix all issues until both pass with zero errors.
2. Mark the task as `[x]` in `AGENTS.MD` on this branch so the roadmap update is included in the PR.
3. Commit and push the branch to GitHub:
```bash
git add .
git commit -m "<type>: <short summary>"
git push -u origin <branch-name>
```

**Step 4: Remind User to Open a PR (Mandatory Stop)**
Immediately after pushing the branch, **STOP working** and output this exact message to the user in chat:

> **🚀 Ready for Pull Request**
> - **Branch:** `<branch-name>` → `main`
> - **PR Title:** `<type>: <short summary>`
> - **PR Description:**
>   - <Bullet changes list made of>
>
> **Your Next Steps:**
> 1. Go to GitHub Web and open a PR from `<branch-name>` into `main`.
> 2. Click **"Squash and merge"** and delete the branch on GitHub.
> 3. Tell me once it's merged so I can pull `main`, delete the local branch, and start the next task.

**Step 5: Post-PR Cleanup**
Once the user confirms the PR is squashed and merged on GitHub, run:
```bash
git checkout main
git pull origin main
git branch -D <old-branch-name>
```
*(Note: Use `-D` because GitHub Squash & Merge creates a new commit hash on `main`).*

---

### 3. Releases (Tag-Based)
When the user asks to create a new release:
1. Switch to `main`, pull the latest code, and create branch `chore/release-vX.Y.Z`.
2. Update `version: X.Y.Z+N` in `pubspec.yaml` (always increment `+N` by 1) and update `CHANGELOG.md`.
3. Push `chore/release-vX.Y.Z` and trigger the **Step 4 PR Reminder**.
4. After the user merges the release PR on GitHub, pull `main` and tag the release:
```bash
git checkout main
git pull origin main
git tag -a vX.Y.Z+N -m "Release vX.Y.Z (Build N)"
git push origin main --tags
```
5. Build release artifacts from the tag (`flutter build appbundle --release` / `flutter build ipa --release`).

---

### 4. Emergency Store Hotfix Flow
If live store release `vX.Y.Z+N` needs an urgent fix while `main` contains unreleased work:
1. Branch from the **Git Tag**: `git checkout -b hotfix/vX.Y.Z+1 vX.Y.Z+N`
2. Fix the bug and bump `pubspec.yaml` to `X.Y.(Z+1)+(N+1)`.
3. Verify with `flutter analyze && flutter test`, commit, tag (`vX.Y.(Z+1)+(N+1)`), push the tag, and build the hotfix release.
4. Create a `fix/port-hotfix-vX.Y.Z+1` branch off `main`, cherry-pick the fix commit, and update `main`'s `pubspec.yaml` build number `+N` so the next `main` release is strictly higher than the hotfix build number. Push this branch and trigger the **Step 4 PR Reminder** so the user can merge it into `main` on GitHub Web.