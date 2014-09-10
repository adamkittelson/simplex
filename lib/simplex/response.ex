defmodule Simplex.Response do
  alias Simplex.Response
  defstruct status_code: nil, raw_body: nil, body: %{}, headers: %{}

  import SweetXml

  def handle("CreateDomain", %HTTPoison.Response{status_code: 200, body: body} = response) do
    body = body
           |> xmap(meta: [~x"//ResponseMetadata",
                     request_id: ~x".//RequestId/text()",
                     box_usage: ~x".//BoxUsage/text()"])

    response = %Response{status_code: 200, raw_body: response.body, body: body, headers: response.headers}
    {:ok, nil, response}
  end

  def handle("ListDomains", %HTTPoison.Response{status_code: 200, body: body} = response) do
    body = body
           |> xmap(meta: [~x"//ResponseMetadata",
                     request_id: ~x".//RequestId/text()",
                     box_usage: ~x".//BoxUsage/text()"],
                   result: ~x"//ListDomainsResponse/ListDomainsResult/DomainName/text()"l,
                   next_token: ~x"//ListDomainsResponse/ListDomainsResult/NextToken/text()")
    response = %Response{status_code: 200, raw_body: response.body, body: body, headers: response.headers}
    result = Enum.map(body[:result], &to_string/1)
    {:ok, result, response}
  end

  def handle("DeleteDomain", %HTTPoison.Response{status_code: 200, body: body} = response) do
      body = body
             |> xmap(meta: [~x"//ResponseMetadata",
                       request_id: ~x".//RequestId/text()",
                       box_usage: ~x".//BoxUsage/text()"])
     response = %Response{status_code: 200, raw_body: response.body, body: body, headers: response.headers}
     {:ok, nil, response}
  end

  def handle("GetAttributes", %HTTPoison.Response{status_code: 200, body: body} = response) do
      body = body
             |> xmap(meta: [~x"//ResponseMetadata",
                       request_id: ~x".//RequestId/text()",
                       box_usage: ~x".//BoxUsage/text()"],
                     attributes: [~x"//GetAttributesResponse/GetAttributesResult/Attribute"le,
                       name: ~x".//Name/text()",
                       value: ~x".//Value/text()"
                       ])

     result = Enum.reduce(body[:attributes], %{}, fn(attribute, map) ->
                name = to_string(attribute[:name])
                value = to_string(attribute[:value])
                case map[name] do
                  nil ->
                    Map.put(map, name, value)
                  old_value when is_binary(old_value) ->
                    Map.put(map, name, [value, old_value])
                  old_value when is_list(old_value) ->
                    Map.put(map, name, [value | old_value])
                end
              end)
     response = %Response{status_code: 200, raw_body: response.body, body: body, headers: response.headers}
     {:ok, result, response}
  end

  def handle("PutAttributes", %HTTPoison.Response{status_code: 200, body: body} = response) do
    body = body
           |> xmap(meta: [~x"//ResponseMetadata",
                     request_id: ~x".//RequestId/text()",
                     box_usage: ~x".//BoxUsage/text()"])

    response = %Response{status_code: 200, raw_body: response.body, body: body, headers: response.headers}
    {:ok, nil, response}
  end

  def handle("DeleteAttributes", %HTTPoison.Response{status_code: 200, body: body} = response) do
    body = body
           |> xmap(meta: [~x"//ResponseMetadata",
                     request_id: ~x".//RequestId/text()",
                     box_usage: ~x".//BoxUsage/text()"])

    response = %Response{status_code: 200, raw_body: response.body, body: body, headers: response.headers}
    {:ok, nil, response}
  end

  def handle("Select", %HTTPoison.Response{status_code: 200, body: body} = response) do
      body = body
             |> xmap(meta: [~x"//ResponseMetadata",
                       request_id: ~x".//RequestId/text()",
                       box_usage: ~x".//BoxUsage/text()"],
                     items: [~x"//SelectResponse/SelectResult/Item"le,
                       name: ~x".//Name/text()",
                       attributes: [~x".//Attribute"l,
                         name: ~x"Name/text()",
                         value: ~x".//Value/text()"
                       ]
                     ])

     result = Enum.reduce(body[:items], [], fn(item, list) ->
                attributes = Enum.reduce(item[:attributes], %{}, fn(attribute, map) ->
                            name = to_string(attribute[:name])
                            value = to_string(attribute[:value])
                            case map[name] do
                              nil ->
                                Map.put(map, name, value)
                              old_value when is_binary(old_value) ->
                                Map.put(map, name, [value, old_value])
                              old_value when is_list(old_value) ->
                                Map.put(map, name, [value | old_value])
                            end
                          end)
                [%{name: to_string(item[:name]), attributes: attributes} | list]
              end)


     response = %Response{status_code: 200, raw_body: response.body, body: body, headers: response.headers}
     {:ok, result, response}
  end

  def handle(_action, response), do: error(response)

  def error(%HTTPoison.Response{status_code: code, body: body} = response) when code >= 400 and code < 500 do
    body = body
           |> xmap(response: [~x"//Response",
                     errors: [~x".//Errors/Error"l,
                        code: ~x".//Code/text()",
                        message: ~x".//Message/text()",
                        box_usage: ~x".//BoxUsage/text()"
                      ],
                     request_id: ~x".//RequestId/text()"])

    response = %Response{status_code: code, raw_body: response.body, body: body[:response], headers: response.headers}
    {:error, format_errors(body[:response][:errors]), response}
  end

  def error(%HTTPoison.Response{status_code: code, body: body} = response) when code >= 500 and code < 600 do
    body = body
           |> xmap(response: [~x"//Response",
                     errors: [~x".//Errors/Error"l,
                        code: ~x".//Code/text()",
                        message: ~x".//Message/text()"
                      ]])

    response = %Response{status_code: code, raw_body: response.body, body: body[:response], headers: response.headers}
    {:error, format_errors(body[:response][:errors]), response}
  end

  defp format_errors(errors) do
    Enum.map(errors, &("#{&1[:code]}: #{&1[:message]}"))
  end

end
