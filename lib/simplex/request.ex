defmodule Simplex.Request do
  alias Simplex.Parameters
  alias Simplex.Response
  use Timex

  def get(params, config) do
    response = Simplex.simpledb_url(config)
               |> signed(params, config)
               |> HTTPoison.get
    Response.handle(params["Action"], response)
  end

  def signed(url, params, config) do
    uri = URI.parse(url)

    query = query_string(params, config)

    request = Enum.join(["GET", uri.host, uri.path || "/", query], "\n")

    signature = :crypto.hmac(:sha256, String.to_char_list(Simplex.aws_secret_access_key(config)), String.to_char_list(request))
                |> :base64.encode
                |> URI.encode
                |> String.replace("/", "%2F")
                |> String.replace("+", "%2B")
                |> String.replace("=", "%3D")

    "#{uri.scheme}://#{uri.authority}#{uri.path || "/"}?#{query}&Signature=#{signature}"
  end

  defp auth_params(config) do
    [
      AWSAccessKeyId: Simplex.aws_access_key(config),
      SignatureVersion: 2,
      SignatureMethod: "HmacSHA256",
      Timestamp: DateFormat.format!(Date.now, "{ISOz}")
    ]
  end

  defp query_string(params, config) do
    Parameters.from_map(params) ++ [{:Version, "2009-04-15"}] ++ auth_params(config)
    |> Enum.sort
    |> URI.encode_query
    |> String.replace("+", "%20")
  end

end
