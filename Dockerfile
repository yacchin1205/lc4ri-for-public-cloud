FROM docker:cli as static-docker-source

FROM yacchin1205/notebook@sha256:eb52a81ec0e4a3f5bd32d60fd40899de894c2079edd2a8c9f4c6c80871832bf7

USER root
RUN conda install awscli boto3 && apt-get update && apt-get install -y groff gnupg2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV CLOUD_SDK_VERSION 484.0.0
COPY --from=static-docker-source /usr/local/bin/docker /usr/local/bin/docker
RUN apt-get -qqy update && apt-get install -qqy \
        curl \
        gcc \
        python3-dev \
        apt-transport-https \
        lsb-release \
        openssh-client \
        git \
        expect && \
    pip install -U crcmod   && \
    export CLOUD_SDK_REPO="cloud-sdk" && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    apt-get update && \
    apt-get install -y \
        google-cloud-cli=${CLOUD_SDK_VERSION}-0 \
        kubectl \
        google-cloud-cli-gke-gcloud-auth-plugin=${CLOUD_SDK_VERSION}-0 && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image && \
    gcloud --version && \
    docker --version && kubectl version --client && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    chown $NB_USER:users -R $HOME/.config/gcloud
RUN curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 /tmp/get_helm.sh && \
    /tmp/get_helm.sh

# utilities
RUN pip install git+https://github.com/RCOSDP/rdmclient.git

USER $NB_USER
