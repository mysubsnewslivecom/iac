# Stage 1: Build Go binaries using a lightweight Alpine image
FROM golang:1.23-alpine3.19 AS builder
WORKDIR /apps

# Initialize Go module (optional if you have go.mod elsewhere)
RUN go mod init scripts

# Get zerolog logging package
RUN go get github.com/rs/zerolog/log

# Copy Go source files from devcontainer folder
COPY .devcontainer/bootstrap.go bootstrap.go
COPY .devcontainer/healthz.go healthz.go

# Build static Go binaries for Linux (no CGO)
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o /apps/bootstrap bootstrap.go
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o /apps/healthz healthz.go

# Stage 2: Final image based on Ubuntu Jammy
ARG BASE_IMAGE_NAME=docker.io/ubuntu
ARG BASE_IMAGE_TAG=jammy
FROM docker.io/ubuntu:jammy AS final

# Arguments for user setup and tool versions
ARG USERNAME=linux
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Set environment variables for locale, path, etc.
ENV \
  PATH="/home/$USERNAME/.local/bin:$PATH" \
  DEBIAN_FRONTEND=noninteractive \
  TZ=UTC \
  LANGUAGE=C.UTF-8 \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8 \
  LC_CTYPE=C.UTF-8 \
  LC_MESSAGES=C.UTF-8 \
  LD_LIBRARY_PATH=/usr/local/lib \
  PIP_CACHE_DIR=/tmp/.cache/pip \
  HOME=/home/${USERNAME}

# Install essential packages and cleanup in single layer
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    jq \
    sudo \
    build-essential \
    vim \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    curl \
    locales \
    lsb-release \
    openssh-client \
    bash-completion \
    sqlite3 \
    skopeo \
    unzip \
    wget \
    fzf \
    fontconfig \
    git \
    gpg \
  && locale-gen en_US.UTF-8 \
  && update-ca-certificates \
  && apt-get autoremove -y --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create user and groups
RUN groupadd --gid $USER_GID $USERNAME \
  && groupadd docker \
  && useradd --uid $USER_UID --gid $USER_GID -s /bin/bash -m $USERNAME \
  && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  && usermod -aG docker $USERNAME

# Install tools as root before switching user
RUN curl -fsSL https://starship.rs/install.sh | sh -s -- -y

# Copy Go binaries from builder stage
COPY --from=builder --chmod=755 /apps/bootstrap /usr/local/bin/bootstrap
COPY --from=builder --chmod=755 /apps/healthz /usr/local/bin/healthz

# Switch to non-root user for remaining operations
USER $USERNAME
WORKDIR $HOME

# Install user-specific tools
RUN curl --location https://taskfile.dev/install.sh | sh -s -- -d -b ~/.local/bin

# Install Nerd Fonts (FiraCode) for better terminal font rendering
RUN mkdir -p ~/.config ~/.local/share/fonts \
  && curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip -o /tmp/FiraCode.zip \
  && unzip /tmp/FiraCode.zip -d ~/.local/share/fonts \
  && fc-cache -fv \
  && rm -f /tmp/FiraCode.zip

# Setup shell configuration
RUN touch ~/.bashrc ~/.bash_aliases ~/.bash_functions ~/.bash_config \
  && echo 'eval "$(starship init bash)"' >> ~/.bashrc \
  && echo '[ -f ~/.bash_aliases ] && source ~/.bash_aliases' >> ~/.bashrc \
  && echo '[ -f ~/.bash_functions ] && source ~/.bash_functions' >> ~/.bashrc \
  && echo '[ -f ~/.bash_config ] && source ~/.bash_config' >> ~/.bashrc

# Copy and run custom install script if present (should be last for better caching)
COPY --chown=${USERNAME}:${USERNAME} .devcontainer/install.sh /tmp/
RUN if [ -f /tmp/install.sh ]; then \
      chmod +x /tmp/install.sh && \
      /tmp/install.sh && \
      rm /tmp/install.sh; \
    else \
      echo "No install.sh found, skipping custom installation"; \
    fi

# Health check using the custom healthz binary
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD healthz

# Set working directory for development
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
