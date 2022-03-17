defmodule Server.Router do
  use Plug.Router

  plug Plug.Static, from: "priv/static", at: "/static"
  plug(:match)
  plug(:dispatch)

  get "/api" do
    send_resp(conn, 200, "It's supposed to be a Swagger but I don't know how to do it yet")
  end

  get "/api/orders" do
    list = Server.Database.get()
    |> Enum.map(&Tuple.to_list/1)
    |> Poison.Encoder.encode(%{})
    send_resp(conn, 200, list)
  end

  get "/api/orders/:order" do
    case Server.Database.get(conn.path_params["order"]) do
      [{_, value}] -> send_resp(conn, 200, Poison.Encoder.encode(value, %{}))
      :notFound -> send_resp(conn, 404, "Where are you ?")
    end
  end

  get _, do: send_file(conn, 200, "priv/static/index.html")

  post "/api/orders" do
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

  post "/api/orders/search" do
    params = Plug.Conn.fetch_query_params(conn, [])
    list = Enum.reduce(params.params, [], fn value, list -> [value] ++ list end)
    |> Server.Database.search()
    |> Enum.map(&Tuple.to_list/1)
    |> Poison.Encoder.encode(%{})
    send_resp(conn, 200, list)
  end

  delete "/api/orders/:name" do
    Server.Database.delete(conn.path_params["name"])
    send_resp(conn, 200, "deleted")
  end

  patch "/api/orders" do
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
