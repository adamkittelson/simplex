defmodule Simplex.Response do
  alias Simplex.Response
  defstruct status_code: nil, raw_body: nil, body: %{}, headers: %{}

  import SweetXml

  def handle("CreateDomain", %HTTPotion.Response{status_code: 200, body: body} = response) do
    body = body
           |> xmap(request_id: ~x"//ResponseMetadata/RequestId/text()",
                   box_usage: ~x"//ResponseMetadata/BoxUsage/text()")
           |> stringify_values

    response = %Response{status_code: 200, raw_body: response.body, body: body, headers: response.headers}
    {:ok, nil, response}
  end

  def handle("ListDomains", %HTTPotion.Response{status_code: 200, body: body} = response) do
    body = body
           |> xmap(request_id: ~x"//ResponseMetadata/RequestId/text()",
                   box_usage: ~x"//ResponseMetadata/BoxUsage/text()",
                   result: ~x"//ListDomainsResponse/ListDomainsResult/DomainName/text()"l,
                   next_token: ~x"//ListDomainsResponse/ListDomainsResult/NextToken/text()")
           |> stringify_values
    response = %Response{status_code: 200, raw_body: response.body, body: body, headers: response.headers}
    {:ok, body[:result], response}
  end

  def handle("DeleteDomain", %HTTPotion.Response{status_code: 200, body: body} = response) do
      body = body
             |> xmap(request_id: ~x"//ResponseMetadata/RequestId/text()",
                     box_usage: ~x"//ResponseMetadata/BoxUsage/text()")
             |> stringify_values
     response = %Response{status_code: 200, raw_body: response.body, body: body, headers: response.headers}
     {:ok, nil, response}
  end

  def handle("GetAttributes", %HTTPotion.Response{status_code: 200, body: body} = response) do
      body = body
             |> xmap(request_id: ~x"//ResponseMetadata/RequestId/text()",
                     box_usage: ~x"//ResponseMetadata/BoxUsage/text()",
                     attributes: [~x"//GetAttributesResponse/GetAttributesResult/Attribute"le,
                       name: ~x".//Name/text()",
                       value: ~x".//Value/text()"
                     ])
             |> stringify_values

     result = Enum.reduce(body[:attributes], %{}, fn(attribute, map) ->
                case map[attribute[:name]] do
                  nil ->
                    Map.put(map, attribute[:name], attribute[:value])
                  old_value when is_binary(old_value) ->
                    Map.put(map, attribute[:name], [attribute[:value], old_value])
                  old_value when is_list(old_value) ->
                    Map.put(map, attribute[:name], [attribute[:value] | old_value])
                end
              end)
     response = %Response{status_code: 200, raw_body: response.body, body: body, headers: response.headers}
     {:ok, result, response}
  end

  def handle("PutAttributes", %HTTPotion.Response{status_code: 200, body: body} = response) do
    body = body
           |> xmap(request_id: ~x"//ResponseMetadata/RequestId/text()",
                   box_usage: ~x"//ResponseMetadata/BoxUsage/text()")
           |> stringify_values

    response = %Response{status_code: 200, raw_body: response.body, body: body, headers: response.headers}
    {:ok, nil, response}
  end

  def handle("DeleteAttributes", %HTTPotion.Response{status_code: 200, body: body} = response) do
    body = body
           |> xmap(request_id: ~x"//ResponseMetadata/RequestId/text()",
                   box_usage: ~x"//ResponseMetadata/BoxUsage/text()")
           |> stringify_values

    response = %Response{status_code: 200, raw_body: response.body, body: body, headers: response.headers}
    {:ok, nil, response}
  end

  def handle("Select", %HTTPotion.Response{status_code: 200, body: body} = response) do
      body = body
             |> xmap(request_id: ~x"//ResponseMetadata/RequestId/text()",
                     box_usage: ~x"//ResponseMetadata/BoxUsage/text()",
                     items: [~x"//SelectResponse/SelectResult/Item"le,
                       name: ~x".//Name/text()",
                       attributes: [~x".//Attribute"l,
                         name: ~x"Name/text()",
                         value: ~x".//Value/text()"
                       ]
                     ])
             |> stringify_values

     result = Enum.reduce(body[:items], [], fn(item, list) ->
                attributes = Enum.reduce(item[:attributes], %{}, fn(attribute, map) ->
                            case map[attribute[:name]] do
                              nil ->
                                Map.put(map, attribute[:name], attribute[:value])
                              old_value when is_binary(old_value) ->
                                Map.put(map, attribute[:name], [attribute[:value], old_value])
                              old_value when is_list(old_value) ->
                                Map.put(map, attribute[:name], [attribute[:value] | old_value])
                            end
                          end)
                [%{name: item[:name], attributes: attributes} | list]
              end)


     response = %Response{status_code: 200, raw_body: response.body, body: body, headers: response.headers}
     {:ok, result, response}
  end

  def handle(_action, response), do: error(response)

  def error(%HTTPotion.Response{status_code: code, body: body} = response) when code >= 400 and code < 500 do
    body = body
           |> xmap(response: [~x"//Response",
                     errors: [~x".//Errors/Error"l,
                        code: ~x".//Code/text()",
                        message: ~x".//Message/text()",
                        box_usage: ~x".//BoxUsage/text()"
                      ],
                     request_id: ~x".//RequestId/text()"])
           |> stringify_values

    response = %Response{status_code: code, raw_body: response.body, body: body[:response], headers: response.headers}
    {:error, format_errors(body[:response][:errors]), response}
  end

  def error(%HTTPotion.Response{status_code: code, body: body} = response) when code >= 500 and code < 600 do
    body = body
           |> xmap(response: [~x"//Response",
                     errors: [~x".//Errors/Error"l,
                        code: ~x".//Code/text()",
                        message: ~x".//Message/text()"
                      ]])
           |> stringify_values

    response = %Response{status_code: code, raw_body: response.body, body: body[:response], headers: response.headers}
    {:error, format_errors(body[:response][:errors]), response}
  end

  # def error(%HTTPotion.Error{} = http_error) do
  #   {:error, "HTTPotion.HTTPError: #{http_error.message}", %HTTPotion.Response{}}
  # end

  defp format_errors(errors) do
    Enum.map(errors, &("#{&1[:code]}: #{&1[:message]}"))
  end

  defp stringify_values(nil), do: nil
  defp stringify_values(value) when is_atom(value), do: nil
  defp stringify_values(%{} = map) do
    Enum.reduce(map, %{}, fn({key, value}, result) ->
      Map.put(result, key, stringify_values(value))
    end)
  end
  defp stringify_values([]), do: []
  defp stringify_values(value) do
    if Enum.all?(value, &is_integer/1)  do
      to_string(value)
    else
      Enum.map(value, &stringify_values/1)
    end
  end
end
