# Secure Django Deployment (Hardened Container)

This project demonstrates a **Production-Ready, High-Security** deployment for Django using Docker. It focuses on infrastructure hardening to prevent unauthorized access and system modifications.

## Security Features
- **Read-Only Filesystem**: Prevents attackers from modifying source code or installing malware.
- **Non-Root User**: Runs under UID 1000 to limit exploit surface.
- **No-New-Privileges**: Kernel-level protection against privilege escalation.
- **Resource Limits**: Hard-capped memory (512MB) to mitigate DoS attacks.
- **Automated Audit**: Includes a custom shell script to verify security layers at runtime.

## Requirements
- Docker >= 24
- Docker Compose >= 2.20
- Python 3.11 (for local management tasks)

## How to Use
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/secure-django-deployment.git
   cd secure-django-deployment
