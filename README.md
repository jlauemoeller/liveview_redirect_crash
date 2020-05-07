# Redirect
This repo demonstrates a LiveView crash that happens when a Plug redirects during a LiveView requests.

The Repo has three pages;

* Landing
* Protected
* Login

Landing can be accessed by anyone, Protected requires a (simulated login), and Login simulates a log-in.

To try it out

  * Setup the project with `mix setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser. Click on the "Protected" link to attempt to access the protected resource without being logged in, thus triggering the redirect in the plug. Once you do, you will see from the server output that Login LiveView crashes upon redirect.

## Explanation

A plug called `RedirectWeb.RequireUser` looks to see if the current session contains a `current_user_id`. If not, it redirects to Login and passes the requested URL (e.g. `/protected`) as the URL parameter `continue_at`. Login then simulates a login, generates a login token and redirects to `RedirectWeb.SessionController` which validates the token and, if valid, stores a `current_user_id` in the session. It then redirects to the URL in `continue_at` (the bounce off of `SessionController` is necessary, I believe, since the Login LiveView doesn't have access to the current session).

The round trip works, but the Login LiveView crashes when redircted to by the plug, as evidenced in the log shown below.

Notice the error message -- it seems like the streams got crossed somewhere since `Phoenix.LiveView.Channel` attempts to call `handle_params/3` for `RedirectWeb.LoginLive` but at the same time seems to think the current url us `/protected` -- that is the request URL *before* the redirect happened in the plug.

```
** (RuntimeError) cannot invoke handle_params/3 for RedirectWeb.LoginLive because RedirectWeb.LoginLive was not mounted at the router with the live/3 macro under URL "http://localhost:4000/protected"
```

## Details

```
[info] GET /
[debug] Processing with Phoenix.LiveView.Plug.index/2
  Parameters: %{}
  Pipelines: [:browser]
[info] Sent 200 in 6ms
[info] CONNECTED TO Phoenix.LiveView.Socket in 114µs
  Transport: :websocket
  Serializer: Phoenix.Socket.V2.JSONSerializer
  Parameters: %{"_csrf_token" => "SFQSNlBlWjkxAmEMcAALfxwEM15ZbhsL90sUh46InL1_DuSFoo_971UR", "vsn" => "2.0.0"}
[info] GET /protected
[debug] Processing with Phoenix.LiveView.Plug.index/2
  Parameters: %{}
  Pipelines: [:browser, :require_user]
[info] Sent 302 in 229µs
[info] GET /login
[debug] Processing with Phoenix.LiveView.Plug.index/2
  Parameters: %{"continue_at" => "/protected"}
  Pipelines: [:browser]
[info] Sent 200 in 293µs
[error] GenServer #PID<0.498.0> terminating
** (RuntimeError) cannot invoke handle_params/3 for RedirectWeb.LoginLive because RedirectWeb.LoginLive was not mounted at the router with the live/3 macro under URL "http://localhost:4000/protected"
    (phoenix_live_view) lib/phoenix_live_view/channel.ex:207: Phoenix.LiveView.Channel.maybe_call_mount_handle_params/4
    (phoenix_live_view) lib/phoenix_live_view/channel.ex:625: Phoenix.LiveView.Channel.verified_mount/4
    (phoenix_live_view) lib/phoenix_live_view/channel.ex:34: Phoenix.LiveView.Channel.handle_info/2
    (stdlib) gen_server.erl:637: :gen_server.try_dispatch/4
    (stdlib) gen_server.erl:711: :gen_server.handle_msg/6
    (stdlib) proc_lib.erl:249: :proc_lib.init_p_do_apply/3
