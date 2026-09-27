# Goose Supply Buildpack

A Cloud Foundry v2 **supply buildpack** that puts one checksum-verified
[goose](https://github.com/aaif-goose/goose) binary in the droplet and exports
`GOOSE_CLI_PATH`. That is everything it does.

It is for applications built on [Spring AI ACP](https://github.com/cpage-pivotal/acp-spring),
such as `spring-ai-acp-chat`, whose goose runtime adapter launches the binary
named by `GOOSE_CLI_PATH`. Spring AI ACP configures the agent itself: provider
and model (including from a bound Tanzu AI Models service), MCP servers, skills,
builtins, and goose's hardening defaults. This buildpack therefore writes no
goose configuration and reads no service bindings.

It is a cut-down [goose-buildpack](https://github.com/cpage-pivotal/goose-buildpack),
which also configures goose from `.goose-config.yml` and `VCAP_SERVICES` for
applications that drive goose directly.

- Buildpack: **1.0.0**
- Goose: **1.52.0**
- Architectures: Linux amd64 and arm64

## Usage

Name it before the final buildpack. A supply buildpack is never auto-detected.

```yaml
applications:
  - name: spring-ai-acp-chat
    path: target/spring-ai-acp-chat-1.0.0.jar
    buildpacks:
      - https://github.com/cpage-pivotal/goose-supply-buildpack
      - java_buildpack_offline
    env:
      ACP_RUNTIME: goose
```

At startup, `.profile.d/goose-env.sh` sets:

| Variable | Value |
| --- | --- |
| `GOOSE_CLI_PATH` | `$DEPS_DIR/<index>/bin/goose` |
| `PATH` | `$DEPS_DIR/<index>/bin` prepended (goose and jq) |

## What staging does

1. Installs jq, pinned by SHA-256 in `lib/installer.sh`, to read the dependency
   manifest.
2. Installs the goose release for the container's architecture from
   `config/dependencies.json`: HTTPS only, SHA-256 verified, and the archive must
   contain exactly one `goose` and no absolute or `..` paths.
3. Writes the profile script and `<deps>/<index>/config.yml`, then runs
   `goose --version`.

Archives are taken from the buildpack's own `dependencies/` directory (the
cached release), then the staging cache, then downloaded.

### A goose that is not pinned

To stage a goose version the manifest doesn't pin, set all three:

```yaml
env:
  GOOSE_VERSION: 1.51.0
  GOOSE_DOWNLOAD_URL: https://example.com/goose-x86_64-unknown-linux-gnu.tar.bz2
  GOOSE_SHA256: <64 hex characters>
```

## Releases

Pushing a `v*` tag builds an offline (cached) buildpack per architecture with
goose and jq bundled, plus a CycloneDX SBOM and checksums:

```bash
cf create-buildpack goose_supply_buildpack goose_supply_buildpack-cached-v1.0.0-amd64.zip 99
```

## Development

```bash
make test        # bash -n, shellcheck, dependency metadata, tests/*-test.sh
make package     # online zip + validated SBOM in build/
make freshness   # compare pins with the latest upstream releases
```

To bump goose, edit `config/dependencies.json` (version, `sourceCommit`, and both
assets' URL and SHA-256) and the version in this README. To bump jq, change it in
both `config/dependencies.json` and `bootstrap_jq_metadata` in `lib/installer.sh`;
`make dependencies` fails if they differ.
