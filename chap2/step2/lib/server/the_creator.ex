defmodule Server.TheCreator do
  import Plug.Conn
  defmacro __using__(_opts) do
    quote do
      import Server.TheCreator

      @routes []
      @before_compile Server.TheCreator
    end
  end

  defmacro my_get(route, do: block) do
    function_name = String.to_atom("my_get " <> route)
    quote do
      # Prepend the newly defined test to the list of tests
      @routes [unquote(function_name) | @routes]
      def unquote(function_name)(), do: unquote(block)
    end
  end

  defmacro my_error(code: code, content: message) do
    function_name = String.to_atom("my_error")
    quote do
      @error {unquote(code), unquote(message)}
      def unquote(function_name)(), do: unquote({code, message})
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def init(opts) do
        opts
      end

      def call(conn, _opts) do
        path = String.to_atom("my_get " <> conn.request_path)
        case Enum.any?(@routes, fn(route) -> path == route end) do
        true ->
          {code, message} = apply(__MODULE__, path, [])
          send_resp(conn, code, message)
        false ->
          {code, message} = apply(__MODULE__, :my_error, [])
          send_resp(conn, code, message)
        end
      end
    end
  end
end
