set -euo pipefail
 
IMAGE="${IMAGE:-pq-agility-dev}"
NAME="${NAME:-pq-agility}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
 
command -v docker >/dev/null 2>&1 || { echo "docker dont found in PATH" >&2; exit 1; }
 
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
    -v "$PWD":/workspace \
    -v pq-agility-svm:/home/dev/.svm \
    -v pq-agility-pnpm:/home/dev/.local/share/pnpm \
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
 
