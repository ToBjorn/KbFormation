defmodule TutoKBRWStack do
  use Application

  def start(_paths, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Server.Router, options: [port: 4001]},
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
