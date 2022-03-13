defmodule Server.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "Welcome")
  end

  get "/api" do
    send_resp(conn, 200, "It's supposed to be a Swagger but I don't know how to do it yet")
  end

  get "/api/:name" do
    case Server.Database.get(conn.path_params["name"]) do
      [{_, value}] -> send_resp(conn, 200, value)
      :notFound -> send_resp(conn, 404, "Where are you ?")
    end
  end

  post "/api" do
    {:ok, body, conn} = Plug.Conn.read_body(conn, [])
    x = body
    |> String.split("&")
    |> Enum.map(fn arg -> String.split(arg, "=") end)
    |> Enum.map(fn [key, value] -> {key, value} end)

    case Server.Database.post(x) do
      :created -> send_resp(conn, 200, "Created")
      :conflict -> send_resp(conn, 409, "Conflict")
    end
  end

  post "/api/search" do
    params = Plug.Conn.fetch_query_params(conn, [])
    list = Enum.reduce(params.params, [], fn value, list -> [value] ++ list end)
    |> Server.Database.search()
    |> Enum.map(&Tuple.to_list/1)
    |> Poison.Encoder.encode(%{})
    send_resp(conn, 200, list)
  end

  delete "/api/:name" do
    Server.Database.delete(conn.path_params["name"])
    send_resp(conn, 200, "deleted")
  end

  patch "/api" do
    {:ok, body, conn} = Plug.Conn.read_body(conn, [])
    x = body
    |> String.split("&")
    |> Enum.map(fn arg -> String.split(arg, "=") end)
    |> Enum.map(fn [key, value] -> {key, value} end)

    case Server.Database.update(x) do
      :modified -> send_resp(conn, 200, "modified")
      :notFound -> send_resp(conn, 404, "Not found")
    end
  end

  match(_, do: send_resp(conn, 404, "Where are you ?"))
end
