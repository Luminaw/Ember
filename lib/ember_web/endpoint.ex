defmodule EmberWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :ember

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_ember_key",
    signing_salt: "wERWMcUO",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :ember,
    gzip: true,
    only: EmberWeb.static_paths(),
    headers: [
      {"cache-control", "public, max-age=31536000, immutable"},
      {"vary", "Accept-Encoding"},
      {"x-content-type-options", "nosniff"},
      {"x-frame-options", "SAMEORIGIN"},
      {"x-xss-protection", "1; mode=block"},
      {"strict-transport-security", "max-age=31536000; includeSubDomains"},
      {"permissions-policy", "accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=()"},
      {"referrer-policy", "strict-origin-when-cross-origin"}
    ]

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug EmberWeb.Router
end
