defmodule HelloPort do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, {"node hello.js", 0, cd: "./"}, name: Hello)
  end

  def init({cmd, init, opts}) do
    port = Port.open({:spawn, '#{cmd}'}, [:binary, :exit_status, packet: 4] ++ opts)
    send(port,{self(),{:command,:erlang.term_to_binary(init)}})
    {:ok,port}
  end

  def call(param) do
    GenServer.call(Hello, param)
  end

  def cast(param) do
    GenServer.cast(Hello, param)
  end

  def handle_call(term,_reply_to,port) do
    send(port,{self(),{:command,:erlang.term_to_binary(term)}})
    res = receive do {^port,{:data,b}}->:erlang.binary_to_term(b) end
    {:reply,res,port}
  end

  def handle_cast(term,port) do
    send(port,{self(),{:command,:erlang.term_to_binary(term)}})
    {:noreply,port}
  end
end
