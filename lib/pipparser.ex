defmodule PipParser do
  def run do
    PipStream.from_stdin
      |> Stream.filter(fn({type,_}) -> type == 3 end)
      |> Stream.flat_map(fn({_, body}) -> PipUpdate.extract_updates(body) end)
      |> Stream.each(fn(u) -> IO.inspect u end)
      |> Stream.run
  end
end
