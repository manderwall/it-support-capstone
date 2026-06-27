# Migration & Stabilization — Windows Enterprise Lab

**AI-Enabled IT Support Capstone · Per Scholas**

Stand up a Windows Server domain from scratch, run a disruptive migration that intentionally breaks it, then investigate and stabilize the fallout — with every step scripted, evidence-captured, and documented end to end.

**Author:** Amanda Kondrat'yev  ·  **Status:** Phases 1–3 complete (build, migration, investigation). Phase 4 (corrective fixes) not undertaken; Phase 5 reporting included — full report, reflection, and a standalone [executive summary](docs/Executive-Summary.md) (see report)

---

## The problem

A small enterprise needs a domain environment migrated without losing stability. The migration is run centrally and, by design, leaves a trail of user-facing incidents. The job: restore the environment to a healthy state **methodically** — diagnose from evidence, fix one thing at a time, and verify each fix — instead of rebuilding or guessing.

## What I built

| Role | Hostname | OS | Resources | Services |
|------|----------|----|-----------|----------|
| Domain Controller | `MIG-SRV01` | Windows Server 2022 | 2 vCPU / 6 GB / 80 GB | AD DS, DNS, File Services |
| Client | `MIG-CLI01` | Windows 11 | 2 vCPU / 4 GB / 60 GB | Domain member |

- **Domain:** `migration.local` (NetBIOS `MIGRATION`)
- **Network:** VirtualBox internal-only network, static addressing (server `.10` / client `.20`)
- **File share:** `\\MIG-SRV01\SharedData`, secured to the `FileShareUsers` group (least privilege)

```
   [ MIG-CLI01 ] ----- internal network (migrationnet) ----- [ MIG-SRV01 ]
    Windows 11                                                 Windows Server 2022
    192.168.50.20                                              192.168.50.10
    domain member                                              AD DS | DNS | SMB share
                              migration.local
```

## Approach — five phases

1. **Environment & Baseline** *(complete & verified).* Built both VMs, installed the OSes, and used an AI-drafted PowerShell script — reviewed line by line — to stand up AD DS, DNS, users, groups, and a permissioned SMB share. Joined the client to the domain, validated against the instructor's verification script (all checks PASS), and snapshotted a clean baseline.
2. **Migration Event** *(complete).* Snapshotted both VMs, then executed the provided migration once on the server and recorded its completion — no other changes, so the fallout could be investigated cleanly.
3. **Incident Response** *(complete).* Investigated all six post-migration tickets on both machines with read-only diagnostics (Event Viewer, `gpresult`, DNS, and service / secure-channel / time checks). Findings: the share's NTFS `Modify` entry was stripped (Access Denied), a new `Baseline-User-Policy` GPO appeared, the printer was removed, and some services stopped — while DNS, secure channel, and time stayed healthy.
4. **Stabilization & Recovery** *(not undertaken).* The Phase 3 diagnoses identify what each fix would target; this step was not carried out — see the report's Project Status section.
5. **Reporting & Reflection** *(complete for the work performed).* The full technical report, a written reflection, and a standalone [executive summary](docs/Executive-Summary.md) are included — covering Phases 1–3, since the Phase 4 fixes were not applied.

## Engineering practices on display

This is an IT-support capstone, but it's deliberately built the way infrastructure work *should* be done — the habits that carry into DevOps, security, and governance roles:

- **Automation & repeatability.** Idempotent-minded PowerShell provisioning that auto-detects the network adapter instead of hard-coding it, so the build reproduces on any machine.
- **Observability & evidence.** Every script run auto-captures a timestamped transcript and screenshots (`Evidence-Helpers.ps1`) — an audit trail by default, not an afterthought.
- **Security by design.** Isolated internal-only network; least-privilege group permissions (Modify, not Admin); TPM 2.0, Secure Boot, and EFI on the client; **no hard-coded credentials** — passwords are prompted at runtime via `Read-Host -AsSecureString`.
- **Change control & governance.** Snapshot-before-change, one verified fix at a time, and a full documented audit trail — plus transparent AI use: generative AI assisted the scripting and analysis, and every output was human-verified before it was trusted.

## Skills demonstrated

VirtualBox & VM lifecycle · Windows Server 2022 / Active Directory (AD DS) · DNS & static networking · SMB shares & NTFS least-privilege permissions · domain join & centralized identity · PowerShell automation · structured incident response & root-cause analysis · technical writing for technical and non-technical audiences · responsible, verified use of generative AI

## How to run

> The scripts make system-level changes and are intended to run **inside the lab VMs only**, never on a host machine.

Open an **elevated Windows PowerShell** session in the target VM and run the relevant script **one block at a time** (the machine reboots between blocks). Server first, then client:

```powershell
# inside MIG-SRV01
.\scripts\MIG-SRV01_Server_Setup.ps1

# inside MIG-CLI01
.\scripts\MIG-CLI01_Client_Setup.ps1
```

Each block re-arms the evidence capture and saves transcripts/screenshots to `C:\CapstoneEvidence`.

## Repository structure

```
.
├─ README.md
├─ LICENSE
├─ SECURITY.md
├─ .gitignore
├─ docs/
│   ├─ Amanda Kondrat'yev.Capstone.pdf      # full technical report — start here
│   ├─ Amanda Kondrat'yev.Capstone.docx     # editable source of the report
│   ├─ Executive-Summary.md                 # one-page plain-language overview
│   ├─ Executive-Summary.pdf                # executive summary (PDF)
│   └─ Executive-Summary.docx               # executive summary (editable source)
├─ scripts/
│   ├─ MIG-SRV01_Server_Setup.ps1           # domain controller build
│   ├─ MIG-CLI01_Client_Setup.ps1           # client build & domain join
│   ├─ Phase3-Investigation.ps1             # read-only diagnostics
│   ├─ Phase4-Verification.ps1              # fix verification (prepared, not run)
│   └─ Evidence-Helpers.ps1                 # transcript + screenshot capture
└─ screenshots/
    ├─ phase1/                              # build & verification evidence
    ├─ phase2/                              # migration completion
    └─ phase3/                              # incident-response diagnostics
```

## Tech stack

`VirtualBox` · `Windows Server 2022` · `Windows 11` · `PowerShell` · `Active Directory / DNS` · `SMB` · generative AI (assistant, verified)

## A note on AI use

Per the program's focus, generative AI was used as a working assistant — drafting scripts, surfacing diagnostic steps, and structuring documentation. It was treated as a junior pair, not an authority: every command was read and understood before it ran, and every claim was verified against actual system output. The DNS fix in Phase 1 is a documented example — the first AI-influenced configuration failed verification, was diagnosed, and was corrected.

## License

[MIT](LICENSE) © 2026 Amanda Kondrat'yev
