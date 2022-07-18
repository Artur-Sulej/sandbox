import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sandbox, SandboxWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "i0kGy5PF+PvkIeUqoZR+gBmLa8OqGQuCWuPvHr+0F0t5UKuc7NQq75rsxrM+6mo/",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :sandbox, base_url: "https://api.example.com"
