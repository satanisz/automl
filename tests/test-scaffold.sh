#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
initializer="${root_dir}/docker/scripts/initialize-workspace.sh"
scaffold="${root_dir}/scaffold"
test_root="$(mktemp -d)"
trap 'rm -rf "${test_root}"' EXIT

empty_workspace="${test_root}/empty"
SCAFFOLD_DIR="${scaffold}" "${initializer}" "${empty_workspace}"
test -f "${empty_workspace}/README.md"
test -f "${empty_workspace}/.gitignore"
test -f "${empty_workspace}/.automl-scaffold-version"

printf 'owned by user\n' > "${empty_workspace}/README.md"
SCAFFOLD_DIR="${scaffold}" "${initializer}" "${empty_workspace}"
grep -q 'owned by user' "${empty_workspace}/README.md"

migration_scaffold="${test_root}/migration-scaffold"
cp -a "${scaffold}" "${migration_scaffold}"
printf 'new in version 2\n' > "${migration_scaffold}/new-mvp-file.txt"
SCAFFOLD_DIR="${migration_scaffold}" SCAFFOLD_VERSION=2 "${initializer}" "${empty_workspace}"
grep -q 'owned by user' "${empty_workspace}/README.md"
grep -q 'new in version 2' "${empty_workspace}/new-mvp-file.txt"
grep -q '^2$' "${empty_workspace}/.automl-scaffold-version"

nonempty_workspace="${test_root}/nonempty"
mkdir -p "${nonempty_workspace}"
printf 'keep me\n' > "${nonempty_workspace}/existing.txt"
SCAFFOLD_DIR="${scaffold}" "${initializer}" "${nonempty_workspace}"
test -f "${nonempty_workspace}/existing.txt"
test ! -e "${nonempty_workspace}/README.md"

resumed_workspace="${test_root}/resumed"
mkdir -p "${resumed_workspace}"
touch "${resumed_workspace}/.automl-scaffold-in-progress"
SCAFFOLD_DIR="${scaffold}" "${initializer}" "${resumed_workspace}"
test -f "${resumed_workspace}/README.md"
test ! -e "${resumed_workspace}/.automl-scaffold-in-progress"

echo "Scaffold tests passed."
