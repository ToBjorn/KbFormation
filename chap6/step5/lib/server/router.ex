defmodule Server.Router do
  use Plug.Router

  plug Plug.Static, from: "priv/static", at: "/static"
  plug(:match)
  plug(:dispatch)

  get "/api" do
    send_resp(conn, 200, "It's supposed to be a Swagger but I don't know how to do it yet")
  end

  get "/api/orders" do
    conn = fetch_query_params(conn)
    qs = conn.params
    list = Riak.search("tdelapi_orders_index", qs["query"] || "type:nat_order", [page: qs["page"], rows: qs["rows"], sort: qs["sort"]])
    send_resp(conn, 200, Poison.encode!(list))
  end

  get "/api/order/:order" do
    send_resp(conn, 200, Poison.encode!(Riak.get("tdelapi_orders", conn.path_params["order"])))
  end

  get _, do: send_file(conn, 200, "priv/static/index.html")

  delete "/api/order/:name" do
    IO.inspect(Riak.delete("tdelapi_orders", conn.path_params["name"]))
    :timer.sleep(2000)
    send_resp(conn, 200, "")
  end

  match(_, do: send_resp(conn, 404, "Where are you ?"))
end
