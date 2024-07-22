FROM docker:cli as static-docker-source

FROM niicloudoperation/notebook:feature-lab

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

# authenticator
RUN curl -o /usr/bin/heptio-authenticator-aws https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/bin/linux/amd64/heptio-authenticator-aws && \
    curl -o /usr/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator && \
    chmod +x /usr/bin/heptio-authenticator-aws /usr/bin/aws-iam-authenticator

#RUN curl -L https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz > /tmp/helm.tar.gz && \
#    cd /tmp/ && tar zxvf helm.tar.gz && \
#    cp /tmp/linux-amd64/helm /usr/local/bin/helm
#RUN cd /tmp/ && curl -L https://github.com/jenkins-x/jx/releases/download/v1.3.1096/jx-linux-amd64.tar.gz | tar xzv && \
#    mv /tmp/jx /usr/local/bin

# utilities
RUN pip install git+https://github.com/RCOSDP/rdmclient.git

USER $NB_USER