Last message: {:mount, Phoenix.LiveView.Channel}
State: {%{"joins" => 0, "params" => %{"_csrf_token" => "SFQSNlBlWjkxAmEMcAALfxwEM15ZbhsL90sUh46InL1_DuSFoo_971UR"}, "session" => "SFMyNTY.g2gDaAJhBHQAAAAHZAACaWRtAAAAFHBoeC1GZ3pBeXJNNXViQU50QUhKZAAKcGFyZW50X3BpZGQAA25pbGQACHJvb3RfcGlkZAADbmlsZAAJcm9vdF92aWV3ZAAcRWxpeGlyLlJlZGlyZWN0V2ViLkxvZ2luTGl2ZWQABnJvdXRlcmQAGUVsaXhpci5SZWRpcmVjdFdlYi5Sb3V0ZXJkAAdzZXNzaW9udAAAAABkAAR2aWV3ZAAcRWxpeGlyLlJlZGlyZWN0V2ViLkxvZ2luTGl2ZW4GAKHtPe9xAWIAAVGA.6uE_BxWBRV1C-FrF7lqtulQUoZxaXkJ3ARnlaBJWNhU", "static" => nil, "url" => "http://localhost:4000/protected"}, {#PID<0.485.0>, #Reference<0.2641993731.981729291.38808>}, %Phoenix.Socket{assigns: %{}, channel: Phoenix.LiveView.Channel, channel_pid: nil, endpoint: RedirectWeb.Endpoint, handler: Phoenix.LiveView.Socket, id: nil, join_ref: "8", joined: false, private: %{session: %{"_csrf_token" => "qdac8Qlp_NPS4uX9sklgn_NY"}}, pubsub_server: Redirect.PubSub, ref: nil, serializer: Phoenix.Socket.V2.JSONSerializer, topic: "lv:phx-FgzAyrM5ubANtAHJ", transport: :websocket, transport_pid: #PID<0.485.0>}}
[error] an exception was raised:
    ** (RuntimeError) cannot invoke handle_params/3 for RedirectWeb.LoginLive because RedirectWeb.LoginLive was not mounted at the router with the live/3 macro under URL "http://localhost:4000/protected"
        (phoenix_live_view) lib/phoenix_live_view/channel.ex:207: Phoenix.LiveView.Channel.maybe_call_mount_handle_params/4
        (phoenix_live_view) lib/phoenix_live_view/channel.ex:625: Phoenix.LiveView.Channel.verified_mount/4
        (phoenix_live_view) lib/phoenix_live_view/channel.ex:34: Phoenix.LiveView.Channel.handle_info/2
        (stdlib) gen_server.erl:637: :gen_server.try_dispatch/4
        (stdlib) gen_server.erl:711: :gen_server.handle_msg/6
        (stdlib) proc_lib.erl:249: :proc_lib.init_p_do_apply/3
[error] GenServer #PID<0.499.0> terminating
** (RuntimeError) cannot invoke handle_params/3 for RedirectWeb.LoginLive because RedirectWeb.LoginLive was not mounted at the router with the live/3 macro under URL "http://localhost:4000/protected"
    (phoenix_live_view) lib/phoenix_live_view/channel.ex:207: Phoenix.LiveView.Channel.maybe_call_mount_handle_params/4
    (phoenix_live_view) lib/phoenix_live_view/channel.ex:625: Phoenix.LiveView.Channel.verified_mount/4
    (phoenix_live_view) lib/phoenix_live_view/channel.ex:34: Phoenix.LiveView.Channel.handle_info/2
    (stdlib) gen_server.erl:637: :gen_server.try_dispatch/4
    (stdlib) gen_server.erl:711: :gen_server.handle_msg/6
    (stdlib) proc_lib.erl:249: :proc_lib.init_p_do_apply/3
Last message: {:mount, Phoenix.LiveView.Channel}
State: {%{"joins" => 0, "params" => %{"_csrf_token" => "SFQSNlBlWjkxAmEMcAALfxwEM15ZbhsL90sUh46InL1_DuSFoo_971UR"}, "session" => "SFMyNTY.g2gDaAJhBHQAAAAHZAACaWRtAAAAFHBoeC1GZ3pBeXJNNXViQU50QUhKZAAKcGFyZW50X3BpZGQAA25pbGQACHJvb3RfcGlkZAADbmlsZAAJcm9vdF92aWV3ZAAcRWxpeGlyLlJlZGlyZWN0V2ViLkxvZ2luTGl2ZWQABnJvdXRlcmQAGUVsaXhpci5SZWRpcmVjdFdlYi5Sb3V0ZXJkAAdzZXNzaW9udAAAAABkAAR2aWV3ZAAcRWxpeGlyLlJlZGlyZWN0V2ViLkxvZ2luTGl2ZW4GAKHtPe9xAWIAAVGA.6uE_BxWBRV1C-FrF7lqtulQUoZxaXkJ3ARnlaBJWNhU", "static" => nil, "url" => "http://localhost:4000/protected"}, {#PID<0.485.0>, #Reference<0.2641993731.981729289.40300>}, %Phoenix.Socket{assigns: %{}, channel: Phoenix.LiveView.Channel, channel_pid: nil, endpoint: RedirectWeb.Endpoint, handler: Phoenix.LiveView.Socket, id: nil, join_ref: "9", joined: false, private: %{session: %{"_csrf_token" => "qdac8Qlp_NPS4uX9sklgn_NY"}}, pubsub_server: Redirect.PubSub, ref: nil, serializer: Phoenix.Socket.V2.JSONSerializer, topic: "lv:phx-FgzAyrM5ubANtAHJ", transport: :websocket, transport_pid: #PID<0.485.0>}}
[error] an exception was raised:
    ** (RuntimeError) cannot invoke handle_params/3 for RedirectWeb.LoginLive because RedirectWeb.LoginLive was not mounted at the router with the live/3 macro under URL "http://localhost:4000/protected"
        (phoenix_live_view) lib/phoenix_live_view/channel.ex:207: Phoenix.LiveView.Channel.maybe_call_mount_handle_params/4
        (phoenix_live_view) lib/phoenix_live_view/channel.ex:625: Phoenix.LiveView.Channel.verified_mount/4
        (phoenix_live_view) lib/phoenix_live_view/channel.ex:34: Phoenix.LiveView.Channel.handle_info/2
        (stdlib) gen_server.erl:637: :gen_server.try_dispatch/4
        (stdlib) gen_server.erl:711: :gen_server.handle_msg/6
        (stdlib) proc_lib.erl:249: :proc_lib.init_p_do_apply/3
[info] GET /protected
[debug] Processing with Phoenix.LiveView.Plug.index/2
  Parameters: %{}
  Pipelines: [:browser, :require_user]
[info] Sent 302 in 224µs
[info] GET /login
[debug] Processing with Phoenix.LiveView.Plug.index/2
  Parameters: %{"continue_at" => "/protected"}
  Pipelines: [:browser]
[info] Sent 200 in 433µs
[info] CONNECTED TO Phoenix.LiveView.Socket in 121µs
  Transport: :websocket
  Serializer: Phoenix.Socket.V2.JSONSerializer
  Parameters: %{"_csrf_token" => "ABwrUggSACQ-ETRjWBFtSikyFA5aMgE-qxJ10ClTa_d0ld5sZYxi4mOg", "vsn" => "2.0.0"}
[info] GET /session/SFMyNTY.g2gDYSpuBgAX_z3vcQFiAAFRgA.5jls3uJRo1kJb_NTO3wsPmV_CM4fl-Ud1lJJ9nVQPC0
[debug] Processing with RedirectWeb.SessionController.login/2
  Parameters: %{"continue_at" => "/protected", "token" => "SFMyNTY.g2gDYSpuBgAX_z3vcQFiAAFRgA.5jls3uJRo1kJb_NTO3wsPmV_CM4fl-Ud1lJJ9nVQPC0"}
  Pipelines: [:browser]
[info] Sent 302 in 376µs
[info] GET /protected
[debug] Processing with Phoenix.LiveView.Plug.index/2
  Parameters: %{}
  Pipelines: [:browser, :require_user]
[info] Sent 200 in 446µs
[info] CONNECTED TO Phoenix.LiveView.Socket in 156µs
  Transport: :websocket
  Serializer: Phoenix.Socket.V2.JSONSerializer
  Parameters: %{"_csrf_token" => "OlwANWkCOzwbfTgCTCIAYEobGDgCBQR0K8aVQSWLD3hQxWXY9pt_lZJ-", "vsn" => "2.0.0"}
```

