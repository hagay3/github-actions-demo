#!/bin/bash

# Usage: ./deploy.sh
# Requires: VERSION, SSH_PRIVATE_KEY, and SERVER_USER to be set as environment variables

set -e

# Ensure required environment variables are set
if [ -z "$VERSION" ] || [ -z "$SSH_PRIVATE_KEY" ] || [ -z "$SERVER_USER" ]; then
  echo "❌ Error: VERSION, SSH_PRIVATE_KEY, and SERVER_USER environment variables must be set."
  exit 1
fi

echo "📦 Deploying version: $VERSION"

# Setup SSH
mkdir -p ~/.ssh
echo "${SSH_PRIVATE_KEY}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

# SSH into server and run Docker
ssh -o StrictHostKeyChecking=no ${SERVER_USER}@production-github-actions-demo.hagaiacademy.com << EOF
  set +x
  echo "🛑 Stopping running Docker containers..."
  running_containers=\$(sudo docker ps -q)

  if [ -n "\$running_containers" ]; then
    sudo docker stop \$running_containers
  else
    echo "No running containers found."
  fi

  echo "🚀 Starting Docker container in background with version: ${VERSION}"
  nohup sudo docker run -t -p 3000:3000 hagay3/github-actions-demo:${VERSION} > docker.log 2>&1 &
  echo "✅ Container started. Logs: docker.log"
EOF

# Clean up
rm -f ~/.ssh/id_rsa

echo "🎉 Deployment complete for version: $VERSION"
