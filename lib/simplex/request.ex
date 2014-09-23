defmodule Simplex.Request do
  alias Simplex.Parameters
  alias Simplex.Response
  use Timex

  def get(params, simplex) do
    response = Simplex.simpledb_url(simplex)
               |> signed(params, Simplex.configuration(simplex))
               |> HTTPoison.get
    Response.handle(params["Action"], response)
  end

  def signed(url, params, config) do
    uri = URI.parse(url)

    query = query_string(params, config)

    request = Enum.join(["GET", uri.host, uri.path || "/", query], "\n")

    signature = :crypto.hmac(:sha256, String.to_char_list(config[:aws_secret_access_key]), String.to_char_list(request))
                |> :base64.encode
                |> URI.encode
                |> String.replace("/", "%2F")
                |> String.replace("+", "%2B")
                |> String.replace("=", "%3D")

    "#{uri.scheme}://#{uri.authority}#{uri.path || "/"}?#{query}&Signature=#{signature}"
  end

  defp auth_params(config) do
    [
      AWSAccessKeyId: config[:aws_access_key],
      SignatureVersion: 2,
      SignatureMethod: "HmacSHA256",
      Timestamp: DateFormat.format!(Date.now, "{ISOz}")
    ] ++ auth_token(config)
  end

  defp auth_token(%{token: token}),  do: [SecurityToken: token]
  defp auth_token(_aws_credentials), do: []

  defp query_string(params, config) do
    Parameters.from_map(params) ++ [{:Version, config[:simpledb_version]}] ++ auth_params(config)
    |> Enum.sort
    |> URI.encode_query
    |> String.replace("+", "%20")
  end

end
