# syntax=docker/dockerfile:1.7

FROM nixos/nix:2.34.7@sha256:bf1d938835ab96312f098fa6c2e9cab367728e0aad0646ee3e02a787c80d8fb8 AS build

ENV NIX_CONFIG="experimental-features = nix-command flakes"
ENV PATH="/home/agent/.local/state/nix/profiles/agentbox/bin:/nix/var/nix/profiles/agentbox/bin:/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin"

WORKDIR /tmp/agentbox-build

COPY nix ./
COPY scripts ./scripts

RUN nix profile add \
      --profile /nix/var/nix/profiles/agentbox \
      --no-write-lock-file \
      .#agentbox-base \
    && s6_overlay="$(nix build --no-link --print-out-paths .#s6-overlay)" \
    && cp -a "${s6_overlay}/." / \
    && nix-store --delete "$s6_overlay" \
    && harness_commands="$(nix build --no-link --print-out-paths .#agentbox-commands)" \
    && mkdir -p /opt/agentbox /run \
    && cp -a /tmp/agentbox-build/. /opt/agentbox/ \
    && cp "$harness_commands" /opt/agentbox/harness-commands \
    && chmod -R a+rX /opt/agentbox \
    && rm -rf /tmp/agentbox-build /root/.cache/nix \
    && nix-store --gc

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
    && mkdir -p /workspace /run \
    && chown agent:agent /workspace /home/agent \
    && printf '%s\n' \
      'experimental-features = nix-command flakes' \
      'sandbox = false' \
      'build-users-group = nixbld' \
      'allowed-users = *' \
      'trusted-users = root' \
      > /etc/nix/nix.conf \
    && rm -f /root/.nix-channels \
    && rm -rf /root/.nix-defexpr \
    && rm -f /nix/var/nix/profiles/per-user/root/channels \
             /nix/var/nix/profiles/per-user/root/channels-*-link \
    && rm -f /nix/var/nix/gcroots/docker/*base-system* \
    && nix-store --gc

COPY docker/rootfs /

# Collapse every layer into one. agentbox installs via flakes (path:/opt/agentbox#...),
# so the base image's baked-in nixos channel and its ~460MB nixpkgs source are dead
# weight; removing them above only produces whiteouts while the bytes linger in the
# lower layers. Copying the merged rootfs onto a scratch base drops them for real.
# BuildKit's COPY --from preserves the Nix store's hardlink optimisation.
FROM scratch

COPY --from=build / /

ENV NIX_CONFIG="experimental-features = nix-command flakes"
ENV PATH="/home/agent/.local/state/nix/profiles/agentbox/bin:/home/agent/.local/state/nix/profiles/home-manager/home-path/bin:/nix/var/nix/profiles/agentbox/bin:/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin"
ENV HOME="/home/agent"
ENV USER="agent"
ENV LOGNAME="agent"
ENV SHELL="/nix/var/nix/profiles/agentbox/bin/bash"
ENV NIX_REMOTE="daemon"
ENV NIX_DAEMON_SOCKET_PATH="/run/nix-daemon/socket"
ENV S6_CMD_ARG0="/command/with-contenv /usr/local/bin/agentbox-cmd"
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2"
ENV SSL_CERT_FILE="/etc/ssl/certs/ca-bundle.crt"
ENV GIT_SSL_CAINFO="/etc/ssl/certs/ca-bundle.crt"
ENV NIX_SSL_CERT_FILE="/etc/ssl/certs/ca-bundle.crt"

WORKDIR /workspace
USER root

ENTRYPOINT ["/usr/local/bin/agentbox-init"]
CMD ["bash"]
