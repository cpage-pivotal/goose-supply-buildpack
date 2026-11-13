# Security policy

## Supported versions

Security fixes go into the latest minor release of this buildpack and the goose
version it pins.

| Component | Supported |
| --- | --- |
| Buildpack 1.0.x | Yes |
| Goose 1.59.x bundled here | Yes |
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

As of 2026-11-13, Goose 1.59.0 is the latest upstream release and still
contains the following RustSec findings:

- `RUSTSEC-2026-0367`, `RUSTSEC-2026-0368`, `RUSTSEC-2026-0369` and
  `RUSTSEC-2026-0429` affect `zip` 8.6.0 and are fixed in 9.0.0. The upstream
  lockfile carries both 8.6.0 and 9.0.5.
- `RUSTSEC-2026-0457` (OAuth client SSRF filter checks host strings, not
  resolved addresses; fixed in 3.7.0), `RUSTSEC-2026-0461` (unbounded tool
  schema cache in the Streamable HTTP server transport; fixed in 3.6.0) and
  `RUSTSEC-2026-0462` (unbounded response body buffering in Streamable HTTP
  clients; fixed in 3.9.0) affect `rmcp` 3.4.1.
- `RUSTSEC-2026-0459` affects `libsqlite3-sys` 0.37.0 through the bundled C
  SQLite (CVE-2026-119375) and is fixed in 0.39.0.
- `RUSTSEC-2026-0523` and `RUSTSEC-2026-0524` affect `quinn-proto` 0.11.18
  and are fixed in 0.11.19.
- `RUSTSEC-2026-0538` affects `quinn-udp` 0.5.15 and is fixed in 0.5.16.

The first three `zip` findings were published while Goose 1.54.0 was pinned,
which carries the same version. The other findings were published while Goose
1.57.0 was pinned, which carries the same versions of all five crates, so
staying on 1.57.0 avoids none of them. No Goose release fixes them yet.

Goose 1.59.0 moved `pulldown-cmark` to 0.13.6 (`RUSTSEC-2026-0414`), and Goose
1.57.0 no longer depends on `rsa` (`RUSTSEC-2023-0071`) and moved `rustls` to
0.23.46 (`RUSTSEC-2026-0346` to `RUSTSEC-2026-0349`), so those exceptions are
gone.

CI audits the pinned goose source commit with `cargo audit`, ignores only the
reviewed IDs above, and fails on any other advisory. Remove each exception as
soon as a goose release updates the affected dependency.
