defmodule JsonLoader do
  def load_to_database(json_file) do
    json_file
    |> File.read!()
    |> Poison.decode!()
    |> Stream.chunk_every(10)
    |> Enum.to_list()
    |> Enum.each(fn chunk -> Stream.run(Task.async_stream(chunk, fn elem -> Riak.post(elem) end)) end)
  end
end
