# OpenBB Open Data Platform (ODP) API server as a container.
# Starts `openbb-api` (FastAPI/Uvicorn) on port 6900. The server has no working
# built-in authentication in openbb 5.0.0 (OPENBB_API_AUTH=true crashes at
# start), so put it behind a reverse proxy that does the access control.

FROM python:3.12-slim

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

ARG OPENBB_VERSION=5.0.0

ENV PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1 \
    HOME=/home/app

# The "routers" extra adds the standard routers (economy, equity, etf, ...);
# without it only the providers' own routes exist and apps that reference
# e.g. the economy calendar widget report missing widgets.
RUN uv pip install --system --no-cache "openbb[routers]==${OPENBB_VERSION}" \
 && useradd --uid 1000 --create-home app

USER app
WORKDIR /home/app

# User settings, API keys (user_settings.json) and the generated widgets.json
# live under $HOME; keep them in a volume.
VOLUME ["/home/app"]
EXPOSE 6900

# The first start builds widgets.json and takes about a minute.
HEALTHCHECK --interval=30s --timeout=10s --start-period=240s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:6900/', timeout=8)"

CMD ["openbb-api", "--host", "0.0.0.0", "--port", "6900"]
