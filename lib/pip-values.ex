defmodule PipValues do

  defmacro uint8_value do
    quote do: little-size(8)
  end

  defmacro sint8_value do
    quote do: little-signed-size(8)
  end

  defmacro uint16_value do
    quote do: little-size(16)
  end

  defmacro sint32_value do
    quote do: little-signed-size(32)
  end

  defmacro uint32_value do
    quote do: little-size(32)
  end

  defmacro float32_value do
    quote do: little-float-size(32)
  end

  defmacro uint8(value, rest) do
    quote do: << unquote(value)::uint8_value, unquote(rest)::binary>>
  end

  defmacro sint8(value, rest) do
    quote do: << unquote(value)::sint8_value, unquote(rest)::binary>>
  end

  defmacro uint16(value, rest) do
    quote do: << unquote(value)::uint16_value, unquote(rest)::binary>>
  end

  defmacro sint32(value, rest) do
    quote do: << unquote(value)::sint32_value, unquote(rest)::binary>>
  end

  defmacro uint32(value, rest) do
    quote do: << unquote(value)::uint32_value, unquote(rest)::binary>>
  end

  defmacro float32(value, rest) do
    quote do: << unquote(value)::float32_value, unquote(rest)::binary>>
  end
end
