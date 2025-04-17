FROM debian:12-slim

# Install tool dependencies for app and git/ssh for the workspace
RUN apt-get update  \
  && apt-get install -y --no-install-recommends \
    sudo gpg make wget curl ssh git ca-certificates build-essential \
    ripgrep fd-find \
    pkg-config libssl-dev \
  && rm -rf /var/lib/apt/lists/* \
  && cp /usr/bin/fdfind /usr/bin/fd \
  && install -dm 755 /etc/apt/keyrings

#RUN #wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null \
#    && echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list \
#    && apt update \
#    && apt install -y mise

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV MISE_DATA_DIR="/mise"
ENV MISE_CONFIG_DIR="/mise"
ENV MISE_CACHE_DIR="/mise/cache"
ENV MISE_INSTALL_PATH="/usr/local/bin/mise"
ENV PATH="/mise/shims:$PATH"
# ENV MISE_VERSION="..."

RUN curl https://mise.run | sh

RUN mise install
