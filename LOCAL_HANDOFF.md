# Local Handoff — Add Phase 1 Screenshots

This task must be finished from a **local** Claude Code session running in a
terminal **on Amanda's PC** (where the Google Drive folder is synced). The
remote/web session cannot reach the PC's filesystem, and streaming the image
binaries back through the Drive connector is impractical.

## Goal
Add the 9 Phase 1 evidence screenshots to this repo under `screenshots/phase1/`,
then commit and push. (Report PDF/docx is intentionally **skipped** this round —
Phase 1 only.)

## Repo / branch
- Repo: `manderwall/it-support-capstone`
- Branch: `claude/blissful-heisenberg-5ccqe9`
  (create from `origin/claude/blissful-heisenberg-5ccqe9` if not checked out;
  clone the repo first if you don't have it locally)

## Source of the screenshots
The Google-Drive-synced folder `…/Per Scholas/Capstone/`. The 9 PNGs live in
that folder directly — **not** in `_repo_upload/`, which is currently empty.

## Files to copy into `screenshots/phase1/`
- `amanda_p1_01_extensionpack.png`
- `amanda_p1_01b_virtualbox_version.png`
- `amanda_p1_02_server_vm_settings.png`
- `amanda_p1_03_server_desktop.png`
- `amanda_p1_04_client_vm_settings.png`
- `amanda_p1_05_snapshot_cleanos.png`
- `amanda_p1_07_domain_login.png`
- `amanda_p1_08_share_access.png`
- `amanda_p1_09_verification_pass.png`

(There is no `06`; `01b` is the VirtualBox version shot. This is the full
Phase 1 set, consistent with the report's Appendix A references.)

## Hard constraints (from CAP-001 handoff) — NEVER commit
- Instructor black-box scripts: `Phase1-EnvironmentVerification.ps1`,
  `Phase2-MigrationEvent.ps1`
- Any `*.iso` files (~12 GB total)
- The `CapstoneEvidence/` folder

## Steps
1. `git checkout claude/blissful-heisenberg-5ccqe9` (or create it from origin)
2. Copy the 9 files above into `screenshots/phase1/`
3. `git add screenshots/phase1/`
4. `git commit -m "Add Phase 1 evidence screenshots"`
5. `git push -u origin claude/blissful-heisenberg-5ccqe9`

## Loose end for later
`README.md` lists a report PDF under "Repository Contents," but no PDF exists
yet. Export it from Word (Ctrl+A → F9 to update the TOC/List of Figures, then
Export to PDF) before that link will work. Not required for this screenshot push.
