#!/usr/bin/env bash
set -euo pipefail

workspace_dir="${WORKSPACE_DIR:-/workspace}"
ide="${WORKSPACE_IDE:-jupyter}"
auth_mode="${WORKSPACE_AUTH_MODE:-auto}"

initialize-workspace "${workspace_dir}"
cd "${workspace_dir}"

case "${ide}" in
  jupyter)
    jupyter_args=(
      lab
      --ip=0.0.0.0
      "--port=${JUPYTER_PORT:-8888}"
      --no-browser
      "--ServerApp.root_dir=${workspace_dir}"
    )

    case "${auth_mode}" in
      auto)
        ;;
      token)
        : "${JUPYTER_TOKEN:?JUPYTER_TOKEN is required when WORKSPACE_AUTH_MODE=token}"
        jupyter_args+=("--IdentityProvider.token=${JUPYTER_TOKEN}")
        ;;
      external)
        jupyter_args+=(--IdentityProvider.token= --ServerApp.password=)
        echo "WARNING: Jupyter authentication is disabled; use only behind a trusted authenticating proxy." >&2
        ;;
      *)
        echo "Unsupported WORKSPACE_AUTH_MODE for Jupyter: ${auth_mode}" >&2
        exit 64
        ;;
    esac

    exec jupyter "${jupyter_args[@]}" "$@"
    ;;

  code-server)
    code_server_args=(
      --bind-addr "0.0.0.0:${CODE_SERVER_PORT:-8080}"
    )

    case "${auth_mode}" in
      auto)
        if [[ -z "${PASSWORD:-}" ]]; then
          PASSWORD="$(python -c 'import secrets; print(secrets.token_urlsafe(16))')"
          export PASSWORD
          echo "Generated one-time code-server password: ${PASSWORD}"
        fi
        code_server_args+=(--auth password)
        ;;
      password)
        : "${PASSWORD:?PASSWORD is required when WORKSPACE_AUTH_MODE=password}"
        export PASSWORD
        code_server_args+=(--auth password)
        ;;
      external)
        code_server_args+=(--auth none)
        echo "WARNING: code-server authentication is disabled; use only behind a trusted authenticating proxy." >&2
        ;;
      *)
        echo "Unsupported WORKSPACE_AUTH_MODE for code-server: ${auth_mode}" >&2
        exit 64
        ;;
    esac

    exec code-server "${code_server_args[@]}" "${workspace_dir}" "$@"
    ;;

  shell)
    if [[ "$#" -gt 0 ]]; then
      exec "$@"
    fi
    exec "${SHELL:-/bin/bash}"
    ;;

  *)
    echo "Unsupported WORKSPACE_IDE: ${ide}; expected jupyter, code-server, or shell" >&2
    exit 64
    ;;
esac
