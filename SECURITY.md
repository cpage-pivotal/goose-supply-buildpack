# Security policy

## Supported versions

Security fixes go into the latest minor release of this buildpack and the goose
version it pins.

| Component | Supported |
| --- | --- |
| Buildpack 1.0.x | Yes |
| Goose 1.61.x bundled here | Yes |
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

As of 2026-11-25, Goose 1.61.0 is the latest upstream release and still
contains the following RustSec findings:

- `RUSTSEC-2026-0367`, `RUSTSEC-2026-0368`, `RUSTSEC-2026-0369` and
  `RUSTSEC-2026-0429` affect `zip` 8.6.0 and are fixed in 9.0.0. The upstream
  lockfile carries both 8.6.0 and 9.8.1.
- `RUSTSEC-2026-0545` (AES entries returned without checking their
  authentication code when the data ends early or is empty),
  `RUSTSEC-2026-0546` (`ZipArchive::extract` can write outside the
  destination through absolute or chained symlink targets) and
  `RUSTSEC-2026-0547` (legacy Shrink, Reduce and Implode decoders preallocate
  the declared uncompressed size) affect `zip` 8.6.0 and are fixed in 9.0.0.
  `RUSTSEC-2026-0548` (`ZipStreamReader` extracts entries under local-header
  names that can differ from the central directory) affects the same version
  and is fixed in 9.0.5.
- `RUSTSEC-2026-0523` and `RUSTSEC-2026-0524` affect `quinn-proto` 0.11.18
  and are fixed in 0.11.19.
- `RUSTSEC-2026-0538` affects `quinn-udp` 0.5.15 and is fixed in 0.5.16.
- `RUSTSEC-2026-0594` (private cookie nonces can repeat in processes that
  fork) affects `cookie` 0.18.2 and is fixed in 0.18.3.

The first three `zip` findings were published while Goose 1.54.0 was pinned,
which carries the same version. The `quinn` findings were published while
Goose 1.57.0 was pinned, which carries the same versions, so staying on 1.57.0
avoids none of them. `RUSTSEC-2026-0545` to `RUSTSEC-2026-0548` and
`RUSTSEC-2026-0594` were first reported by CI when Goose 1.61.0 was proposed;
Goose 1.59.0 carries the same `zip` and `cookie` versions, so staying on it
avoids none of them either. No Goose release fixes them yet.

Goose 1.61.0 moved `rmcp` to 3.11.0 (`RUSTSEC-2026-0457`, `RUSTSEC-2026-0461`,
`RUSTSEC-2026-0462`) and `libsqlite3-sys` to 0.40.0 (`RUSTSEC-2026-0459`),
Goose 1.59.0 moved `pulldown-cmark` to 0.13.6 (`RUSTSEC-2026-0414`), and Goose
1.57.0 no longer depends on `rsa` (`RUSTSEC-2023-0071`) and moved `rustls` to
0.23.46 (`RUSTSEC-2026-0346` to `RUSTSEC-2026-0349`), so those exceptions are
gone.

CI audits the pinned goose source commit with `cargo audit`, ignores only the
reviewed IDs above, and fails on any other advisory. Remove each exception as
soon as a goose release updates the affected dependency.
