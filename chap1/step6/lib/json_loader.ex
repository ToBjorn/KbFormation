defmodule JsonLoader do
  def load_to_database(database, json_file) do
    json_file
    |> File.read!()
    |> Poison.decode!()
    |> Enum.each(fn elem -> GenServer.call(database, {:post, {elem["id"], elem}}) end)
  end
end
