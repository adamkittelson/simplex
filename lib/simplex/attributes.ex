defmodule Simplex.Attributes do
  alias Simplex.Request

  def get(simplex, domain_name, item_name, params \\ %{}) do
    params
    |> Map.merge(%{"Action"     => "GetAttributes",
                   "DomainName" => domain_name,
                   "ItemName"   => item_name})
    |> Request.get(simplex)
  end

  def put(simplex, domain_name, item_name, attributes, expected \\ %{}) do
    params = expected
             |> format_expected
             |> Map.merge(parse_attributes(attributes))
             |> Map.merge(%{"Action"     => "PutAttributes",
                            "DomainName" => domain_name,
                            "ItemName"   => item_name})
    Request.get(params, simplex)
  end

  def delete(simplex, domain_name, item_name, attributes \\ %{}, expected \\ %{}) do
    params = expected
             |> format_expected
             |> Map.merge(parse_attributes(attributes))
             |> Map.merge(%{"Action"     => "DeleteAttributes",
                            "DomainName" => domain_name,
                            "ItemName"   => item_name})
    Request.get(params, simplex)
  end

  def parse_attributes(attributes) do
    attributes
    |> Enum.reduce([], fn(attribute, list) ->
         append_attribute(attribute, list)
       end)
    |> Enum.with_index
    |> Enum.reduce(%{}, fn({elem, index}, map) ->
         Map.merge(map, index_map_keys(elem, index + 1))
       end)
  end

  def index_map_keys(map, index) do
    Enum.reduce(map, %{}, fn({key, value}, new_map) ->
      Map.put(new_map, String.replace(key, "{index}", to_string(index)), value)
    end)
  end

  def append_attribute(attribute, list) do
    list ++ parse_attribute(attribute)
  end

  def parse_attribute({key, {:replace, value}}) do
    parse_attribute({key, value})
    |> Enum.map(fn(attribute) ->
         Map.put(attribute, "Attribute.{index}.Replace", "true")
       end)
  end

  def parse_attribute({key, values}) when is_list(values) do
    Enum.reduce(values, [], fn(value, list) ->
      list ++ parse_attribute({key, value})
    end)
  end

  def parse_attribute({key, value}) do
    [%{
      "Attribute.{index}.Name" => key,
      "Attribute.{index}.Value" => to_string(value)
     }]
  end

  defp format_expected(expected) do
    expected
    |> Map.take(["Name", "Value", "Exists"])
    |> Enum.reduce(%{}, fn({key, value}, map) ->
         Map.put(map, "Expected.#{key}", value)
       end)
  end

end
