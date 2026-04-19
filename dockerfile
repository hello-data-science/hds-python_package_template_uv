# Start from a lightweight base image with a specific Python version.
# uv can also install/manage Python, but starting with a standard slim base
# keeps the container predictable and small.
FROM python:3.11-slim

# System packages needed for common Python builds (most wheels are prebuilt,
# but some packages still want a C toolchain) and for Quarto.
# Note: the long list of pyenv build deps is no longer required because
# uv fetches prebuilt Python distributions rather than compiling from source.
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set architecture-specific Quarto URL.
# This runs at build time to determine the architecture and download the correct Quarto package.
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        ARCH="amd64"; \
    elif [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then \
        ARCH="arm64"; \
    else \
        echo "Unsupported architecture"; exit 1; \
    fi && \
    curl -fsSL https://github.com/quarto-dev/quarto-cli/releases/download/v1.7.6/quarto-1.7.6-linux-${ARCH}.tar.gz | tar -xz -C /opt \
    && ln -s /opt/quarto-1.7.6/bin/quarto /usr/local/bin/quarto

# Verify Quarto installation
RUN quarto --version

# Install uv (Astral). uv is an all-in-one replacement for pip, pip-tools,
# pipx, poetry, pyenv, twine and virtualenv.
# Pinning UV_INSTALL_DIR keeps the binary on PATH for all subsequent layers.
ENV UV_INSTALL_DIR="/root/.local/bin"
ENV PATH="${UV_INSTALL_DIR}:${PATH}"
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && uv --version

# Copy rather than hardlink when populating project venvs. Inside a
# devcontainer the uv cache and .venv typically live on different
# overlay mounts, so hardlinks fail and uv emits a noisy warning on
# every install. The copy is fast enough for this template's scale.
ENV UV_LINK_MODE=copy

# Let uv manage Python versions (replaces pyenv). Pre-install the same two
# versions the previous template provided, so `uv python pin 3.9` / `3.11`
# just works inside generated projects.
RUN uv python install 3.9 3.11

# uv already creates project-local .venv directories by default, but make it
# explicit for readers of the image.
ENV UV_PROJECT_ENVIRONMENT=".venv"

# Install IPython as a uv tool (globally available, isolated env) and apply
# the same autoreload + vi editing-mode defaults as the previous image.
RUN uv tool install ipython && \
    /root/.local/bin/ipython profile create && \
    echo "c.InteractiveShellApp.extensions = ['autoreload']" >> /root/.ipython/profile_default/ipython_config.py && \
    echo "c.InteractiveShellApp.exec_lines = ['%autoreload 2']" >> /root/.ipython/profile_default/ipython_config.py && \
    echo "c.TerminalInteractiveShell.editing_mode = 'vi'" >> /root/.ipython/profile_default/ipython_config.py

# Set work directory (to be replaced in downstream images by project-specific directories)
WORKDIR /app

# Optionally add an entrypoint to make uv commands easier to run in derived images.
# (Mirrors the previous `ENTRYPOINT ["poetry"]`.)
ENTRYPOINT ["uv"]
