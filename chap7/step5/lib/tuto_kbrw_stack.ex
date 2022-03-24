defmodule TutoKBRWStack do
  use Application

  def start(_paths, _args) do
    children = [
      {Server.Database, []},
      {Plug.Cowboy, scheme: :http, plug: Server.Router, options: [port: 4001]},
    ]
    _ = IO.puts("Starting server at http://localhost:4001")
    Application.put_env(
      :reaxt,:global_config,
      Map.merge(
        Application.get_env(:reaxt,:global_config), %{localhost: "http://localhost:4001"}
      )
    )
    Reaxt.reload
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
