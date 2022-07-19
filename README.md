# Sandbox

## How to run?

### Local
To start your Phoenix server locally:
  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server`
  * Server is running on [`localhost:4000`](http://localhost:4000)

### Tests
To run all `ExUnit` tests:
   * Install dependencies with `mix deps.get`
   * Run `mix test`

### Production
To generate release:
  * Install dependencies with `mix deps.get --only prod`
  * Assemble release with `MIX_ENV=prod mix release`

To start your Phoenix with production setup:
  * `PHX_SERVER=true PHX_HOST=localhost PORT=4000 SECRET_KEY_BASE=secret_key_base _build/prod/rel/sandbox/bin/sandbox start`
  * With default settings, server is running on [`localhost:4000`](http://localhost:4000)

## Authentication
* Use this script to generate encoded token: `elixir scripts/generate_token.exs test_123456`
* Add header to the request: `Authorization: Basic <generated_string>`

### Example request
```shell
curl --request GET \
--url http://localhost:4000/accounts \
--header 'Authorization: Basic dGVzdF8xMjM0NTY6'
```
## Metrics dashboard
You can visit [`/metrics`](http://localhost:4000/metrics) to see LiveView metrics with requests count.
