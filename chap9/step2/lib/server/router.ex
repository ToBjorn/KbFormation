defmodule Server.Router do
  require EEx
  use Plug.Router

  plug(Plug.Static, at: "/public", from: :tutokbrwstack)
  plug(:match)
  plug(:dispatch)

  EEx.function_from_file(:defp, :layout, "web/layout.html.eex", [:render])

  get "/api" do
    send_resp(conn, 200, "It's supposed to be a Swagger but I don't know how to do it yet")
  end

  get "/api/orders" do
    conn = fetch_query_params(conn)
    qs = conn.params

    list =
      Riak.search("tdelapi_orders_index", qs["query"] || "type:nat_order",
        page: qs["page"],
        rows: qs["rows"],
        sort: qs["sort"]
      )

    send_resp(conn, 200, Poison.encode!(list))
  end

  post "/api/order/:order/pay" do
    order = Riak.get("tdelapi_orders", conn.path_params["order"])
    Server.DynamicSupervisor.start_child(order["id"])

    case Server.Worker.call(order["id"], order) do
      {:error, order} -> send_resp(conn, 200, Poison.encode!(order))
      {:updated, order} -> Riak.post(order); send_resp(conn, 200, Poison.encode!(order))
    end
  end

  get "/api/order/:order" do
    send_resp(conn, 200, Poison.encode!(Riak.get("tdelapi_orders", conn.path_params["order"])))
  end

  get _ do
    conn = fetch_query_params(conn)
    data = %{path: conn.request_path, cookies: conn.cookies, query: conn.params}
    render = Reaxt.render!(:app, data, 30_000)

    conn
    |> put_resp_header("content-type", "text/html;charset=utf-8")
    |> send_resp(render.param || 200, layout(render))
  end

  delete "/api/order/:name" do
    send_resp(conn, 200, "")
  end

  match(_, do: send_resp(conn, 404, "Where are you ?"))
end
