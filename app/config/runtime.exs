import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere.

# For desktop app, always start the server
config :app, AppWeb.Endpoint, server: true

if config_env() == :prod do
  # For a desktop app, we use a fixed secret key base since it's localhost only
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      "desktop-app-secret-key-base-that-is-at-least-64-bytes-long-for-security"

  config :app, AppWeb.Endpoint,
    url: [host: "localhost", port: 4000, scheme: "http"],
    http: [
      ip: {127, 0, 0, 1},
      port: String.to_integer(System.get_env("PORT") || "4000")
    ],
    secret_key_base: secret_key_base
end
