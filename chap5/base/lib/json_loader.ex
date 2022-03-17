defmodule JsonLoader do
  def load_to_database(json_file) do
    json_file
    |> File.read!()
    |> Poison.decode!()
    |> Enum.map(fn elem -> {elem["id"], elem} end)
    |> Server.Database.post()
  end
end
