#!/bin/bash
set -e

# Ensure required environment variables are set
: "${AZP_URL:?Environment variable AZP_URL is required}"
: "${AZP_TOKEN:?Environment variable AZP_TOKEN is required}"
: "${AZP_POOL:?Environment variable AZP_POOL is required}"

# Set working directory
cd /azp/agent

# Set a default agent name if not provided
AZP_AGENT_NAME="${AZP_AGENT_NAME:-$(hostname)}"

echo "🔹 Starting Azure DevOps Self-Hosted Agent..."
echo "🔹 Agent Name: $AZP_AGENT_NAME"
echo "🔹 Agent Pool: $AZP_POOL"
echo "🔹 Azure DevOps URL: $AZP_URL"

# Ensure Docker is running
if ! pgrep -x "dockerd" > /dev/null; then
    echo "🔹 Starting Docker service..."
    sudo service docker start || echo "⚠️ Failed to start Docker"
else
    echo "✅ Docker is already running."
fi

# Test Docker by running a simple container
echo "🔹 Running a test Docker container..."
docker run --rm hello-world || echo "⚠️ Docker run test failed"

# Configure the agent
echo "🔹 Configuring the Azure DevOps agent..."
./config.sh --unattended \
    --url "$AZP_URL" \
    --auth PAT \
    --token "$AZP_TOKEN" \
    --pool "$AZP_POOL" \
    --agent "$AZP_AGENT_NAME" \
    --replace

# Cleanup function to unregister the agent on container stop
cleanup() {
    echo "🔹 Removing Azure DevOps agent before shutting down..."
    ./config.sh remove --unattended --auth PAT --token "$AZP_TOKEN"
}
trap cleanup EXIT

# Run the agent
echo "✅ Agent is running. Listening for jobs..."
./run.sh

