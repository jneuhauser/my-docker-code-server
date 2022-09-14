FROM codercom/code-server:latest

# Install VSCode extensions
#ARG OPENVSX_EXTENSIONS="eamodio.gitlens,ms-python.python,ms-azuretools.vscode-docker"
#RUN for ext in ${OPENVSX_EXTENSIONS//,/ }; do \
#      code-server --install-extension "${ext}"; \
#    done

#ARG CPPTOOLS_VSIX_URL=https://github.com/microsoft/vscode-cpptools/releases/download/v1.10.8/cpptools-linux.vsix
#RUN wget -O extension.vsix "${CPPTOOLS_VSIX_URL}" && \
#      code-server --install-extension extension.vsix

ARG INSTALL_EXTENSIONS="ms-python.python,ms-vscode.cpptools,eamodio.gitlens,ms-azuretools.vscode-docker"
# https://coder.com/docs/code-server/latest/FAQ#how-do-i-use-my-own-extensions-marketplace
ENV EXTENSIONS_GALLERY='{"serviceUrl":"https://marketplace.visualstudio.com/_apis/public/gallery","cacheUrl":"https://vscode.blob.core.windows.net/gallery/index","itemUrl": "https://marketplace.visualstudio.com/items"}'
RUN for ext in ${INSTALL_EXTENSIONS//,/ }; do \
      code-server --install-extension "${ext}"; \
    done

RUN sudo apt-get update \
      && sudo apt-get install -y --no-install-recommends \
        bash \
        build-essential \
        cmake \
        git \
        nano \
        python3 \
        python3-venv \
        tmux \
      && sudo apt-get clean \
      && sudo rm -rf /var/lib/apt/lists/*

ARG SMING_REF=master
RUN sudo chown 1000:1000 /opt \
      && git clone --depth 1 -b "${SMING_REF}" \
        https://github.com/SmingHub/Sming /opt/sming \
      && /bin/bash -c ". /opt/sming/Tools/install.sh all" \
      && rm -rf /home/coder/.cache /home/coder/downloads
ENV SMING_HOME=/opt/sming/Sming
ENV ESP_HOME=/opt/esp-quick-toolchain
ENV IDF_PATH=/opt/esp-idf
ENV IDF_TOOLS_PATH=/opt/esp32
ENV ESP32_PYTHON_PATH=/usr/bin
ENV PICO_TOOLCHAIN_PATH=/opt/rp2040

# Extracting home.tar.gz to coders home with custom entrypoint
# creates defaults if coders home is mounted as volume.
RUN touch .initialized_home && tar czf /opt/home.tar.gz . 
COPY my-entrypoint.sh /usr/bin/my-entrypoint.sh
RUN mv /usr/bin/entrypoint.sh /usr/bin/entrypoint-code-server.sh \
      mv /usr/bin/my-entrypoint.sh /usr/bin/entrypoint.sh
#ENTRYPOINT ["/usr/bin/my-entrypoint.sh", "--bind-addr", "0.0.0.0:8080", "."]
