Что именно делает этот скрипт (коротко и по факту):
- использует Docker executor
- job-контейнеры получают доступ к Docker daemon VPS
- токен берётся только из env

Финальная «одна команда» для установки (только подставить токен):
```bash
export GITLAB_RUNNER_TOKEN=XXXX && \
curl -fsSL https://raw.githubusercontent.com/nodax-hub/gitlab-runner-setup/main/setup-gitlab-runner.sh | bash
```

Пример быстрого изменения некоторых параметров:
```bash
export GITLAB_RUNNER_TOKEN=XXXX
export RUNNER_TAGS=prod
export RUNNER_NAME=vps-prod-1

curl -fsSL https://raw.githubusercontent.com/<yourname>/gitlab-runner-setup/main/setup-gitlab-runner.sh | bash
```
