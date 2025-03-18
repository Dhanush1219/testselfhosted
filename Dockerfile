FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    unzip \
    git \
    ca-certificates \
    sudo \
    apt-transport-https \
    lsb-release \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI (NOT the daemon)
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli

# Add user for running the agent
RUN useradd -m agentuser && echo "agentuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the new user
USER agentuser

# Set work directory
WORKDIR /azp

# Copy entrypoint script
COPY start.sh /azp/start.sh
RUN chmod +x /azp/start.sh

ENTRYPOINT ["/azp/start.sh"]
