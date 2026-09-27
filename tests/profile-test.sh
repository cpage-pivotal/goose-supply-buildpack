#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "${repo_dir}/tests/test-helper.sh"
source "${repo_dir}/lib/installer.sh"
source "${repo_dir}/lib/environment.sh"

build_dir="${TEST_TMP}/app"
deps_root="${TEST_TMP}/deps"
index=3
mkdir -p "${build_dir}" "${deps_root}/${index}"

setup_environment "${deps_root}/${index}" "${build_dir}" "${index}"
create_config_file "${deps_root}/${index}" "${repo_dir}"

profile="${build_dir}/.profile.d/goose-env.sh"
assert_eq 3 "$(grep -c . "${profile}")" "profile should set PATH and GOOSE_CLI_PATH only"

export DEPS_DIR="${deps_root}"
original_path=${PATH}
unset GOOSE_CLI_PATH
# shellcheck source=/dev/null
source "${profile}"

assert_eq "${deps_root}/${index}/bin/goose" "${GOOSE_CLI_PATH}"
case "${PATH}" in
  "${deps_root}/${index}/bin:${original_path}") ;;
  *) fail "generated runtime PATH did not expand DEPS_DIR and PATH" ;;
esac

assert_file_contains "${deps_root}/${index}/config.yml" "name: goose-supply-buildpack"
assert_file_contains "${deps_root}/${index}/config.yml" \
  "version: $(jq -r '.dependencies.goose.version' "${repo_dir}/config/dependencies.json")"

if "${repo_dir}/bin/detect" "${build_dir}"; then
  fail "a supply-only buildpack must not auto-detect"
fi

echo "profile-test: PASS"
