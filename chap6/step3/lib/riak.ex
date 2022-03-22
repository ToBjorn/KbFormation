defmodule Riak do
  def url, do: "https://kbrw-sb-tutoex-riak-gateway.kbrw.fr"

  def auth_header do
    username = "sophomore"
    password = "jlessthan3tutoex"
    auth = :base64.encode_to_string("#{username}:#{password}")
    [{'authorization', 'Basic #{auth}'}]
  end

  def post(obj) do
    case obj do
      {key, _} -> :httpc.request(:post, {'#{Riak.url}/buckets/tdelapi_orders/keys/#{key}', Riak.auth_header(), 'application/json', obj}, [], [])
      obj when is_map(obj) ->  :httpc.request(:post, {'#{Riak.url}/buckets/tdelapi_orders/keys/#{obj["id"]}', Riak.auth_header(), 'application/json', Poison.Encoder.encode(obj, %{})}, [], [])
      _ -> :httpc.request(:post, {'#{Riak.url}/buckets/tdelapi_orders/keys', Riak.auth_header(), 'application/json', obj}, [], [])
    end
  end

  def bucket_list do
    :httpc.request(:get, {'#{Riak.url}/buckets?buckets=true', Riak.auth_header()}, [], [])
  end

  def get(bucket) do
    :httpc.request(:get, {'#{Riak.url}/buckets/#{bucket}/keys?keys=true', Riak.auth_header()}, [], [])
  end

  def get(bucket, key) do
    :httpc.request(:get, {'#{Riak.url}/buckets/#{bucket}/keys/#{key}', Riak.auth_header()}, [], [])
  end

  def delete(bucket, key) do
    :httpc.request(:delete, {'#{Riak.url}/buckets/#{bucket}/keys/#{key}', Riak.auth_header()}, [], [])
  end

  def schema(toPush) do
    case File.read(toPush) do
      {:ok, binary} -> :httpc.request(:put, {'#{Riak.url}/search/schema/tdelapi_orders_schema', Riak.auth_header(), 'application/xml', binary}, [], [])
      {:error, _} -> raise "File doesn't exist"
    end
  end

  def index do
    #Didn't accept params to have a custom index name or schema name cause we're not 'allowed' to anyway.
    :httpc.request(:put, {'#{Riak.url}/search/index/tdelapi_orders_index', Riak.auth_header(), 'application/json', '{"schema": "tdelapi_orders_schema"}'}, [], [])
  end

  def assign(index, bucket) do
    :httpc.request(:put, {'#{Riak.url}/buckets/#{bucket}/props', Riak.auth_header(), 'application/json', '{"props":{"search_index":"#{index}"}}'}, [], [])
  end

  def index_list do
    :httpc.request(:get, {'#{Riak.url}/search/index?index=true', Riak.auth_header()}, [], [])
  end

  def empty(bucket) do
    {_, {_, _, list}} = get(bucket)
    list = Poison.decode!(list)
    Enum.each(list["keys"], fn key -> delete(bucket, key) end)
  end

  def delete(bucket) do
    empty(bucket)
    :httpc.request(:delete, {'#{Riak.url}/buckets/#{bucket}/props', Riak.auth_header()}, [], [])
  end
end

{:ok, {{'HTTP/1.1', 200, 'OK'}, [{'cache-control', 'max-age=0, private, must-revalidate'}, {'date', 'Tue, 22 Mar 2022 09:12:15 GMT'}, {'server', 'Cowboy'}, {'content-length', '70'}, {'strict-transport-security', 'max-age=31536000; includeSubDomains'}], '{"keys":["SLCp8hEy91a2hpN3TBRIhI2Cajh","Fca611iU90rWXsEVyrEEI8GFeW8"]}'}}
