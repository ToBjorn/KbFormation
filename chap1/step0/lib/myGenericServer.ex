defmodule MyGenericServer do
  @moduledoc """
  Documentation for `MyGenericServer`.
  """

  defp loop({callback_module, server_state}) do
    receive do
      {:get, caller} ->
        {amount, _} = apply(callback_module, :handle_call, [:get, server_state])
        send(caller, {:get, amount})
        loop({callback_module, amount})
      {:credit, value} ->
        amount = apply(callback_module, :handle_cast, [{:credit, value}, server_state])
        loop({callback_module, amount})
      {:debit, value} ->
        amount = apply(callback_module, :handle_cast, [{:debit, value}, server_state])
        loop({callback_module, amount})
    end
  end

  def cast(process_pid, request) do
    send(process_pid, request)
    :ok
  end

  def call(process_pid, request) do
    send(process_pid, {request, self()})
    receive do
      {:get, value} ->
        value
    end

  end

  def start_link(callback_module, server_initial_state) do
    pid = spawn_link(fn -> loop({callback_module, server_initial_state}) end)
    {:ok, pid}
  end
end
