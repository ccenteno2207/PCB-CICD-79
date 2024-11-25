FROM alpine:3.18.6 as base
COPY plugins.py /opt/plugins.py
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
ARG GO_VERSION="1.20.10"
ENV PATH="/usr/local/go/bin:${PATH}"
COPY plugins.json /opt/plugins.json
RUN apk --no-cache add \
    jq=1.6-r4 \
    curl=8.9.1-r1 \
    unzip=6.0-r14 \
    tar=1.34-r3 \
    python3=3.11.10-r1 \
    py3-pip=23.1.2-r0 && \
    VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version') ;\
    curl -LsS \
    "https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_amd64.zip" -o /tmp/terraform.zip && \
    unzip /tmp/terraform.zip -d /tmp/ && \
    chmod +x /tmp/terraform && \
    mv /tmp/terraform /usr/bin/ && \
    rm -f ./terraform.zip && \
    VERSION=$(curl -LsS https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | jq -r .name) ;\
    curl -LsS \
    "https://github.com/gruntwork-io/terragrunt/releases/download/${VERSION}/terragrunt_linux_amd64" -o /usr/bin/terragrunt ;\
    chmod +x /usr/bin/terragrunt&& \
    VERSION=$(curl -LsS https://api.github.com/repos/terraform-linters/tflint/releases/latest | jq -r .name) ;\
    curl -LsS \
    "https://github.com/terraform-linters/tflint/releases/download/${VERSION}/tflint_linux_amd64.zip" -o tflint.zip ;\
    unzip tflint.zip -d /usr/bin ;\
    rm tflint.zip && \
    curl -Ls -o /usr/bin/tfsec https://github.com/tfsec/tfsec/releases/latest/download/tfsec-linux-amd64 && \
    chmod +x /usr/bin/tfsec && \
    python3 /opt/plugins.py && \
    curl -LsS https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz -o go.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz && \
    curl -Lo /usr/local/bin/go-getter https://github.com/hashicorp/go-getter/releases/download/v1.7.3/go-getter_1.7.3_linux_amd64.zip && \
    chmod +x /usr/local/bin/go-getter 



FROM alpine:3.18.6 as iac
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin
ENV TF_CLI_CONFIG_FILE=/home/terraformrc
ENV PATH="/usr/local/go/bin:${PATH}"
ARG APK_GLIBC_VERSION=2.35-r1
ARG APK_GLIBC_FILE="glibc-${APK_GLIBC_VERSION}.apk"
ARG APK_GLIBC_BIN_FILE="glibc-bin-${APK_GLIBC_VERSION}.apk"
ARG APK_GLIBC_I18N_FILE="glibc-i18n-${APK_GLIBC_VERSION}.apk"
ARG APK_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${APK_GLIBC_VERSION}"

RUN apk update && \
    apk add --no-cache \
    gcc=12.2.1_git20220924-r10 \
    musl-dev=1.2.4-r2 \
    python3-dev=3.11.10-r1 \
    libffi-dev=3.4.4-r2 \
    git=2.40.3-r0 \
    jq=1.6-r4 \
    jo=1.9-r0 \
    curl=8.9.1-r1 \
    unzip=6.0-r14 \
    yq=4.33.3-r5 \
    docker=25.0.5-r0 \
    docker-compose=2.17.3-r5 \
    python3=3.11.10-r1 \
    py3-pip=23.1.2-r0 \
    nodejs-current=20.8.1-r0 \
    npm=9.6.6-r0 \   
    docker=25.0.5-r0 \
    docker-compose=2.17.3-r8 && \
    apk --update --no-cache --virtual .build-deps==20230825.192007 add groff==1.22.4-r4

RUN pip install --no-cache-dir boto3==1.28.62 \
    htmlmin==0.1.12 \
    ansible==8.5.0 \
    certifi==2023.7.22

RUN npm install -g \
    html-minifier@4.0.0 \
    html-validate@8.0.5 \
    serverless-openapi-integration-helper@2.3.0 && \
    curl https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub && \
    curl -sLO "${APK_GLIBC_BASE_URL}/${APK_GLIBC_FILE}" && \
    curl -sLO "${APK_GLIBC_BASE_URL}/${APK_GLIBC_BIN_FILE}" && \
    curl -sLO "${APK_GLIBC_BASE_URL}/${APK_GLIBC_I18N_FILE}" && \
    apk add --no-cache \
    "${APK_GLIBC_FILE}" \
    "${APK_GLIBC_BIN_FILE}" \
    "${APK_GLIBC_I18N_FILE}" && \
    /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    ln -sf /usr/glibc-compat/lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2 && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.13.25.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm awscliv2.zip  && \
    curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz && \
    mkdir -p /usr/local/gcloud  && \
    tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz && \
    /usr/local/gcloud/google-cloud-sdk/install.sh 


#copy terraform, tflint, tfsec, and terragrunt
COPY --from=base /usr/bin/terraform /usr/bin/terraform
COPY --from=base /usr/bin/terragrunt /usr/bin/terragrunt
COPY --from=base /usr/bin/tflint /usr/bin/tflint
COPY --from=base /usr/bin/tfsec /usr/bin/tfsec
COPY --from=base /opt/plugins /opt/plugins
COPY --from=base /usr/local/bin/go-getter /usr/local/bin/go-getter
COPY --from=base /usr/local/go/bin/go /usr/local/go/bin/go
RUN ls -la /opt/plugins/registry.terraform.io

RUN rm -rf \
    /usr/local/lib/aws-cli/aws_completer \
    /usr/local/lib/aws-cli/awscli/data/ac.index \
    /usr/local/lib/aws-cli/awscli/examples \
    && aws --version && \   
    terraform --version && \
    terragrunt --version && \
    tflint --version && \
    tfsec --version && \
    git --version  && \
    go version && \
    gcloud version

WORKDIR /app
ENTRYPOINT [ "/usr/bin/terraform" ]