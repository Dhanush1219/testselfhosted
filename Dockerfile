# Use an official Ubuntu base image
FROM ubuntu:20.04

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install required packages
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    gnupg \
    lsb-release

# Install Docker (latest version)
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
    echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io

# Create a non-root user and grant sudo privileges
RUN useradd -m agentuser && echo "agentuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set working directory and copy files
WORKDIR /azp
COPY start.sh /azp/start.sh

# Ensure correct ownership and permissions
RUN chown agentuser:agentuser /azp/start.sh && chmod +x /azp/start.sh

# Switch to non-root user
USER agentuser

# Disable ulimits for Docker inside the container
RUN sudo sed -i 's/^ulimit/#ulimit/g' /etc/init.d/docker

# Start Docker inside the container and run the agent
CMD sudo service docker start && /azp/start.sh
