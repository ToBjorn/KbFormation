defmodule JsonLoader do
#  defp insert_in_db(content, database) when is_tuple(content), do: GenServer.call(database, {:post, content})
#  defp insert_in_db(content, database) when is_map(content), do: Enum.each(content, fn elem -> insert_in_db(elem, database) end)

  def load_to_database(database, json_file) do
    json_file
    |> File.read!()
    |> Poison.decode!()
    |> Enum.each(fn elem -> GenServer.call(database, {:post, {elem["id"], elem}}) end)
  end
end
