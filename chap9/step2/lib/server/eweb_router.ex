defmodule MyJSONApi do
  use Ewebmachine.Builder.Handlers
  plug(:cors)
  plug(:add_handlers, init: %{})

  content_types_provided(do: ["application/json": :to_json])
  defh(to_json, do: Poison.encode!(state[:json_obj]))

  defp cors(conn, _), do: put_resp_header(conn, "Access-Control-Allow-Origin", "*")
end

defmodule ErrorRoutes do
  use Ewebmachine.Builder.Resources
  resources_plugs()

  resource "/error/:status" do
    %{s: elem(Integer.parse(status), 0)}
  after
    content_types_provided(do: ["text/html": :to_html, "application/json": :to_json])

    defh(to_html, do: "<h1> Error ! : '#{Ewebmachine.Core.Utils.http_label(state.s)}'</h1>")

    defh(to_json,
      do: ~s/{"error": #{state.s}, "label": "#{Ewebmachine.Core.Utils.http_label(state.s)}"}/
    )

    finish_request(do: {:halt, state.s})
  end
end

defmodule Server.EwebRouter do
  use Ewebmachine.Builder.Resources
  if Mix.env == :dev, do: plug Ewebmachine.Plug.Debug
  plug(Plug.Static, at: "/public", from: :tutokbrwstack)
  resources_plugs(error_forwarding: "/error/:status", nomatch_404: true)
  plug(ErrorRoutes)

  resource "/api/orders" do %{} after
    allowed_methods do: ["GET"]
    content_types_provided(do: ["application/json": :to_json])
    defh to_json do
      conn = fetch_query_params(conn)
      qs = conn.params

      list =
        Riak.search("tdelapi_orders_index", qs["query"] || "type:nat_order",
        page: qs["page"],
        rows: qs["rows"],
        sort: qs["sort"]
        )

        wrap_response(Poison.encode!(list), conn, state)
      end
  end

  resource "/api/order/:name" do %{name: name} after
    allowed_methods do: ["GET","DELETE"]
    content_types_provided(do: ["application/json": :to_json])
    delete_resource do: Riak.delete("tdelapi_orders", state.name)
    defh to_json do
      wrap_response(Poison.encode!(Riak.get("tdelapi_orders", state.name)), conn, state)
    end
  end

  resource "/api/order/:name/pay" do %{name: name} after
    allowed_methods do: ["POST"]

    process_post do
      order = Riak.get("tdelapi_orders", state.name)
      Server.DynamicSupervisor.start_child(order["id"])
      {:updated, order} = Server.Worker.call(order["id"], order)
      Riak.post(order)
      {true, %{conn | resp_body: Poison.encode!(order)}, state}
    end
  end

  resource "/" do %{} after
    require EEx

    EEx.function_from_file(:defp, :layout, "web/layout.html.eex", [:render])

    content_types_provided do: ['text/html': :to_html]
    allowed_methods do: ["GET"]
    defh to_html do
      conn = fetch_query_params(conn)
      data = %{path: conn.request_path, cookies: conn.cookies, query: conn.params}
      render = Reaxt.render!(:app, data, 30_000)
      conn = put_resp_header(conn, "content-type", "text/html;charset=utf-8")
      wrap_response(layout(render), conn, state)
    end
  end
end
