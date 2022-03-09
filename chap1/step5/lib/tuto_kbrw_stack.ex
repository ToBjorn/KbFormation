defmodule TutoKBRWStack do
  use Application

  def start(_type, _args) do
    children = [{Server.Database, [name: :database]}]
    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end
