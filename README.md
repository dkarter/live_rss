# LiveRSS

A lightweight, self-hosted RSS Reader.
Runs on a single container and uses SQLite3 as the database.

> THIS IS STILL A WIP!

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

# Running with Docker

First build an image:

```bash
docker build -f Dockerfile . -t live_rss
```

Then create a local database file:

```bash
touch prod.db
```

Map the database to your local file and run migration:

```bash
docker run -it \
  -e DATABASE_PATH=/app/prod.db \
  -e SECRET_KEY_BASE=$(mix phx.gen.secret) \
  -v $(pwd)/prod.db:/app/prod.db \
  live_rss bin/migrate
```

Run the server:

```bash
docker run -it -d \
  -p 4000:4000 \
  -e DATABASE_PATH=/app/prod.db \
  -e SECRET_KEY_BASE=$(mix phx.gen.secret) \
  -v $(pwd)/prod.db:/app/prod.db \
  live_rss
```
