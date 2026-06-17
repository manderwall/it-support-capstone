# 1024.3 AI-Enabled IT Support Capstone
## Migration & Stabilization — Windows Server & Client

Build a Windows domain environment, run a disruptive migration, then investigate and stabilize the issues it caused — documented end to end.

> Capstone project for the Per Scholas AI-Enabled IT Support program. Built and documented by **Amanda Kondrat'yev**.

---

## Overview

Acting as the IT support technician, I built a small Windows enterprise environment (a domain controller and a domain-joined client), executed a provided migration that intentionally destabilized the environment, then diagnosed and resolved the resulting user-reported incidents using a structured, evidence-based process. Generative AI was used as an assistant for scripting and analysis — every AI output was manually verified before use.

## Environment / Architecture

| Role | Hostname | OS | Resources | Services |
|------|----------|----|-----------|----------|
| Domain Controller | MIG-SRV01 | Windows Server 2022 | 2 vCPU / 6 GB / 80 GB | AD DS, DNS, File Services |
| Client | MIG-CLI01 | Windows 11 | 2 vCPU / 4 GB / 60 GB | Domain member |

- **Domain:** migration.local (NetBIOS: MIGRATION)
- **Network:** VirtualBox Internal Network, static addressing (server .10 / client .20)
- **File share:** `\\MIG-SRV01\SharedData`, secured to the `FileShareUsers` group

```
   [ MIG-CLI01 ]----- Internal Network (migrationnet) -----[ MIG-SRV01 ]
    Windows 11                                               Windows Server 2022
    192.168.50.20                                            192.168.50.10
    domain member                                            AD DS | DNS | SMB share
                              migration.local
```

## What I Did

**Phase 1 — Environment & Baseline.** Built both VMs in VirtualBox and installed the operating systems. Used AI to draft a PowerShell setup script (reviewed and verified line by line) to stand up AD DS, DNS, the user and group accounts, and an SMB file share. Joined the client to the domain, validated the baseline, and snapshotted.

**Phase 2 — Migration Event.** Executed the provided migration once on the server under change-control discipline — captured execution evidence, made no changes.

**Phase 3 — Incident Response.** Investigated six post-migration tickets (shared-file access, slow logon, desktop policy, printer availability, performance, intermittent access) using Event Viewer, `gpresult`, DNS lookups, service checks, and secure-channel/time checks. Collected evidence and correlated related issues. _(Root causes: summarize what you found.)_

**Phase 4 — Stabilization & Recovery.** Applied targeted, evidence-based fixes one at a time and re-tested each against the original symptom. _(Fixes: summarize what you changed.)_

**Phase 5 — Reporting.** Produced the full technical report (PDF), an executive summary for non-technical stakeholders, and a professional reflection.

## Skills Demonstrated

- VirtualBox virtualization and VM lifecycle management
- Windows Server 2022 setup and Active Directory (AD DS)
- DNS and static IP network configuration
- SMB file sharing and NTFS permissions
- Group Policy and domain authentication troubleshooting
- Domain join and centralized account/group management
- PowerShell scripting and automation
- Structured incident response and root-cause analysis
- Technical documentation for technical and non-technical audiences
- Responsible, verified use of generative AI

## Repository Contents

| Item | Description |
|------|-------------|
| `Amanda Kondrat'yev.Capstone.pdf` | Final technical report — **start here** |
| `scripts/` | PowerShell setup scripts (server and client) |
| `screenshots/` | Evidence, organized by phase |
| `README.md` | This file |

## Tools

VirtualBox · Windows Server 2022 · Windows 11 · PowerShell · Active Directory / DNS · Generative AI (assistant, verified)

---
