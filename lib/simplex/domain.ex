defmodule Simplex.Domains do
  alias Simplex.Request
  import SweetXml

  def create(name) do
    params = %{
      "Action" => "CreateDomain",
      "DomainName" => name
    }

    case HTTPoison.get(Request.signed("https://sdb.amazonaws.com", params)) do
      %HTTPoison.Response{status_code: 200, body: body} = response ->
        body = body
               |> xmap(meta: [~x"//ResponseMetadata",
                         request_id: ~x".//RequestId/text()",
                         box_usage: ~x".//BoxUsage/text()"])
        %Simplex.Success{status_code: 200, metadata: body[:meta], full_response: response}
      response ->
        Simplex.error(response)
    end
  end

  def list(params \\ %{}) do
    params = Map.merge(params, %{"Action" => "ListDomains"})

    case HTTPoison.get(Request.signed("https://sdb.amazonaws.com", params)) do
      %HTTPoison.Response{status_code: 200, body: body} = response ->
        body = body
               |> xmap(meta: [~x"//ResponseMetadata",
                         request_id: ~x".//RequestId/text()",
                         box_usage: ~x".//BoxUsage/text()"],
                       result: ~x"//ListDomainsResponse/ListDomainsResult/DomainName/text()"l,
                       next_token: ~x"//ListDomainsResponse/ListDomainsResult/NextToken/text()")
        %Simplex.Success{status_code: 200, result: body[:result], metadata: body[:meta], next_token: body[:next_token], full_response: response}
      response ->
        Simplex.error(response)
    end
  end

end
