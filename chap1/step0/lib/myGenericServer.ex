defmodule MyGenericServer do
  @moduledoc """
  Documentation for `MyGenericServer`.
  """

  defp loop({callback_module, server_state}) do
    receive do
      {:get, caller} ->
        send(caller, {:get, {callback_module, server_state}})
        loop({callback_module, server_state})
      {:set, state} ->
        loop({callback_module, state})
    end
  end

  defp getState(process_pid) do
    send(process_pid, {:get, self()})
    receive do
      {:get, value} ->
        value
      end
  end

  def cast(process_pid, request) do
    {callback_module, state} = getState(process_pid)
    amount = apply(callback_module, :handle_cast, [request, state])
    send(process_pid, {:set, amount})
    :ok
  end

  def call(process_pid, request) do
    {callback_module, state} = getState(process_pid)
    {amount, _} = apply(callback_module, :handle_call, [request, state])
    amount
  end

  def start_link(callback_module, server_initial_state) do
    pid = spawn_link(fn -> loop({callback_module, server_initial_state}) end)
    {:ok, pid}
  end
end
