defmodule Riak do
  def url, do: "https://kbrw-sb-tutoex-riak-gateway.kbrw.fr"

  def auth_header do
    username = "sophomore"
    password = "jlessthan3tutoex"
    auth = :base64.encode_to_string("#{username}:#{password}")
    [{'authorization', 'Basic #{auth}'}]
  end

  def initialize_commands(bucket) do
    map = Riak.get(bucket)
    Enum.map(map["keys"], fn key -> Riak.get(bucket, key) end)
    |> Enum.reject(fn key -> key["status"]["state"] == "init" end)
    |> Enum.map(fn key -> put_in(key["status"]["state"], "init") end)
    |> Stream.chunk_every(10)
    |> Enum.each(fn chunk -> Stream.run(Task.async_stream(chunk, fn elem -> Riak.post(elem) end)) end)
  end

  def post(obj) do
    case obj do
      {key, _} ->
        :httpc.request(
          :put,
          {'#{Riak.url()}/buckets/tdelapi_orders/keys/#{key}', Riak.auth_header(),
           'application/json', obj},
          [],
          []
        )
      obj when is_map(obj) ->
        :httpc.request(
          :put,
          {'#{Riak.url()}/buckets/tdelapi_orders/keys/#{obj["id"]}', Riak.auth_header(),
           'application/json', Poison.encode!(obj)},
          [],
          []
        )
      _ ->
        :httpc.request(
          :put,
          {'#{Riak.url()}/buckets/tdelapi_orders/keys', Riak.auth_header(), 'application/json',
           obj},
          [],
          []
        )
    end
  end

  def bucket_list do
    :httpc.request(:get, {'#{Riak.url()}/buckets?buckets=true', Riak.auth_header()}, [], [])
  end

  def get(bucket) do
    {:ok, {{_, _, _message}, _response_headers, body}} = :httpc.request(
      :get,
      {'#{Riak.url()}/buckets/#{bucket}/keys?keys=true', Riak.auth_header()},
      [],
      []
    )
    case body do
      'not found\n' -> []
      _ -> Poison.decode!(body)
    end
  end

  def get(bucket, key) do
    {:ok, {{_, _, _message}, _response_headers, body}} =
      :httpc.request(
        :get,
        {'#{Riak.url()}/buckets/#{bucket}/keys/#{key}', Riak.auth_header()},
        [],
        []
      )

    case body do
      'not found\n' -> []
      _ -> Poison.decode!(body)
    end
  end

  def delete(bucket, key) do
    :httpc.request(
      :delete,
      {'#{Riak.url()}/buckets/#{bucket}/keys/#{key}', Riak.auth_header()},
      [],
      []
    )
  end

  def schema(toPush) do
    case File.read(toPush) do
      {:ok, binary} ->
        :httpc.request(
          :put,
          {'#{Riak.url()}/search/schema/tdelapi_orders_schema', Riak.auth_header(),
           'application/xml', binary},
          [],
          []
        )

      {:error, _} ->
        raise "File doesn't exist"
    end
  end

  def index do
    # Didn't accept params to have a custom index name or schema name cause we're not 'allowed' to anyway.
    :httpc.request(
      :put,
      {'#{Riak.url()}/search/index/tdelapi_orders_index', Riak.auth_header(), 'application/json',
       '{"schema": "tdelapi_orders_schema"}'},
      [],
      []
    )
  end

  def assign(index, bucket) do
    :httpc.request(
      :put,
      {'#{Riak.url()}/buckets/#{bucket}/props', Riak.auth_header(), 'application/json',
       '{"props":{"search_index":"#{index}"}}'},
      [],
      []
    )
  end

  def index_list do
    :httpc.request(:get, {'#{Riak.url()}/search/index?index=true', Riak.auth_header()}, [], [])
  end

  def empty(bucket) do
    {_, {_, _, list}} = get(bucket)
    list = Poison.decode!(list)
    Enum.each(list["keys"], fn key -> delete(bucket, key) end)
  end

  def delete(bucket) do
    empty(bucket)
    :httpc.request(:delete, {'#{Riak.url()}/buckets/#{bucket}/props', Riak.auth_header()}, [], [])
  end

  def escape(query) do
    URI.encode(query)
  end

  def search(index, query, opts \\ []) do
    {page, _} = Integer.parse(opts[:page] || "1")
    {rows, _} = Integer.parse(opts[:rows] || "30")
    page = (page - 1) * rows
    sort = opts[:sort] || "creation_date_index"
    query = escape(query)

    {:ok, {{_, _, _message}, _response_headers, body}} =
      :httpc.request(
        :get,
        {'#{Riak.url()}/search/query/#{index}/?wt=json&q=#{query}&start=#{page}&rows=#{rows}&sort=#{sort}%20asc',
         Riak.auth_header()},
        [],
        []
      )

    body = Poison.decode!(body)
    number = body["response"]["numFound"]

    case body["response"]["docs"] do
      nil ->
        []

      _ ->
        [
          number,
          Enum.map(body["response"]["docs"], fn elem ->
            [hd | _] = elem["id"]
            [hd, get("tdelapi_orders", elem["id"])]
          end)
        ]
    end
  end
end
