defmodule Riak do
  def url, do: "https://kbrw-sb-tutoex-riak-gateway.kbrw.fr"

  def auth_header do
    username = "sophomore"
    password = "jlessthan3tutoex"
    auth = :base64.encode_to_string("#{username}:#{password}")
    [{'authorization', 'Basic #{auth}'}]
  end

  def put(obj) do
    :httpc.request(:post, {'#{Riak.url}/buckets/tdelapi_orders/keys', Riak.auth_header(), 'application/json', obj}, [], [])
  end

  def get do
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
end
