FROM ubuntu

LABEL version="1.0.0"

LABEL "maintainer"="Mridhul Pax <mridhuljospax@gmail.com>"
LABEL "repository"="https://github.com/mridhul/cfn-deploy"

LABEL com.github.actions.name="Cloudformation Github Deploy"
LABEL com.github.actions.description="Cloudformation Github Deploy"
LABEL com.github.actions.icon="upload-cloud"
LABEL com.github.actions.color="orange"

RUN apt-get update && apt-get install -y awscli && apt-get install -y shellcheck && \
rm -rf /var/lib/apt/lists/*

ADD entrypoint.sh /entrypoint.sh
RUN shellcheck entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
