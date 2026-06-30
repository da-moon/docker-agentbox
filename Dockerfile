# syntax=docker/dockerfile:1.7

FROM nixos/nix:2.34.7@sha256:bf1d938835ab96312f098fa6c2e9cab367728e0aad0646ee3e02a787c80d8fb8

ENV NIX_CONFIG="experimental-features = nix-command flakes"
ENV PATH="/home/agent/.local/state/nix/profiles/agentbox/bin:/nix/var/nix/profiles/agentbox/bin:/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin"

WORKDIR /tmp/agentbox-build

COPY flake.nix flake.lock ./
COPY nix ./nix

RUN nix profile add \
      --profile /nix/var/nix/profiles/agentbox \
      --no-write-lock-file \
      .#agentbox-base \
    && mkdir -p /opt/agentbox \
    && cp -a flake.nix flake.lock /opt/agentbox/ \
    && cp -a nix /opt/agentbox/nix \
    && chmod -R a+rX /opt/agentbox \
    && rm -rf /tmp/agentbox-build /root/.cache/nix

RUN for account_file in passwd group shadow gshadow; do \
      if [ -e "/etc/${account_file}" ]; then \
        cp --dereference --preserve=mode,ownership "/etc/${account_file}" "/tmp/${account_file}"; \
        rm -f "/etc/${account_file}"; \
        mv "/tmp/${account_file}" "/etc/${account_file}"; \
      fi; \
    done \
    && groupadd --gid 1000 agent \
    && useradd \
      --uid 1000 \
      --gid 1000 \
      --create-home \
      --home-dir /home/agent \
      --shell /nix/var/nix/profiles/agentbox/bin/bash \
      agent \
    && mkdir -p /workspace /nix/var/nix/daemon-socket \
    && chown agent:agent /workspace /home/agent \
    && printf '%s\n' \
      'experimental-features = nix-command flakes' \
      'sandbox = false' \
      'build-users-group = nixbld' \
      'allowed-users = *' \
      'trusted-users = root' \
      > /etc/nix/nix.conf \
    && nix-store --gc

COPY --chmod=0755 docker/entrypoint.sh /usr/local/bin/agentbox-entrypoint

ENV HOME="/home/agent"
ENV USER="agent"
ENV LOGNAME="agent"
ENV SHELL="/nix/var/nix/profiles/agentbox/bin/bash"
ENV NIX_REMOTE="daemon"
ENV SSL_CERT_FILE="/etc/ssl/certs/ca-bundle.crt"
ENV GIT_SSL_CAINFO="/etc/ssl/certs/ca-bundle.crt"
ENV NIX_SSL_CERT_FILE="/etc/ssl/certs/ca-bundle.crt"

WORKDIR /workspace
USER root

ENTRYPOINT ["/usr/local/bin/agentbox-entrypoint"]
CMD ["bash"]
