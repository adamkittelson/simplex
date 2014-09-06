defmodule Simplex.Parameters do

  @doc """
  Converts a map into a Keyword list of request parameters.
  List values will be converted duplicate keys with different values.

  ## Examples

      iex> Simplex.Parameters.from_map %{:hello => "there"}
      [hello: "there"]
      iex> Simplex.Parameters.from_map %{"testing" => "success", :wat => ["the deuce", "the heck", "I don't even"]}
      [testing: "success", wat: "I don't even", wat: "the heck", wat: "the deuce"]

  """
  def from_map(%{} = map) do
    Enum.reduce(map, [], fn({key, value}, params) ->
      append_value(params, key, value)
    end)
  end

  defp format_key(key) when is_atom(key),   do: key
  defp format_key(key) when is_binary(key), do: String.to_atom(key)

  defp append_value(list, key, value) when is_binary(value) do
    [{format_key(key), value} | list]
  end

  defp append_value(list, key, values) when is_list(values) do
    Enum.reduce(values, list, fn(value, list) ->
      append_value(list, key, value)
    end)
  end

end
