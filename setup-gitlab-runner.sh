#!/usr/bin/env bash
set -euo pipefail

# ===============================
# REQUIRED ENV
# ===============================
if [ -z "${GITLAB_RUNNER_TOKEN:-}" ]; then
  echo "ERROR: GITLAB_RUNNER_TOKEN is not set"
  echo "Usage:"
  echo "  export GITLAB_RUNNER_TOKEN=XXXX"
  echo "  curl -fsSL <script_url> | bash"
  exit 1
fi

# ===============================
# CONFIG (can be overridden via env)
# ===============================
GITLAB_URL="${GITLAB_URL:-https://gitlab.com/}"
RUNNER_NAME="${RUNNER_NAME:-vps-docker-runner}"
RUNNER_TAGS="${RUNNER_TAGS:-prod}"
RUNNER_IMAGE="${RUNNER_IMAGE:-docker:26}"

BASE_DIR="${BASE_DIR:-/srv/gitlab-runner}"
CONFIG_FILE="$BASE_DIR/config.toml"

# ===============================
# PRECHECKS
# ===============================
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker is not installed"
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "ERROR: docker daemon is not accessible"
  exit 1
fi

# ===============================
# PREPARE DIRECTORIES
# ===============================
mkdir -p "$BASE_DIR"
chmod 700 "$BASE_DIR"

# ===============================
# WRITE CONFIG.TOML
# ===============================
cat > "$CONFIG_FILE" <<EOF
concurrent = 1
check_interval = 0

[[runners]]
  name = "$RUNNER_NAME"
  url = "$GITLAB_URL"
  token = "$GITLAB_RUNNER_TOKEN"
  executor = "docker"
  tags = ["$RUNNER_TAGS"]

  [runners.docker]
    image = "$RUNNER_IMAGE"
    privileged = false
    network_mode = "host"
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock",
      "/cache"
    ]
EOF

chmod 600 "$CONFIG_FILE"

# ===============================
# RUN / RESTART RUNNER
# ===============================
docker rm -f gitlab-runner >/dev/null 2>&1 || true

docker run -d \
  --name gitlab-runner \
  --restart always \
  -v "$CONFIG_FILE:/etc/gitlab-runner/config.toml" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:alpine

# ===============================
# DONE
# ===============================
echo "GitLab Runner successfully started"
echo "Name : $RUNNER_NAME"
echo "Tags : $RUNNER_TAGS"
echo "URL  : $GITLAB_URL"

