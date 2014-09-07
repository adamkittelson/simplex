defmodule Simplex.Domain do
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

end