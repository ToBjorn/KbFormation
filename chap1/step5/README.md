# Step 4 - My Key-Value database

## Usage
Bash
```bash
iex -S mix
```

Elixir
```elixir
{:ok, my_account} = AccountServer.start_link(4)
MyGenericServer.cast(my_account, {:credit, 5})
MyGenericServer.cast(my_account, {:credit, 2})
MyGenericServer.cast(my_account, {:debit, 3})
amount = MyGenericServer.call(my_account, :get)
IO.puts "current credit hold is #{amount}"
```

