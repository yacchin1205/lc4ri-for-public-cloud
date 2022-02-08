FROM docker:18.06.3-ce as static-docker-source

FROM niicloudoperation/notebook:latest

USER root
RUN conda install awscli boto3 && apt-get update && apt-get install -y groff && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y gnupg2
ENV CLOUD_SDK_VERSION 343.0.0
COPY --from=static-docker-source /usr/local/bin/docker /usr/local/bin/docker
RUN apt-get -qqy update && apt-get install -qqy \
        curl \
        gcc \
        python-dev \
        apt-transport-https \
        lsb-release \
        openssh-client \
        git \
        expect && \
    pip install -U crcmod   && \
    export CLOUD_SDK_REPO="cloud-sdk" && \
    echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && \
    apt-get install -y google-cloud-sdk=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-app-engine-python=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-app-engine-java=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-app-engine-go=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-datalab=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-datastore-emulator=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-pubsub-emulator=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-bigtable-emulator=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-cbt=${CLOUD_SDK_VERSION}-0 \
        kubectl && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image && \
    gcloud --version && \
    docker --version && kubectl version --client

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
