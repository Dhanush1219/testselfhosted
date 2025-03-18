FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl sudo unzip jq docker.io && \
    apt-get clean

# Set environment variables
ENV AGENT_DIR=/agent
ENV AZP_AGENT_NAME=selfhosted-agent
ENV AZP_POOL=Default

# Create agent directory
RUN mkdir -p ${AGENT_DIR} && chmod 777 ${AGENT_DIR}
WORKDIR ${AGENT_DIR}

# Install Azure DevOps agent
RUN curl -LsS https://vstsagentpackage.azureedge.net/agent/3.225.0/vsts-agent-linux-x64-3.225.0.tar.gz | tar -xz
RUN ./config.sh --unattended --url ${AZP_URL} --auth pat --token ${AZP_TOKEN} --pool ${AZP_POOL} --agent ${AZP_AGENT_NAME} --replace

# Install Kaniko
RUN mkdir -p /kaniko && cd /kaniko \
    && curl -sSLO https://github.com/GoogleContainerTools/kaniko/releases/latest/download/executor \
    && chmod +x executor

# Start the agent
CMD ["./svc.sh", "run"]

