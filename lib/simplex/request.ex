defmodule Simplex.Request do
  alias Simplex.Parameters
  alias Simplex.Response
  use Timex

  def get(params, simplex) do
    response = Simplex.simpledb_url(simplex)
               |> signed(params, Simplex.aws_credentials(simplex))
               |> HTTPoison.get
    Response.handle(params["Action"], response)
  end

  def signed(url, params, aws_credentials) do
    uri = URI.parse(url)

    query = query_string(params, aws_credentials)

    request = Enum.join(["GET", uri.host, uri.path || "/", query], "\n")

    signature = :crypto.hmac(:sha256, String.to_char_list(aws_credentials[:aws_secret_access_key]), String.to_char_list(request))
                |> :base64.encode
                |> URI.encode
                |> String.replace("/", "%2F")
                |> String.replace("+", "%2B")
                |> String.replace("=", "%3D")

    "#{uri.scheme}://#{uri.authority}#{uri.path || "/"}?#{query}&Signature=#{signature}"
  end

  defp auth_params(aws_credentials) do
    [
      AWSAccessKeyId: aws_credentials[:aws_access_key],
      SignatureVersion: 2,
      SignatureMethod: "HmacSHA256",
      Timestamp: DateFormat.format!(Date.now, "{ISOz}")
    ] ++ auth_token(aws_credentials)
  end

  defp auth_token(%{token: token}),  do: [SecurityToken: token]
  defp auth_token(_aws_credentials), do: []

  defp query_string(params, aws_credentials) do
    Parameters.from_map(params) ++ [{:Version, "2009-04-15"}] ++ auth_params(aws_credentials)
    |> Enum.sort
    |> URI.encode_query
    |> String.replace("+", "%20")
  end

end
