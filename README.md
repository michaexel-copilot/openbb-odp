# openbb-odp

[OpenBB Open Data Platform](https://github.com/OpenBB-finance/OpenBB) (`openbb` from PyPI)
as a container: `openbb-api` on port 6900, published as
`ghcr.io/michaexel-copilot/openbb-odp`, deployed behind Traefik on a Hostinger VPS.

- `Dockerfile` installs `openbb==5.0.0` (pin it via the `OPENBB_VERSION` build arg).
- `docker-compose.yml` adds Traefik routing, Let's Encrypt and basic auth.
- The built-in API authentication of openbb 5.0.0 does not start (`OPENBB_API_AUTH=true`
  fails with `duplicate parameter name: '__authenticated_user_settings'`), hence the
  proxy-level protection.
- Provider API keys go into the container environment (`OPENBB_<PROVIDER>_API_KEY`) or
  into `~/.openbb_platform/user_settings.json` inside the volume. Never commit them.
- First start takes about a minute (widgets.json is generated).
