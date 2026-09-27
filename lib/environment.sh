#!/usr/bin/env bash
# The runtime environment: the goose binary's location, and nothing else.

setup_environment() {
    local deps_dir=$1
    local build_dir=$2
    local index=$3
    local profile_script="${build_dir}/.profile.d/goose-env.sh"

    mkdir -p "${build_dir}/.profile.d"
    {
        printf '%s\n' '# Goose supply buildpack runtime environment'
        # These variables intentionally expand when Cloud Foundry sources the profile.
        # shellcheck disable=SC2016
        printf 'export PATH="$DEPS_DIR/%s/bin:$PATH"\n' "${index}"
        # shellcheck disable=SC2016
        printf 'export GOOSE_CLI_PATH="$DEPS_DIR/%s/bin/goose"\n' "${index}"
    } > "${profile_script}"
    chmod 0644 "${profile_script}"

    export PATH="${deps_dir}/bin:${PATH}"
    export GOOSE_CLI_PATH="${deps_dir}/bin/goose"
}

# The multi-buildpack convention: a supply buildpack describes what it supplied
# in <deps>/<index>/config.yml for the buildpacks that follow it.
create_config_file() {
    local deps_dir=$1
    local bp_dir=$2
    local config_file="${deps_dir}/config.yml"
    local version="${GOOSE_RESOLVED_VERSION:-$(dependency_version "${bp_dir}/config/dependencies.json" goose)}"

    cat > "${config_file}" <<EOF
---
name: goose-supply-buildpack
config:
  version: ${version}
  cli_path: ${deps_dir}/bin/goose
EOF
    chmod 0644 "${config_file}"
}
