defmodule PipUpdate do
  import PipValues

  defstruct type: nil, id: nil, contents: nil

  def extract_updates(body) when byte_size(body) > 0 do
    <<
      type_int    :: uint8_value,
      id          :: uint32_value,
      update_blob :: binary
    >> = body

    type = type_int_to_atom(type_int)

    {contents, rest} = extract_update_info(type, update_blob)
    [%PipUpdate{type: type, id: id, contents: contents}] ++ extract_updates(rest)
  end

  def extract_updates(<<>>) do
    []
  end

  def extract_update_info(:bool, bytes) do
    uint8(bit, rest) = bytes
    value = bit == 1
    {value, rest}
  end

  def extract_update_info(:string, bytes) do
    extract_string(bytes)
  end

  def extract_update_info(:list, bytes) do
    extract_list(bytes, &extract_reference/1)
  end

  def extract_update_info(:dict_update, bytes) do
    extract_dictionary_update(bytes)
  end

  def extract_update_info(:sint8, bytes) do
    sint8(value, rest) = bytes
    {value, rest}
  end

  def extract_update_info(:uint8, bytes) do
    uint8(value, rest) = bytes
    {value, rest}
  end

  def extract_update_info(:sint32, bytes) do
    sint32(value, rest) = bytes
    {value, rest}
  end

  def extract_update_info(:uint32, bytes) do
    uint32(value, rest) = bytes
    {value, rest}
  end

  def extract_update_info(:float32, bytes) do
    float32(value, rest) = bytes
    {value, rest}
  end

  #Reads until a 0 is encountered (null terminator)
  defp extract_string(bytes, n \\ 0) do
    case bytes do
      << str::binary-size(n), 0, rest::binary>> ->
        {str, rest}
      _ when byte_size(bytes) > n ->
        extract_string(bytes, n+1)
      _ ->
        :error
    end
  end

  defp extract_dictionary_update(bytes) do
    {inserts, rest} = extract_list(bytes, &extract_dictionary_entry/1)
    {removals, rest} = extract_list(rest, &extract_reference/1)
    {{inserts, removals}, rest}
  end

  defp extract_dictionary_entry(bytes) do
    uint32(reference, rest) = bytes
    {string, rest} = extract_string(rest)
    {{reference, string}, rest}
  end

  defp extract_list(uint16(count, rest), extractor) do
    extract_list(count, rest, extractor)
  end

  defp extract_list(size, bytes, extractor) when size > 0 do
    {item, rest} = extractor.(bytes)
    {list, rest} = extract_list(size-1, rest, extractor)
    {[item] ++ list, rest}
  end

  defp extract_list(0, rest, _) do
    {[], rest}
  end

  defp extract_reference(uint32(reference, rest)) do
    {reference, rest}
  end

  defp type_int_to_atom(type) do
    case type do
      0 -> :bool
      1 -> :sint8
      2 -> :uint8
      3 -> :sint32
      4 -> :uint32
      5 -> :float32
      6 -> :string
      7 -> :list
      8 -> :dict_update
      _ -> :unknown
    end
  end
end
