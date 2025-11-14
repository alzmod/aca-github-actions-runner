FROM ghcr.io/actions/actions-runner:2.329.0
# for latest release, see https://github.com/actions/runner/releases

USER root

# install dependencies
RUN apt-get update && apt-get install -y \
  curl \
  jq \
  apt-transport-https \
  ca-certificates \
  gnupg \
  lsb-release \
  wget \
  unzip \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# install az cli
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# install terraform (no sudo; ensure keyring dir exists)
RUN set -eux; \
  mkdir -p /usr/share/keyrings; \
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg; \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release; echo $UBUNTU_CODENAME) main" > /etc/apt/sources.list.d/hashicorp.list; \
  apt-get update && apt-get install -y terraform && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

USER runner

ENTRYPOINT ["./entrypoint.sh"]
