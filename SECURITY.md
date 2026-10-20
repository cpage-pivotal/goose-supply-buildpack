# Security policy

## Supported versions

Security fixes go into the latest minor release of this buildpack and the goose
version it pins.

| Component | Supported |
| --- | --- |
| Buildpack 1.0.x | Yes |
| Goose 1.55.x bundled here | Yes |
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

As of 2026-10-20, Goose 1.55.0 is the latest upstream release and still
contains the following RustSec findings:

- `RUSTSEC-2023-0071` affects `rsa` 0.9.10, has no fixed release, and is
  present in the upstream lockfile but not in Goose's all-target workspace
  dependency graph.
- `RUSTSEC-2026-0346`, `RUSTSEC-2026-0347`, `RUSTSEC-2026-0348` and
  `RUSTSEC-2026-0349` affect `rustls` 0.23.45 and are fixed in 0.23.46.
- `RUSTSEC-2026-0367`, `RUSTSEC-2026-0368` and `RUSTSEC-2026-0369` affect
  `zip` 8.6.0 and are fixed in 9.0.0.

The `rustls` and `zip` findings were published while Goose 1.54.0 was pinned,
which carries the same versions; no Goose release fixes them yet.

CI audits the pinned goose source commit with `cargo audit`, ignores only the
reviewed IDs above, and fails on any other advisory. Remove each exception as
soon as a goose release updates the affected dependency. Until then, keep Cloud
Foundry memory limits and restart policies as defense in depth against denial of
service for the `rsa` finding.
