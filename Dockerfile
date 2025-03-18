FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl sudo unzip jq docker.io && \
    apt-get clean

# Set environment variables
ENV AGENT_DIR=/agent
ENV AZP_AGENT_NAME=ado-agent
ENV AZP_POOL=Default

# Create a non-root user
RUN useradd -m agentuser && echo "agentuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create agent directory and set ownership
RUN mkdir -p ${AGENT_DIR} && chown agentuser:agentuser ${AGENT_DIR}

# Switch to the non-root user
USER agentuser

WORKDIR ${AGENT_DIR}

# Install Azure DevOps agent
RUN curl -LsS https://vstsagentpackage.azureedge.net/agent/3.225.0/vsts-agent-linux-x64-3.225.0.tar.gz | tar -xz
RUN ./config.sh --unattended --url ${AZP_URL} --auth pat --token ${AZP_TOKEN} --pool ${AZP_POOL} --agent ${AZP_AGENT_NAME} --replace

# Install Kaniko
RUN mkdir -p /kaniko && cd /kaniko \
    && curl -sSLO https://github.com/GoogleContainerTools/kaniko/releases/latest/download/executor \
    && chmod +x executor

# Switch back to root for Docker service
USER root

# Fix: Disable ulimits inside the Docker init script
RUN sudo sed -i 's/^ulimit/#ulimit/g' /etc/init.d/docker

# Start Docker service when the container starts
CMD ["sh", "-c", "service docker start && su - agentuser -c './svc.sh run'"]
