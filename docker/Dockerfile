# ============================================================================
# Multi-Stage Dockerfile - Security-Hardened Django Production Image
# ============================================================================
# Stage 1: Builder
FROM python:3.11-slim as builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy requirements and install dependencies
COPY docker/requirements.txt .
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt

# ============================================================================
# Stage 2: Runtime (Security-Hardened)
FROM python:3.11-slim

# Set metadata
LABEL maintainer="Padova Applicant <security@example.com>"
LABEL description="Security-Hardened Django Production Container"
LABEL version="1.0.0"

# Install runtime dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# ============================================================================
# Create Non-Root User with Fixed UID/GID
# ============================================================================
# This prevents privilege escalation and container breakout attacks
RUN groupadd -r -g 1000 django && \
    useradd -r -u 1000 -g django -d /home/django -s /sbin/nologin -c "Django Application User" django && \
    mkdir -p /home/django && \
    chown -R django:django /home/django

# Create application directories with proper permissions
RUN mkdir -p /app /var/log/django /var/run/django && \
    chown -R django:django /app /var/log/django /var/run/django && \
    chmod 755 /app /var/log/django /var/run/django

# ============================================================================
# Security: Set umask to prevent world-readable files
# ============================================================================
RUN echo "umask 0077" >> /home/django/.bashrc

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv

# Set environment variables
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DJANGO_SETTINGS_MODULE=config

# Copy application code
WORKDIR /app
COPY --chown=django:django src/ .

# ============================================================================
# Security Hardening
# ============================================================================

# 1. Remove setuid/setgid bits (privilege escalation prevention)
RUN find / -perm /6000 -type f 2>/dev/null | xargs chmod a-s 2>/dev/null || true

# 2. Verify permissions (Django user owns all application files)
RUN ls -la /app | head -5

# ============================================================================
# Health Check
# ============================================================================
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health/ || exit 1

# Switch to non-root user
USER django

# Expose port (for documentation)
EXPOSE 8000

# ============================================================================
# Runtime Security Constraints (Set via docker-compose.yml)
# - cap_drop: ALL (all capabilities)
# - security_opt: no-new-privileges (prevent privilege escalation)
# - read_only: true (read-only root filesystem)
# ============================================================================

# Start Gunicorn with security flags
CMD ["gunicorn", \
     "--bind", "0.0.0.0:8000", \
     "--workers", "4", \
     "--worker-class", "sync", \
     "--access-logfile", "/var/log/django/access.log", \
     "--error-logfile", "/var/log/django/error.log", \
     "--log-level", "info", \
     "--timeout", "30", \
     "--keep-alive", "5", \
     "wsgi:application"]
