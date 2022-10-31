ARG CODE_SERVER_IMG=codercom/code-server
ARG CODE_SERVER_TAG=latest
FROM ${CODE_SERVER_IMG}:${CODE_SERVER_TAG}

RUN sudo apt-get update \
      && sudo apt-get install -y --no-install-recommends \
        bash \
        bash-completion \
        build-essential \
        clang-format \
        clang-tidy \
        cmake \
        command-not-found \
        git \
        nano \
        pigz \
        python3 \
        python3-venv \
        shellcheck \
        tmux \
      && sudo apt-get clean \
      && sudo rm -rf /var/lib/apt/lists/*

# Install SmingFramework developer setup
ARG SMING_REPO=https://github.com/jneuhauser/Sming
ARG SMING_REF=master
RUN sudo chown 1000:1000 /opt \
      && git clone --depth 1 -b "${SMING_REF}" "${SMING_REPO}" /opt/sming \
      && /bin/bash -c ". /opt/sming/Tools/install.sh all" \
      && /bin/bash -c "rm -rf /home/coder/{.cache,.wget-hsts,downloads}"
ENV SMING_HOME=/opt/sming/Sming
ENV ESP_HOME=/opt/esp-quick-toolchain
ENV IDF_PATH=/opt/esp-idf
ENV IDF_TOOLS_PATH=/opt/esp32
ENV ESP32_PYTHON_PATH=/usr/bin
ENV PICO_TOOLCHAIN_PATH=/opt/rp2040

# Setup microsoft vscode extension store.
# https://coder.com/docs/code-server/latest/FAQ#how-do-i-use-my-own-extensions-marketplace
ENV EXTENSIONS_GALLERY='{"serviceUrl":"https://marketplace.visualstudio.com/_apis/public/gallery","cacheUrl":"https://vscode.blob.core.windows.net/gallery/index","itemUrl":"https://marketplace.visualstudio.com/items"}'

# Install some useful vscode extensions.
ARG INSTALL_EXTENSIONS="ms-python.python,ms-vscode.cpptools,ms-vscode.cpptools-extension-pack,eamodio.gitlens,timonwong.shellcheck"
RUN /bin/bash -c 'for ext in ${INSTALL_EXTENSIONS//,/ }; do code-server --install-extension "${ext}"; done'

# Set entrypoint dir and copy custom scripts into it.
# https://github.com/coder/code-server/pull/5194
ENV ENTRYPOINTD=/entrypoint.d
COPY entrypoint.d/* ${ENTRYPOINTD}/

# Extracting coder.tar.gz to home with entrypoint.d/init-home.sh
# script to create default files if /home/coder is a mountpoint.
RUN sudo tar -I pigz -cvf /home/coder.tar.gz -C /home/coder .
