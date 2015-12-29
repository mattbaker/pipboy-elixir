defmodule PipStream do
  import PipValues

  def from(device) do
    Stream.resource(
      fn -> device end,
      &next/1,
      fn(device) -> device end)
  end

  defp next(device) do
    case IO.binread(device, 4) do
      << size::uint32_value >> -> {[read_message(device, size)], device}
      :eof -> {:halt, device}
      _ -> {:error, device}
    end
  end

  defp read_message(device, size) do
    <<
      type :: uint8_value,
      body :: binary-size(size)-unit(8)
    >> = IO.binread(device, size + 1)

    {type, body}
  end

  def from_stdin do
    :io.setopts(:standard_io, encoding: :latin1)
    PipStream.from(:stdio)
  end
end
