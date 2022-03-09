defmodule Server.ServSupervisor do
  use Supervisor

  def start_link(children, opts) do
    {:ok, _} = Supervisor.start_link(__MODULE__, children, [name: __MODULE__ ++ opts ])
  end

  def init(children) do
    Supervisor.init(children, strategy: :one_for_one)
  end
end
