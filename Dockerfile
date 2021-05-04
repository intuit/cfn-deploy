FROM ubuntu:16.04

LABEL version="1.0.0"

LABEL "maintainer"="Mridhul Pax <mridhuljospax@gmail.com>"
LABEL "repository"="https://github.com/mridhul/cfn-deploy"

LABEL com.github.actions.name="Cloudformation Github Deploy"
LABEL com.github.actions.description="Cloudformation Github Deploy"
LABEL com.github.actions.icon="upload-cloud"
LABEL com.github.actions.color="orange"

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y update \
&& apt-get install -y awscli shellcheck --no-install-recommends \
&& rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
