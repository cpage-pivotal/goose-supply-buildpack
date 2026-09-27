# Security policy

## Supported versions

Security fixes go into the latest minor release of this buildpack and the goose
version it pins.

| Component | Supported |
| --- | --- |
| Buildpack 1.0.x | Yes |
| Goose 1.52.x bundled here | Yes |
| Earlier versions | No |

## Reporting a vulnerability

Don't open a public issue with exploit details, credentials, internal routes or
customer information. Use GitHub's private security-advisory reporting for this
repository. If that isn't enabled, contact the maintainers privately and ask for
a secure channel.

Include the affected version, the impact, a minimal reproduction, and whether the
issue is in this buildpack or in upstream goose.

## Security posture

- Dependencies are fetched over HTTPS only and pinned by SHA-256, both when
  downloaded and when taken from the cache or a cached release.
- `config/dependencies.json` records a security floor for goose and the
  advisories it fixes. `make dependencies` fails if the pinned goose is below
  that floor.
- Goose archives are checked for exactly one `goose` entry and no absolute or
  parent-directory paths before extraction.
- Cached releases are per-architecture and ship with a CycloneDX SBOM.
- The buildpack reads no service bindings and writes no credentials into the
  droplet.

### Known upstream Goose advisories

As of 2026-09-27, Goose 1.52.0 is the latest upstream release and still
contains the following RustSec finding:

- `RUSTSEC-2023-0071` affects `rsa` 0.9.10, has no fixed release, and is
  present in the upstream lockfile but not in Goose's all-target workspace
  dependency graph.

CI audits the pinned goose source commit with `cargo audit`, ignores only the
reviewed ID above, and fails on any other advisory. Remove the exception as soon
as a goose release updates the affected dependency. Until then, keep Cloud
Foundry memory limits and restart policies as defense in depth against denial of
service for the `rsa` finding.
