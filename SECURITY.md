# Security Notes

This repository documents a **self-contained lab environment** built for an educational capstone. It is not a production system.

- All machines ran in VirtualBox on an **isolated, internal-only network** with no bridge to a real network or the internet.
- **No real credentials or secrets are stored in this repository.** The setup scripts prompt for passwords at runtime via `Read-Host -AsSecureString`; nothing sensitive is hard-coded.
- Account names, IP addresses, and the domain (`migration.local`) are throwaway lab values.
- Instructor-provided "black-box" scripts are intentionally excluded (see `.gitignore`); only my own work is published here.
- The scripts make system-level changes and are intended to run **inside the lab VMs only**, never on a host machine.

If you believe you've found a leaked secret or a security issue in this repository, please open an issue and I'll address it.
