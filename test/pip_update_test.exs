defmodule PipUpdateTest do
  use ExUnit.Case
  doctest PipUpdate

  test "extract_updates" do
    float32_type = <<5>>
    float_object_id = <<7, 0, 0, 0>>
    float_value = <<0, 0, 0, 64>>

    string_type = <<6>>
    string_object_id = <<8, 0, 0, 0>>
    string_value = <<"F","O","O",0>>

    bytes = float32_type <> float_object_id <> float_value <>
            string_type <> string_object_id <> string_value

    updates = PipUpdate.extract_updates(bytes)

    assert length(updates) == 2

    [float_update, string_update | _] = updates

    assert float_update.type == :float32
    assert float_update.id == 7
    assert float_update.contents == 2.0

    assert string_update.type == :string
    assert string_update.id == 8
    assert string_update.contents == "FOO"
  end

  test "extract_update_info boolean true" do
    {result, _} = PipUpdate.extract_update_info(:bool, <<1>>)
    assert result == true
  end

  test "extract_update_info boolean false" do
    {result, _} = PipUpdate.extract_update_info(:bool, <<0>>)
    assert result == false
  end

  test "extract_update_info sint8" do
    {result, _} = PipUpdate.extract_update_info(:sint8, <<255>>)
    assert result == -1
  end

  test "extract_update_info uint8" do
    {result, _} = PipUpdate.extract_update_info(:uint8, <<255>>)
    assert result == 255
  end

  test "extract_update_info sint32" do
    {result, _} = PipUpdate.extract_update_info(:sint32, <<255, 255, 255, 255>>)
    assert result == -1
  end

  test "extract_update_info uint32" do
    {result, _} = PipUpdate.extract_update_info(:uint32, <<255, 255, 255, 255>>)
    assert result == 4294967295
  end

  test "extract_update_info float32" do
    {result, _} = PipUpdate.extract_update_info(:float32, <<0, 0, 0, 64>>)
    assert result == 2.0
  end

  test "extract_update_info string" do
    str = "HELLO" <> <<0>> <> "WORLD"

    {result, rest} = PipUpdate.extract_update_info(:string, str)

    assert result == "HELLO"
    assert rest == "WORLD"
  end

  test "extract_update_info list" do
    size = <<3, 0>>
    items = <<
      1, 0, 0, 0,
      2, 0, 0, 0,
      3, 0, 0, 0
    >>
    remainder = <<1,1,1,1>>
    payload = size <> items <> remainder
    {result, rest} = PipUpdate.extract_update_info(:list, payload)
    assert result == [1,2,3]
    assert rest == <<1,1,1,1>>
  end

  test "extract_update_info dict_update" do
    insert_count = <<2, 0>>
    inserts = <<
      1, 0, 0, 0, "hello", 0,
      2, 0, 0, 0, "world", 0
    >>
    remove_count = <<3, 0>>
    removals = <<
      3, 0, 0, 0,
      4, 0, 0, 0,
      5, 0, 0, 0
    >>

    payload = insert_count <> inserts <> remove_count <> removals
    {{inserts, removals}, _} = PipUpdate.extract_update_info(:dict_update, payload)
    assert inserts == [{1, "hello"}, {2, "world"}]
    assert removals == [3, 4, 5]
  end
end
