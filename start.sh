#!/bin/bash
set -e

echo "🔹 Starting Azure DevOps Self-Hosted Agent..."

echo "🔹 Agent Name: $(hostname)"
echo "🔹 Agent Pool: ${AZP_POOL}"
echo "🔹 Azure DevOps URL: ${AZP_URL}"

# Check if required environment variables are set
if [[ -z "$AZP_URL" || -z "$AZP_TOKEN" || -z "$AZP_POOL" ]]; then
    echo "❌ Missing required environment variables AZP_URL, AZP_TOKEN, or AZP_POOL."
    exit 1
fi

# Check if Docker CLI is working (without daemon)
echo "🔹 Checking Docker CLI version..."
docker --version || { echo "⚠️ Docker CLI is not installed properly!"; exit 1; }

# Check if Kaniko is installed
echo "🔹 Checking Kaniko Executor..."
kaniko --help >/dev/null 2>&1 || { echo "⚠️ Kaniko is not installed properly!"; exit 1; }

# Run Azure DevOps agent configuration
echo "🔹 Configuring the Azure DevOps agent..."
./config.sh --unattended --url "$AZP_URL" --auth pat --token "$AZP_TOKEN" --pool "$AZP_POOL" --agent "$(hostname)" --acceptTeeEula --replace

# Start the agent
echo "🔹 Running the Azure DevOps agent..."
./run.sh
