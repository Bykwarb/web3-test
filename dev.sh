#!/usr/bin/env bash
set -euo pipefail
 
export MSYS_NO_PATHCONV=1
 
IMAGE="${IMAGE:-test-web3-dev}"
NAME="${NAME:-test-web3}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
 
command -v docker >/dev/null 2>&1 || { echo "docker не найден в PATH" >&2; exit 1; }
 
HOST_UID="$(id -u)"
HOST_GID="$(id -g)"
if [ "$HOST_UID" -eq 0 ]; then HOST_UID=1000; HOST_GID=1000; fi
 
build() {
  docker build "$@" \
    --build-arg "UID=${HOST_UID}" --build-arg "GID=${HOST_GID}" \
    -t "$IMAGE" - < "$SCRIPT_DIR/Dockerfile"
}
 
run_container() {
  if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then build; fi
  docker run --rm -it --init --name "$NAME" \
    -v "$SCRIPT_DIR":/workspace \
    -v test-web3-svm:/home/dev/.svm \
    -v test-web3-pnpm:/home/dev/.local/share/pnpm \
    -p 8545:8545 -p 4337:4337 \
    "$IMAGE" "$@"
}
 
cmd="${1:-run}"
shift || true
 
case "$cmd" in
  build)   build "$@" ;;
  rebuild) build --no-cache "$@" ;;
  run)     run_container "$@" ;;
  exec)    docker exec -it "$NAME" bash ;;
  *)       echo "Использование: $0 [run [cmd...]|build|rebuild|exec]" >&2; exit 1 ;;
esac
 
